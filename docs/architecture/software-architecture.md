# 软件架构与工程目录

状态：设计基线草案 v0.1；2026-11-09。本文是目标结构，不表示树中的所有文件已经生成。

## 1. 架构目标

首先交付可体验的 Web 版本，验证工资计算和交互；随后复用计算核心和 UI 生成 Android APK。保持少依赖、离线可计算、无后台保活、无敏感权限。第一阶段不搭建微服务，不引入消息队列、事件总线或通用插件框架。

文档、业务源码、配置源、环境说明分别管理。Flutter 自身的平台工程和构建入口遵循工具链的标准布局，不为了顶层分类而搬动其约定文件。

## 2. 目标目录树

```text
PayBySecond/
  README.md
  .gitignore
  docs/
    requirements/
      product-spec.md
    architecture/
      software-architecture.md
      decisions/
        0001-web-first-flutter.md
    design/                         # 后续计算、存储、页面详细设计
    testing/
      verification-plan.md
    development/
      environment.md
  src/
    apps/
      pay_by_second/                # 唯一 Flutter 客户端工程根
        pubspec.yaml               # 后续由工程初始化创建
        pubspec.lock               # 应用锁文件提交
        analysis_options.yaml
        lib/
          main.dart                # 只调用 app/bootstrap.dart
          app/
            bootstrap.dart         # 组合依赖、读取配置、初始化
            app.dart               # MaterialApp、主题、路由
            lifecycle_controller.dart
          application/
            ports/                 # Clock、存储、认证等接口
            models/                # 应用快照、加载/错误状态
            use_cases/             # 查询收入、保存配置、账号用例
            services/              # 刷新协调、版本及缓存失效
          features/
            dashboard/presentation/
            profile/presentation/
            calendar/presentation/
            auth/presentation/
            settings/presentation/
          infrastructure/
            clock/
            storage/               # 原生文件/Web IndexedDB 适配
            auth/                  # HTTP、会话与凭证适配
            calendar/              # 日历包加载与验证
            platform/              # 可见性、生命周期等桥接
          shared/
            presentation/          # 通用数字组件、主题等
        assets/
          calendar/                # 从 config/calendar 校验后生成
          config/                  # 允许公开的运行配置
          images/                  # 实际随应用打包的资源
        test/                      # 应用用例、组件、适配器测试
        integration_test/          # 完整客户端流程
        web/                       # Web 平台工程
        android/                   # Android Gradle、Manifest 等
        windows/                   # 后续启用时生成
        linux/                     # 后续启用时生成
        macos/                     # 后续启用时生成
    packages/
      earnings_core/               # 不依赖 Flutter 的纯 Dart 包
        pubspec.yaml
        lib/
          earnings_core.dart       # 有限的公开导出接口
          src/
            money/
            time/
            salary/
            schedule/
            calendar/
            engine/
        test/
          fixtures/
  config/
    README.md
    app/                           # 默认值、配置 schema、公开环境配置
    calendar/                      # 有来源和版本的地区日历源
    quality/                       # 静态检查规则源和测试策略配置
    ci/                            # 构建矩阵、脚本参数与辅助配置
  env/
    examples/
      development.env.example
    README.md
  tools/
    bootstrap/
    run/
    build/
    check/
  assets/
    branding/                      # 设计原稿，不自动打包
  .local/                          # 忽略：本机配置、临时签名文件
  out/                             # 忽略：交付包、构建报告
```

没有分别建立 Web 和 Android 两套业务源码。两端共用同一个 Flutter 工程，只在 infrastructure 和平台工程中区分实现。先生成 Web；Android 在对应阶段启用，桌面工程暂不生成。

## 3. 依赖方向

```mermaid
flowchart TD
    BOOT[app/bootstrap 依赖组合入口] --> UI[features/*/presentation]
    BOOT --> INFRA[infrastructure 平台实现]
    UI --> APP[application 用例与 ports]
    APP --> CORE[earnings_core 纯 Dart 领域包]
    INFRA --> APP
    INFRA --> CORE
```

| 模块 | 允许依赖 | 禁止事项 |
|---|---|---|
| earnings_core | Dart 标准库、经评估的纯 Dart 精度/时区依赖 | Flutter、HTTP、文件系统、浏览器 API、直接读取系统当前时间 |
| application | earnings_core、自有 ports 和应用模型 | 平台插件、具体 Repository 实现、页面组件 |
| infrastructure | application ports、earnings_core、必要的平台插件 | 调用页面、独自决定工资规则 |
| presentation | application、公开领域值类型、Flutter | 直接读写存储、发认证请求、复制工资公式 |
| app/bootstrap | 各层公开入口 | 承载业务计算规则 |

不引入全局 ServiceLocator。bootstrap 创建 Repository、Clock、UseCase 和页面控制器，通过构造函数注入。页面控制器可以使用 ValueNotifier/ChangeNotifier；application 和领域包不继承 Flutter UI 基类。

UI 只做格式化和操作编排。计算包独立发布不是首版目标；拆包的目的是形成可测试且无法意外依赖 Flutter 的边界。

## 4. 数据和控制流

启动：读取公开 AppConfig → 初始化平台适配器 → 读取带 schemaVersion 的本地配置 → 恢复会话 → 校验日历覆盖 → 创建用例和首页。无配置时进入引导；已有配置时可离线进入面板。真实登录必选与本机体验模式的产品决策仍按需求文档待确认。

查询：页面请求统计范围 → QueryEarnings 取得同一份配置快照和 now → earnings_core 计算 → 返回金额、速率、计薪状态、下一边界、日历完整性 → UI 只更新变化组件。

保存：验证输入 → 原子保存版本 → 仅成功后发布新配置快照 → 失效受影响缓存 → 重新计算。失败保留编辑内容，禁止提前显示为保存成功。

认证：登录页面调用 AuthUseCase → AuthGateway → HTTPS 服务。客户端不记录密码；认证不可用不阻断已有本地规则计算。未完成真实后端前只能显示本机模式，不能模拟注册成功。

## 5. 核心接口职责

以下是接口设计意图，不是已经存在的源码签名。

| 接口/服务 | 输入与输出 | 位置 |
|---|---|---|
| EarningsEngine | 时间区间、当前时刻、规则版本、日历快照 → 精确金额和当前速率 | earnings_core |
| ScheduleCompiler | 排班和日期例外 → 去重、分段、有序有效区间及前缀和 | earnings_core |
| Clock | 当前 instant、单调经过时间；可注入测试时钟 | application/ports |
| ProfileRepository | 加载/原子保存带版本配置；不每tick保存 | application/ports |
| CalendarRepository | 读取有地区、年份、来源和版本的日历快照 | application/ports |
| AuthGateway | 注册、登录、退出、恢复和撤销会话 | application/ports |
| VisibilitySource | 前台/后台、页面或标签可见性事件 | application/ports |
| RefreshCoordinator | 一个刷新源、可见性切换、下一工作边界调度 | application/services |

权限检查、网络超时等作为明确失败返回；数据校验失败与系统异常分开。不给工资规则加“万能 catch 后返回0”，以免错误变成看似正确的金额。

## 6. 时间、精度和资源所有权

- 金额始终根据当前时间和规则求值，不按刷新次数累加。1秒和100ms只影响显示频率。
- 输入金额存整数分；计算精度策略在 earnings_core 唯一实现，禁止 UI 和服务端各自舍入。
- 固定工作时区定义日历边界；所有查询只捕获一次 now，避免多个卡片跨秒读出不一致的快照。
- RefreshCoordinator 由应用会话持有，只有面板可见且应用活跃时开启一个刷新源；不可见即取消。
- 页面控制器拥有自己的监听器并释放；Repository 连接由 bootstrap 创建并在应用会话结束时关闭。
- 缓存有容量限制，键包含工资、排班和日历版本；历史跨年计算分批聚合，禁止每100ms扫描全部历史。
- 不引入后台服务、持续网络请求和无限日志。单线程起步，测得阻塞后才决定分批计算或工作线程。

## 7. 配置工程与平台约定

产品配置集中放在 config/；构建必须读取显式指定的配置，缺失关键项报错。生成脚本将经验证的公开字段写入应用 assets 或编译参数，不把原始 env 文件整体复制进应用。

Flutter 的 pubspec.yaml、lock 文件、Android Gradle/Manifest、Web index.html 等必须在标准工程位置保留。质量配置的共享规则可放 config/quality，应用根 analysis_options.yaml 仅引用它；不同时手工维护两份规则。

CI 平台要求的入口文件，例如未来的 .github/workflows 或 .gitlab-ci.yml，保留在工具要求位置，只调用 tools/ 脚本并引用 config/ci 参数。发布签名注入为环境秘密，不放 config/。

## 8. 未来后端边界

首阶段不生成空的服务端框架。选择自建认证时再创建 src/services/account_api，拥有自己的依赖清单、迁移、测试和运行说明；选择托管认证时不创建重复后端。

认证服务只负责账号、会话和可选配置同步，不承担每秒工资刷新。客户端内禁止嵌入服务端管理员密钥。同步默认不启用；启用后用配置 revision 检测冲突，不能靠设备时间简单覆盖历史。

## 9. 演进顺序

1. 初始化 Flutter Web 应用与纯 Dart 包，冻结计算测试样例。
2. 打通本地配置、主面板、保存与恢复、生命周期刷新。
3. 加入日历版本、薪资历史和真实账号；是否发布无账号早期体验版单独确认。
4. 启用 Android 工程，替换平台适配，验证权限、生命周期、内存和签名 APK。
5. 在对应宿主构建环境启用桌面平台，复用既有业务测试。

## 10. 实施约束

文档描述需求与设计；可执行规则来自代码、配置 schema 和测试。修改工资口径时同时修改需求、计算实现和边界用例，不另写一套散落的公式文档。每项重要决策以 ADR 记录原因、影响和替代方案。

当前只落地目录和说明；pubspec、入口源码、脚本、日历包和平台工程均在实际开发阶段通过工具链生成或实现，避免假工程看似可构建。
