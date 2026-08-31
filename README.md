# Notecast

跨平台课程笔记工具：录音或导入音频/文本 → 语音转写（文本会跳过）→ AI 结构化整理 → Markdown 编辑/预览 → Obsidian Vault 或 `.md` 导出。

## 下载安装

前往 [GitHub Releases](https://github.com/runninhwater25-svg/notecast/releases)：

- macOS：下载 `Notecast-macOS.zip`，解压后得到 `Notecast.app`；也可下载 DMG。
- Windows：下载 `Notecast-Windows-Setup.exe`，运行安装程序。

当前 macOS 构建使用临时签名，未经过 Apple 公证。首次打开可能需要右键 App 选择“打开”。要消除该提示，需要 Apple Developer ID 证书和公证流程。

## 输入能力

- App 内直接录音，音频先保存到本机。
- 点击选择或在 macOS/Windows 桌面端拖入课程文件。
- 音频格式：WAV、MP3、M4A、AAC、FLAC、OGG、OPUS、WEBM、MP4。
- 文本格式：UTF-8 TXT、MD、Markdown；导入后直接调用笔记模型，不经过语音转写。
- 文本文件上限 10 MB。音频最终能否转写还取决于所连接服务支持的格式和上传大小。

## 当前平台

- macOS：工程与权限已配置；需要完整 Xcode 首次安装组件才能构建。
- Windows：工程已生成，需在 Windows 10/11 + Visual Studio C++ 工具链中构建验证。
- Android：工程和麦克风/网络权限已配置；第一阶段以系统文件选择器导出 `.md`。

## 本地运行

```bash
flutter pub get
flutter test
flutter run -d macos
```

Windows：

```powershell
flutter run -d windows
```

Android：

```bash
flutter run -d android
```

## 首次设置

在左侧选择“AI 设置”，选择“本地服务”或“在线 API”。界面提供 Ollama、本地 Whisper 和 MLX Whisper 配置提示，也可以填写任意 OpenAI-compatible 地址：

- 转写 API：应用请求 `<地址>/v1/audio/transcriptions`
- 笔记 API：应用请求 `<地址>/v1/chat/completions`
- 如果地址已经以 `/v1` 结尾，应用不会重复添加。
- API Key 保存于系统安全存储，不写入源码或普通偏好设置。
- 笔记提示语可以修改；应用会在其后自动附加稳定的 JSON 输出约束。

推荐的本地组合：

- 笔记：Ollama `http://127.0.0.1:11434/v1` + `qwen3:14b`
- 转写：提供 OpenAI-compatible `/v1/audio/transcriptions` 的本地 Whisper 服务

注意：Ollama 只负责整理文本，不负责语音转写。文本导入模式可以只配置笔记服务。

桌面端可选择 Obsidian Vault，笔记写入 `01-课程笔记/`。若同名文件存在，会生成带时间戳的新文件，不覆盖旧笔记。

## 架构边界

```text
RecordingService
  → TranscriptionProvider
  → NoteProvider（结构化 JSON）
  → MarkdownService（确定性模板）
  → 编辑/预览
  → ExportService / Obsidian Vault
```

`TranscriptionProvider` 和 `NoteProvider` 是可替换接口。后续可增加 `whisper.cpp`、MLX Whisper、Ollama 或其他云服务实现，不需要重写界面。

## MVP 限制

- 当前不包含 API 额度代理服务，适合用户自带 Key 或本地兼容接口。
- 当前按完整文件上传，尚未实现长音频切片、自动转码、断点续传和说话人分离。
- Android 暂不承诺直接写入任意 Obsidian Vault；优先使用系统导出。
- 没有把本地大模型或 Whisper 模型打进安装包。
