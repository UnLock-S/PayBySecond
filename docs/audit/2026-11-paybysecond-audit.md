# Phased upgrade audit / 分阶段升级审计

## English

### Scope and baseline

P0-A, 2026-11-10. Baseline: `213fefb` on main, synchronized with origin with no local changes. Work proceeds on `feat/phased-upgrade-p0-p1`; no main merge, ruleset bypass, release publication or APK upload is authorized. The supplied upgrade plan is the task input; existing findings are rechecked rather than assumed.

Required evidence is separate from actual evidence. Inspection establishes design gaps; a failing executable counterexample establishes a reproduced defect. `confirmed`, `not-reproduced`, `design-gap` and `deferred` describe audit outcomes, not implementation completion. Severity: S1 data integrity/misleading historical result; S2 calculation boundary or significant feature gap; S3 tooling/usability. No payroll/tax certification is claimed.

### Executed baseline

- Standard check: 13 core + 33 app tests passed; formatting, static analysis, fonts and bilingual links passed before new regression probes.
- Core LCOV: 200/218 measured executable lines, 91.74%, across two files. App LCOV: 1670/1916, 87.16%, across 18 instrumented files; generated localization/config excluded. These are line measurements, not branch coverage or all-source coverage. Bootstrap and several concrete platform/preference adapters are absent from the app report, so the percentage does not prove persistence coverage.
- New boundary probes: three failed as expected against baseline, two passed. New home-layout matrix: 24 passed, covering zh/en/ja, 320×640, 390×844, 768×1024 and 640×320, at 100%/200% text.
- Web Release compiled. Initial browser smoke hit a route-transition race (old salary textboxes were still in the accessibility tree); the harness now waits for their removal instead of immediately counting. Browser qualification is recorded only after the rerun completes.
- Android device discovery: zero ready devices. No physical-device run, screen-reader session, installation, energy or memory measurement is claimed.

### Risk matrix

| ID | Severity / outcome | Evidence and existing behavior | Next action |
|---|---|---|---|
| AUD-01 | S2 / design-gap | settings.dart splits overnight spans; engine.dart applies each actual date's weekday/override. `audit_risks_test.dart` proves Friday 22:00 accrues but Saturday 01:00 does not when only Friday is selected. ADR-002 explicitly chose calendar-date attribution: this is not a regression against that baseline. | Add explicit shift-start attribution; preserve calendar-date semantics for migrated data; test Friday/Saturday, Sunday/Monday, year boundaries and breaks. |
| AUD-02 | S1 / design-gap | One Settings snapshot; editor confirms retrospective recalculation. There is no effective-dated salary or schedule history. This is disclosed, not an existing hidden historical-version implementation. | Add immutable dated rules and interval splitting; default changes preserve old periods, with explicit preview for backdating. |
| AUD-03 | S1 / design-gap | dateOverrides is Map<String,bool>. It cannot represent both legal holiday identity and personal work decisions. No official calendar is currently bundled. | Separate holiday classification from scheduled work. Personal overrides must not manufacture a statutory-holiday multiplier. |
| AUD-04 | S2 / design-gap | OvertimePolicy uses exact monthly base/174 and 150/200/300. UI already limits this to mainland standard-hours references and has a separate base. No source/version/applicability metadata is stored. | Add dated policy provenance and explicit applicability; do not relabel legacy snapshots as human-verified. |
| AUD-05 | S2 / design-gap | Compensated rest-day cash reference is zero, while holiday remains 3×; these cases already pass. Overtime is not added to ordinary income. Compensatory time/state and employer-arranged eligibility are not modeled. | Keep cash and time separate; add evidence/applicability warnings and traceable policy snapshots. |
| AUD-06 | S2 / confirmed + not-reproduced | Money's exact half-away-from-zero formatting passes signed/zero/large/6-decimal probes; no floating-point accumulation found. A query ending in February 2101 is accepted despite the documented 2100 upper bound: reproduced failing test. | Validate the complete exclusive end boundary; preserve exact arithmetic and separate display from future settlement rules. |
| AUD-07 | S1 / confirmed + design-gap | Settings.fromJson normalizes 2026-02-30 into March rather than rejecting it. OvertimeEntry constructor accepts pre-1970/post-2100 instants that its JSON reader refuses, so a saved ledger can become unreadable. All reproduced. Storage currently lacks migration/backups; salary/overtime clearing spans separate writes and already discloses partial failure. | Strict dates; symmetric constructor/reader invariants; copy-on-write migration, retained originals, recoverable import and no silent fallback-to-empty. |
| AUD-08 | S2 / not-reproduced | Existing session tests compare cached snapshots with direct calculation through time/date rollback; source evaluates from time and cancels invisible refresh. Work timezone is fixed UTC+08:00, not silently device-derived. | Extend version-boundary and background tests; maintain no-tick-replay behavior. |
| AUD-09 | S2 / not-reproduced | Existing numeric-version, asset/host/ABI, ETag/cache, offline/404/rate-limit and bridge tests pass. Browser download is explicitly unverified by the app; test signing is disclosed. | Preserve the updater boundary; policy-data downloads must have independent consent and integrity checks. |
| AUD-10 | S2 / design-gap | 24 new home layout cases pass; this does not qualify every secondary page. Privacy currently belongs to Dashboard; overtime details can display amounts after navigating from a masked home. No trace/calendar/history/backup workflow, dark theme or physical-device accessibility evidence. | Shared privacy behavior, clear simulation/reference labels, calculation trace, calendar/history/data pages and wider responsive tests. |
| TOOL-01 | S3 / confirmed | browser-smoke.cjs counts fields before the Material route transition finishes. | Await removal of previous-route fields; retain initial failure and rerun evidence. |

Source paths are repository-relative: `src/packages/earnings_core/lib/src/{engine,overtime}.dart`, `src/apps/pay_by_second/lib/application/{settings,income_session,overtime,app_updates}.dart`, `lib/infrastructure/settings_repository.dart`, `lib/features/settings/presentation/configuration_editor.dart`, `lib/features/dashboard/presentation/dashboard.dart`. Executable probes: `src/apps/pay_by_second/test/audit_risks_test.dart` and `audit_layout_test.dart`.

### Architecture and migration decisions

Retain Flutter/Dart and one Web/Android business implementation; do not add a backend or payroll module. The user's explicit feature-branch/PR requirement overrides the repository's default direct-main workflow for this upgrade. P2 remains deferred.

P0-B will first fix the three reproduced boundary defects, then add immutable salary/schedule versions, traceable calculations and selectable overnight attribution. Legacy v1 values must be copied/retained before committing a separate v2 document; reads/writes fail closed, and rollback/import must be explicit and idempotent. Do not reinterpret old overnight schedules or overtime snapshots. A new initial history entry represents the user's previous single-rule estimate, not reconstructed actual historical salary.

Policy evidence is agent-reviewed, not human-approved. Bundled government-source data must retain a pending/human-review distinction, cannot activate silently, and must not turn a long adjusted holiday interval into statutory holidays. Conflicting/unsupported classifications remain unknown. The policy mechanism can be completed without falsely asserting that an authority/human signed the data.

### Official-source register

Checked 2026-11-10; stored source metadata must also include document dates, applicability and version. These sources support reference estimates only, not determination of employment rights.

- [Labor Law article 44, 2018 amended text](https://www.samr.gov.cn/zw/zfxxgk/fdzdgknr/bgt/art/2023/art_d9aa750028b14b99a776cb93726a360d.html).
- [MoHRSS notice 2025 No.2, dated/effective 2025-01-01](https://www.mohrss.gov.cn/SYrlzyhshbzb/laodongguanxi_/zcwj/202501/t20250101_533693.html): distinguishes institutional workday statistics from paid-day wage conversion; prior 2008 notice superseded.
- [State Council Order 795, effective 2025-01-01](https://app.www.gov.cn/govdata/gov/202411/12/521605/article.html): national statutory-holiday categories.
- [2026 arrangement, State Council office 2025 No.7, dated 2025-11-04](https://www.beijing.gov.cn/cs/gncs/zcwj/202603/t20260327_4568275.html): government republication of day-off/make-up arrangements, not a per-day 3× wage classification.

### Stage gates and artifacts

P0-A audit is complete when its measurements, classifications and browser rerun are recorded; it is not a claim that the three new red tests pass. P0-B must make them green and add version/migration/roundtrip/trace/overnight/policy boundary tests. P1 must validate responsive localized UI and policy-cache failure/rollback paths. Native device checks remain a separately reported gap when hardware is absent. P2/tax, widgets and desktop delivery remain deferred.

Machine artifacts are ignored under `out/reports/upgrade-p0-a/`: baseline-check.log, reproductions-red.log, app/core LCOV and coverage-summary.json, layout-baseline.log and browser logs/screenshots. No raw machine paths, finance data or private logs are committed. Each implementation stage appends its actual results below and uses a separate feature-branch commit; no main merge or publication.

### P0-A closeout

Status: PASS for audit completion, not product completion. Browser rerun passed in all three languages at desktop/phone viewports, with zero runtime errors, remote font requests or Web APK checks after fixing the harness transition wait. Original 46 tests and 24 layout cases are green; three new boundary regression tests are intentionally red and move to P0-B. Screenshots are archived separately so P1 cannot overwrite the baseline.

### P0-B boundary slice

The three reproduced regressions are now fixed: persisted employment dates require canonical valid calendar dates; overtime constructors reject dates their reader cannot restore; core queries reject exclusive ends after 2101-01-01. Standard checks pass with 13 core + 62 app tests, including all 24 new layouts and five audit probes. This closes the reproduced boundary defects only; history/migration/policy/UI work continues.

### P0-B and P1 implementation checkpoint

The integrated checker now passes 25 core and 158 application tests, including 72 new page combinations (three locales, six viewports, 100%/200% text, light/dark) and the retained baseline layout matrix. It also passes formatting, fatal-info analysis, font and bilingual documentation checks. New page tests cover history, traces, calendar/policy, backup/recovery and appearance; this is not a physical screen-reader/device test. An initial calendar cell overflow at 320 px/200% was reproduced and corrected with a horizontally scrollable minimum-width grid. A test asset-wait timeout was isolated from product rendering and replaced with an injected fixture loader; the actual bundled asset remains subject to browser verification.

History, independent salary/schedule effective rules, selected overnight attribution, merged work/break intervals and exact calculation traces are implemented. Profile and overtime copy-on-write migration retain v1 originals, detect legacy edits and reject stale writes. Fault injection proves retry, corrupted-value failure, pre-import journal rollback, retained pre-import state and checksum/schema rejection. New overtime estimates retain unknown cross-day time as pending and separate compensatory time. Local user review is recorded, never fabricated as a project/government approval. The new reference date test exposed device-local parsing in the newly added code; normalized UTC civil parsing fixed it before release. Existing legacy snapshots keep their arithmetic.

See [implemented design and limits](../design/versioned-calculation-and-data.md). The bundled 2026 source is pending human verification and not an automatic statutory-holiday classifier. Software release and policy updates are independent. The owner subsequently authorized PR merge and a new release; this replaces the earlier no-merge/no-release scope, without authorizing force push or protection changes. Browser/native package validation and final measured coverage are still pending at this checkpoint; P2 remains deferred.

## 中文

### 范围与基线

P0-A，2026-11-10。基线main提交`213fefb`，与origin同步，启动前工作区干净。升级在`feat/phased-upgrade-p0-p1`进行；不授权合并main、绕过规则、发布Release或上传APK。升级计划作为任务依据，各项风险重新核实，不直接认定文档猜测为缺陷。

区分所需证据与已取得证据：源码审查确认设计缺口，可执行反例确认复现缺陷。状态为confirmed（已确认）、not-reproduced（未复现）、design-gap（设计缺口）、deferred（后续），不等同于修复完成。严重度S1表示数据完整性/历史结果风险，S2表示计算边界或重要能力缺口，S3表示工具/体验问题。不宣称工资结算或税务认证。

### 实际基线验证

- 原检查脚本通过：13项核心、33项应用，格式、静态分析、字体与双语链接通过；此数字不含新增反例。
- 核心LCOV实测200/218行，91.74%，2个文件；应用1670/1916行，87.16%，18个已插桩文件，排除生成的本地化/配置。这是行覆盖率，不是分支或全源码覆盖率；bootstrap及多个真实平台/偏好适配器未进入应用报告，不能据此宣称存储覆盖完整。
- 新增边界探针3项如预期失败、2项通过。首页布局矩阵24项通过：三语，320×640、390×844、768×1024、640×320，100%/200%文字。
- Web Release编译通过。首次浏览器脚本因页面转场尚未完成就统计旧薪资输入框而失败；已改为等待旧字段移除。仅在重跑完成后记录浏览器通过。
- 可用Android设备为0；不宣称真机运行、读屏、安装、功耗或内存验证通过。

### 风险矩阵

| 编号 | 严重度/结论 | 证据与现状 | 后续动作 |
|---|---|---|---|
| AUD-01 | S2/设计缺口 | settings拆分跨夜，engine按实际日期应用周排班/覆盖。反例确认仅选周五时周五22点计入、周六1点不计；ADR-002明确选择了日历日归属，并非违反旧版约定。 | 增加班次起始日选项；迁移保持原语义，测试周末、周界、年界和休息段。 |
| AUD-02 | S1/设计缺口 | 只有单套Settings，编辑会明确确认历史重算，没有生效日期历史；文档已披露。 | 不可变薪资/排班版本及区间切分，默认保留旧期间，回溯修改先预览。 |
| AUD-03 | S1/设计缺口 | 日期覆盖只有bool，无法表达法定类别与个人排班的双重语义，当前无官方日历。 | 法定分类与是否工作分离，个人覆盖不能制造法定节日倍数。 |
| AUD-04 | S2/设计缺口 | 加班精确使用月基数/174与150/200/300；UI已限制大陆标准工时并有独立工资基数，但无机器可追溯来源/版本/适用性。 | 增加生效版本和来源，旧记录不得冒充已人工核验。 |
| AUD-05 | S2/设计缺口 | 休息日补休仅使现金参考为0，法定节日仍3倍，已有测试；加班不叠加正常工资。缺补休工时/状态和单位安排适用性。 | 时间与现金分开，补充适用条件、警示及政策快照。 |
| AUD-06 | S2/已确认＋未复现 | Money负数半值、零、大数、6位通过，无浮点逐tick问题；结束到2101年2月的查询却被接受，超出文档上界，已复现。 | 校验完整的排他结束边界，保持精确计算，显示舍入与未来结算分离。 |
| AUD-07 | S1/已确认＋设计缺口 | 存储入职日期2026-02-30会归一化到3月；加班构造器接受1970前/2100后时间，但读JSON拒绝，导致写入后无法恢复，已复现。尚无迁移/备份，跨键清理已说明可能部分完成。 | 严格日期、读写对称校验、保留原值的写时复制迁移、可恢复导入，禁止错误退为空。 |
| AUD-08 | S2/未复现 | 原缓存会跨日期/回拨与直接计算对比；按时间重算、不可见取消刷新，固定UTC+08:00。 | 补版本生效边界、后台恢复用例，保持不补tick。 |
| AUD-09 | S2/未复现 | 版本、架构/下载源、ETag、离线/404/限流与桥接测试通过；说明了浏览器文件未由应用校验及测试签名。 | 保留软件更新边界，政策下载独立授权和校验。 |
| AUD-10 | S2/设计缺口 | 24个首页布局通过，不推广为全部页面通过；显隐只属于Dashboard，进入加班明细仍可显示金额。缺计算依据、日历、版本、备份、深色主题及真机无障碍证据。 | 共享隐私、区分模拟/参考、计算追溯、日历/历史/数据管理及更广布局验证。 |
| TOOL-01 | S3/已确认 | 浏览器脚本在Material转场结束前读取旧字段。 | 等待旧输入框移除；保留首次失败及重跑证据。 |

源码为仓库相对路径：`src/packages/earnings_core/lib/src/{engine,overtime}.dart`、应用`lib/application/{settings,income_session,overtime,app_updates}.dart`、`lib/infrastructure/settings_repository.dart`、配置编辑器和Dashboard。新增探针为应用`test/audit_risks_test.dart`及`audit_layout_test.dart`。

### 架构与迁移决定

保留Flutter/Dart、Web/Android同一业务实现，不引入后端或工资单模块。本次用户明确要求功能分支/PR，优先于仓库默认直接维护main；P2后置。

P0-B先修复三处复现边界，再增加不可变薪资/排班版本、可解释计算及跨夜归属选项。写入独立v2文档前保留原v1；失败关闭写入入口，恢复/导入显式且幂等。不重新解释旧排班或加班快照。初始历史条目仅代表原单套估算配置，不能伪造实际历史薪资。

政策证据是代理核对，不是人类批准。内置官方来源数据保留待核验/人工核验区分，不静默激活，不把长放假区间全部当作法定节假日。冲突/不支持项保持未知；机制实现不代表主管机关或人工已签署数据。

### 官方来源登记

核对日期2026-11-10；后续结构化数据还须记录文号、发布/生效时间、地区与版本。仅支持参考估算，不判定具体劳动权利。

- [劳动法第44条，2018年修正文本](https://www.samr.gov.cn/zw/zfxxgk/fdzdgknr/bgt/art/2023/art_d9aa750028b14b99a776cb93726a360d.html)。
- [人社部发〔2025〕2号，2025-01-01](https://www.mohrss.gov.cn/SYrlzyhshbzb/laodongguanxi_/zcwj/202501/t20250101_533693.html)：制度工日与工资折算口径不同，废止2008通知。
- [国务院令795号，2025-01-01施行](https://app.www.gov.cn/govdata/gov/202411/12/521605/article.html)：全国法定节日类别。
- [国办发明电〔2025〕7号，2025-11-04](https://www.beijing.gov.cn/cs/gncs/zcwj/202603/t20260327_4568275.html)：政府转载2026放假调休安排，不直接等于每天的3倍工资分类。

### 阶段门槛和产物

P0-A在实测、分类及浏览器重跑登记后完成，不宣称三个反例已通过。P0-B须使其转绿并补版本、迁移、往返、追溯、跨日和政策边界测试；P1验证三语响应式与政策缓存失败/回退。无硬件时真机项单列缺口。P2税费、小组件、桌面交付后置。

原始日志、LCOV、coverage-summary.json、布局日志、浏览器截图放被忽略的`out/reports/upgrade-p0-a/`，不提交真实路径/财务或原始日志。阶段实际结果在本报告追加，使用功能分支独立提交，不合并或发布。

### P0-A收口

审计完成状态PASS，不等于产品修复完成。修正工具等待后，三语桌面/手机浏览器重跑通过，运行异常、远程字体请求及Web APK检查均为0。原46项与24个布局用例通过，3个新增边界反例保留失败交由P0-B修复。截图单独归档，避免P1覆盖基线。

### P0-B边界修复切片

三处反例已修复：存储入职日须为规范且真实的日期；加班构造器拒绝读回时无法恢复的年份；核心拒绝超过2101-01-01排他边界的查询。标准检查现为13项核心＋62项应用通过，包含24项布局及5项审计探针。仅关闭已复现边界缺陷，版本、迁移、政策和UI仍继续。

### P0-B 与 P1 实现检查点

集成检查现为 25 项核心、158 项应用测试通过，包含新增页面 72 组（三语、六种视口、100%/200% 文字、明暗主题）及原首页布局矩阵；格式、严格静态分析、字体和双语文档检查通过。新增页面包括历史、计算依据、日历/政策、备份恢复及外观，不代表物理读屏或真机测试。首次发现 320 宽度/200% 日历单元溢出，已改为可横向滚动的最小宽度网格；测试资源等待超时已与产品渲染区分，改为注入测试资源，真实内置资源仍交浏览器验证。

已实现独立薪资/排班生效历史、可选跨日归属、多工作/休息时段合并及精确追溯。档案、加班写时复制迁移保留 v1 原文，检测旧版改写并拒绝过期写入。故障注入覆盖重试、损坏失败关闭、导入预写日志回滚、导入前状态保留及摘要/结构拒绝。新加班记录将未知跨日工时保留待核验，补休单列。本地用户核验真实记录，不冒充项目或政府批准。新增日期用例暴露新代码中设备本地日期解析问题，已在发布前修正为 UTC 民用组件；原快照算法保留。

详见[实现设计与边界](../design/versioned-calculation-and-data.md)。内置 2026 来源待人工核验，不自动认定法定节日；软件与政策更新独立。所有者后续已授权主动合入 PR 并发布新 Release，替代此前禁止合入/发布的范围，但不授权强推或改变保护。本检查点的浏览器、原生包和最终覆盖率仍待验证，P2 继续后置。
