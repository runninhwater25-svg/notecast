# Notecast 项目协作规范

本文件规定本仓库中的协作行为。产品、技术、设计和进度事实以 `DOCUMENT_MAP.md` 映射的文档为准，本文件不复制这些事实。

## 开始任务前

1. 先读取 `DOCUMENT_MAP.md`，再读取与任务相关的需求、决策、进度、PRD、PDD、UI 与业务流程文档。
2. Bug 写入 `docs/BUG_TRACKER.md`；功能、优化和体验变更写入 `Requirements/LEDGER.md`。
3. 跨平台、文件、权限、密钥、外部 AI、发布或多模块变更必须建立详细 REQ；大任务还需建立 `Progress/PROG-*.md`。
4. 会改变产品范围、数据语义、权限、安全、兼容性或成本的未知事项必须先获得用户确认。

## 文档优先级

本文件 → 用户本次明确确认 → 已确认的 REQ/DEC → `PRODUCT.md`（PRD）、`docs/PDD.md`、`DESIGN.md`、`docs/BUSINESS_FLOW.md` → 进度文档 → 代码、测试、配置与构建脚本。

代码和文档冲突时不得静默猜测：记录差异，按更高优先级事实处理；若会影响公开行为则先向用户确认。

## 实现、验证与 Git

- 只修改当前需求范围，保留无关改动，不为未确认需求预建复杂能力。
- 新增持久化数据、迁移、权限或密钥策略前必须建立 DEC 并取得明确确认。
- 实现与需求、决策、PRD/PDD、进度同步更新；跨模块需求逐项回填行为验收矩阵。
- 真实平台或外部服务不可用时写明“待实机回归”，不得用静态检查冒充行为验证。
- 提交前检查工作区和忽略规则；不得提交 API Key、`.env*`、录音、日志、构建产物或用户 Vault 内容。
- 推送、创建 Release、部署或修改 CI 需要用户明确授权。

## 常用验证

```bash
flutter pub get
flutter test
```

macOS/Windows 正式安装包由 `.github/workflows/release.yml` 在对应平台构建；发布证据以 GitHub Actions 与 Releases 为准。
