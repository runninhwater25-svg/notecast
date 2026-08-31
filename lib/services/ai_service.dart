import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/workflow_models.dart';
import 'settings_service.dart';

abstract interface class TranscriptionProvider {
  Future<TranscriptResult> transcribe(String audioPath);
}

abstract interface class NoteProvider {
  Future<NoteDraft> generate(String transcript);
}

class CompatibleAiProvider implements TranscriptionProvider, NoteProvider {
  CompatibleAiProvider({required this.settings, required this.apiKey, Dio? dio})
    : _dio =
          dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 30)));

  final AppSettings settings;
  final String apiKey;
  final Dio _dio;

  Options get _options => Options(
    headers: apiKey.isEmpty ? null : {'Authorization': 'Bearer $apiKey'},
    receiveTimeout: const Duration(minutes: 15),
    sendTimeout: const Duration(minutes: 15),
  );

  @override
  Future<TranscriptResult> transcribe(String audioPath) async {
    final base = _normalized(settings.transcriptionBaseUrl);
    if (base.isEmpty) throw StateError('请先在设置中填写转写 API 地址。');
    final response = await _dio.post<Map<String, dynamic>>(
      '$base/audio/transcriptions',
      data: FormData.fromMap({
        'model': settings.transcriptionModel,
        'file': await MultipartFile.fromFile(audioPath),
        'response_format': 'json',
      }),
      options: _options,
    );
    final text = response.data?['text']?.toString().trim() ?? '';
    if (text.isEmpty) throw StateError('转写接口没有返回文本。');
    return TranscriptResult(text: text);
  }

  @override
  Future<NoteDraft> generate(String transcript) async {
    final base = _normalized(settings.noteBaseUrl);
    if (base.isEmpty || settings.noteModel.trim().isEmpty) {
      throw StateError('请先在设置中填写笔记 API 地址和模型名称。');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '$base/chat/completions',
      data: {
        'model': settings.noteModel.trim(),
        'temperature': 0.2,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': _systemPrompt(settings.notePrompt)},
          {'role': 'user', 'content': '请只根据以下课程材料生成笔记：\n\n$transcript'},
        ],
      },
      options: _options,
    );
    final content = response.data?['choices']?[0]?['message']?['content']
        ?.toString();
    if (content == null || content.trim().isEmpty) {
      throw StateError('笔记模型没有返回内容。');
    }
    final decoded = jsonDecode(_extractJson(content));
    if (decoded is! Map) throw const FormatException('笔记模型返回的不是 JSON 对象。');
    return NoteDraft.fromJson(Map<String, dynamic>.from(decoded));
  }

  static String _normalized(String value) {
    var result = value.trim();
    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    if (result.endsWith('/v1')) return result;
    return result.isEmpty ? '' : '$result/v1';
  }

  static String _extractJson(String value) {
    final trimmed = value.trim();
    if (!trimmed.startsWith('```')) return trimmed;
    final firstLine = trimmed.indexOf('\n');
    final lastFence = trimmed.lastIndexOf('```');
    return trimmed.substring(firstLine + 1, lastFence).trim();
  }

  static String _systemPrompt(String customPrompt) =>
      '''
${customPrompt.trim()}

返回严格 JSON：
{
  "title": "课程标题",
  "summary": ["概要"],
  "chapters": [{"title":"章节", "timestamp":"", "points":["要点"]}],
  "concepts": ["概念"],
  "examples": ["例子"],
  "review_questions": ["复习题"],
  "uncertain_terms": ["听不清或需核实的术语"]
}
不输出 Markdown，不输出 JSON 以外的解释。无法确认的内容放入 uncertain_terms。
''';
}
