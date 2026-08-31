import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AiConnectionMode { local, api }

class AppSettings {
  const AppSettings({
    this.transcriptionBaseUrl = '',
    this.transcriptionModel = 'whisper-1',
    this.noteBaseUrl = '',
    this.noteModel = '',
    this.connectionMode = AiConnectionMode.local,
    this.notePrompt = defaultNotePrompt,
    this.vaultPath = '',
  });

  final String transcriptionBaseUrl;
  final String transcriptionModel;
  final String noteBaseUrl;
  final String noteModel;
  final AiConnectionMode connectionMode;
  final String notePrompt;
  final String vaultPath;

  AppSettings copyWith({
    String? transcriptionBaseUrl,
    String? transcriptionModel,
    String? noteBaseUrl,
    String? noteModel,
    AiConnectionMode? connectionMode,
    String? notePrompt,
    String? vaultPath,
  }) => AppSettings(
    transcriptionBaseUrl: transcriptionBaseUrl ?? this.transcriptionBaseUrl,
    transcriptionModel: transcriptionModel ?? this.transcriptionModel,
    noteBaseUrl: noteBaseUrl ?? this.noteBaseUrl,
    noteModel: noteModel ?? this.noteModel,
    connectionMode: connectionMode ?? this.connectionMode,
    notePrompt: notePrompt ?? this.notePrompt,
    vaultPath: vaultPath ?? this.vaultPath,
  );

  static const defaultNotePrompt = '''
你是严谨的中文课堂笔记整理器。只使用输入材料中的事实，不得补充或猜测。
提取课程概要、章节、核心概念、课堂例子、复习题和待核实术语。
章节应按内容结构划分；音频转写中有时间信息时保留时间戳。
''';
}

class SettingsService {
  static const _secure = FlutterSecureStorage();

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      transcriptionBaseUrl: prefs.getString('transcriptionBaseUrl') ?? '',
      transcriptionModel: prefs.getString('transcriptionModel') ?? 'whisper-1',
      noteBaseUrl: prefs.getString('noteBaseUrl') ?? '',
      noteModel: prefs.getString('noteModel') ?? '',
      connectionMode: AiConnectionMode.values.firstWhere(
        (mode) => mode.name == prefs.getString('connectionMode'),
        orElse: () => AiConnectionMode.local,
      ),
      notePrompt:
          prefs.getString('notePrompt') ?? AppSettings.defaultNotePrompt,
      vaultPath: prefs.getString('vaultPath') ?? '',
    );
  }

  Future<void> save(AppSettings settings, {String? apiKey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'transcriptionBaseUrl',
      settings.transcriptionBaseUrl,
    );
    await prefs.setString('transcriptionModel', settings.transcriptionModel);
    await prefs.setString('noteBaseUrl', settings.noteBaseUrl);
    await prefs.setString('noteModel', settings.noteModel);
    await prefs.setString('connectionMode', settings.connectionMode.name);
    await prefs.setString('notePrompt', settings.notePrompt);
    await prefs.setString('vaultPath', settings.vaultPath);
    if (apiKey != null) {
      await _secure.write(key: 'aiApiKey', value: apiKey.trim());
    }
  }

  Future<String> apiKey() async => await _secure.read(key: 'aiApiKey') ?? '';
}
