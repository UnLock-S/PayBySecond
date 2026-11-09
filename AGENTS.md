# Development rules / PayBySecond 开发约定

## English

### Project boundaries

- Maintain main directly as requested. Inspect the remote before pushing; do not force-push or overwrite others' commits.
- Validate Flutter Web first and reuse its business/UI implementation for Android, the main delivery target.
- Put requirements/design in docs/, business/platform source in src/, public config in config/, environment guidance/templates in env/, and scripts in tools/.
- Never commit SDKs, caches, build outputs, machine paths, real salary, tokens or keys. Keep ignore rules aligned.

### Dependencies and licensing

- Prefer Dart/Flutter built-ins and official plugins. Review the resolved version's original LICENSE/NOTICE before adding dependencies.
- Prefer permissive licenses suitable for commercial integration. Do not add paid-contract, noncommercial-only or unknown-license components.
- Review actual GPL/AGPL/LGPL, unknown or dual-license obligations; a package-page label alone is insufficient.
- Preserve Flutter's mixed third-party NOTICES and font OFL/source notices.
- Do not assign an MIT/Apache/project-wide license without the owner's decision. Public visibility does not assign a license; third parties retain their own terms.
- No copied commercial/unknown-source code, assets, fonts or keys; no ads, analytics or tracking SDKs.

### Implementation and validation

- Keep wage formulas in pure-Dart earnings_core. Exact amounts must not depend on floating-point tick accumulation.
- Cancel invisible/background refresh and recompute from time on resume. No sensitive permissions or keepalive.
- Explicitly label unimplemented accounts, official holidays and salary history. Do not simulate success.
- After Dart edits run tools/check/check.ps1; for Web changes run tools/build/web.ps1 and relevant browser verification.
- New Chinese/Japanese copy needs font coverage checks and, if needed, rebuilding under third-party-assets.md. Never shrink by dropping notices.
- After dependency changes restore dependencies/locks and update dependency-inventory.md, recording scope.
- Update README/design documentation and distinguish plans from implementation and Web checks from native measurements.
- Keep UI copy in zh/en/ja ARB files and use built-in gen-l10n. Japanese should favor natural kanji vocabulary, not Chinese text presented as Japanese.
- Language changes display only, not currency/timezone/salary rules. Use category pages rather than returning to a long home form/modal.
- Maintain project-authored Markdown in English followed by Chinese. Preserve upstream legal texts verbatim. Public docs must not include machine usernames, private paths, credentials or real personal finance.

## 中文

### 工程边界

- 在本仓库直接维护 main，按用户要求提交和推送；推送前检查远端，禁止 force push 或覆盖他人提交。
- Flutter Web 先行，Android 为后续主要交付目标；不要另起一套 Web 业务实现。
- 需求与设计放 docs，业务源码和平台工程放 src，公开配置源放 config，环境说明和模板放 env，脚本放 tools。
- 不提交 SDK、缓存、构建产物、本机路径、真实薪资、令牌或密钥。保持 .gitignore 与这些边界一致。

### 依赖与授权

- 优先 Dart/Flutter 标准能力和官方插件，新增依赖前检查锁定版本及其原始 LICENSE/NOTICE。
- 优先适合商业应用集成的宽松许可；不得自行引入付费授权、仅限非商业或需要单独商业合同的组件。
- GPL/AGPL/LGPL、来源不明或多重许可组件需先分析实际使用方式与义务，不能仅凭包主页标签判断。
- Flutter 引擎是混合依赖集合，保留构建产物中的第三方 NOTICES；本地字体保留 OFL 正文和来源。
- 不擅自为项目自有代码选择 MIT/Apache 等公开授权；当前项目自身许可证尚未确定，第三方仍各自遵循原许可。
- 不复制来源不明的商业代码、设计素材、字体或密钥，不引入广告/分析/跟踪 SDK。

### 实现与验证

- 工资计算只在纯 Dart earnings_core 内实现，金额精度不能依赖逐 tick 浮点累加。
- 离开前台停止刷新，恢复时直接按时间重算；不申请敏感权限或使用保活。
- 真实账号、官方节假日、历史薪资等未实现能力必须明确标注，不用模拟成功替代。
- 修改 Dart 后执行 tools/check/check.ps1；影响 Web 交付时执行 tools/build/web.ps1，并做相关浏览器复验。
- 新增中文文案后运行字体覆盖检查，必要时按 third-party-assets.md 重建字体；不删第三方声明来减少包体。
- 依赖变化后恢复依赖、更新锁文件和 docs/development/dependency-inventory.md，记录验证范围。
- 更新 README 与相关设计文档，避免把计划写成已实现或将 Web 验证推广为 Android 资源验证。
- 界面文案维护在 lib/l10n 的中文、英语、日语ARB中，使用Flutter内置gen-l10n；日语优先自然的汉字词，不将中文词直接当日语。
- 语言切换只影响显示，不改币种、时区、薪资存储或计算规则；新增配置按分类页面组织，避免重新堆回首页或长弹窗。

- 自有Markdown文档统一先英文后中文；上游许可正文原样保留。公开文档不得包含本机用户名、私有路径、凭据或真实个人财务。
