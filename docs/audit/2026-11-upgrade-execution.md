# P0/P1 execution report / P0/P1 升级执行报告

## English

Date: 2026-11-10. Scope: P0-A audit, P0-B calculation/data upgrade and P1 presentation/policy management. P2 remains deferred. The owner subsequently authorized proactive PR merge and release publication. Work uses a feature branch and [PR #1](https://github.com/UnLock-S/PayBySecond/pull/1); no force push, replacement of others' commits or changes to main protection are part of this work.

### Stages and outcomes

| Stage | Delivered result | Evidence and boundary |
|---|---|---|
| P0-A | Source, architecture, test and documentation audit; ten AUD risk IDs classified by severity and outcome | [Audit report](2026-11-paybysecond-audit.md); baseline 46 tests; three reproduced boundary defects, with design gaps distinguished from regressions |
| P0-B | Strict date/interval/range validation; independent dated salary/schedule histories; optional overnight attribution; multi-interval/break compilation; exact traces | Pure-Dart rational tests, partition invariance, full-period denominators, future activation, weekend/year boundaries, immutable rule/correction snapshots |
| P0-B data | Recoverable profile/ledger v2 migration, retained originals/previous values, stale-write rejection, legacy-conflict detection, plaintext backup preview/import/recovery | Fault injection, exact originals across restart, interrupted multi-key import journal recovery; preferences storage remains outside database/power-loss durability guarantees |
| P1 UI | Primary simulated amount, folded secondary totals, top-bar overtime shortcut, shared display privacy, separate history/trace/calendar/appearance/recovery pages | Three locales; 72 new page combinations across six viewports, two text scales and light/dark; existing home layout cases retained |
| P1 policy | Independent day classification/work override, provenance/version/review metadata, pending offline 2026 arrangements, explicit online checks and previous-cache rollback | Source/checksum/schema/revision rejection tests; failed requests retain data; applying a candidate is a dated personal schedule assumption, not official legal approval |
| P2 | Deferred | Tax/payroll/social insurance, real accounts/sync, widgets and desktop delivery are not claimed |

The three initially reproduced boundary defects are closed by passing regressions. Calendar-date overnight behavior was an intentional legacy boundary; migration preserves it and the new shift-start option is explicit. The newly added reference/calendar parser initially exposed device-local date conversion and was corrected to UTC civil components before delivery. A 320 px/200% calendar overflow was corrected with a scrollable minimum-width grid. Browser harness fixes wait for route transitions and committed overtime data before copying storage into another isolated context; they do not suppress product errors.

### Calculation and policy interpretation

`earnings_core` retains `BigInt` rational money and derives values from query time. Salary/schedule version boundaries split a query, while each segment retains its complete-year/month denominator. No tick accumulation or remaining-employment renormalization was introduced. Trace records carry interval, rule IDs, time numerator/denominator, exact minor-unit rational, calendar version/digest, formula, display rounding and warnings. Historical schedules retain the policy source snapshot and personal confirmation timestamp even after the current policy cache changes. Trace rendering initially shows 30 segments to bound page construction.

New overtime references require explicit standard-hours, employer-arranged and local source/applicability confirmations. Only the confirmed UTC+08 date receives its selected classification; other dates remain pending. Cash subtotals, pending time and recorded compensatory time are separate. Legacy snapshots retain their original arithmetic and an unverified label. End correction retains prior endpoints, update time and reason. This does not establish actual attendance, payroll entitlement, received pay or compliant leave delivery. See [implemented formulas, official sources and limits](../design/versioned-calculation-and-data.md).

### Executed validation

| Check | Actual result |
|---|---|
| `tools/check/check.ps1` | PASS: 29 core + 159 application tests; formatting, fatal-info analysis, font coverage, bilingual links and diff checks |
| Core LCOV | 534/581 measured lines, 91.91%, four instrumented project files |
| App LCOV | 2784/3454 measured lines, 80.60%, 33 instrumented project files; generated localization/config excluded |
| `tools/build/web.ps1` | Release compilation PASS; Wasm dry run PASS, not a separately qualified Wasm deployment |
| `tools/check/browser-smoke.cjs` | Three-language desktop/mobile setup, persistence, privacy, navigation, updates and overtime flows; no runtime errors, remote font requests or automatic Web APK checks |
| `tools/check/upgrade-browser.cjs` | Isolated synthetic data: real Web v1 migration, exact originals, idempotent reload, future salary, cancelled preview, detail privacy, policy failure, backup tamper rejection/confirmed import, dark theme and explicit legacy-conflict recovery |
| Android | ARM64 Release-optimized test APK compiled in a neutral build workspace; 78 tracked product source/resource files matched the checkout |
| Package checks | APK signature v2 verified; same existing test certificate; 16 KiB ZIP/ELF alignment passed; engine NOTICES and both original OFL files/four fonts retained |
| Permissions/privacy | INTERNET plus AndroidX's package-local signature guard; no new sensitive runtime permission; binary scan found no configured personal-path/name/credential patterns |
| Hardware discovery | Zero connected devices; installation, real screen reader, physical-device memory/energy and upgrade behavior remain unverified |

LCOV percentages cover reported instrumented executable lines, not branches or every source file. Concrete platform adapters/bootstrap are not fully represented. Widget and Web passes do not establish Android resource measurements. Original logs, LCOV and screenshots are ignored under `out/reports/upgrade-p0-a`, `out/reports/upgrade-p1`, `out/reports/browser` and `out/reports/upgrade-browser`; all browser finance is synthetic.

### Artifact and main changes

Prepared version: **0.3.0+4**, Android package versionCode **2004** for split ARM64, min SDK 24, target SDK 36. APK: `PayBySecond-0.3.0-arm64-v8a-test.apk`, **20,613,374 bytes**. SHA-256: `7bcd60da6055f11797c73ee1d0abd98e6d7484a34853544bb9d90113599ebebc`. Test-certificate SHA-256: `e6aa7e857ba55d6276bb9916fff52a05939cdae6651313c1fcdf48d39cb03471`. This remains a test-signed package, not an app-store production-signing claim. Release assets and their anonymous metadata/download verification are recorded in the final delivery.

Main source areas: `src/packages/earnings_core/lib/src/{engine,history,overtime,policy}.dart`; application `settings.dart`, `profile_document.dart`, `income_session.dart` and `overtime.dart`; recoverable repositories, integrity/backup/policy adapters; dashboard/settings/overtime presentation; zh/en/ja ARB and generated localizations. Public policy source lives in `config/policy`; tests, font checks, browser verification and bilingual design/audit docs were updated. The existing locked `crypto` 3.0.8 was promoted to a direct dependency after its original BSD-3-Clause review; no new resolved version, paid UI framework, telemetry or tracking SDK was introduced.

### Remaining limits

Official candidate data is **pending human verification**. Missing statutory classifications, unsupported working-time regimes, disputed wage bases and unconfirmed overtime remain explicit gaps; the application does not guess legal entitlements. Cross-day pending time is not a final zero entitlement or an automatically resolved historical legal ledger. The policy transport trusts the fixed project HTTPS source, not a new cryptographic signing authority. Plaintext backups and local preferences require private handling; external browser/device cleanup and storage failures remain possible. Full file-picker/cloud backup, arbitrary multi-date legal reclassification and verified physical attendance are not claimed. P2 and native-device qualification remain later work.

## 中文

日期：2026-11-10。范围为 P0-A 审计、P0-B 计算/数据升级、P1 界面与政策管理；P2 后置。所有者后续已授权主动合入 PR 并发布 Release。本次使用功能分支及 [PR #1](https://github.com/UnLock-S/PayBySecond/pull/1)，不强推、不替换他人提交、不改变 main 保护。

### 阶段结果

| 阶段 | 交付内容 | 证据与边界 |
|---|---|---|
| P0-A | 源码、架构、测试和文档审计，十个 AUD 风险编号按严重度及结论分类 | [审计报告](2026-11-paybysecond-audit.md)；原 46 项测试；复现三个边界缺陷，并区分设计缺口与旧版回归 |
| P0-B | 严格日期/区间/范围校验，独立薪资及排班生效历史，可选跨日归属，多工作/休息时段，精确追溯 | 纯 Dart 有理数、分段守恒、完整周期分母、未来生效、周末/年界、不可变修正快照测试 |
| P0-B 数据 | 档案/账本 v2 可恢复迁移、原文及上次有效值、过期写入拒绝、旧版冲突检测、明文备份预览/导入/恢复 | 故障注入、重启原文一致、多键导入中断日志恢复；偏好存储不宣称数据库或断电级耐久 |
| P1 界面 | 主模拟金额、折叠次级合计、顶部加班快捷入口、共享金额隐私、独立历史/依据/日历/外观/恢复页 | 三语、六种视口、两种文字比例、明暗主题，共 72 组新增页面组合，保留原首页矩阵 |
| P1 政策 | 日期分类与工作覆盖分离，来源/版本/核验元数据，待核验 2026 离线候选，主动联网检查及缓存回退 | 来源/摘要/结构/修订拒绝测试，失败保留数据；应用候选是带生效日的个人排班假设，不是官方法律批准 |
| P2 | 后置 | 不宣称提供税费/工资单/社保、真实账号同步、小组件或桌面交付 |

三个初始边界缺陷已由回归转绿关闭。旧跨夜日历日语义属于原设计边界，迁移保留，新增起始日模式由用户显式选择。新参考/日历解析测试暴露设备本地日期转换，已在交付前改用 UTC 民用组件。320 宽度/200% 日历溢出改为可滚动最小宽度网格。浏览器脚本修正为等待转场及加班写入完成，再向独立上下文复制存储，不屏蔽产品异常。

### 计算及政策口径

核心使用 `BigInt` 有理数并按查询时间计算；薪资/排班边界切分查询，每片保留完整年/月分母，不按 tick 累加、不将整月工资压缩到剩余入职日。追溯记录包含区间、规则 ID、时间分子分母、最小币种精确分数、日历版本/摘要、公式、显示舍入及警示。历史排班保留政策来源快照和个人确认时间，不因当前缓存更新而丢失来源。明细初始仅构建 30 个片段，控制页面开销。

新加班参考须明确确认标准工时、单位安排和本地来源/适用条件；只对确认的 UTC+08 日期应用所选分类，其他日期保持待核验。已知现金小计、待核验工时、补休工时分列。旧快照保留原算法并标识未核验；结束修正保留原结束时刻、更新时间和原因。这些不证明真实考勤、法定权益、工资到账或补休已合规兑现，详见[实现公式、官方依据与边界](../design/versioned-calculation-and-data.md)。

### 实际验证

| 检查 | 实测结果 |
|---|---|
| `tools/check/check.ps1` | 通过：29 项核心 + 159 项应用；格式、严格静态分析、字体、双语链接及差异检查 |
| 核心 LCOV | 534/581 行，91.91%，四个已插桩项目文件 |
| 应用 LCOV | 2784/3454 行，80.60%，33 个已插桩项目文件，排除生成的本地化/配置 |
| Web 构建 | Release 编译及 Wasm dry run 通过，不表示另行验收了 Wasm 部署 |
| 通用浏览器脚本 | 三语桌面/手机首次配置、持久化、隐私、导航、更新及加班；无运行异常、远程字体请求、Web 自动 APK 检查 |
| 升级浏览器脚本 | 独立合成数据：真实 Web v1 迁移、原文保留、重载幂等、未来薪资、取消预览、明细隐私、政策失败、备份损坏拒绝/确认导入、深色及旧版冲突显式恢复 |
| Android | 中性构建目录编译 ARM64 Release 优化测试包；78 个受控产品源码/资源文件与工作区一致 |
| 包检查 | APK v2 签名通过，延用原测试证书；16 KiB ZIP/ELF 对齐通过；保留引擎 NOTICES、两份原 OFL 和四份字体 |
| 权限/隐私 | INTERNET 与 AndroidX 包内签名保护权限，无新增敏感运行时权限；二进制未命中配置的个人路径/姓名/凭据模式 |
| 硬件 | 连接设备为零；安装、真实读屏、手机内存/电量及设备升级行为未验证 |

LCOV 是报告中已插桩可执行行覆盖，不是分支或全源码覆盖，真实平台适配器/bootstrap 未全面进入报告。组件/Web 不替代 Android 资源实测。原始日志、LCOV 和截图在被忽略的 `out/reports/upgrade-p0-a`、`out/reports/upgrade-p1`、`out/reports/browser`、`out/reports/upgrade-browser`；浏览器财务值全部为合成数据。

### 制品及主要修改

准备版本 **0.3.0+4**，ARM64 拆包后的 versionCode **2004**，最低 SDK 24、目标 SDK 36。APK 为 `PayBySecond-0.3.0-arm64-v8a-test.apk`，**20,613,374 字节**。SHA-256：`7bcd60da6055f11797c73ee1d0abd98e6d7484a34853544bb9d90113599ebebc`。测试证书 SHA-256：`e6aa7e857ba55d6276bb9916fff52a05939cdae6651313c1fcdf48d39cb03471`。仍是测试签名，不宣称应用商店生产签名；最终交付登记发行资产及匿名元数据/下载校验。

主要源码为纯 Dart 核心的 engine/history/overtime/policy；应用 settings/profile_document/income_session/overtime；可恢复仓储、完整性/备份/政策适配器；首页/设置/加班界面；三语 ARB 及生成文案。公开政策源在 `config/policy`，并维护测试、字体检查、浏览器脚本及双语设计/审计文档。已核对原 BSD-3-Clause 后，将已锁定的 `crypto` 3.0.8 从间接提升为直接依赖，未新增解析版本、付费 UI 框架或遥测/跟踪 SDK。

### 剩余边界

官方候选数据**待人工核验**。缺失法定分类、不支持工时制度、有争议工资基数、未确认加班仍明确保留缺口，不猜测法定权益。跨日待核验工时不代表最终权益为零，也不是自动解决的历史法律账本。政策传输信任固定项目 HTTPS 源，不提供新的密码学签名机构。明文备份和偏好存储须妥善保管，外部清理及存储失败仍可能发生。不宣称完整文件选择器/云备份、任意多日期法律重分类或已核实考勤；P2 和原生设备验收留后续。
