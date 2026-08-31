import 'package:course_notes_flutter/models/workflow_models.dart';
import 'package:course_notes_flutter/services/markdown_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('结构化笔记稳定渲染为 Obsidian Markdown', () {
    const draft = NoteDraft(
      title: '机会成本',
      summary: ['机会成本是放弃选项中的最高价值。'],
      chapters: [
        {
          'title': '定义',
          'timestamp': '00:01:20',
          'points': ['比较被放弃的可选方案'],
        },
      ],
      concepts: ['机会成本'],
      examples: [],
      reviewQuestions: ['机会成本如何定义？'],
      uncertainTerms: [],
    );

    final markdown = MarkdownService().render(
      draft,
      sourcePath: '/audio/course.wav',
      transcript: '课堂完整转写',
    );

    expect(markdown, contains('# 机会成本'));
    expect(markdown, contains('### [00:01:20] 定义'));
    expect(markdown, contains('## 完整转写'));
    expect(markdown, contains('课堂完整转写'));
  });
}
