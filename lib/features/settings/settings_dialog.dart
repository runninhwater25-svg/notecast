import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/settings_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.settings,
    required this.loadApiKey,
    required this.onSave,
  });

  final AppSettings settings;
  final Future<String> Function() loadApiKey;
  final Future<void> Function(AppSettings settings, String apiKey) onSave;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late final TextEditingController transcriptionBase;
  late final TextEditingController transcriptionModel;
  late final TextEditingController noteBase;
  late final TextEditingController noteModel;
  late final TextEditingController notePrompt;
  final apiKey = TextEditingController();
  bool saving = false;
  bool revealKey = false;
  String? validationError;
  late AiConnectionMode mode;

  @override
  void initState() {
    super.initState();
    mode = widget.settings.connectionMode;
    transcriptionBase = TextEditingController(
      text: widget.settings.transcriptionBaseUrl,
    );
    transcriptionModel = TextEditingController(
      text: widget.settings.transcriptionModel,
    );
    noteBase = TextEditingController(text: widget.settings.noteBaseUrl);
    noteModel = TextEditingController(text: widget.settings.noteModel);
    notePrompt = TextEditingController(text: widget.settings.notePrompt);
    widget.loadApiKey().then((value) {
      if (mounted) apiKey.text = value;
    });
  }

  @override
  void dispose() {
    transcriptionBase.dispose();
    transcriptionModel.dispose();
    noteBase.dispose();
    noteModel.dispose();
    notePrompt.dispose();
    apiKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surfaceRaised,
    title: const Text('AI 接口设置'),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('运行方式', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SegmentedButton<AiConnectionMode>(
              segments: const [
                ButtonSegment(
                  value: AiConnectionMode.local,
                  icon: Icon(Icons.computer_outlined),
                  label: Text('本地服务'),
                ),
                ButtonSegment(
                  value: AiConnectionMode.api,
                  icon: Icon(Icons.cloud_outlined),
                  label: Text('在线 API'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (value) => setState(() => mode = value.first),
            ),
            const SizedBox(height: 10),
            Text(
              mode == AiConnectionMode.local
                  ? '数据发送到你电脑上运行的兼容服务。需要先启动 Ollama 和本地转写服务。'
                  : '数据会发送到你填写的服务商。请确认其隐私政策和费用。',
              style: const TextStyle(color: AppColors.secondary, height: 1.4),
            ),
            if (mode == AiConnectionMode.local) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('套用 Ollama + 本地 Whisper'),
                    onPressed: _applyLocalPreset,
                  ),
                  ActionChip(
                    label: const Text('套用 MLX Whisper'),
                    onPressed: _applyMlxPreset,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            const Text('语音转写', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: transcriptionBase,
              decoration: const InputDecoration(
                labelText: '转写服务地址',
                hintText: '例如 http://127.0.0.1:8000/v1',
                helperText: '应用调用 /audio/transcriptions；导入文本时不会使用此服务。',
              ),
            ),
            if (validationError != null) ...[
              const SizedBox(height: 12),
              Text(
                validationError!,
                style: const TextStyle(color: AppColors.red, height: 1.4),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: transcriptionModel,
              decoration: const InputDecoration(
                labelText: '转写模型',
                hintText: '例如 whisper-1 或 mlx-community/whisper-large-v3-turbo',
              ),
            ),
            const SizedBox(height: 22),
            const Text('笔记服务', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: noteBase,
              decoration: const InputDecoration(
                labelText: '笔记服务地址',
                hintText: '例如 http://127.0.0.1:11434/v1',
                helperText: '必须兼容 OpenAI 的 /chat/completions 接口。',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteModel,
              decoration: const InputDecoration(labelText: '笔记模型，例如 qwen3:14b'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apiKey,
              obscureText: !revealKey,
              decoration: InputDecoration(
                labelText: mode == AiConnectionMode.local
                    ? 'API Key（本地服务通常可留空）'
                    : 'API Key',
                helperText: '仅保存在系统安全存储，不会写入项目或导出的笔记。',
                suffixIcon: IconButton(
                  tooltip: revealKey ? '隐藏密钥' : '显示密钥',
                  onPressed: () => setState(() => revealKey = !revealKey),
                  icon: Icon(
                    revealKey ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              '笔记整理提示语',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notePrompt,
              minLines: 5,
              maxLines: 9,
              decoration: const InputDecoration(
                hintText: '告诉 AI 笔记应该如何组织，以及哪些内容不能猜测。',
                helperText: '应用会自动追加结构化 JSON 输出要求。',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: saving ? null : _save,
        child: Text(saving ? '保存中…' : '保存'),
      ),
    ],
  );

  Future<void> _save() async {
    final noteUri = Uri.tryParse(noteBase.text.trim());
    final transcriptionUri = Uri.tryParse(transcriptionBase.text.trim());
    final validNoteUrl =
        noteUri != null &&
        (noteUri.scheme == 'http' || noteUri.scheme == 'https') &&
        noteUri.host.isNotEmpty;
    final validTranscriptionUrl =
        transcriptionBase.text.trim().isEmpty ||
        (transcriptionUri != null &&
            (transcriptionUri.scheme == 'http' ||
                transcriptionUri.scheme == 'https') &&
            transcriptionUri.host.isNotEmpty);
    if (!validNoteUrl || noteModel.text.trim().isEmpty) {
      setState(() => validationError = '请填写有效的笔记服务地址和模型名称。');
      return;
    }
    if (!validTranscriptionUrl ||
        (transcriptionBase.text.trim().isNotEmpty &&
            transcriptionModel.text.trim().isEmpty)) {
      setState(
        () => validationError = '转写服务地址必须以 http:// 或 https:// 开头，并填写模型名称。',
      );
      return;
    }
    setState(() => saving = true);
    await widget.onSave(
      widget.settings.copyWith(
        transcriptionBaseUrl: transcriptionBase.text.trim(),
        transcriptionModel: transcriptionModel.text.trim(),
        noteBaseUrl: noteBase.text.trim(),
        noteModel: noteModel.text.trim(),
        connectionMode: mode,
        notePrompt: notePrompt.text.trim().isEmpty
            ? AppSettings.defaultNotePrompt
            : notePrompt.text.trim(),
      ),
      apiKey.text,
    );
    if (mounted) Navigator.pop(context);
  }

  void _applyLocalPreset() {
    setState(() {
      transcriptionBase.text = 'http://127.0.0.1:8000/v1';
      transcriptionModel.text = 'whisper-1';
      noteBase.text = 'http://127.0.0.1:11434/v1';
      noteModel.text = 'qwen3:14b';
    });
  }

  void _applyMlxPreset() {
    setState(() {
      transcriptionBase.text = 'http://127.0.0.1:8000/v1';
      transcriptionModel.text = 'mlx-community/whisper-large-v3-turbo';
      noteBase.text = 'http://127.0.0.1:11434/v1';
      noteModel.text = 'qwen3:14b';
    });
  }
}
