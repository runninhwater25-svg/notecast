# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Stack

Flutter 与 Dart，共享 macOS、Windows、Android 的 UI 和业务逻辑；平台能力通过插件或窄接口接入。

## Users

需要长期把课程、讲座或会议录音整理为 Obsidian 笔记的个人用户。首要用户是每周高频录制中文课程、希望保留原始资料并减少手工整理的学生。

## Product Purpose

把“录音—转写—AI 整理—编辑—导出”收束为一条可理解、可恢复的工作流。成功意味着用户无需接触命令行，即可得到可编辑的 Obsidian 风格 Markdown 文件。

## Positioning

本地资料优先、输出格式开放、AI 服务可替换。录音和 Markdown 始终属于用户，不把笔记锁进专有云端。

## Operating Context

- 桌面端优先运行于 macOS 和 Windows，Android 为同一代码库的下一阶段目标。
- 用户可导出单个 `.md`，桌面端还可直接写入自己选择的 Obsidian vault。
- 第一版使用联网转写和 AI 接口；以后可接入 Whisper 与 Ollama 本地 Provider。

## Capabilities and Constraints

- 开始、暂停和停止录音，音频先保存到本地。
- 选择或拖入常见音频文件；导入 UTF-8 文本时跳过转写，直接生成笔记。
- 转写与笔记模型通过 OpenAI-compatible HTTP Provider 接入，凭证不写入源码。
- AI 返回结构化数据，客户端负责渲染 Markdown 模板。
- 本地与在线 Provider 都通过 OpenAI-compatible 接口配置，提示语由用户编辑。
- 第一版不做账号、云同步、实时字幕、说话人分离、自动转码和本地大模型打包。
- Windows 安装包必须在 Windows 构建环境完成最终验证。

## Brand Commitments

继承已批准的深色机场导视语言：深石墨背景、路线黄主动作、清晰阶段编号；不使用渐变、玻璃拟态或泛滥的 AI 闪光符号。

## Evidence on Hand

- 已有可运行的 macOS 中文转写与 Qwen3 14B → Obsidian 工作流。
- 已有课程笔记 App 图标与机场导视视觉方向。
- 暂无商业背书、用户规模或准确率数据，不得自行编造。

## Product Principles

1. 音频先落盘，失败不丢失。
2. Provider 可替换，不把核心流程绑定一家模型供应商。
3. Markdown 是最终可移植产物。
4. 当前阶段与恢复动作必须明确。
5. 移动和桌面遵循各自平台的输入与导航习惯。

## Accessibility & Inclusion

使用语义标签、系统字体缩放、键盘焦点与不依赖颜色的状态文字；Android 触控目标不小于 48dp。
