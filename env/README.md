# 环境文件约定

本目录只提交说明和 examples/ 下的示例。复制示例后填写本机值，保存到 .local/env/，不提交。

development、staging、production 表示业务环境，不等同于 Flutter 的 debug、profile、release 编译模式。运行和构建脚本必须分别选择两者。

Flutter/Dart SDK、Android SDK、JDK 和浏览器安装在工作区外，不复制到本目录。具体版本在首次初始化时锁定，不能在尚未验证时编造版本号。

示例中的 AUTH_BASE_URL 只表示公开服务地址，不包含实际服务或认证能力。不要将 .env 文件直接作为 Flutter 资产打包，也不要默认认为 Flutter 会自动读取它。
