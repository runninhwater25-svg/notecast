import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingService {
  AudioRecorder? _recorder;

  Future<String> start() async {
    final recorder = _recorder ??= AudioRecorder();
    if (!await recorder.hasPermission()) {
      throw StateError('没有麦克风权限。请在系统设置中允许“课程笔记”使用麦克风。');
    }
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'recordings'));
    await directory.create(recursive: true);
    final now = DateTime.now();
    final stamp =
        '${now.year}${_two(now.month)}${_two(now.day)}-'
        '${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';
    final path = p.join(directory.path, 'course-$stamp.wav');
    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: path,
    );
    return path;
  }

  Future<String?> stop() => _recorder?.stop() ?? Future.value();
  Future<void> pause() => _recorder?.pause() ?? Future.value();
  Future<void> resume() => _recorder?.resume() ?? Future.value();
  Future<void> dispose() => _recorder?.dispose() ?? Future.value();

  static String _two(int value) => value.toString().padLeft(2, '0');
}
