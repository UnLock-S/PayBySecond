# Input and overtime / 日期时间输入与加班账本

## English

Implementation update: the earlier MVP single-rule/storage/overnight boundaries below are superseded for the P0/P1 upgrade by [versioned calculation and recoverable data](versioned-calculation-and-data.md). Requirements and target architecture below remain plans where not explicitly implemented there. Historical test reports retain their original revision scope.

2026-11-09, introduced in 0.2.0. Shared Web/Android business implementation.

### Input/navigation

Year-first dates accept 20261109, 2026-11-9, 2026/11/9, 2026.11.9, 2026 11 9 and 2026年11月9日. Do not guess month-first or variable-length compact dates. Validate real calendar dates/leap days, 1970–2100.

24-hour time: 1, 01, 100, 0100 and 1:0 mean 01:00; 805, 8:5, 8：05 and 8时5分 mean 08:05. Reject decimal hours and 24:00. Compare parsed schedule values so 1 versus 01:00 cannot bypass equal-time validation. The core still splits overnight schedules.

Use Flutter's built-in Cupertino wheels beside text fields. Confirmation replaces text; cancellation preserves it. Date overrides and overtime end correction share the component, without a picker dependency. Successful language persistence returns to root home; failure retains language/page. Language never changes currency/zone/legal region/pay rules.

### Pages/actions

- Home's separate card shows cumulative expected/reference pay, current duration and day/pay type. Privacy masking also hides overtime money.
- First start opens rules: unpaid/statutory/1×/custom, day classification, monthly wage base. Save-and-start is one persisted ledger update.
- Later home start/stop are one tap, using visible defaults. Details → rules edits future defaults.
- Details shows total duration/expected/statutory/unpaid-time value and progressively loaded history. Correct forgotten end dates/times at minute precision, rejecting before-start/future/overlapping intervals. Deletion confirms.
- Stop active sessions before correcting their end. New defaults do not rewrite active/history policy snapshots.
- Store at most 2000 closed sessions; block new starts at the cap, never auto-evict. Clearing finance removes salary/overtime but retains language. Two storage keys are cleared sequentially; errors disclose possible partial completion, not false atomicity.

### Money

Overtime is independent and is not added into the normal income total, preventing double counting.

```text
reference hourly rate = entered monthly overtime base / 21.75 / 8
expected pay = hourly rate × actual duration in hours × configured multiplier
```

Unpaid is 0, single is 1, custom is 0.01–100 with two decimal places. Statutory mode uses the mainland China standard-hours reference: weekday extension 1.5×; rest day without compensatory leave 2×; compensated rest-day cash reference 0; statutory holiday 3×, unaffected by the compensatory-leave flag.

The unpaid joke values time at 1× hourly rate. It is neither a payroll deduction nor the statutory-reference amount. Details retains cumulative unpaid-time value. All amounts use core Money BigInt rationals from timestamps, rounded only for display; no floating-point tick accumulation.

Users select day type manually. Weekends, make-up days and statutory holidays differ. Split a session when day classification changes across midnight. No official holiday lookup, contract/overtime qualification, comprehensive/irregular-hours regime or received-wages claim. Japanese UI does not switch to Japanese law.

Official references, checked 2026-11-09:

- [2025 wage conversion notice](https://www.mohrss.gov.cn/SYrlzyhshbzb/laodongguanxi_/zcwj/202501/t20250101_533693.html): 21.75 monthly paid days, eight-hour hourly conversion; supersedes the 2008 notice.
- [Labor Law article 44](https://www.samr.gov.cn/zw/zfxxgk/fdzdgknr/bgt/art/2023/art_d9aa750028b14b99a776cb93726a360d.html): different extension/rest-day/holiday standards.

### Source/resources

| Path | Ownership |
|---|---|
| earnings_core/lib/src/overtime.dart | Exact formulas, policy snapshots, UTC intervals |
| application/overtime.dart | Immutable ledger, overlap/cap validation, persistence coordination, closed-total cache |
| infrastructure/overtime_repository.dart | SharedPreferencesAsync JSON key pay_by_second.overtime.v1 |
| features/overtime/presentation | Card/rules/details/end correction |
| application/date_time_input.dart | Locale-independent parsing |
| shared/presentation/date_time_field.dart | Text/wheel fields and date dialog |

Salary schemaVersion=1/language keys stay unchanged. Persist only start/stop/rule/history edits, never ticks. Restore an active session from current time after reopening; no background service/notification/keepalive.

Home reuses its snapshot timer, including when normal work income is resting but overtime is active. Covered home pauses; details runs one-second updates only while visible/foreground/active, pausing under rules/correction. Cache closed amounts/durations on ledger changes; each tick computes only the active session. History loads 20 records at a time.

The feature adds no dependency/permission. Keep Flutter NOTICES, both OFLs and SC/JP subsets; test new text/wheels on narrow screens. Test-signed Android builds do not establish real-device memory/energy behavior. In 0.2.1 platform source is retained in src and only build copies/artifacts remain ignored.

## 中文

实现更新：下文早期 MVP 的单规则、存储及跨夜边界已由 P0/P1 [版本化计算与可恢复数据设计](versioned-calculation-and-data.md)更新；未在其中明确实现的需求和目标架构仍属于计划。历史验证报告保留其原版本范围。

2026-11-09；0.2.0。本地实现，保留 Web、Android 共用业务代码。

### 输入和导航

日期采用年份在前的格式，支持 `20261109`、`2026-11-9`、`2026/11/9`、`2026.11.9`、`2026 11 9`、`2026年11月9日`。不猜测月日在前的格式或不定长紧凑日期；严格检查闰日和真实日历日期，范围1970至2100年。

时间采用24小时制，`1`、`01`、`100`、`0100`、`1:0` 都是01:00；`805`、`8:5`、`8：05`、`8时5分` 都是08:05。不解释小数小时，不接收24:00。排班开始结束按解析后的数值比较，不能用 `1` 与 `01:00` 绕过相同时间检查。原有跨夜排班仍由计算包拆段。

文本输入旁提供 Flutter 内置 Cupertino 滚轮，确认才替换文本，取消保留输入。休假日期及加班结束时间修正复用同一控件，无第三方选择器依赖。

语言持久化成功后直接返回根首页，失败保留当前页面与原语言。语言不改变币种、时区、法规地区或薪资配置。

### 页面和交互

- 首页新增加班卡片，展示累计约定费用、法定参考、本次时间和当前日期/薪酬类型。金额显隐同时遮罩加班金额。
- 首次开始进入独立加班规则页，选择无薪/法定参考/1倍/自定义倍数、日期性质及月工资基数，保存与开始一次持久化。
- 后续开始/结束都是首页一键操作，沿用所显示的默认规则；可以通过“加班统计 → 加班规则”修改下一次默认值。
- 统计页展示累计时间、约定费用、法定参考、无薪时间价值，以及分页追加的记录列表。结束忘记点击可修正结束日期与时间，精确到分钟；不能早于开始、晚于现在或与其他记录重叠。记录删除须确认。
- 活跃记录需要先结束后修正结束时间。规则变更仅用于新记录；当前和历史记录持有原始基数、倍数、日期类型快照。
- 每台设备最多保存2000条已结束记录，达到上限后阻止新开始，不自动淘汰。语言偏好保留，“清空薪资数据”同时删除加班记录；清理跨两个存储键，失败时提示可能部分完成，不宣称原子清理。

### 金额口径

加班与原来的年/月均摊工资完全独立，不增加首页正常工资，避免重复累计。

参考时薪 = 输入的加班月工资基数 ÷ 21.75 ÷ 8。

约定费用 = 参考时薪 × 实际时长（小时）× 约定倍数。无薪为0，1倍为1，自定义支持0.01至100、最多两位小数。法定参考模式采用下面的参考倍率。

中国大陆标准工时参考倍率：工作日延时1.5；休息日未安排补休2；已安排补休的休息日现金参考为0；法定节假日3，不能通过补休选项清零。

“这波约亏 ¥…，老板快乐 +1”的金额 = 无薪时间 × 参考时薪 × 1，是时间价值的幽默估算，不是实际扣薪，也不是与法定参考金额相同的概念。统计页保留累计无薪时间价值。所有金额使用纯 Dart `Money` 的 BigInt 有理数，从起止时间计算，显示时才舍入；不逐秒累加浮点数。

日期性质由用户手选；周末、调休、法定假日并不互相等价。跨日后日期性质发生变化，应结束并分段记录。当前不自动读取官方节假日、不判断劳动合同或加班认定，不适用于综合计算/不定时工时；金额是参考估算，并非已到账工资。切换日语不会切换成日本劳动法规。

官方依据（核对日期2026-11-09）：

- [人社部2025年工作时间与工资折算通知](https://www.mohrss.gov.cn/SYrlzyhshbzb/laodongguanxi_/zcwj/202501/t20250101_533693.html)：月计薪天数21.75，小时工资按月计薪天数和8小时折算；不要继续引用已废止的2008年通知作为当前依据。
- [《中华人民共和国劳动法》第四十四条](https://www.samr.gov.cn/zw/zfxxgk/fdzdgknr/bgt/art/2023/art_d9aa750028b14b99a776cb93726a360d.html)：延长工时、休息日未补休及法定休假日的不同工资标准。

### 源码和资源

| 位置 | 职责 |
|---|---|
| earnings_core/lib/src/overtime.dart | 精确金额公式、策略快照、UTC时间区间 |
| application/overtime.dart | 不变账本、重叠/数量校验、持久化状态控制、已结束统计缓存 |
| infrastructure/overtime_repository.dart | 官方 SharedPreferencesAsync，单键JSON `pay_by_second.overtime.v1` |
| features/overtime/presentation | 首页卡片、规则、统计、结束时间修正页面 |
| application/date_time_input.dart | 与设备区域无关的日期时间解析 |
| shared/presentation/date_time_field.dart | 文本/滚轮共用字段及日期弹窗 |

原薪资存储 schemaVersion=1 与语言键不变，旧用户无需重建薪资配置。账本在开始、结束、规则更新和记录修改时保存，刷新不写磁盘。活跃记录在重新打开时按当前时间恢复；不使用后台服务或保活。

首页复用现有工资快照计时器，活跃加班时即使正常工资休息也会更新。离开首页暂停该计时器；加班统计页仅在可见、前台且有活跃记录时每秒刷新，打开规则/修正页会暂停。已结束金额与时长在账本变更时缓存，每次刷新只计算当前记录，历史分页每次追加20条。

未增加依赖或系统权限。继续保留 Flutter 第三方 NOTICES、两份 OFL 和本地SC/JP字形；滚轮和新增三语文案纳入字体覆盖及手机布局检查。Android APK 是本机隔离工程构建的测试签名版本，未验证真实手机上的功耗或内存占用。
