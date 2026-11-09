# 开发环境与工程初始化

## 当前状态

Web 客户端与纯 Dart 计算包已建立。Flutter 锁定 3.47.9（根目录 .flutter-version），所带 Dart 为 3.13.7。当前机器的 SDK 以 stable 浅克隆安装在工作区外的项目专用工具链目录，未修改全局 PATH；实际路径保存在被忽略的 .local/toolchain.json。应用和计算包均提交 pubspec.lock。Android SDK/JDK 本阶段不安装、不要求配置。

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

已提供 PowerShell 7 脚本：bootstrap/setup.ps1、run/web.ps1、check/check.ps1、build/web.ps1。脚本通过显式参数、PBS_FLUTTER_ROOT 或本机 toolchain.json 定位 SDK，不包含机器绝对路径。bootstrap 检查版本并恢复依赖，不安装或升级全局 SDK。

首次初始化的 Web 平台模板在 .local/flutter_scaffold 中通过 Flutter CLI 生成，再仅将 web/ 和 .metadata 纳入应用，避免覆盖已编写的业务源码。该临时模板不提交。

当前只使用开发本机模式；没有认证环境模板或伪认证请求。公开日历配置生成、CI 发布和秘密注入留待对应功能实际接入。
