# ADR-002: MVP boundaries / ADR-002：首版可运行范围与平台边界

## English

Implementation update: the earlier MVP single-rule/storage/overnight boundaries below are superseded for the P0/P1 upgrade by [versioned calculation and recoverable data](../../design/versioned-calculation-and-data.md). Requirements and target architecture below remain plans where not explicitly implemented there. Historical test reports retain their original revision scope.

Date: 2026-11-09. Implementation decision; the full requirements remain future scope.

### Decision

The first local Web preview covers salary/date, annual/monthly distribution, weekdays, single/overnight shift, optional fixed lunch, date overrides, live totals and local persistence. Label it as a local preview; do not simulate login/registration. The user selected Web-first validation, not deletion of real accounts from future scope.

There is one salary rule set, so edits explicitly recalculate history. Work zone is UTC+08:00, without device-zone switching/daylight-saving configuration. Input is integer minor units; Money uses BigInt rationals and half-up display rounding; serialize money as strings.

Workdays use weekly templates/manual overrides, not official holiday data. Split overnight shifts into actual-date intervals and apply each date's rules.

SharedPreferencesAsync stores one schema-versioned settings JSON behind an adapter. This is not a transaction database/permanent backup and does not promise power-loss durability, migrations or automatic corruption recovery. Failed writes do not publish new settings; failed reads preserve data and request retry/explicit reconfiguration.

### Consequences

Avoid an unselected auth backend/database. Versioned salary/schedule history and sync will require a transactional repository plus migration/recovery tests. Formal account, timezone, history and reliability requirements are not completed by MVP success.

Re-evaluate from wall time rather than tick accumulation; no tamper-proof-clock claim. The MVP has no monotonic interpolation; the next refresh corrects jumps. During work-mode rest, check boundaries at most once per minute. One-second/100 ms cadence applies while accruing. Hidden/background pages cancel timers.

Later overtime/update features are documented separately and do not silently expand these original qualification claims.

## 中文

实现更新：下文早期 MVP 的单规则、存储及跨夜边界已由 P0/P1 [版本化计算与可恢复数据设计](../../design/versioned-calculation-and-data.md)更新；未在其中明确实现的需求和目标架构仍属于计划。历史验证报告保留其原版本范围。

日期：2026-11-09。状态：实施决定，完整需求仍保留后续范围。

### 决策

Web 本机体验版先打通薪资输入、入职日期、年/月均摊、工作周、单段/跨夜排班、可选固定午休、日期例外、实时统计和本地保存。界面明确标注本机体验，不模拟注册或登录。

用户确认的是先跑通 Web 基本功能；真实账号是完整产品的后续范围，不据此将其从需求删除。当前不支持工资历史，配置编辑的保存按钮明确标注“保存并重算历史”。

时区暂时固定 UTC+08:00，不支持随设备时区切换或夏令时地区配置。金额输入整数分，计算采用 BigInt 有理数，显示采用四舍五入；平台序列化金额使用字符串。

工作日先按周模板和手动日期覆盖判断，不声称提供官方节假日日历。跨夜班次拆分为两个实际日期的区间，每段应用该日期的排班/覆盖。

小规模单配置使用 SharedPreferencesAsync 存储一个带 schemaVersion 的 JSON 值，保持跨平台适配封装；不是交易数据库或持久备份。写入失败不切换页面配置，读取失败保留原值并提示重试/显式覆盖；尚不承诺断电级耐久性、迁移或损坏自动恢复。

### 影响

避免为体验版引入未选择的认证后端或数据库。后续加入工资/排班历史和同步时，应迁移到支持事务的版本化 Repository，补充迁移和损坏恢复测试。原需求文档的正式登录、时区扩展、历史版本和数据可靠性验收不因本版通过而视为完成。

刷新以系统当前时间重新求值，不累加tick；不做防改时钟保证。活动期间未增加单调时钟插值，系统时间跳变由下一次刷新校正。工作模式休息时最多每分钟检查一次边界，默认每秒/可选100ms仅用于实际累计期间；隐藏/后台取消计时器。
