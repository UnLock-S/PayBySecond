# PayBySecond

实时工资估算工具，Flutter Web 优先验证，后续交付 Android APK，再扩展 Windows、Linux、macOS。

仓库：[UnLock-S/PayBySecond](https://github.com/UnLock-S/PayBySecond)。当前直接维护 `main`。

当前为 Web 本机体验版：已实现独立工资计算包、薪资配置、实时面板、本地保存及生命周期刷新。真实账号、官方节假日日历和薪资历史尚未接入；Android 平台工程尚未启用。

## 启动与检查

安装 `.flutter-version` 指定的 Flutter SDK（包含 Dart），使用 PowerShell 7 在仓库根执行：

```powershell
./tools/bootstrap/setup.ps1 -FlutterRoot '<Flutter SDK目录>'
./tools/check/check.ps1
./tools/run/web.ps1
```

运行地址为 `http://127.0.0.1:7357`。脚本只记录本机 SDK 路径到被忽略的 `.local/`，不修改全局 PATH。`./tools/build/web.ps1` 构建 Release 并归档至 `out/web/`，部署时需提供 HTTP/HTTPS 静态服务，不能直接双击 index.html。

当前界面的“调整估算配置”会显式提示重算全部历史。时区固定为 UTC+08:00，数据只保存在本机且未加密；浏览器清理存储后可能丢失。不要将体验版当作实际工资结算或唯一数据记录。

## 阅读入口

- [产品需求与计算口径](docs/requirements/product-spec.md)
- [软件架构与目录约定](docs/architecture/software-architecture.md)
- [开发环境与配置管理](docs/development/environment.md)
- [验证与发布门槛](docs/testing/verification-plan.md)
- [架构决策 ADR-001](docs/architecture/decisions/0001-web-first-flutter.md)
- [Git 维护约定](docs/development/git-workflow.md)
- [首版验证记录](docs/testing/web-mvp-validation.md)
- [第三方字体与重建说明](docs/development/third-party-assets.md)
- [第三方组件与授权说明](THIRD_PARTY_NOTICES.md)
- [已解析依赖许可清单](docs/development/dependency-inventory.md)
- [开发与依赖约定](AGENTS.md)

## 顶层分工

| 目录 | 内容 |
|---|---|
| `docs/` | 需求、架构、详细设计、验证与开发说明 |
| `src/` | Flutter 应用、纯 Dart 计算包及其测试、平台工程 |
| `config/` | 可提交的产品配置源、日历数据源、质量和 CI 配置 |
| `env/` | 环境变量示例与本机环境入口；真实本机配置不提交 |
| `tools/` | 初始化、运行、构建和检查脚本 |
| `.local/` | 本机工具链定位、字体源与测试依赖，Git 忽略 |
| `out/` | 交付产物和报告，Git 忽略 |

部分目录目前为空，后续在对应阶段填入实现；Git 不保存空目录，不为每个目录制造占位文件。

## 依赖与授权

优先 Flutter 标准能力与官方插件，避免引入需单独商业合同、仅限非商业或来源不明的组件。框架、插件、字体和工具各自遵循其原许可证，发行时保留第三方声明；应用提供“开源许可”入口。

项目自有代码尚未指定公开许可证，未擅自添加 MIT/Apache 授权。第三方许可和后续依赖管理规则见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
