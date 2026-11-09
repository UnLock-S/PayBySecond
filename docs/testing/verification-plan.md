# Verification plan / 验证计划

## English

Full-product plan, not a pass report. Some cases are implemented in the Web MVP; see [historical MVP results](web-mvp-validation.md) and newer feature reports. Unimplemented features are not qualified. Requirements: ../requirements/product-spec.md.

| Level | Location | Focus |
|---|---|---|
| Domain tests | src/packages/earnings_core/test | Common/leap years, annual/monthly basis, lunch, overnight, make-up work, version splitting, precision, zero denominator |
| Application tests | src/apps/pay_by_second/test | Orchestration, failed saves, invalidation, one-now snapshots, pause/recovery |
| Widget tests | App test/, grouped by feature | Validation, money/privacy/errors/period switching |
| Adapters | App tests/platform integration | Web/native storage, migration/corruption/credential boundaries |
| End-to-end | integration_test/ and browser tooling | Setup → dashboard → close → restore; real-auth success/failure when implemented |
| Resources/permissions | Real Android Release device | 1 s/100 ms, stable heap, route round trips, background work, merged manifest |

Identical time/rules must produce identical money; tick count must not matter; resume must not replay old ticks. Missing calendar coverage is explicit. Routes must not leak timers/subscriptions.

Validate schema, dates, calendar sources/coverage and mutually exclusive fields. Static checks prevent core dependence on Flutter/platform APIs. Implement critical executable tests; the plan itself is not evidence.

Before Web publication run domain/app tests, analysis and Release build. Android additionally needs real-device flows, resource measurement and permission review. Archive reports under out/reports/ with version/device/build mode, using synthetic finance data and no private machine paths in public summaries.

## 中文

状态：完整产品验证计划；部分已在 Web MVP 实现并验证，结果见 [首版验证记录](web-mvp-validation.md)。尚未实现的完整产品能力不视为通过。需求明细见 ../requirements/product-spec.md。

| 层级 | 位置 | 重点 |
|---|---|---|
| 领域单测 | src/packages/earnings_core/test | 平年/闰年、年/月基准、午休、跨夜、补班、版本分段、精度、分母0 |
| 应用单测 | src/apps/pay_by_second/test | 用例编排、保存失败、缓存失效、同一now快照、恢复和暂停 |
| 组件测试 | 应用 test 中按 feature 分类 | 配置校验、金额显示、隐藏、错误提示与统计范围切换 |
| 平台适配测试 | 应用 test 及必要的平台集成环境 | IndexedDB/原生存储、迁移、损坏恢复、凭证边界 |
| 端到端 | src/apps/pay_by_second/integration_test | 首次配置→面板→关闭→恢复；真实认证上线后覆盖成功与失败 |
| 性能和权限 | Android Release 实机阶段 | 1秒/100ms刷新、稳定堆、页面往返、后台任务、合并Manifest |

核心判据：相同时间和规则产生相同金额；tick数量不影响计算；恢复前台后不补跑历史tick；日历缺失必须提示；页面退出不残留计时器和订阅。

配置校验检查 schema、日期区间、日历来源/覆盖和互斥字段；源码静态检查防止领域包依赖 Flutter 或平台 API。先实现关键测试，再建立可执行门槛，不能用本计划代替通过记录。

Web 发布前运行领域测试、应用测试、静态分析和 Web Release 构建。Android 发布额外执行真机流程、资源测量和权限检查。报告归档至 out/reports/ 并记录版本、设备和构建模式。
