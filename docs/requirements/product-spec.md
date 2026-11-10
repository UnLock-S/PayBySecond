# Product requirements / PayBySecond 需求与架构草案

## English

Implementation update: the earlier MVP single-rule/storage/overnight boundaries below are superseded for the P0/P1 upgrade by [versioned calculation and recoverable data](../design/versioned-calculation-and-data.md). Requirements and target architecture below remain plans where not explicitly implemented there. Historical test reports retain their original revision scope.

Version 0.1, 2026-11-09. This is the original target design, not an implementation or performance certificate. Later MVP boundaries are defined in ADR-002 and feature design documents. [ADR-001](../architecture/decisions/0001-web-first-flutter.md) supersedes the development order with Web first; APK remains the main delivery target. See [software architecture](../architecture/software-architecture.md) for project boundaries.

### 1. Product scope

A personal live income estimator targeting Android, with Web, Windows, Linux and macOS in the platform plan. Users provide salary, employment date, a fixed work time zone, weekly workdays and daily intervals. Accrued income is an estimate, not a bank payment, attendance record or employer payroll settlement. A proposed gross/net label does not calculate taxes.

### 2. System requirements

| ID | Requirement | Acceptance criteria |
|---|---|---|
| SYS-001 | Register, sign in/out, delete account; offline local calculation after authentication | Existing local settings work after an offline restart; explicit sync status |
| SYS-002 | Monthly salary, employment date and work schedule | Finite nonnegative salary, including zero for unpaid periods; reject invalid input |
| SYS-003 | Weekly workdays, multiple intervals, lunch and overnight shifts | 08:00–12:00 plus 13:00–17:00 totals eight hours; split 22:00–06:00 correctly |
| SYS-004 | All-calendar-time and work-interval accrual | Explain policy and estimated differences before switching; no silent historical changes |
| SYS-005 | Weekends, statutory days off, make-up work and personal overrides | Make-up Sunday can accrue; Wednesday off can stop accrual |
| SYS-006 | Year/month/week/day/hour and employment totals; selectable main amount | Calendar periods; weeks begin Monday; pre-employment income is zero |
| SYS-007 | Minute/second rates and current-minute/second totals | Distinguish currency/second from an amount earned in the current second |
| SYS-008 | One-second foreground refresh, optional 100 ms | Delayed callbacks, backgrounding and termination do not lose accrual; no hard real-time promise |
| SYS-009 | Effective-dated salary/schedule changes | New salary does not overwrite old periods; explicit retroactive recalculation |
| SYS-010 | Persist settings/preferences | Restore on restart; keep draft and report save failures |
| SYS-011 | Hide amounts and clear local data | Hidden amounts absent from home/logs; explicit clear confirmation |
| SYS-012 | No dependence on background execution or sensitive permissions | Cancel background refresh; evaluate current time on resume |

The original recommendation covered SYS-002–012. Mandatory SYS-001 requires a real authentication backend. A local nickname/PIN must not masquerade as an online account. The MVP defers several target requirements; this table is not a pass report.

### 3. Calculation policy

#### 3.1 Independent dimensions

Separate which time accrues from how salary is distributed:

- Calendar time accrues throughout all 24 hours, including weekends/holidays, without an 08:00–17:00 limit. This captures 365/366-day averaging.
- Work time accrues only within valid scheduled intervals, excluding breaks and configured nonworking dates.
- Annual distribution, the original recommended default: salary M produces budget 12M distributed over the complete year's eligible time. A complete month need not equal M.
- Monthly distribution: each complete month has budget M; per-second rates can differ between months.

Use an explicit “accrue during rest time too” label and a 24-hour/work-interval explanation. Keep annual/monthly distribution separate. One switch must not conflate statutory paid leave, eligible time and the salary budget.

#### 3.2 Common formula

Split at salary-version, schedule-version and calendar-year/month boundaries:

```text
segment amount = B(P) × V(segment ∩ query ∩ employment) / V(P)
total amount = sum of segment amounts
```

P is the complete containing year/month; B(P)=12M annually or M monthly. V measures eligible time: equal civil-day weights with within-day fractions in calendar mode, actual valid interval duration in work mode.

Each civil day has equal weight; within-day progress uses its actual length. Common/leap years have 365/366 units even when a daylight-saving day is not 24 hours. An MVP without daylight saving must state that restriction and not mix elapsed seconds with civil-day counts.

A midyear salary change affects only its new segment, using 12 × new salary and the complete-year denominator; old segments retain old salary. Employment clips the numerator, not the denominator: joining near year-end must not earn a full year's salary in the remaining days. Employment end dates are a future extension.

In work mode, use the segment's salary/schedule template over the full reference period as denominator. Midyear schedule changes can move the annual sum away from 12M; explain this. Strict remaining-budget conservation needs a separate redistribution policy and is not automatic in the MVP.

If V(P)=0, return zero amount/rate with a no-eligible-work-time state. Use half-open [start,end) intervals, merge overlaps, and split overnight shifts before applying actual-date rules to avoid duplicate boundary accrual.

#### 3.3 Examples and precision

For monthly salary 10000 and annual calendar distribution in a common year:

```text
daily = 120000 / 365 ≈ 328.767123 yuan
per second on a 24-hour day ≈ 0.003805175 yuan
complete 31-day month ≈ 10191.780822 yuan
```

For an illustrative 250-workday year with eight-hour days:

```text
per second = 120000 / (250 × 8 × 3600) ≈ 0.016666667 yuan
```

250 days is an example, not an official calendar. Two decimals can make one-second progress invisible; support 2/4/6 decimals, default four, and six for rates. A 100 ms refresh does not mean one cent per tick.

Store salary as integer minor units. Use exact fractions/high-precision decimals, aggregate before display rounding, and never accumulate/round a double per tick. Web/native share precision rules; serialize large integers as decimal strings.

#### 3.4 Calendar rules

Priority: personal override > confirmed regional holiday/make-up calendar > weekly template. A manually added workday inherits a daily template; require one if absent instead of inventing duration.

Calendar data needs region, year, revision, source and coverage. Mainland China needs actual holiday/make-up dates, not a weekend guess. Sourced packages and manual corrections are targets; the MVP currently has manual overrides only. Missing historical coverage must show weekly-template estimation and require the chosen fallback. Never invent future statutory arrangements.

Calendar mode is independent of holiday coverage. Calendar updates can change history; show affected periods, apply explicitly and retain old versions in the target design. Lock work zone so travel/device-zone changes do not silently move boundaries.

### 4. Pages and interaction

1. Accounts: proposed email/password; no phone, contacts or device identifiers. Real accounts remain future scope.
2. Setup: salary/gross-net label, currency, employment date, work zone, weekdays, intervals and mode; defaults require confirmation.
3. Dashboard: amount, period, accruing/rest/not-employed state, rate and proposed next boundary; secondary totals.
4. Settings: salary history, schedule, calendar, refresh, precision, visibility, account/local data.

Default period is today-to-now and overall total is since employment. Week/month/year are calendar periods; hour means the current clock hour. A rolling last-60-minutes metric needs another label. Minute/second totals belong in details so frequent resets do not distract on home. Current multipage/language/input/overtime designs refine this proposal.

### 5. Framework

Use one Flutter/Dart client; check target support/minimum versions against the pinned SDK and tests. Share logic/UI and isolate storage, lifecycle and credential adapters. Flutter has engine overhead and is not claimed smaller than native Android. Kotlin-native is an alternative when APK-specific size/memory outweigh shared UI, at the cost of separate Web/desktop implementations. This is a tradeoff, not a performance measurement.

Avoid game engines, Electron, complex charts, continuous animation, ads and analytics. Start with ValueNotifier/ChangeNotifier; add libraries only for demonstrated complexity. Small configuration does not require a database up front.

### 6. Layers and modules

```text
Presentation → Application → Domain
                    ↑          ↑
              Infrastructure adapters
```

| Layer | Responsibilities |
|---|---|
| Domain | Pure Dart SalaryPolicy, Schedule, Calendar, Money, Interval, EarningsEngine; no Flutter/network/database/system clock |
| Application | Configuration, queries, versions, lifecycle; external access through Clock/Repository ports |
| Infrastructure | Storage, time/zone, auth HTTP, credentials, calendars; no plugin types leaking into domain |
| Presentation | Pages and small numeric updates; consume snapshots, never duplicate salary formulas |

Proposed modules: earnings/profile/calendar/auth/settings/storage/platform. Maintain one money implementation; the backend does not calculate each second.

Conceptual API: calculate(queryInterval, now, policyVersions, calendarSnapshot) → EarningsSnapshot with amount, rate, next boundary, policy and coverage. Identical inputs produce identical outputs; inject clocks for tests.

Target entities: SalaryVersion(id,effectiveDate,monthlyMinorUnits,currency,payLabel,basis,accrualMode); ScheduleVersion(id,effectiveDate,timeZone,weekTemplate,breaks); CalendarSnapshot(region,year,revision,source,exceptions); Profile(startDate); DisplaySettings(period,precision,refreshMs). Initial effective dates are local midnight, not arbitrary instants.

Persist configuration/versions/calendars rather than per-second records. Caches are rebuildable, bounded and version-keyed. Target persistence includes schemaVersion, atomic replacement/failure recovery and native private-file/Web IndexedDB adapters; the MVP's single JSON preference is a documented simplification.

### 7. Time, refresh and memory

Display earnings(now), never amount += rate × tickCount. Reopening days later needs no replay. Use one visible foreground refresh source: 1000 ms normally, optional 100 ms. Stop high-frequency work during rest; use boundary scheduling/low-frequency checks. Cancel on backgrounding, covered routes and hidden Web tabs, and evaluate immediately on resume.

Wall time determines calendar position. The target may use monotonic interpolation with recalibration; the MVP does not. Re-evaluate on jumps/date changes/resume. Manual time changes can increase/decrease estimates; offline time is not tamper-proof.

Parse/compile once; use yearly intervals/prefix sums and boundary searches rather than a full-history scan every 100 ms. Bound compiled calendars, originally suggested as three-year LRU; aggregate/release long-history intermediates and invalidate affected years.

Rebuild numeric widgets only; avoid whole-page setState, repeated JSON/formatters/lists and unbounded snapshots/logs/chart points. Dispose timers/streams/listeners. Start single-threaded; add compatible chunking/workers only after measured UI blocking.

### 8. Accounts, privacy and permissions

Real cross-device accounts need HTTPS authentication, users and sessions. Salary stays local; sync is opt-in. Choose hosted/self-hosted auth, region and cost at implementation time. Servers own hashing, throttling, revocation, recovery and deletion; no plaintext client passwords. Native sessions use secure credentials; Web should prefer HttpOnly/Secure/SameSite cookies and CSRF protection. Expiry blocks online features, not local estimates.

Online APKs need ordinary INTERNET permission without a runtime prompt; fully offline variants may omit it. No location/contacts/camera/microphone/broad storage/notifications/overlays/exact alarms/boot/foreground service/battery exemption. No wake locks or forced always-on display. Use app-private storage; future import/export uses a user-invoked system picker.

Never log salary/passwords/tokens; audit merged manifests and implicit permissions. Browser storage is not backup. Disable native cloud backup by default; sandboxing is not encryption. Encryption needs a defined threat model.

### 9. Resource budgets

Proposals only; measure an agreed real Android device, Release build, fixed brightness/mode. Debug emulators do not qualify.

| Item | Proposed criterion |
|---|---|
| Query | Compiled-calendar p95 < 2 ms; measure 1 s/100 ms separately |
| Interaction | No sustained dropped frames; record initial long-history compilation |
| Cold start | Target < 2 s to usable home; report auth wait separately |
| Memory | RSS/PSS/Dart-heap baseline; no ongoing retained-object/heap growth after 30 min and 100 route round trips |
| Background | Zero app-created refresh tasks/calculation network calls; no zero-process-memory promise |
| Size/energy | Report per-ABI Release size; compare 1 s/100 ms with a static control, without invented thresholds |

Use Flutter DevTools/Android tools. Screen/rendering use energy too. Fast refresh is optional; cancelling background work is the main constraint.

### 10. Acceptance cases

- Complete common/leap years conserve 12M annually; each full monthly-distribution month conserves M.
- A fixed yearly work template totals 12M, with no rest-period increase.
- Mid/future employment, calendar boundaries, lunch and overnight intervals do not double-count.
- Make-up Sundays work, holiday weekdays stop, personal overrides win, missing calendars warn.
- Version changes split correctly, including zero denominators.
- Ten minutes of display equals direct evaluation; 100 ms/1 s agree at the same instant.
- Backgrounding/termination/restart/offline/expired-auth do not replay or lose ticks.
- Define clock-jump, work-zone and repeated/nonexistent daylight-saving instant policies; reject nonexistent schedule instants, disclose earlier-offset handling for repeated ones.
- Preserve 2/4/6 decimals, large amounts and Web serialization; explain item-rounding differences.
- Failed save/corruption/migration never silently erase data; failed registration is not simulated success.
- No sensitive permissions, background refresh or leaked listeners.

### 11. Stages/open decisions

Originally: freeze calculations/tests; Android local UI/storage/lifecycle and resource measurement; then real auth/sync and further platforms. ADR-001 changes this to Web first. Mandatory authentication remains a formal-release gate. Native builds need supported hosts; macOS needs a Mac.

Original choices included local use, annual/monthly conservation, all-day accrual, calendar region/years and gross/net labels. Proposed defaults were APK delivery, annual all-day accrual, CNY, mainland calendar and gross label. Only implemented settings may be described as adjustable; the MVP fixes CNY/UTC+08:00 and lacks official calendars/tax calculation.

### 12. Official references

- https://docs.flutter.dev/reference/supported-platforms
- https://docs.flutter.dev/platform-integration
- https://docs.flutter.dev/perf/best-practices
- https://developer.android.com/guide/components/activities/process-lifecycle

Platform support is documented officially; framework choice, layers and budgets are project judgments, not official guarantees.

## 中文

实现更新：下文早期 MVP 的单规则、存储及跨夜边界已由 P0/P1 [版本化计算与可恢复数据设计](../design/versioned-calculation-and-data.md)更新；未在其中明确实现的需求和目标架构仍属于计划。历史验证报告保留其原版本范围。

版本：0.1，2026-11-09。性质：开发前设计建议；推荐默认值尚未由用户逐项确认；未进行性能实测或实现。

实施顺序更新：用户随后确定先做 Web 验证，再推进 Android 等平台。本文中的 APK 优先表示主要交付目标；开发阶段顺序以 [ADR-001](../architecture/decisions/0001-web-first-flutter.md) 为准。工程目录和模块边界见 [软件架构](../architecture/software-architecture.md)。

### 1. 产品范围

面向个人的工资实时估算工具，Android APK 优先，预留 Windows、Linux、macOS 和 Web。用户输入薪资、入职日期、固定工作时区、周工作安排和每日工作时段，即可看到随时间变化的预计收入。

金额是按用户配置估算的应计收入，不等同于实际到账、考勤记录或企业工资结算。工资允许选择税前/税后标签，不自动计算税费。

### 2. 系统需求

| ID | 需求 | 验收要点 |
|---|---|---|
| SYS-001 | 支持注册、登录、退出及账号删除；首次认证后本地计算可离线运行 | 断网重启仍能使用已有本地配置；明确显示同步状态 |
| SYS-002 | 输入月薪、入职日期和工作时间 | 月薪必须为有限、非负金额；输入零用于无薪阶段；错误输入不能保存 |
| SYS-003 | 支持每周工作日、多个每日时段、午休和跨午夜班次 | 08:00–12:00、13:00–17:00只计8小时；22:00–次日06:00正确分段 |
| SYS-004 | 提供全部自然时间均摊和仅工作时段累计两种模式 | 模式切换前显示计算说明和预估差异，不能静默改变历史口径 |
| SYS-005 | 支持周末、法定放假、调休补班、自定义日期例外 | 补班星期日可以累计；放假星期三可停止累计 |
| SYS-006 | 显示当前年/月/周/日/小时累计及入职以来累计，支持选主金额 | 按自然周期统计，周默认周一开始；入职前为0 |
| SYS-007 | 显示每分钟、每秒速率，并可查看当前分钟/秒累计 | 所有指标明确区分“元/秒”等速率和“本秒已赚”等累计 |
| SYS-008 | 活跃前台默认每秒更新，支持100ms模式 | 延迟回调、切后台和杀进程后不丢失应计金额；调度不承诺硬实时 |
| SYS-009 | 支持带生效日期的薪资和排班变更 | 新薪资不自动覆盖旧期间；允许显式追溯修正并重算 |
| SYS-010 | 保存用户配置和显示偏好 | 正常重启恢复；保存失败提示并保留编辑内容 |
| SYS-011 | 提供薪资隐藏、一键清空本地数据 | 隐藏时不在首页或日志暴露金额；清空需明确确认 |
| SYS-012 | 计算不依赖后台运行或敏感系统权限 | 进入后台停止刷新任务；回到前台按时间重新求值 |

建议首版完整支持SYS-002至012；SYS-001若首版必须上线，需同时实现最小认证后端。可以增设“本机使用”入口，但不能将本地昵称或PIN冒充互联网注册账号。

### 3. 计算口径

#### 3.1 两个独立维度

“哪些时间计薪”与“薪资如何均摊”需要分开。否则“固定月薪”和“全年平均”容易出现相互矛盾的月度结果。

时间范围：

- 全部自然时间：每天24小时累计，包括周末和节假日，不使用08:00–17:00限制。对应用户提出的365/366天均摊意图。
- 仅工作时段：只在排班的有效工作区间累计，扣除休息和配置的非工作日。

工资基准：

- 按年均摊（推荐默认，贴合原始描述）：固定月薪M对应年预算12M；按该年的自然时间或有效工作时长均摊。完整月份的结果可能不等于M。
- 按月均摊（备选）：每个完整月的预算为M，按该月自然时间或有效工作时长均摊。不同月份每秒速率可能变化。

界面建议将“计算节假日”改为“休息时间也累计”，下方写明“全年每天24小时均摊”或“只在设置的工作时间累计”。高级设置提供年均摊/月均摊。不能用一个开关同时表示法定带薪休假、时间范围和工资预算。

#### 3.2 统一公式

将统计区间按工资版本、日历年/月和排班版本边界切片。每段j：

    段金额 = B(P) × V(段与统计区间及在职区间的交集) / V(P)
    总金额 = 所有段金额之和

P是该段所在完整日历年或月；年预算B(P)=12M，月预算B(P)=M。V是计薪时间函数：自然时间模式采用固定工作时区内的民用日历天数及日内比例；工作时间模式采用有效工作区间的实际持续时间。

自然时间采用每个民用日相同权重，日内按该日实际长度计算比例，从而完整平年为365单位、闰年为366单位。夏令时日可以不是24小时；不支持夏令时的初版也必须明确限制，不能混用秒差和日历天数。

薪资年中变化时，不把新月薪重算到全年；新段使用12×新月薪及其所在完整年的分母，旧段用旧月薪。入职只裁剪分子，不能缩小全年分母让剩余几天赚满一年工资。离职日期可作为未来扩展的在职终点。

工作模式下，分母为该薪资/排班版本在完整基准周期内的计划工作时长；此版本是用于求该段速率的假定模板。年中调整排班可能使全年结果偏离12M，界面须说明；若要求固定预算严格守恒，需要另行设计剩余预算重分配规则，首版不自动补差。

当V(P)=0时金额和速率返回0，并显示“当前周期无有效工作时间”，禁止除零。工作时段使用半开区间[start,end)，重复区间合并，跨午夜先拆分，避免边界重复计薪。跨日班次默认按每个实际日期应用放假/补班规则。

#### 3.3 数字示例与显示精度

固定月薪10000元，平年自然时间年均摊：

    每日 = 120000 / 365 ≈ 328.767123元
    普通24小时日每秒 ≈ 0.003805175元
    完整31天月 ≈ 10191.780822元

假设全年有效工作日250天、每天8小时，工作时段年均摊：

    每秒 = 120000 / (250 × 8 × 3600) ≈ 0.016666667元

250天只是算例，不代表任一年度官方日历。金额两位小数时每秒可能看起来不变化；提供2/4/6位显示选项，默认4位，速率可显示6位。100ms刷新不意味着每100ms都增加一分钱。

月薪以整数分保存。计算采用精确分数/高精度十进制策略，累加后只在展示边界舍入；不逐tick舍入或累加double。Web和原生端使用同一精度规则；大整数通过十进制字符串序列化。

#### 3.4 日历规则

日期例外优先级：个人显式覆盖 > 已确认地区日历中的放假/补班 > 每周常规排班。手动指定补班但无时段时继承默认工作日模板；无法继承则要求填写，不能凭空生成时长。

日历必须携带地区、年份、版本、来源和覆盖范围。中国大陆模板需要实际放假和调休补班表，不能仅判断周六/周日。首版内置有来源的日历包并支持手工修正；历史年份缺失时显示“仅按周排班估算”，经用户选择后使用该回退；未知未来年份不伪造法定安排。

自然时间模式不受日历包缺失影响。日历更新或历史修正会改变结果，应展示影响区间、由用户明确应用并保留旧版本。锁定工作时区，不因旅行或设备时区变化静默改历史边界。

### 4. 页面与交互

1. 登录/注册：建议邮箱和密码；不获取手机号、通讯录或设备标识。可选本机模式待确认。
2. 首次配置：月薪和税前/税后标签、币种、入职日期、工作时区、周排班、每日时段、累计模式；默认配置只是待确认的预填值。
3. 主面板：主累计金额、统计范围选择、计薪/休息/未入职状态、每秒速率、下个工作边界；次级卡片显示年/月/日累计。
4. 设置：薪资历史、排班、地区日历、刷新周期、显示精度、金额隐藏、账号与本地数据管理。

统计范围默认“本日截至当前”，总累计默认“入职以来”。周/月/年都是自然周期；小时是当前自然小时，另设“最近60分钟”必须使用不同文案。分钟和秒的周期累计放在详情，不让每秒归零的指标干扰首页。

### 5. 框架选择

推荐Flutter + Dart统一客户端，APK先落地。Flutter官方覆盖Android、Windows、macOS、Linux、Web；平台最低版本以实施时官方支持表和实测确定。共享业务逻辑和绝大多数UI，平台差异隔离于存储、生命周期、安全凭证适配器。

Flutter有引擎基础开销，不承诺比原生Android更小。若APK大小和内存的最高优先级超过多平台共用UI，可选Kotlin原生Android并将计算规范独立实现；这会增加其余平台UI与一致性维护成本。当前推荐Flutter是对所列平台和维护成本的综合判断，并非已测性能结论。

不引入游戏引擎、Electron外壳、复杂图表、持续动画、广告或分析SDK。初版状态管理用Flutter内置ValueNotifier/ChangeNotifier即可，是否增加第三方状态库由实际复杂度决定。缓存的数据量很小，不需要将数据库设为前置依赖。

### 6. 分层与模块

    Presentation → Application → Domain
                         ↑         ↑
                   Infrastructure adapters

| 层 | 职责与约束 |
|---|---|
| Domain | 纯Dart计算；SalaryPolicy、Schedule、Calendar、Money、Interval、EarningsEngine；禁止依赖Flutter、网络、数据库或真实系统时钟 |
| Application | 配置用例、查询、版本切换、生命周期协调；通过Clock、Repository接口接入外部能力 |
| Infrastructure | 本地存储、时间与时区、账号HTTP、安全凭证、日历包；实现接口，不向领域层泄漏插件类型 |
| Presentation | 页面和小范围数字刷新；只消费计算快照和状态，不自行计算工资 |

建议模块：earnings、profile、calendar、auth、settings、storage、platform。金额规则只能有一个权威实现；后端不做每秒计算。

核心API概念：calculate(queryInterval, now, policyVersions, calendarSnapshot) -> EarningsSnapshot。输出金额、当前速率、下一变化边界、计算口径、日历完整性提示。相同输入必须得到相同输出，测试时注入固定Clock。

主要实体：SalaryVersion(id, effectiveDate, monthlyMinorUnits, currency, payLabel, basis, accrualMode)、ScheduleVersion(id, effectiveDate, timeZone, weekTemplate, breaks)、CalendarSnapshot(region, year, revision, source, exceptions)、Profile(startDate)、DisplaySettings(period, precision, refreshMs)。生效日首版按本地日期00:00，暂不支持任意时刻变更。

只持久化配置、版本和日历，不保存每秒收入流水。计算缓存按规则版本键管理，用户修改时明确失效；缓存可重建，不作为唯一真值。本地设置/薪资变化一次事务写入，具有schemaVersion、原子替换和失败恢复；原生私有文件存储与Web IndexedDB分别适配。

### 7. 时间、刷新与内存模型

用户看到的金额为earnings(now)，禁止amount += rate × tickCount。进程退出数天后重开，只需用当前时间重算；无须补跑每秒事件。

前台主面板可见时仅保留一个刷新源，默认1000ms，可选100ms。自然时间持续累计；工作模式休息时金额静止，停止高频金额刷新，用单次边界调度加低频时钟校验恢复。切后台、页面离开、Web标签隐藏即取消计时器，恢复时立即校时重算。

系统时间决定日历位置，单调时钟用于活动期间平滑插值并定期校准；发现时间跳变、跨日期或恢复前台时重新求值。手动改时间可能造成金额向前或向后修正，不许用永久递增掩盖错误。离线无法提供防篡改时间保证。

一次解析和编译配置；按年生成有效区间与前缀和，查询用边界查找，禁止每100ms扫描入职以来每一天。缓存采用有界LRU（建议最多3年编译日历）；长历史分年聚合后释放中间区间。完整历史摘要也需限制范围，修改配置按受影响年份失效。

只重建金额组件；避免整页setState、重复解析JSON、频繁创建格式化器和字符串列表。Timer、StreamSubscription、页面监听器必须在所属生命周期结束时释放；不保存无限历史快照、日志或图表点。单线程先实现；仅当测量发现首次长区间构建阻塞UI时引入平台兼容的异步分批/工作线程方案。

### 8. 账号、隐私与权限

真实跨设备账号需要后端。最小方案为HTTPS认证服务、用户表、会话管理；薪资默认只存本机，跨设备配置同步作为显式开关。可采用托管认证，供应商、部署地区和成本实施前再定，避免现阶段锁死SDK。

服务端处理密码哈希、限速、会话撤销、重置密码和删号；客户端不保存明文密码。原生会话存系统安全凭证存储；Web优先服务端HttpOnly/Secure/SameSite cookie并处理CSRF。认证到期不影响本地估算，联网功能再要求登录。

账号版APK只需必要的INTERNET普通权限，不需要弹窗式敏感权限。纯离线版本可不声明INTERNET。禁止定位、通讯录、相机、麦克风、广泛文件权限、通知、悬浮窗、精确闹钟、开机自启、前台服务和电池优化豁免；不持有唤醒锁或强制常亮。通过应用沙箱保存数据；未来导入导出走系统选择器并由用户发起。

不记录薪资、密码或令牌到日志；发布构建检查合并Manifest和依赖隐含权限。Web数据可能被浏览器清理，不能将其描述为永久备份。原生默认不上传薪资到系统云备份；是否提供加密本地数据属于后续明确的威胁模型决策，沙箱本身不等于数据库加密。

### 9. 资源预算与验证

以下为建议验收目标，尚无测量依据；以约定Android基准机、Release构建、固定亮度和刷新模式测量，不能用Debug模拟器结果认定合格。

| 项目 | 初始建议 |
|---|---|
| 数字查询 | 已编译日历下p95 < 2ms；分别测1秒和100ms刷新 |
| 前台交互 | 常规输入与切页无持续掉帧；记录首次长历史构建耗时 |
| 冷启动 | 基准机到可操作首页目标 < 2秒，登录网络等待单独统计 |
| 内存 | 先建立RSS/PSS和Dart堆基线；30分钟运行及100次页面进出后，稳定对象和堆无持续增长 |
| 后台 | App主动创建的刷新任务为0、计算网络请求为0；不能承诺系统进程物理占用为0 |
| 包体和耗电 | 按ABI构建Release APK后报告实际体积；固定场景比较1秒/100ms与静态页对照，不预先承诺虚构阈值 |

测量工具：Flutter DevTools与Android系统性能工具。能耗主要还包括屏幕和渲染，100ms模式由用户主动选择；后台停止刷新是首要设计约束。

### 10. 核心验收用例

- 固定薪资完整平年、闰年：自然模式年均摊分别跨365/366天，精确累计为12M；月均摊每完整月为M。
- 工作模式在固定全年排班下累计全年所有有效时段为12M；休息区间金额不变。
- 入职中途、未来入职、跨年、跨月、跨周、午休及跨午夜不重复累计。
- 调休星期日计薪、法定放假工作日不计薪，个人例外优先；缺少日历必须出现精度提示。
- 薪资和排班生效前后按版本分段；变更分母为0时无异常。
- 运行10分钟与直接求结束时刻一致；100ms与1秒模式相同时间输入得到同一金额。
- 后台30分钟、强杀、重启、离线、认证过期后计算一致；无补tick循环。
- 时钟前后跳变、工作时区锁定、夏令时重复/不存在时刻有明确策略；不存在时刻拒绝排班，重复时刻默认取较早偏移并提示。
- 2/4/6位显示、长历史大金额及Web序列化不丢精度；分项舍入差异有说明。
- 存储失败、损坏恢复、schema升级不会静默清空原始数据；注册失败不伪装成功。
- 发布包无敏感权限申请，后台无应用刷新任务，页面反复进出无监听器泄漏。

### 11. 开发阶段与待决策项

阶段1：冻结计算口径，完成纯Dart计算引擎和关键边界测试。

阶段2：Android本地面板、配置、生命周期和持久化；测Release资源基线。若必须登录才可用，认证是此阶段发布门槛，不以本机模式替代交付。

阶段3：最小真实认证和可选同步；Windows/Web适配验证，再推进Linux/macOS。目标原生平台的打包和签名在相应构建环境完成，macOS需要Mac环境。

待确认但不阻碍设计：是否允许本机免账号使用；默认年均摊还是月薪每月守恒；自然模式是否全天累计；首版日历地区及覆盖年份；税前/税后标签默认值。本文暂定为APK优先、年均摊、自然模式全天累计、人民币、中国大陆日历模板、税前标签，均允许在设置中修改。

### 12. 官方技术依据

- Flutter平台支持：https://docs.flutter.dev/reference/supported-platforms
- Flutter多平台集成：https://docs.flutter.dev/platform-integration
- Flutter性能建议：https://docs.flutter.dev/perf/best-practices
- Android进程生命周期：https://developer.android.com/guide/components/activities/process-lifecycle

平台支持为官方说明；框架推荐、分层设计和资源预算为本项目设计判断，不是官方性能保证。
