# Public configuration / 可提交配置源

## English

- app/: non-sensitive defaults, schemas and public parameters. updates.json selects the GitHub owner/repository; tools/build/update-config.ps1 generates the application constants.
- calendar/: holiday/make-up sources with region/year/revision/source/coverage; official data integration remains future scope.
- quality/: shared Dart analysis rules and check configuration.
- ci/: future build matrices/publication parameters; never secrets.

Product defaults belong here; user salary, schedule and overrides are runtime data, never written into the repository. Validate config before generating runtime assets/constants. Generated output is not a second source of truth and must not be edited manually. Do not create configuration entry points with no implementing consumer.

Environment variables, --dart-define values, Web bundles and APK constants are public to their recipient. Do not put private keys, service credentials, signing/database passwords or GitHub tokens in them.

## 中文

- `app/`：非敏感默认设置、环境公开参数和未来的配置 schema。
- `calendar/`：节假日/补班数据源，必须带地区、年份、版本、来源及覆盖范围。
- `quality/`：未来的 Dart 静态分析规则源和检查配置。
- `ci/`：未来构建矩阵、发布参数，不保存密钥。

产品配置属于本目录；用户填写的薪资、排班和个人例外属于应用运行数据，不写回仓库。

配置源经过 tools/check 校验，再由 tools/build 生成应用运行资产。生成文件不手工编辑，输出不作为第二份配置真值。脚本未实现之前不创建无法执行的配置入口。

环境变量、--dart-define、Web bundle 和 APK 内任何值都不能当成秘密。禁止放私钥、服务账号凭据、签名密码和数据库密码。
