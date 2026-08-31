import 'dart:io';

import 'package:course_notes_flutter/core/app_theme.dart';
import 'package:course_notes_flutter/features/workflow/workflow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('desktop visual baseline', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final bytes = File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf')
        .readAsBytesSync();
    final loader = FontLoader('GoldenCJK')
      ..addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
    await loader.load();
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final baseTheme = buildTheme();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: baseTheme.copyWith(
            textTheme: baseTheme.textTheme.apply(fontFamily: 'GoldenCJK'),
            primaryTextTheme: baseTheme.primaryTextTheme.apply(
              fontFamily: 'GoldenCJK',
            ),
          ),
          home: const WorkflowScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(WorkflowScreen),
      matchesGoldenFile('goldens/desktop.png'),
    );
  });

  testWidgets('android phone visual baseline', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final bytes = File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf')
        .readAsBytesSync();
    final loader = FontLoader('GoldenCJKMobile')
      ..addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
    await loader.load();
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final baseTheme = buildTheme();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: baseTheme.copyWith(
            textTheme: baseTheme.textTheme.apply(fontFamily: 'GoldenCJKMobile'),
            primaryTextTheme: baseTheme.primaryTextTheme.apply(
              fontFamily: 'GoldenCJKMobile',
            ),
          ),
          home: const WorkflowScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(WorkflowScreen),
      matchesGoldenFile('goldens/android-phone.png'),
    );
  });
}
