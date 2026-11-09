# 第三方组件与授权管理

本项目优先采用无需单独商业授权的开源组件。商业软件使用第三方开源组件仍需保留其版权、许可证和必要声明；这里不将“免费”解释为没有义务。

## 当前主要组件

| 组件 | 用途 | 许可与处理 |
|---|---|---|
| Flutter / Dart | 客户端与计算运行环境 | 框架顶层 BSD-3-Clause；引擎有多项独立第三方许可，保留生成的 NOTICES |
| shared_preferences | 本机配置存储 | 锁定包顶层 BSD-3-Clause；其平台包一并纳入清单 |
| Noto Sans SC 派生子集 | 本地中文字体 | SIL OFL-1.1，改名 PayBySecond Sans，保留原版权与 OFL 正文 |
| flutter_lints / test 等 | 仅开发与验证 | 具体版本和顶层许可见依赖清单 |
| Playwright 1.65.0 | 可选浏览器测试工具 | Apache-2.0，不打包进入应用 |
| fontTools 4.67.0 | 可选字体子集生成工具 | MIT，不打包进入应用 |

当前未接入付费 SDK、广告分析 SDK 或需单独商业合同的组件。此结论基于当前声明和解析的组件范围，不涵盖未来 Android/桌面平台的新增二级依赖。

## 声明位置

- [已解析依赖清单](docs/development/dependency-inventory.md)：从当前恢复的 Dart/Flutter 包顶层许可正文生成，包含版本与原文摘要哈希。
- [字体来源与重建](docs/development/third-party-assets.md)。
- [字体原始许可](src/apps/pay_by_second/assets/fonts/OFL.txt)：随应用打包。
- [Flutter 框架原始许可](docs/legal/licenses/Flutter-LICENSE.txt)：保留生成的平台工程模板相关许可。
- Web Release 的 `assets/NOTICES`：Flutter 构建生成的完整第三方声明，部署时不得移除。它是当前交付物的重要许可依据，不能只拿顶层依赖表替代。

## 新增依赖规则

优先标准库、官方插件和 MIT/BSD/Apache 等宽松许可组件；对 GPL/AGPL/LGPL、非商业限制、多重许可或无许可组件单独审查使用方式与实际义务。授权不清晰时优先选择替代实现，不为了功能便利引入商业合同依赖。升级依赖后重新生成清单并保留锁文件。

本清单是工程核查记录，不是对所有平台和全部嵌入式第三方代码的完整法律审计。尤其是 Flutter 引擎与未来原生插件的二级依赖，必须以实际发布版本的完整声明为准。

## 项目自身代码

项目所有者尚未指定自有代码的公开使用许可证，仓库未添加 MIT/Apache 等总许可证。上传 GitHub 不代表将自有代码按第三方组件的许可证授权；第三方组件仍受各自原许可约束。

## 官方依据

- [Flutter FAQ：BSD-3-Clause 与引擎第三方依赖](https://docs.flutter.dev/resources/faq)
- [shared_preferences 原始许可证](https://pub.dev/packages/shared_preferences/license)
- [SIL：OFL 字体使用与分发](https://openfontlicense.org/how-to-use-ofl-fonts/)
- [Playwright 原始许可证](https://github.com/microsoft/playwright/blob/v1.65.0/LICENSE)
- [fontTools 原始许可证](https://github.com/fonttools/fonttools/blob/4.67.0/LICENSE)
