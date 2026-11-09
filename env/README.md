# Environment conventions / 环境文件约定

## English

This directory holds environment guidance and font-tool requirements. There is no authentication backend or env-loader yet, so no unused auth URL templates are retained. Add examples when a feature actually consumes them; put real local values in ignored .local/env/.

development/staging/production describe business environments, not Flutter debug/profile/release modes. Scripts must distinguish them.

Install Flutter/Dart, Android SDK, JDK and browsers outside the workspace. Lock/check actual versions during setup rather than inventing unverified versions. Never bundle an .env file as a Flutter asset or assume Flutter reads it automatically.

## 中文

本目录提交环境说明和字体工具依赖清单。目前应用没有认证后端或环境变量加载功能，因此不保留未使用的认证地址模板。未来功能实际接入时再添加对应示例，本机值保存到 .local/env/，不提交。

development、staging、production 表示业务环境，不等同于 Flutter 的 debug、profile、release 编译模式。运行和构建脚本必须分别选择两者。

Flutter/Dart SDK、Android SDK、JDK 和浏览器安装在工作区外，不复制到本目录。具体版本在首次初始化时锁定，不能在尚未验证时编造版本号。

不要将 .env 文件直接作为 Flutter 资产打包，也不要默认认为 Flutter 会自动读取它。
