# PayBySecond

实时工资估算工具，Flutter Web 优先验证，后续交付 Android APK，再扩展 Windows、Linux、macOS。

当前仓库是设计与目录骨架，尚未初始化 Flutter/Dart 工程，也不能直接运行。没有占位业务实现或未经验证的构建配置。

## 阅读入口

- [产品需求与计算口径](docs/requirements/product-spec.md)
- [软件架构与目录约定](docs/architecture/software-architecture.md)
- [开发环境与配置管理](docs/development/environment.md)
- [验证与发布门槛](docs/testing/verification-plan.md)
- [架构决策 ADR-001](docs/architecture/decisions/0001-web-first-flutter.md)

## 顶层分工

| 目录 | 内容 |
|---|---|
| `docs/` | 需求、架构、详细设计、验证与开发说明 |
| `src/` | Flutter 应用、纯 Dart 计算包及其测试、平台工程 |
| `config/` | 可提交的产品配置源、日历数据源、质量和 CI 配置 |
| `env/` | 环境变量示例与本机环境入口；真实本机配置不提交 |
| `tools/` | 初始化、运行、构建和检查脚本 |
| `assets/` | 品牌等设计原稿，区别于运行时打包资源 |
| `.local/` | 未来本机临时数据和秘密文件，Git 忽略 |
| `out/` | 未来统一归档的 APK、Web 产物和报告，Git 忽略 |

部分目录目前为空，后续在对应阶段填入实现；Git 不保存空目录，不为每个目录制造占位文件。

原根目录 `PRODUCT_ARCHITECTURE.md` 已归入 `docs/requirements/product-spec.md`，保留其中的计算规范；该文档中开发阶段的顺序由 ADR-001 更新为 Web 优先。
