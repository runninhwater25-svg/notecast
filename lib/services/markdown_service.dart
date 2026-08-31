import '../models/workflow_models.dart';

class MarkdownService {
  String render(
    NoteDraft draft, {
    required String sourcePath,
    String sourceKind = 'audio',
    required String transcript,
  }) {
    final created = DateTime.now().toIso8601String();
    final buffer = StringBuffer()
      ..writeln('---')
      ..writeln('title: "${_yaml(draft.title)}"')
      ..writeln('created: "$created"')
      ..writeln('source_type: "$sourceKind"')
      ..writeln('source_file: "${_yaml(sourcePath)}"')
      ..writeln('tags:')
      ..writeln('  - 课程笔记')
      ..writeln('---\n')
      ..writeln('# ${draft.title}\n');
    _list(buffer, '课程概览', draft.summary);
    buffer.writeln('## 章节笔记\n');
    if (draft.chapters.isEmpty) {
      buffer.writeln('- 本次转写未识别出明确章节。\n');
    } else {
      for (final chapter in draft.chapters) {
        final title = chapter['title']?.toString() ?? '未命名章节';
        final timestamp = chapter['timestamp']?.toString() ?? '';
        buffer.writeln('### ${timestamp.isEmpty ? '' : '[$timestamp] '}$title');
        final points = (chapter['points'] as List? ?? const []).map(
          (e) => e.toString(),
        );
        for (final point in points) {
          buffer.writeln('- $point');
        }
        buffer.writeln();
      }
    }
    _list(buffer, '核心概念', draft.concepts);
    _list(buffer, '课堂例子', draft.examples);
    _numbered(buffer, '复习题', draft.reviewQuestions);
    _list(buffer, '待核实内容', draft.uncertainTerms);
    buffer
      ..writeln('## 完整转写\n')
      ..writeln(transcript.trim())
      ..writeln();
    return buffer.toString();
  }

  static void _list(StringBuffer buffer, String title, List<String> values) {
    buffer.writeln('## $title\n');
    if (values.isEmpty) {
      buffer.writeln('- 课程未提供相关内容。');
    }
    for (final value in values) {
      buffer.writeln('- $value');
    }
    buffer.writeln();
  }

  static void _numbered(
    StringBuffer buffer,
    String title,
    List<String> values,
  ) {
    buffer.writeln('## $title\n');
    if (values.isEmpty) buffer.writeln('1. 本节课的核心内容是什么？');
    for (var index = 0; index < values.length; index++) {
      buffer.writeln('${index + 1}. ${values[index]}');
    }
    buffer.writeln();
  }

  static String _yaml(String value) => value.replaceAll('"', '\\"');
}
