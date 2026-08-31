import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';

import '../../core/app_theme.dart';
import '../../models/workflow_models.dart';
import '../settings/settings_dialog.dart';
import 'workflow_controller.dart';

class WorkflowScreen extends ConsumerStatefulWidget {
  const WorkflowScreen({super.key});

  @override
  ConsumerState<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends ConsumerState<WorkflowScreen> {
  final markdownController = TextEditingController();
  bool showPreview = true;
  String? shownError;
  String lastModelMarkdown = '';
  bool draggingInput = false;

  @override
  void dispose() {
    markdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(workflowProvider);
    if (model.markdown != lastModelMarkdown) {
      markdownController.text = model.markdown;
      lastModelMarkdown = model.markdown;
    }
    if (model.error != null && model.error != shownError) {
      shownError = model.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(model.error!),
            action: SnackBarAction(
              label: '设置',
              onPressed: () => _openSettings(model),
            ),
          ),
        );
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (wide) _DesktopRail(onSettings: () => _openSettings(model)),
                Expanded(
                  child: Column(
                    children: [
                      _Header(
                        model: model,
                        wide: wide,
                        onSettings: () => _openSettings(model),
                      ),
                      _RouteBand(stage: model.stage),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(wide ? 28 : 16),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1320),
                              child: Column(
                                children: [
                                  DropTarget(
                                    onDragEntered: (_) =>
                                        setState(() => draggingInput = true),
                                    onDragExited: (_) =>
                                        setState(() => draggingInput = false),
                                    onDragDone: (details) {
                                      setState(() => draggingInput = false);
                                      if (details.files.isNotEmpty) {
                                        model.importPath(
                                          details.files.first.path,
                                        );
                                      }
                                    },
                                    child: _RecorderPanel(
                                      model: model,
                                      dragging: draggingInput,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _OutputPanel(
                                    model: model,
                                    wide: wide,
                                    controller: markdownController,
                                    showPreview: showPreview,
                                    onPreviewChanged: (value) =>
                                        setState(() => showPreview = value),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSettings(WorkflowController model) => showDialog<void>(
    context: context,
    builder: (_) => SettingsDialog(
      settings: model.settings,
      loadApiKey: model.loadApiKey,
      onSave: model.saveSettings,
    ),
  );
}

class _DesktopRail extends StatelessWidget {
  const _DesktopRail({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Container(
    width: 220,
    decoration: const BoxDecoration(
      color: Color(0xFF0B0D0F),
      border: Border(right: BorderSide(color: AppColors.divider)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 30),
          child: Text(
            '课程笔记',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
        const _RailItem(icon: Icons.route, label: '当前任务', selected: true),
        const Spacer(),
        _RailItem(
          icon: Icons.settings_outlined,
          label: 'AI 设置',
          onTap: onSettings,
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 17, color: AppColors.secondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '录音先保存在本机',
                  style: TextStyle(fontSize: 12, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: selected ? AppColors.surface : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: selected ? AppColors.yellow : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
            color: selected ? AppColors.yellow : AppColors.secondary,
          ),
          const SizedBox(width: 13),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.model,
    required this.wide,
    required this.onSettings,
  });
  final WorkflowController model;
  final bool wide;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 18, wide ? 28 : 8, 16),
    child: Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: model.title,
            onChanged: model.setTitle,
            style: Theme.of(context).textTheme.headlineLarge,
            decoration: const InputDecoration(
              hintText: '课程名称',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.yellow),
              ),
            ),
          ),
        ),
        if (!wide)
          IconButton(
            onPressed: onSettings,
            tooltip: 'AI 设置',
            icon: const Icon(Icons.settings_outlined),
          ),
      ],
    ),
  );
}

class _RouteBand extends StatelessWidget {
  const _RouteBand({required this.stage});
  final WorkflowStage stage;

  static const steps = [
    ('01', '输入'),
    ('02', '转写'),
    ('03', 'AI 整理'),
    ('04', '编辑'),
    ('05', '导出'),
  ];

  int get active => switch (stage) {
    WorkflowStage.recording => 0,
    WorkflowStage.transcribing => 1,
    WorkflowStage.generating => 2,
    WorkflowStage.ready => 3,
    WorkflowStage.failed => 0,
    WorkflowStage.idle => 0,
  };

  @override
  Widget build(BuildContext context) => Container(
    height: 96,
    color: AppColors.yellow,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          Expanded(
            child: Opacity(
              opacity: index <= active ? 1 : 0.52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    steps[index].$1,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    steps[index].$2,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (index < steps.length - 1)
            const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
        ],
      ],
    ),
  );
}

class _RecorderPanel extends StatelessWidget {
  const _RecorderPanel({required this.model, required this.dragging});
  final WorkflowController model;
  final bool dragging;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: dragging ? const Color(0xFF252619) : AppColors.surface,
      border: Border.all(
        color: dragging ? AppColors.yellow : AppColors.divider,
        width: dragging ? 2 : 1,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(14)),
    ),
    padding: const EdgeInsets.all(22),
    child: Wrap(
      runSpacing: 18,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: model.isRecording
                      ? AppColors.red
                      : AppColors.surfaceRaised,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  model.isRecording ? Icons.graphic_eq : Icons.mic_none,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _stageLabel(model),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dragging ? '松开即可导入' : model.sourceLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        if (model.isRecording) ...[
          Text(
            _duration(model.elapsed),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 14),
          OutlinedButton.icon(
            onPressed: model.togglePause,
            icon: Icon(model.paused ? Icons.play_arrow : Icons.pause),
            label: Text(model.paused ? '继续' : '暂停'),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: model.stopRecording,
            icon: const Icon(Icons.stop),
            label: const Text('停止并保存'),
          ),
        ] else ...[
          FilledButton.icon(
            onPressed: model.isBusy ? null : model.startRecording,
            icon: const Icon(Icons.mic),
            label: const Text('开始录音'),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: model.isBusy ? null : model.pickInput,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('选择音频或文本'),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: model.canProcess ? model.processAudio : null,
            icon: model.isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_motion),
            label: Text(
              model.stage == WorkflowStage.transcribing
                  ? '正在转写…'
                  : model.stage == WorkflowStage.generating
                  ? '正在整理…'
                  : model.hasTextInput
                  ? '根据文本生成笔记'
                  : '转写并生成笔记',
            ),
          ),
        ],
      ],
    ),
  );

  static String _duration(Duration duration) =>
      '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  static String _stageLabel(WorkflowController model) => switch (model.stage) {
    WorkflowStage.recording => model.paused ? '录音已暂停' : '正在录音',
    WorkflowStage.transcribing => '正在转写音频',
    WorkflowStage.generating => 'AI 正在整理笔记',
    WorkflowStage.ready => '笔记已经生成',
    WorkflowStage.failed => '上一步没有完成',
    WorkflowStage.idle =>
      model.audioPath.isEmpty
          ? '录音、选择或拖入文件'
          : model.hasTextInput
          ? '文本已导入'
          : '音频已就绪',
  };
}

class _OutputPanel extends StatelessWidget {
  const _OutputPanel({
    required this.model,
    required this.wide,
    required this.controller,
    required this.showPreview,
    required this.onPreviewChanged,
  });

  final WorkflowController model;
  final bool wide;
  final TextEditingController controller;
  final bool showPreview;
  final ValueChanged<bool> onPreviewChanged;

  @override
  Widget build(BuildContext context) {
    final editor = _Editor(model: model, controller: controller);
    final preview = _Preview(markdown: controller.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Markdown 笔记',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            if (!wide)
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('编辑'),
                    icon: Icon(Icons.edit_outlined),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('预览'),
                    icon: Icon(Icons.visibility_outlined),
                  ),
                ],
                selected: {showPreview},
                onSelectionChanged: (value) => onPreviewChanged(value.first),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: wide ? 390 : 430,
          child: wide
              ? Row(
                  children: [
                    Expanded(child: editor),
                    const SizedBox(width: 14),
                    Expanded(child: preview),
                  ],
                )
              : (showPreview ? preview : editor),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.end,
          children: [
            if (!Platform.isAndroid) ...[
              OutlinedButton.icon(
                onPressed: model.chooseVault,
                icon: const Icon(Icons.folder_open),
                label: Text(
                  model.settings.vaultPath.isEmpty ? '选择 Vault' : '更换 Vault',
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: model.canExport ? model.saveToVault : null,
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('写入 Obsidian'),
              ),
            ],
            FilledButton.icon(
              onPressed: model.canExport ? model.exportMarkdown : null,
              icon: const Icon(Icons.download),
              label: const Text('导出 .md'),
            ),
          ],
        ),
        if (model.lastOutputPath != null) ...[
          const SizedBox(height: 12),
          Text(
            '已保存：${model.lastOutputPath}',
            textAlign: TextAlign.end,
            style: const TextStyle(color: AppColors.green),
          ),
        ],
      ],
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.model, required this.controller});
  final WorkflowController model;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: model.setMarkdown,
    maxLines: null,
    expands: true,
    textAlignVertical: TextAlignVertical.top,
    keyboardType: TextInputType.multiline,
    style: const TextStyle(fontFamily: 'monospace', height: 1.5, fontSize: 14),
    decoration: const InputDecoration(
      hintText: '生成后的 Markdown 会显示在这里，也可以直接编辑。',
      contentPadding: EdgeInsets.all(18),
    ),
  );
}

class _Preview extends StatelessWidget {
  const _Preview({required this.markdown});
  final String markdown;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border.fromBorderSide(BorderSide(color: AppColors.divider)),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    child: markdown.trim().isEmpty
        ? const Center(
            child: Text(
              '完成转写后，在这里预览 Obsidian 笔记。',
              style: TextStyle(color: AppColors.secondary),
            ),
          )
        : Markdown(
            data: markdown,
            selectable: true,
            padding: const EdgeInsets.all(20),
          ),
  );
}
