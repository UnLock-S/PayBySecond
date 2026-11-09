# Historical input/overtime results / 日期输入与加班功能验证

## English

Historical 0.2.0+2 record, 2026-11-09. Checks were local at that stage; newer updater/publication work has a separate report.

| Check | Result |
|---|---|
| Standard script | Formatting/font coverage, both analyzers, whitespace passed |
| Core | 13 tests: statutory 1.5/2/3, compensatory leave, unpaid reference, 1×/custom, exact 100 ms partitions, midnight/rollback |
| App | 22 tests: flexible dates/times, recovery, failed-save retry, snapshots, wheel cancel/confirm, route/background pause, three-language 360×800 layout |
| Web | Release passed without new dependency |
| Browser | Edge156.0.4314.58, three languages at 1365×1000/390×844; setup, unchanged salary on language switch, automatic home return, overtime start/stop/reload, custom 2.5× and unchanged active unpaid snapshot |
| Visual | Desktop setup/active card and Japanese phone active/custom pages showed no overflow/missing glyph |
| Localization/fonts | 165 messages/language; 826 codepoints, four fonts totaling 978316 bytes; OFL/NOTICES retained; zero remote font requests/errors |
| APK | 0.2.0/versionCode2002, ARM64, min24/target36; Release optimized with Debug test certificate matching 0.1.0 |
| APK audit | v2 signature, 16 KiB ZIP/four ELF library alignment; no network/sensitive permission at that version; backup disabled |
| Source | 53 code/config/resource hashes matched the isolated build, excluding non-executable analyzer configuration modified by Flutter |

Reproduce via tools/check/check.ps1, tools/build/web.ps1, tools/check/browser-smoke.cjs. Local reports: out/reports/; APK/build/audits under out/android/<build>/. These artifacts are ignored, not committed documentation attachments.

That APK was 19732064 bytes, SHA256 78f58e97a633672da9cf24c4749293c9b2913343a7d22cd7fb981a1cbeaf0f9c. No physical-device installation, upgrade, memory or energy measurement was performed. Same package/certificate/increased version supported the planned upgrade path but was not a real-device upgrade test.

Compiler warnings included optional CupertinoIcons font scanning; the wheels used text and app buttons used Material icons. Gradle reported future-version deprecations; the pinned build succeeded. Warnings do not establish UI/native compatibility. See [feature design](../design/overtime-and-input.md) for rules/official sources; earlier UI/i18n results remain historical.

## 中文

2026-11-09，0.2.0+2，历史验证记录，仅反映0.2.0当时的本地验证范围。

| 验证 | 结果 |
|---|---|
| 标准检查脚本 | tools/check/check.ps1通过：格式、字体覆盖、两包静态分析、Git空白检查 |
| 计算核心 | 13项测试通过：含1.5/2/3倍、休息日补休、无薪参考、1倍/自定义、100ms分区一致性、跨日和时钟倒退 |
| 应用 | 22项测试通过：灵活日期时间、账本恢复、保存失败重试、规则快照不变、滚轮取消/确认、后台/路由暂停、三语360×800布局等 |
| Web Release | tools/build/web.ps1通过，未新增依赖 |
| 浏览器 | Edge156.0.4314.58，三语1365×1000与390×844通过；首次配置、薪资不因语言改变、语言自动回首页、加班开始/结束、重载恢复、自定义2.5倍、当前快照保留无薪规则 |
| 视觉检查 | 查看桌面加班规则/活跃卡片、手机日语活跃卡片/自定义规则截图，无可见溢出或缺字 |
| ARB与字体 | 每语言165条消息；826个覆盖字符，4份字体合计978316字节，OFL与Flutter NOTICES保留；浏览器远程字体请求和运行异常均为0 |
| APK | 0.2.0、versionCode2002，ARM64、minSdk24、targetSdk36；release优化但Debug测试签名，与0.1.0签名证书一致 |
| APK静态核验 | v2签名通过，zipalign -P16通过，全部4个原生库16KiB对齐；无新增敏感权限、无网络权限、allowBackup=false |
| 源码一致性 | 隔离Android副本与当前工作区53个源码/配置/资源文件SHA256一致；分析配置不属可执行代码，Flutter会追加平台目录排除项 |

复现入口：tools/check/check.ps1、tools/build/web.ps1、tools/check/browser-smoke.cjs。机器结果和截图：out/reports/browser/；检查日志：out/reports/overtime-check.log。APK、构建日志、签名/权限/对齐核验及源码清单：out/android/<build>/。

APK SHA256：`78f58e97a633672da9cf24c4749293c9b2913343a7d22cd7fb981a1cbeaf0f9c`，19732064字节。未在真实设备安装或测量内存、电量，不把浏览器/组件生命周期验证当作真机结果。正常升级保留数据仅依据同包名/同证书/递增版本核验，尚无真机升级结果。

Web编译有Flutter对未打包CupertinoIcons字体的扫描提示；本次滚轮使用数字/日期文本，自有按钮使用Material图标，未引入cupertino_icons包。Gradle同时有未来10版弃用提示，当前锁定工具链构建成功；这些提示不作为布局和真机兼容性的通过证据。

实现范围、金额口径及官方法规来源见 [专项设计](../design/overtime-and-input.md)。原UI三语验证记录保留为上一版历史记录。
