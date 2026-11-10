# PayBySecond / PayBySecond

## English

**Android test APK:** [Download v0.3.0](https://github.com/UnLock-S/PayBySecond/releases/download/v0.3.0/PayBySecond-0.3.0-arm64-v8a-test.apk) · [Release notes and SHA256](https://github.com/UnLock-S/PayBySecond/releases/tag/v0.3.0). Android 7.0+, ARM64; Release-optimized with the existing Debug test certificate. Older local versions without an updater need this version installed manually once.

PayBySecond is a live income estimator: validate on Flutter Web first, deliver Android APK from the same client, then extend to Windows/Linux/macOS.

Repository: [UnLock-S/PayBySecond](https://github.com/UnLock-S/PayBySecond). This upgrade uses a feature branch and reviewed PR; main remains admin-only. Project-owned code has no selected overall license; public visibility does not change third-party terms or assign an MIT/Apache license.

### Current functionality

Exact pure-Dart salary calculations, multipage configuration, live dashboard, local persistence, lifecycle-aware refresh, flexible text/wheel input, independent overtime ledger and GitHub Release checking. The Android source is included and local test APKs can be built. Dated salary/schedule history, recoverable v2 storage, plaintext JSON backups, calculation explanations, selectable overnight attribution and calendar/policy review are implemented. The bundled 2026 arrangements remain pending human verification; missing legal day classifications remain unknown. Accounts, synchronization, payroll/tax settlement and desktop platform projects remain unimplemented.

UI languages: Chinese, English, Japanese, persisted locally. First use has a language action; after configuration use Settings → Language. A successful change returns home automatically. Language changes display only: currency remains CNY and work zone UTC+08:00. Japanese uses a local JP font and natural kanji vocabulary.

### Navigation

- Home: period, privacy mask, settings and a separate one-tap overtime start/stop card.
- Setup: Salary → Calculation → Work schedule (work mode only) → Review/save.
- Settings: salary, calculation, work schedule, date overrides, display, language, software update, data/information.
- Text/wheels: dates such as 20261109 or 2026/11/9; times 1/01 both mean 01:00, 805/8:5 mean08:05. Invalid calendar dates/times are rejected.
- Overtime: unpaid, statutory reference, 1× or custom multiplier; independently stored snapshots/history, end correction and totals; unpaid humor represents time value, not salary deduction.
- Wage-rule changes have an effective date and preview; older intervals retain their rules and same-date corrections are archived. Unsaved configuration can be discarded explicitly.
- Separate history, month calendar/policy source, appearance and backup/recovery pages. Light/dark/system themes and session-wide financial display privacy.
- See [versioned calculation and data design](docs/design/versioned-calculation-and-data.md) for formulas, limits, source provenance and recovery boundaries.

### Run/check

Install the Flutter version pinned in .flutter-version and run PowerShell 7 at the root:

```powershell
./tools/bootstrap/setup.ps1 -FlutterRoot '<Flutter SDK directory>'
./tools/check/check.ps1
./tools/run/web.ps1
```

The local URL is http://127.0.0.1:7357. Scripts store machine SDK locations only in ignored .local/ and do not edit global PATH. tools/build/web.ps1 archives Release output in out/web/. Serve through HTTP/HTTPS; do not open index.html as a local file.

Salary and schedule changes use dated rules and full-period denominators; they are mathematical simulation, not verified pay history. Local finance and exported JSON are not encrypted and browser cleanup can erase storage. Keep a private backup. Policy requests require an explicit user gesture and never upload financial data.

### GitHub updates

On Android, startup checks at most once per 24 hours; disable this in Software update or check manually with a 30-second cooldown. Stable releases only; show notes, then open the matching ARM64/universal APK in the system browser. No automatic install, storage permission, GitHub token or salary upload. Ordinary INTERNET permission is necessary and has no runtime prompt. No background polling.

Configure owner/repository in config/app/updates.json. A public repository still needs a published Release with an appropriately named APK; until then, show no accessible release rather than “up to date.” See [update design](docs/design/github-updates.md). No release/asset is automatically published by building the app.

### Documentation

- [P0/P1 execution report](docs/audit/2026-11-upgrade-execution.md)
- [Phased upgrade audit](docs/audit/2026-11-paybysecond-audit.md)
- [Requirements/calculation policy](docs/requirements/product-spec.md)
- [Architecture/layout](docs/architecture/software-architecture.md)
- [Multipage/language UI](docs/design/ui-navigation.md)
- [Input/overtime](docs/design/overtime-and-input.md)
- [GitHub updater](docs/design/github-updates.md)
- [Environment](docs/development/environment.md)
- [Verification plan](docs/testing/verification-plan.md)
- [ADR-001](docs/architecture/decisions/0001-web-first-flutter.md), [ADR-002](docs/architecture/decisions/0002-mvp-boundaries.md)
- [Git workflow](docs/development/git-workflow.md)
- [Initial results](docs/testing/web-mvp-validation.md)
- [UI/i18n results](docs/testing/ui-i18n-validation.md)
- [Overtime/input results](docs/testing/overtime-input-validation.md)
- [Updater/publication results](docs/testing/github-updates-validation.md)
- [Font sources/rebuild](docs/development/third-party-assets.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md), [resolved licenses](docs/development/dependency-inventory.md)
- [Development rules](AGENTS.md)

### Top-level ownership

| Directory | Content |
|---|---|
| docs/ | Requirements, architecture, design, validation and development guidance |
| src/ | Flutter/native source, pure Dart package and tests |
| config/ | Public defaults, source calendars, quality/CI settings |
| env/ | Environment instructions/examples, never real secrets |
| tools/ | Setup/run/build/check scripts |
| .local/ | Ignored SDK locators, source fonts, test tooling/build copies |
| out/ | Ignored packages and reports |

Do not create placeholder files for every planned empty directory. Prefer built-ins/official plugins and permissive licensing; no paid-contract, noncommercial-only or unknown components. Preserve copyright/licenses/NOTICES, including the in-app license page. Upstream legal texts remain verbatim; project documents are English/Chinese. Historical author metadata is retained with the owner's explicit consent; new commits use a public noreply identity.

## 中文

**Android测试包：**[下载v0.3.0](https://github.com/UnLock-S/PayBySecond/releases/download/v0.3.0/PayBySecond-0.3.0-arm64-v8a-test.apk) · [更新说明与SHA256](https://github.com/UnLock-S/PayBySecond/releases/tag/v0.3.0)。适用于Android 7.0+、ARM64，Release优化并沿用Debug测试证书。旧版若没有更新入口，需先手动安装本版一次。

实时工资估算工具，Flutter Web 优先验证，后续交付 Android APK，再扩展 Windows、Linux、macOS。

仓库：[UnLock-S/PayBySecond](https://github.com/UnLock-S/PayBySecond)。本次升级通过功能分支及 PR，main 保留仅管理员写入保护。

当前为 Web 本机体验版：已实现独立工资计算包、薪资配置、实时面板、本地保存及生命周期刷新。已加入带生效日的薪资/排班历史、可恢复 v2 数据、明文 JSON 备份、计算依据、可选跨日归属和日历/政策核验；内置 2026 安排仍待人工核验，未确认法定分类保持未知。真实账号、同步、工资结算及税费未实现；Android 已通过本机隔离平台工程生成测试 APK，平台源码保留在src，构建产物和本机配置不提交。

界面支持中文、English、日本語，语言偏好保存到本机。首次打开可通过右上角语言图标选择语言，已有配置后通过“设置 → 语言”切换。

### 界面与配置

- 收入首页：统计范围选择、金额显隐、设置入口，以及独立的加班开始/结束卡片。
- 首次设置：薪资信息 → 计算方式 → 工作时间（仅工作模式）→ 确认保存。
- 分类设置：薪资信息、计算方式、工作时间、休假与补班、显示偏好、语言、数据与说明。
- 日期/时间支持滚轮与灵活文本输入，例如20261109、2026/11/9、8、08、8:5；休假日期也复用此能力。
- 语言保存成功自动返回首页；加班通过独立页面配置无薪、法定参考、1倍或自定义倍数，保存本地记录并单独统计。
- 离开配置页时可放弃未保存修改；涉及收入规则的保存须选择生效日并预览确认；旧区间保留规则，同日修正归档。

语言只改变界面，币种仍为人民币 CNY，时区仍固定 UTC+08:00。日语使用独立的本地 JP 字体子集，文案优先采用自然、简洁的汉字词。

### 启动与检查

安装 `.flutter-version` 指定的 Flutter SDK（包含 Dart），使用 PowerShell 7 在仓库根执行：

```powershell
./tools/bootstrap/setup.ps1 -FlutterRoot '<Flutter SDK目录>'
./tools/check/check.ps1
./tools/run/web.ps1
```

运行地址为 `http://127.0.0.1:7357`。脚本只记录本机 SDK 路径到被忽略的 `.local/`，不修改全局 PATH。`./tools/build/web.ps1` 构建 Release 并归档至 `out/web/`，部署时需提供 HTTP/HTTPS 静态服务，不能直接双击 index.html。

薪资与排班使用带生效日的历史规则及完整周期分母，属于数学模拟，不是核实的工资历史。数据及导出 JSON 未加密，浏览器清理仍可能导致丢失，请另存私有备份。政策请求须用户主动触发，不上传财务数据。

### 阅读入口

- [P0/P1 升级执行报告](docs/audit/2026-11-upgrade-execution.md)
- [分阶段升级审计](docs/audit/2026-11-paybysecond-audit.md)
- [产品需求与计算口径](docs/requirements/product-spec.md)
- [软件架构与目录约定](docs/architecture/software-architecture.md)
- [多页面与多语言界面设计](docs/design/ui-navigation.md)
- [日期时间输入与加班账本](docs/design/overtime-and-input.md)
- [开发环境与配置管理](docs/development/environment.md)
- [验证与发布门槛](docs/testing/verification-plan.md)
- [架构决策 ADR-001](docs/architecture/decisions/0001-web-first-flutter.md)
- [Git 维护约定](docs/development/git-workflow.md)
- [首版验证记录](docs/testing/web-mvp-validation.md)
- [多页面与三语验证记录](docs/testing/ui-i18n-validation.md)
- [日期输入与加班验证记录](docs/testing/overtime-input-validation.md)
- [第三方字体与重建说明](docs/development/third-party-assets.md)
- [第三方组件与授权说明](THIRD_PARTY_NOTICES.md)
- [已解析依赖许可清单](docs/development/dependency-inventory.md)
- [开发与依赖约定](AGENTS.md)

### 顶层分工

| 目录 | 内容 |
|---|---|
| `docs/` | 需求、架构、详细设计、验证与开发说明 |
| `src/` | Flutter 应用、纯 Dart 计算包及其测试、平台工程 |
| `config/` | 可提交的产品配置源、日历数据源、质量和 CI 配置 |
| `env/` | 环境变量示例与本机环境入口；真实本机配置不提交 |
| `tools/` | 初始化、运行、构建和检查脚本 |
| `.local/` | 本机工具链定位、字体源与测试依赖，Git 忽略 |
| `out/` | 交付产物和报告，Git 忽略 |

部分目录目前为空，后续在对应阶段填入实现；Git 不保存空目录，不为每个目录制造占位文件。

### 依赖与授权

优先 Flutter 标准能力与官方插件，避免引入需单独商业合同、仅限非商业或来源不明的组件。框架、插件、字体和工具各自遵循其原许可证，发行时保留第三方声明；应用提供“开源许可”入口。

项目自有代码尚未指定公开许可证，未擅自添加 MIT/Apache 授权。第三方许可和后续依赖管理规则见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

### GitHub软件更新

Android启动时最多每24小时检查一次，可在“软件更新”关闭自动检查，也可手动检查（至少间隔30秒）。只跟随稳定Release，展示版本说明后由系统浏览器下载对应ARM64/universal APK。不自动安装，不申请安装/存储权限，不内置令牌，不上传薪资。仅增加普通INTERNET权限，无授权弹窗，无后台轮询。

更新源为config/app/updates.json；公开仓库仍需发布稳定Release并上传对应APK。尚无Release时提示尚无公开发行版，不误报最新版。构建不会自动发布制品。见 [更新设计](docs/design/github-updates.md) 与 [验证记录](docs/testing/github-updates-validation.md)。

按所有者选择保留历史作者信息；新提交使用公开noreply身份。公开仓库不自动赋予项目自有代码MIT/Apache等许可证。未接入真实账号、同步或税费结算；薪资/排班历史已版本化，2026 日历候选待人工核验，桌面平台工程仍待生成。详见[版本化设计](docs/design/versioned-calculation-and-data.md)。
