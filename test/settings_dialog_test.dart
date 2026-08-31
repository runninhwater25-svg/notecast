import 'package:course_notes_flutter/features/settings/settings_dialog.dart';
import 'package:course_notes_flutter/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AI 设置解释本地与在线模式并提供提示语', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsDialog(
            settings: const AppSettings(),
            loadApiKey: () async => '',
            onSave: (_, _) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地服务'), findsOneWidget);
    expect(find.text('在线 API'), findsOneWidget);
    expect(find.text('套用 Ollama + 本地 Whisper'), findsOneWidget);
    expect(find.text('笔记整理提示语'), findsOneWidget);
    expect(find.textContaining('OpenAI'), findsOneWidget);
  });
}
