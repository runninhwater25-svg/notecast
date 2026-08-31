import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'features/workflow/workflow_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CourseNotesApp()));
}

class CourseNotesApp extends StatelessWidget {
  const CourseNotesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '课程笔记',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    darkTheme: buildTheme(),
    themeMode: ThemeMode.dark,
    home: const WorkflowScreen(),
  );
}
