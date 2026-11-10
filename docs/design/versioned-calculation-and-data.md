# Versioned calculation and recoverable data / 版本化计算与可恢复数据

## English

This document describes the P0/P1 upgrade implementation. Earlier MVP validation reports describe their original revision; they are not current feature inventories. See the [audit](../audit/2026-11-paybysecond-audit.md) for the baseline and stage evidence. Web and Android use the same Flutter application and pure-Dart `earnings_core`; no backend or second Web implementation was added.

### Rule history and exact amounts

Profile schema v2 contains independent immutable salary and schedule versions, civil effective dates, stable IDs, UTC creation/update timestamps, a revision counter and archived same-date corrections. The initial version is the user's configured baseline assumption, not a reconstructed or verified historical payslip. Each list accepts 1–128 versions; replacements have a 512-entry archive limit and fail visibly at capacity rather than pruning records. Moving employment earlier extends the first baseline only after the change preview.

Queries split at salary/schedule and month/year boundaries. Each segment uses its rule's complete-period denominator: monthly budget or twelve monthly budgets multiplied by eligible intersection milliseconds divided by eligible full-period milliseconds. No remaining-employment renormalization occurs. Different rules can produce a total different from a single fixed budget. `BigInt` rational amounts are independent of refresh frequency; display uses half-away-from-zero rounding at 2/4/6 decimals. The calculation details page exposes rule IDs, interval, numerator/denominator, exact minor-unit rational and the calendar version. These are simulation results, not payroll settlement, bank receipts or entitlement decisions.

The work timezone remains fixed UTC+08:00 independently of device locale/timezone. Legacy schedules keep calendar-date attribution. Optional shift-start attribution carries the starting date's work/rest rule across midnight, including weekend/year boundaries. Up to 16 work intervals and 16 break intervals compile into merged paid intervals. Overlaps are never counted twice; the legacy fixed lunch break remains optional. The engine caches at most four compiled rule pairs and three years per compiled engine. The UI pauses its single refresh timer while hidden or on secondary routes and recomputes from time on return.

### Overtime reference

Existing overtime snapshots remain `legacy-unverified`; their historical arithmetic is preserved and visibly identified. New snapshots identify `cn.standard-hours.2025-01.v1`, an independent monthly overtime base, the selected pay mode/day classification, local source-review timestamp, standard-hours confirmation and employer-arranged confirmation. Without these conditions, or outside the confirmed civil date, statutory reference time remains pending. Crossing midnight does not apply one day's classification to the next. Known cash subtotal, pending time and recorded compensatory time are separate. Selecting unpaid pay can display a humorous 1× time value, explicitly not a deduction.

The conditional reference uses [Labor Law article 44](https://www.samr.gov.cn/zw/zfxxgk/fdzdgknr/bgt/art/2023/art_d9aa750028b14b99a776cb93726a360d.html) (2018-12-29 amended text) and [MoHRSS notice 2025 No. 2](https://www.mohrss.gov.cn/SYrlzyhshbzb/laodongguanxi_/zcwj/202501/t20250101_533693.html), effective 2025-01-01. Its narrow scope is mainland China labor relationships under standard eight-hour working-time rules, with the lawful base and actual applicability confirmed separately. Paid days 21.75 × 8 = 174 hours is distinct from institutional workdays 20.67; it is not a universal salary denominator. Reference factors are 150% for extended work, 200% for rest-day work without compliant compensatory leave, and 300% for statutory holidays. Rest-day leave records time separately when its cash reference is zero; it does not waive a statutory-holiday reference. Comprehensive/irregular-hours arrangements, disputed facts, local base disputes and actual settlement are not automatically determined. The application's bundled source review remains pending; a user's local confirmation is not a government or project-wide approval.

End corrections retain the previous end instants, UTC update time and the explicit `end-time-correction` reason, up to 32 corrections per record. The ledger retains its 2,000-record bound without automatic deletion.

### Copy-on-write storage and backups

`RecoverableSettingsRepository` writes `profile.v2` while retaining the original `profile.v1` and its byte-identical original copy. Overtime similarly writes a sealed `overtime.v2` and retains `overtime.v1`. Migration is idempotent and never silently substitutes an empty profile/ledger. Profile migration write failure exposes a pending read-only state; overtime read/migration failure blocks edits. Previous committed values are saved before replacement. Legacy digests detect edits by an older application and require explicit recovery. Revisions/digests reject stale writers. An origin-scoped Web Lock serializes supported secure-context browsers; unavailable Web Locks fail closed. Native operations share an in-process serial queue. These adapters are preferences storage, not a database or a guarantee of power-loss durability or multi-process native transactions.

Canonical JSON and SHA-256 detect accidental corruption. They do not encrypt salary, authenticate an untrusted backup or replace trusted HTTPS/source review. Documents are bounded at 4 MiB. The backup page exports plaintext JSON for explicit copying and later import; it does not upload data or claim automatic file/cloud backup. Imports validate schema, exact values, provenance and checksums, show rule/record counts and reject changes since preview. A write-ahead journal restores all original financial keys before repositories resume after an interrupted import. The full pre-import state is retained separately for explicit restoration. Recovery keeps damaged/current copies; no automatic record pruning occurs. User-confirmed finance clearing removes retained financial recovery copies while preserving language/appearance. Device/browser storage can still be erased externally; keep a private backup.

### Policy/calendar data

`config/policy/cn-2026.json` is the public source and its byte-identical application asset is the offline baseline. It records schema, version/revision, region, document number, official URL, original publication date, effective interval, checked time and review state. It derives work/rest arrangements from [State Council notice 2025 No. 7](https://www.beijing.gov.cn/cs/gncs/zcwj/202603/t20260327_4568275.html), dated 2025-11-04. The bundle is **pending human verification**. Extended holiday breaks are not all statutory holidays; unverified legal classifications remain unknown. The UI separates source classification, weekly schedule and personal override. Applying the candidate requires an explicit source-check declaration, dated schedule change preview and confirmation, and remains a personal simulation assumption.

No policy request occurs at startup. An explicit online check fetches only the project's fixed HTTPS GitHub endpoint, with timeout, size, checksum/schema/provenance and monotonic revision checks. Same-version content changes are rejected. Native redirects are disabled; Web rejects a changed final URL. Network/validation failure leaves the prior cache; a retained previous cache can be restored offline. New data never automatically rewrites a salary rule or the user's schedule. Source review is pending versus human-reviewed with review metadata; no approval is fabricated. The release hosting repository's HTTPS ownership is the transport trust boundary; checksums alone are not signatures. This upgrade does not ship a signing-key infrastructure or an auto-approved official calendar.

### Presentation and boundaries

The home page presents one primary simulated amount, with secondary totals folded into details, a calculation explanation and an independent overtime action. Configuration remains category pages and short onboarding. History, month calendar/source review, appearance, and backup/recovery are separate pages. Light/dark/system appearance and language are independent preferences. Session-wide display privacy covers dashboard/history/calculation/overtime financial values; it does not block system screenshots, hide deliberate salary editing, or encrypt storage. New copy is in zh/en/ja ARB and bundled SC/JP font subsets; original OFL and engine notices are retained.

P2 tax/social-insurance/payroll, desktop platform generation, widgets and cross-device accounts remain outside this upgrade. Native compilation/static package checks and Web/widget validation do not establish phone installation, screen-reader behavior, process memory or battery results. See the stage report for actual measured checks.

## 中文

本文描述 P0/P1 升级实现。早期 MVP 验证报告保留其原版本语境，不作为当前功能清单；基线及阶段证据见[审计报告](../audit/2026-11-paybysecond-audit.md)。Web 与 Android 共用 Flutter 应用及纯 Dart `earnings_core`，未新增后端或独立 Web 业务。

### 历史规则与精确金额

档案 schema v2 分别保存不可变薪资、排班版本，包含民用生效日、稳定 ID、UTC 创建/更新时间、修订号以及同日修正归档。首条规则只是用户配置的初始假设，不冒充真实历史工资单。各列表限 1–128 条，替换归档限 512 条；达到容量时明确失败，不自动删记录。提前入职日须预览确认后才延伸初始假设。

查询按薪资、排班及月/年边界切分。每片使用其规则对应的完整周期分母：月预算或十二个月预算 × 相交有效毫秒数 ÷ 完整周期有效毫秒数，不将整月工资压缩到剩余入职时间。不同规则合计可能不同于单一固定预算。内部使用 `BigInt` 有理数，与刷新次数无关；仅显示时按远离零的半值舍入到 2/4/6 位。计算依据页列出规则 ID、区间、时间分子分母、最小币种单位精确分数及日历版本。这些是模拟值，不是工资结算、银行入账或法定权益认定。

工作时区固定 UTC+08:00，不受语言和设备时区影响。旧排班保留日历日归属；可选班次起始日归属将开始日工作规则延续到跨午夜部分，覆盖周末及跨年。最多 16 个工作时段、16 个休息时段，编译后合并重叠且不重复计时，原固定午休可选。核心最多缓存四组规则组合，每组最多三年。界面不可见或进入明细时停止唯一刷新计时器，返回后按当前时间重算。

### 加班参考

旧快照标记 `legacy-unverified`，保留历史算法并明确显示。新快照包含 `cn.standard-hours.2025-01.v1`、独立加班月基数、所选工资模式与日期分类、本地核验时间、标准工时及单位安排确认。条件未确认或超出已确认民用日期时，法规参考工时保持待核验，不将某一天分类套用到跨日部分。已知现金小计、待核验工时、补休工时分开显示。无薪模式可幽默显示一倍时间价值，明确不是扣款。

条件参考依据[劳动法第四十四条](https://www.samr.gov.cn/zw/zfxxgk/fdzdgknr/bgt/art/2023/art_d9aa750028b14b99a776cb93726a360d.html)的 2018-12-29 修正文本及[人社部发〔2025〕2号](https://www.mohrss.gov.cn/SYrlzyhshbzb/laodongguanxi_/zcwj/202501/t20250101_533693.html)，后者自 2025-01-01 生效。仅针对中国大陆劳动关系、标准八小时工时制度，法定基数及具体适用须另行确认。计薪天数 21.75 × 8 = 174 小时与制度工日 20.67 不同，不是通用薪资分母。延长工时参考 150%，休息日不能安排合规补休参考 200%，法定节假日参考 300%；休息日补休现金参考为零时仍记录对应工时，不据此免除法定节假日参考。综合/不定时工时、争议事实、地方工资基数及真实结算不自动判定。内置来源仍为待人工核验，用户本地确认不是政府或项目整体批准。

结束时间修正保留原结束时刻、UTC 更新时间和明确的 `end-time-correction` 原因，每条最多 32 次。账本最多 2,000 条，不自动删除。

### 写时复制与备份

档案仓储写入 `profile.v2`，保留原 `profile.v1` 及其逐字节一致副本；加班写入带校验的 `overtime.v2` 并保留 `overtime.v1`。迁移幂等，读取失败不退回空数据。档案迁移写入失败显示待迁移只读状态；加班读取/迁移失败禁止编辑。替换前保留上次有效值；旧版摘要检测旧应用改写，须显式恢复。修订号和摘要拒绝过期写入。安全上下文 Web 浏览器使用同源 Web Lock，不支持时关闭写入；原生操作共享进程内串行队列。仍是偏好存储，不宣称数据库事务、断电级耐久或原生多进程事务。

规范 JSON 与 SHA-256 只检测意外损坏，不加密薪资、不认证不可信备份，也不替代 HTTPS 和来源核验。文档限 4 MiB。备份页导出明文 JSON 供用户主动复制、导入，不上传数据，也不宣称自动文件或云备份。导入校验结构、精确值、来源及摘要，预览规则/记录数量，并拒绝预览后的数据变更。预写日志保证中断导入后先恢复全部原始财务键，再允许仓储读取；另保留整份导入前状态供显式恢复。恢复保留损坏/当前副本，不自动删历史。用户确认清空财务时同时清理财务恢复副本，保留语言和外观。设备或浏览器仍可能从外部清除存储，请另存私有备份。

### 政策与日历

公开来源为 `config/policy/cn-2026.json`，应用内逐字节一致的资源提供离线基线。字段包括结构、版本/修订号、地区、文号、官方 URL、原始发布日期、生效区间、核对时间及核验状态。工作安排来自 2025-11-04 的[国办发明电〔2025〕7号](https://www.beijing.gov.cn/cs/gncs/zcwj/202603/t20260327_4568275.html)。内置数据**待人工核验**，长假不全部等于法定节日，未核实的法定分类保持未知。界面区分来源分类、周排班、个人覆盖。应用候选数据须用户声明核对来源，选择生效日并预览确认，仍作为个人模拟假设。

启动不联网请求政策；用户主动联网检查仅获取本项目固定 HTTPS GitHub 地址，检查超时、大小、摘要、结构、来源及递增修订号；拒绝同版本内容变化。原生禁止重定向，Web 拒绝最终地址改变。网络或校验失败保留旧缓存，可离线恢复上个缓存；新数据不自动改写薪资或排班。待核验与含核验元数据的人工已核验严格区分，不伪造批准。传输信任边界是发布仓库的 HTTPS 控制权，摘要不是签名；本次不提供签名密钥体系或自动获批的官方日历。

### 界面与边界

首页突出单一模拟金额，次级合计折叠到明细，提供计算依据和独立加班操作。继续使用分类配置页与短首次引导，历史、月日历/来源、外观、备份恢复分别成页。浅色/深色/跟随系统与语言独立保存。会话级金额隐私覆盖首页、历史、计算及加班明细，不阻止系统截图、不隐藏主动薪资编辑、不加密存储。新文案均在 zh/en/ja ARB，重建本地中日文字体且保留 OFL 及引擎声明。

P2 税费、社保、工资结算、桌面平台工程、小组件与跨端账号不在本次范围。原生编译/包静态检查及 Web/组件验证不能证明手机安装、读屏、进程内存或电量结果；实际实测范围见阶段报告。
