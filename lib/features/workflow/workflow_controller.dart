import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../models/workflow_models.dart';
import '../../services/ai_service.dart';
import '../../services/export_service.dart';
import '../../services/input_service.dart';
import '../../services/markdown_service.dart';
import '../../services/recording_service.dart';
import '../../services/settings_service.dart';

final workflowProvider = ChangeNotifierProvider<WorkflowController>((ref) {
  return WorkflowController();
});

class WorkflowController extends ChangeNotifier {
  WorkflowController() {
    unawaited(initialize());
  }

  final _recording = RecordingService();
  final _settingsService = SettingsService();
  final _markdownService = MarkdownService();
  final _exportService = ExportService();
  final _inputService = InputService();

  WorkflowStage stage = WorkflowStage.idle;
  AppSettings settings = const AppSettings();
  String title = '新课程';
  String audioPath = '';
  String transcript = '';
  InputKind inputKind = InputKind.audio;
  String markdown = '';
  String? error;
  String? lastOutputPath;
  bool initialized = false;
  bool paused = false;
  Duration elapsed = Duration.zero;
  Timer? _timer;

  bool get isRecording => stage == WorkflowStage.recording;
  bool get isBusy =>
      stage == WorkflowStage.transcribing || stage == WorkflowStage.generating;
  bool get canProcess => audioPath.isNotEmpty && !isRecording && !isBusy;
  String get sourceLabel =>
      audioPath.isEmpty ? '录音或导入课程文件' : audioPath.split(RegExp(r'[/\\]')).last;
  bool get hasTextInput => inputKind == InputKind.text && transcript.isNotEmpty;
  bool get canExport => markdown.trim().isNotEmpty && !isBusy;

  Future<void> initialize() async {
    settings = await _settingsService.load();
    initialized = true;
    notifyListeners();
  }

  void setTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setMarkdown(String value) {
    markdown = value;
    notifyListeners();
  }

  Future<void> startRecording() async {
    await _guard(() async {
      audioPath = await _recording.start();
      transcript = '';
      inputKind = InputKind.audio;
      markdown = '';
      lastOutputPath = null;
      elapsed = Duration.zero;
      paused = false;
      stage = WorkflowStage.recording;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!paused) {
          elapsed += const Duration(seconds: 1);
          notifyListeners();
        }
      });
    });
  }

  Future<void> pickInput() async {
    await _guard(() async {
      final input = await _inputService.pick();
      if (input != null) await _applyInput(input);
    });
  }

  Future<void> importPath(String path) async {
    await _guard(() async => _applyInput(await _inputService.inspect(path)));
  }

  Future<void> _applyInput(ImportedInput input) async {
    _timer?.cancel();
    audioPath = input.path;
    inputKind = input.kind;
    transcript = input.text ?? '';
    markdown = '';
    lastOutputPath = null;
    stage = WorkflowStage.idle;
    paused = false;
    final stem = input.path.split(RegExp(r'[/\\]')).last.split('.').first;
    if (title == '新课程' || title.trim().isEmpty) title = stem;
  }

  Future<void> stopRecording() async {
    await _guard(() async {
      final result = await _recording.stop();
      _timer?.cancel();
      if (result != null) audioPath = result;
      if (audioPath.isEmpty || !await File(audioPath).exists()) {
        throw StateError('录音没有成功保存，请重新录制。');
      }
      stage = WorkflowStage.idle;
      paused = false;
    });
  }

  Future<void> togglePause() async {
    if (!isRecording) return;
    await _guard(() async {
      if (paused) {
        await _recording.resume();
      } else {
        await _recording.pause();
      }
      paused = !paused;
    });
  }

  Future<void> processAudio() async {
    if (!canProcess) return;
    await _guard(() async {
      final apiKey = await _settingsService.apiKey();
      final provider = CompatibleAiProvider(settings: settings, apiKey: apiKey);
      if (!hasTextInput) {
        stage = WorkflowStage.transcribing;
        notifyListeners();
        final result = await provider.transcribe(audioPath);
        transcript = result.text;
      }
      stage = WorkflowStage.generating;
      notifyListeners();
      final draft = await provider.generate(transcript);
      if (title.trim().isEmpty || title == '新课程') title = draft.title;
      markdown = _markdownService.render(
        draft,
        sourcePath: audioPath,
        sourceKind: inputKind.name,
        transcript: transcript,
      );
      stage = WorkflowStage.ready;
    });
  }

  Future<void> exportMarkdown() async {
    if (!canExport) return;
    await _guard(() async {
      lastOutputPath = await _exportService.exportMarkdown(markdown, title);
    });
  }

  Future<void> chooseVault() async {
    await _guard(() async {
      final path = await _exportService.chooseVault();
      if (path == null) return;
      settings = settings.copyWith(vaultPath: path);
      await _settingsService.save(settings);
    });
  }

  Future<void> saveToVault() async {
    if (!canExport) return;
    if (settings.vaultPath.isEmpty) {
      await chooseVault();
      if (settings.vaultPath.isEmpty) return;
    }
    await _guard(() async {
      lastOutputPath = await _exportService.writeToVault(
        settings.vaultPath,
        markdown,
        title,
      );
    });
  }

  Future<void> saveSettings(AppSettings value, String apiKey) async {
    await _guard(() async {
      settings = value;
      await _settingsService.save(value, apiKey: apiKey);
    });
  }

  Future<String> loadApiKey() => _settingsService.apiKey();

  Future<void> _guard(Future<void> Function() operation) async {
    error = null;
    try {
      await operation();
    } catch (exception) {
      error = _friendly(exception);
      if (!isRecording) stage = WorkflowStage.failed;
    } finally {
      notifyListeners();
    }
  }

  static String _friendly(Object exception) {
    if (exception is DioException) {
      final status = exception.response?.statusCode;
      if (status == 401 || status == 403) return 'API 拒绝访问，请检查 API Key 和服务权限。';
      if (status == 413) return '文件超过服务允许的上传大小，请压缩或切分后重试。';
      if (status == 429) return '请求过于频繁或额度不足，请稍后重试并检查账户额度。';
      if (status != null && status >= 500) return 'AI 服务暂时不可用（$status），请稍后重试。';
      if (exception.type == DioExceptionType.connectionError ||
          exception.type == DioExceptionType.connectionTimeout) {
        return '无法连接 AI 服务，请确认本地服务已启动或检查网络和地址。';
      }
    }
    final raw = exception.toString();
    return raw.replaceFirst(
      RegExp(r'^(StateError|Exception|DioException):\s*'),
      '',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_recording.dispose());
    super.dispose();
  }
}
