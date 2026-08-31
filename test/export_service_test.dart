import 'package:course_notes_flutter/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('导出文件名移除跨平台非法字符', () {
    expect(ExportService.safeName('经济学: 第一课/导论?'), '经济学- 第一课-导论-');
    expect(ExportService.safeName('  '), '未命名课程笔记');
  });
}
