import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class ExportService {
  Future<String?> exportMarkdown(String markdown, String title) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: '导出 Obsidian Markdown 笔记',
      fileName: '${safeName(title)}.md',
      bytes: utf8.encode(markdown),
      mimeType: 'text/markdown',
    );
    if (uri == null) return null;
    return uri.scheme == 'file' ? uri.toFilePath() : uri.toString();
  }

  Future<String?> chooseVault() =>
      FilePicker.getDirectoryPath(dialogTitle: '选择 Obsidian Vault');

  Future<String> writeToVault(
    String vaultPath,
    String markdown,
    String title,
  ) async {
    final directory = Directory(p.join(vaultPath, '01-课程笔记'));
    await directory.create(recursive: true);
    var output = File(p.join(directory.path, '${safeName(title)}.md'));
    if (await output.exists()) {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      output = File(p.join(directory.path, '${safeName(title)}-$stamp.md'));
    }
    await output.writeAsString(markdown, flush: true);
    return output.path;
  }

  static String safeName(String input) {
    final clean = input.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '-');
    return clean.isEmpty ? '未命名课程笔记' : clean;
  }
}
