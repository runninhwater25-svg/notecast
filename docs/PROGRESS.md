# Notecast 项目总进度

> 最后更新：2026-09-01  
> 当前阶段：桌面 V1 已发布，治理契约接入中  
> 产品事实来源：`PRODUCT.md`  
> 技术事实来源：`docs/PDD.md`

## 状态约定

已通过（POC）、已完成（V1）、开发中、待开发、待拆分需求、待澄清、不纳入本版本。

## 已验证 POC 基线

| 基线能力 | PRD | PDD | 状态 | 证据 / REQ |
|---|---|---|---|---|
| macOS 录音落盘 | 主流程 | RecordingService | 已通过（POC） | 真实录音生成有效 WAV；REQ-20260831-001 |
| AI 到 Obsidian Markdown | 输出与可移植性 | AI/Markdown/Export | 已通过（POC） | 自动测试与本地 UI 验证；REQ-20260831-001 |

## PRD 功能交付台账

| 功能域 | PRD 章节 | PDD 章节 | 当前状态 | 关联 REQ | 完成条件 | 证据 / 下一步 |
|---|---|---|---|---|---|---|
| 录音与材料输入 | 主流程、V1 范围 | Recording/Input | 已完成（V1） | REQ-20260831-001 | 录音、音频和文本入口可用且源文件不丢失 | 测试 + macOS POC；Android 待实机 |
| AI 转写与整理 | AI 与隐私边界 | API 契约 | 已完成（V1） | REQ-20260831-001 | 可配置兼容 Provider，错误可恢复 | 服务实现、设置测试；真实 Provider 矩阵待扩展 |
| Markdown 与 Obsidian | 输出与验收 | Markdown/Export | 已完成（V1） | REQ-20260831-001 | 可编辑、预览、导出，桌面 Vault 不覆盖 | Markdown/导出测试 |
| 桌面发布 | 平台范围 | 发布与验证 | 已完成（V1） | REQ-20260831-001 | macOS ZIP/DMG 与 Windows Setup 可下载 | `v1.1.1` GitHub Release |
| Android 完整体验 | 平台范围 | 平台边界 | 待验证 | REQ-20260831-001 | 实机录音、选择、AI、导出全流程 | 需要 Android SDK 与实体设备/模拟器 |
| 长音频稳健处理 | 非目标/后续 | API 边界 | 待拆分需求 | — | 分段、重试、恢复和验收口径确认 | 建立新 REQ 后规划 |

## PDD 技术交付台账

| 技术域 | PDD 章节 | 当前状态 | 关联 REQ | 完成条件 | 证据 / 下一步 |
|---|---|---|---|---|---|
| Flutter 工作流与平台壳 | 架构、平台边界 | 已完成（V1） | REQ-20260831-001 | macOS/Windows 构建通过 | GitHub Actions 33403384420 |
| 本地文件与密钥边界 | 数据、权限 | 已完成（V1） | REQ-20260831-001 | Key 不进仓库，源文件不被删除 | 实现与 `.gitignore`；持续安全复查 |
| 自动化验证 | 验证 | 已完成（V1） | REQ-20260831-001 | 9 项测试和双平台构建 | 测试与 Actions |
| 代码签名与公证 | 权限、发布 | 待开发 | 待拆分需求 | Apple 公证、Windows Authenticode 均通过 | 需要证书、费用和用户决策 |
| Project Vibe Spec | 文档治理 | 开发中 | REQ-20260901-001 | 地图、台账、事实和证据闭环 | `Progress/PROG-REQ-20260901-001-governance.md` |

## 当前里程碑

| 阶段 | 交付范围 | 状态 | 退出条件 | 关联 REQ / 进度 |
|---|---|---|---|---|
| Desktop V1.1.1 | macOS/Windows 安装资产 | 已完成（V1） | Release 公开且资产校验 | REQ-20260831-001 |
| 治理接入 | Project Vibe Spec 契约 | 开发中 | 文档验证、提交和推送 | REQ-20260901-001 / PROG |
| Mobile V1 | Android 用户路径 | 待验证 | 实机全流程证据 | REQ-20260831-001；后续可拆独立 REQ |

## 发布与回归门槛

- PRD：相关行为有确认范围和验收矩阵。
- PDD：测试通过，目标平台构建成功，外部依赖边界明确。
- 发布：仅用户明确授权后创建；不包含密钥和用户资料。
- 未完成风险：macOS/Windows 未使用商业代码签名；Android、长音频和 Provider 兼容矩阵仍需真实环境验证。
