# 开发环境与工程初始化

## 当前状态

只有目录骨架和设计文档，尚未选择 Flutter/Dart、Android SDK 和 JDK 具体版本，没有安装依赖或执行工程初始化。首次初始化后记录版本与安装方式，应用提交 pubspec.lock，并在 CI 复用相同版本。

## 环境边界

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

## 初始化顺序

1. 确认 SDK，记录 flutter --version、dart --version 和 flutter doctor 结果。
2. 在 src/apps/pay_by_second 初始化仅 Web 的 Flutter 应用，保留已有目标目录；先预览生成差异，禁止覆盖设计文件和既有业务源码。
3. 在 src/packages/earnings_core 初始化纯 Dart 包。
4. 应用通过 path: ../../packages/earnings_core 引用计算包，随后运行依赖解析。
5. 实现最小计算、存储和首页，分别验证计算包测试、应用测试和 Web Release 构建。
6. 后续启用 Android 时在原 Flutter 应用根生成 Android 平台工程，不创建第二个客户端。

## 脚本约定

- tools/bootstrap：环境诊断和初始化说明/脚本，禁止未经选择安装或升级全局 SDK。
- tools/run：在正确工程目录启动，并显式传入业务环境。
- tools/check：格式、静态分析、单测、日历和配置校验。
- tools/build：Release 构建与 out/ 归档；签名秘密从外部注入。

首选支持 PowerShell 7 的 .ps1 脚本以覆盖不同宿主；需要 Flutter/Dart 后的配置生成可采用 Dart 工具。脚本自身不包含机器绝对路径。当前目录中尚无这些脚本，不应将目录存在误认为自动化已经可用。
