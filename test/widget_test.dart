import 'package:course_notes_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('主界面提供完整 MVP 入口', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: CourseNotesApp()));
    await tester.pumpAndSettle();

    expect(find.text('开始录音'), findsOneWidget);
    expect(find.text('选择音频或文本'), findsOneWidget);
    expect(find.text('转写并生成笔记'), findsOneWidget);
    expect(find.text('导出 .md'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsWidgets);
  });
}
