# 验证计划

状态：计划，尚未实现测试或运行检查。需求明细见 requirements/product-spec.md。

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
