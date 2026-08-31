import 'dart:io';

import 'package:course_notes_flutter/services/input_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('识别 UTF-8 文本输入并移除 BOM', () async {
    final directory = await Directory.systemTemp.createTemp('course-input-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/第一课.txt');
    await file.writeAsString('\ufeff课堂原文');

    final input = await InputService().inspect(file.path);

    expect(input.kind, InputKind.text);
    expect(input.text, '课堂原文');
  });

  test('识别常见音频扩展名', () async {
    final directory = await Directory.systemTemp.createTemp('course-audio-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/lesson.M4A');
    await file.writeAsBytes([0, 1, 2]);

    final input = await InputService().inspect(file.path);

    expect(input.kind, InputKind.audio);
  });

  test('拒绝不支持的文件', () async {
    final directory = await Directory.systemTemp.createTemp('course-bad-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/lesson.pdf');
    await file.writeAsBytes([0]);

    expect(() => InputService().inspect(file.path), throwsA(isA<StateError>()));
  });
}
