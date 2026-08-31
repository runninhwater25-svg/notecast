import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

enum InputKind { audio, text }

class ImportedInput {
  const ImportedInput({required this.path, required this.kind, this.text});

  final String path;
  final InputKind kind;
  final String? text;
}

class InputService {
  static const audioExtensions = {
    'wav',
    'mp3',
    'm4a',
    'aac',
    'flac',
    'ogg',
    'opus',
    'webm',
    'mp4',
  };
  static const textExtensions = {'txt', 'md', 'markdown'};
  static const supportedExtensions = {...audioExtensions, ...textExtensions};
  static const maxTextBytes = 10 * 1024 * 1024;

  Future<ImportedInput?> pick() async {
    final result = await FilePicker.pickFile(
      dialogTitle: '选择课程音频或文本',
      type: FileType.custom,
      allowedExtensions: supportedExtensions.toList(),
    );
    final path = result?.path;
    return path == null ? null : inspect(path);
  }

  Future<ImportedInput> inspect(String path) async {
    final file = File(path);
    if (!await file.exists()) throw StateError('找不到所选文件，请重新选择。');
    final extension = p.extension(path).replaceFirst('.', '').toLowerCase();
    if (!supportedExtensions.contains(extension)) {
      throw StateError('不支持 .$extension 文件。请选择常见音频、TXT 或 Markdown 文件。');
    }
    if (textExtensions.contains(extension)) {
      final length = await file.length();
      if (length > maxTextBytes) throw StateError('文本文件超过 10 MB，请拆分后再导入。');
      final bytes = await file.readAsBytes();
      String text;
      try {
        text = utf8.decode(bytes).replaceFirst('\ufeff', '').trim();
      } on FormatException {
        throw StateError('文本不是 UTF-8 编码，请转换为 UTF-8 后重试。');
      }
      if (text.isEmpty) throw StateError('文本文件没有可用于生成笔记的内容。');
      return ImportedInput(path: path, kind: InputKind.text, text: text);
    }
    return ImportedInput(path: path, kind: InputKind.audio);
  }
}
