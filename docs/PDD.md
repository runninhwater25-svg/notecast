# Notecast 技术设计文档（PDD）

> 最后更新：2026-09-01

## 技术约束

- 运行环境：macOS、Windows 桌面优先；Android 保留同代码库支持。
- 框架与语言：Flutter 3.47.1、Dart 3.13.1；Material 3。
- 包管理：Flutter pub，锁定于 `pubspec.lock`。
- 存储：原始音频/导出文件使用本地文件系统；普通设置使用 SharedPreferences；API Key 使用系统安全存储；无数据库。
- 检查与构建：`flutter test`；平台正式包由 `.github/workflows/release.yml` 构建。

## 架构、模块与接口

| 模块 | 职责 | 入口 | 关键依赖 |
|---|---|---|---|
| Workflow UI | 输入、阶段、编辑、预览和导出界面 | `workflow_screen.dart` | Riverpod、Material、desktop_drop |
| WorkflowController | 状态机、恢复边界和服务编排 | `workflow_controller.dart` | 各 Service |
| RecordingService | 权限、WAV 录音和本地落盘 | `recording_service.dart` | record、path_provider |
| InputService | 文件选择、格式/大小/UTF-8 校验 | `input_service.dart` | file_picker、dart:io |
| CompatibleAiProvider | 转写与笔记 HTTP 请求 | `ai_service.dart` | Dio、OpenAI-compatible API |
| SettingsService | Provider 设置与密钥 | `settings_service.dart` | SharedPreferences、secure storage |
| MarkdownService | 结构化结果到稳定 Markdown | `markdown_service.dart` | 无外部状态 |
| ExportService | `.md` 导出和 Vault 写入 | `export_service.dart` | file_picker、dart:io |

## 数据与状态

- 内存状态：WorkflowController 保存当前来源、转写、Markdown、阶段、错误与输出路径；重启后不恢复未完成任务。
- 持久化设置：Provider 地址、模型、模式、提示语和 Vault 路径；API Key 单独进入系统安全存储。
- 用户文件：应用不删除导入源文件；录音写入用户文档目录；同名 Markdown 不覆盖。
- 无数据库、DDL 或迁移。以后新增任务历史、索引或云同步必须建立数据 DEC 并取得用户确认。

## API 契约

- 转写：`POST <base>/v1/audio/transcriptions`，multipart 包含 `model`、`file`、`response_format=json`，期望响应含 `text`。
- 笔记：`POST <base>/v1/chat/completions`，期望 `choices[0].message.content` 为规定 JSON 对象。
- 客户端追加 `/v1`；Key 非空时发送 Bearer Authorization。
- 第三方格式、限额、隐私和可用性由用户选择的 Provider 决定。

## 权限、安全与平台边界

- macOS：沙盒启用麦克风、网络客户端和用户选择文件读写；未配置 Apple Developer ID 公证。
- Windows：Inno Setup 安装器；未配置 Authenticode 签名。
- Android：麦克风和网络权限；任意 Vault 直写不在当前承诺内。
- 在线 API 会接收课程材料；App 不内置公共 API Key，也不提供费用代理。

## 兼容、回滚与验证

- Provider 可替换，Markdown 是稳定可移植输出；设置错误可通过重新配置恢复。
- 正式发布必须通过聚焦测试、目标平台构建、资产存在性和 macOS codesign 结构校验。
- 当前自动化：输入、Markdown、设置、导出、主界面及桌面/手机视觉基线共 9 项。
- 待实机：Android 全流程、不同 Windows 设备安装体验、长音频和各 Provider 格式矩阵。
