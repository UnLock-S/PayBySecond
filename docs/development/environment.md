# Development environment / 开发环境与工程初始化

## English

### Current state

The Web app and pure-Dart package use Flutter 3.47.9 from .flutter-version and bundled Dart 3.13.7. Install SDKs outside the repository; record their location only in ignored .local/toolchain.json or PBS_FLUTTER_ROOT, without changing global PATH. Commit application/core pubspec.lock files. Android platform source is now present; the original Web-only stage did not require Android SDK/JDK.

### Boundaries

| Category | Location | Commit policy |
|---|---|---|
| Flutter/Dart/Android SDK/JDK | External toolchain installation | No binaries in src/Git |
| Public environment examples | env/examples/ when consumed | Template only |
| Local overrides/signing secrets | .local/ or system secret store | Never commit |
| Product defaults/calendars | config/ | Validate before commit |
| Download caches | Tool default cache locations | Ignore |
| Intermediate files | Flutter/Gradle standard layout | Ignore |
| Packages/reports | out/ by version/platform | Ignore; publish only selected artifacts |

Web requires Flutter and a supported browser. Android additionally needs SDK/JDK and, for qualification, a real device. macOS native builds require a Mac. Check host/target support against the pinned SDK.

### Initialization

1. Record flutter --version, dart --version and flutter doctor.
2. Initialize Web under src/apps/pay_by_second, preview generated differences and preserve existing business/design files.
3. Initialize pure Dart at src/packages/earnings_core.
4. Reference it through path: ../../packages/earnings_core and resolve dependencies.
5. Validate calculation, storage, dashboard, unit/widget tests and Web Release.
6. Enable Android within the same Flutter app, not a second client. This source now exists; avoid recreating it over custom platform code.

### Scripts

- tools/bootstrap diagnoses/restores dependencies without silently installing/upgrading global SDKs.
- tools/run selects the correct project/environment.
- tools/check covers formatting, analysis, tests and configuration/font checks.
- tools/build creates Release outputs under out/ and receives secrets externally.

PowerShell 7 entry points: bootstrap/setup.ps1, run/web.ps1, check/check.ps1, build/web.ps1. SDK selection order is explicit parameter, PBS_FLUTTER_ROOT, ignored local toolchain configuration. Scripts contain no machine-specific absolute paths. The original Web template was generated in ignored .local/flutter_scaffold, then only Web/.metadata were integrated to preserve source.

The current client is a local preview, with no auth environment or simulated auth calls. Calendar generation and CI publication remain deferred. tools/build/update-config.ps1 validates the public update repository and generates version/config constants; the canonical check/run/Web-build scripts invoke it. Android uses the package manager's actual installed version. Keep all SDK paths, local.properties, signing keys and reports out of Git.

## 中文

### 当前状态

Web 客户端与纯 Dart 计算包已建立。Flutter 锁定 3.47.9（根目录 .flutter-version），所带 Dart 为 3.13.7。当前机器的 SDK 以 stable 浅克隆安装在工作区外的项目专用工具链目录，未修改全局 PATH；实际路径保存在被忽略的 .local/toolchain.json。应用和计算包均提交 pubspec.lock。Web运行不要求Android SDK/JDK；0.2.1已保留Android平台源码，Android构建另需项目外部SDK/JDK。

### 环境边界

| 类别 | 放置位置 | 提交规则 |
|---|---|---|
| Flutter/Dart、Android SDK、JDK | 工作区外部统一安装目录 | 不提交二进制，不复制进 src |
| 公开环境变量示例 | env/examples/ | 提交模板 |
| 本机覆盖配置、签名秘密 | .local/ 或系统秘密存储 | 不提交 |
| 产品默认配置、地区日历 | config/ | 校验后提交 |
| Dart/Gradle 下载缓存 | 工具默认缓存目录 | 不提交 |
| 工程中间产物 | Flutter/Gradle 默认路径 | 忽略 |
| 交付包和测量报告 | out/ 按版本/平台归档 | 忽略，CI发布到制品存储 |

Web 阶段需要 Flutter SDK 及可用的浏览器/调试环境。Android 阶段再接入 Android SDK/JDK 和真机。macOS 原生应用需要 Mac 构建环境；各平台构建支持在实施时对照锁定 SDK 的官方说明确认。

### 初始化顺序

1. 确认 SDK，记录 flutter --version、dart --version 和 flutter doctor 结果。
2. 在 src/apps/pay_by_second 初始化仅 Web 的 Flutter 应用，保留已有目标目录；先预览生成差异，禁止覆盖设计文件和既有业务源码。
3. 在 src/packages/earnings_core 初始化纯 Dart 包。
4. 应用通过 path: ../../packages/earnings_core 引用计算包，随后运行依赖解析。
5. 实现最小计算、存储和首页，分别验证计算包测试、应用测试和 Web Release 构建。
6. Android平台源码已在同一Flutter工程保留，不另建客户端；重新生成前预览差异，保留自定义桥接代码。

### 脚本约定

- tools/bootstrap：环境诊断和初始化说明/脚本，禁止未经选择安装或升级全局 SDK。
- tools/run：在正确工程目录启动，并显式传入业务环境。
- tools/check：格式、静态分析、单测、日历和配置校验。
- tools/build：Release 构建与 out/ 归档；签名秘密从外部注入。

已提供 PowerShell 7 脚本：bootstrap/setup.ps1、run/web.ps1、check/check.ps1、build/web.ps1。脚本通过显式参数、PBS_FLUTTER_ROOT 或本机 toolchain.json 定位 SDK，不包含机器绝对路径。bootstrap 检查版本并恢复依赖，不安装或升级全局 SDK。

首次初始化的 Web 平台模板在 .local/flutter_scaffold 中通过 Flutter CLI 生成，再仅将 web/ 和 .metadata 纳入应用，避免覆盖已编写的业务源码。该临时模板不提交。

当前只使用开发本机模式；没有认证环境模板或伪认证请求。公开日历配置生成、CI 发布和秘密注入留待对应功能实际接入。

0.2.1使用tools/build/update-config.ps1从config/app/updates.json和pubspec生成公开更新配置；标准检查/运行/Web构建自动调用。SDK位置、local.properties、签名密钥和报告不纳入Git。
