# Updater and publication validation / 更新与公开准备验证

## English

Version 0.2.1+3, 2026-11-09. This records executed local checks and publication boundaries, without machine-specific paths or personal finance.

| Check | Result |
|---|---|
| Standard checks | Formatting, font coverage, core/app analysis and whitespace passed |
| Core tests | 13 passed, including existing salary and independent overtime calculations |
| App tests | 33 passed; updater additions cover numeric versions, release flags, ABI/universal selection, URL restrictions, caching/ETag, restart throttling, offline/404/rate limits, failed storage, duplicate requests, clock rollback, platform bridge and three-language narrow layout |
| HTTP adapter | Local server verified JSON/ETag, non-200 handling, oversized/invalid response rejection and absence of Authorization |
| Web Release | Built successfully with existing dependencies; no new Dart package |
| Browser | Edge 156.0.4314.58, three languages at 1365×1000 and 390×844; setup, language auto-return, money/privacy, overtime recovery/custom rules and update-page navigation passed |
| Web privacy | No automatic GitHub APK requests, no remote-font requests, no runtime errors |
| APK | 0.2.1, versionCode2003, ARM64, minSdk24/targetSdk36; 20097060 bytes |
| APK static audit | v2 signature, 16 KiB ZIP and four native-library ELF alignments passed; package/test certificate retained; original fonts/OFLs/NOTICES present |
| Permissions | Ordinary INTERNET added; AndroidX signature-scoped receiver guard remains; no install/storage/sensitive permission; backup/cleartext traffic disabled |
| Source/privacy | Existing five commits/115 distinct historical blobs and current publication candidates scanned; no detected credential, internal-organization reference or local-user path in file text. Historical author metadata is retained by explicit owner choice, not falsely described as anonymous |

The owner requested public visibility and preservation of existing history. No history rewrite/force push is needed. New commits use the GitHub public username/noreply identity; local/global private Git settings are not published. SDKs, keys, caches, local build copies, APKs and raw reports stay ignored. Upstream license/copyright text is unchanged.

Reproduce with tools/check/check.ps1, tools/build/web.ps1 and tools/check/browser-smoke.cjs. Machine reports/screenshots live in ignored out/reports/; APK/build/signature/permission records in out/android/<build>/. Project-authored Markdown has English/Chinese sections and checked local links. License inventory generation preserves bilingual explanations.

The real repository initially had no GitHub Releases. Tests use synthetic release metadata; this is not a claim that a downloadable update has been published. Public visibility still requires a stable Release plus matching APK before real updates can be offered. No release/upload is automatically performed. No physical-device installation, upgrade, memory or power measurement has been performed. Android browser-channel behavior is covered by Dart bridge tests and native compilation, not a physical-device click test.

Known nonfatal build messages remain the framework's optional CupertinoIcons-font scan and Gradle future-version deprecations; they do not establish native compatibility. New source/resources matched the isolated Android build; environment-only wrapper/SDK locations stay private.

## 中文

0.2.1+3，2026-11-09。记录本地实际执行检查及公开边界，不包含本机绝对路径或真实个人财务。

| 检查 | 结果 |
|---|---|
| 标准检查 | 格式、字体覆盖、核心/应用静态分析及空白检查通过 |
| 核心测试 | 13项通过，覆盖原工资与独立加班计算 |
| 应用测试 | 33项通过；更新测试覆盖数值版本、发行标记、ABI/universal、URL约束、缓存/ETag、重启限频、离线/404/限流、存储失败、并发点击、时钟倒退、平台桥接及三语窄屏 |
| HTTP适配 | 本地服务验证JSON/ETag、非200响应、超大/非法响应拒绝、无Authorization请求头 |
| Web Release | 沿用现有依赖构建成功，无新增Dart包 |
| 浏览器 | Edge156.0.4314.58，三语1365×1000与390×844；配置、语言自动回首页、金额显隐、加班恢复/自定义规则及更新页面通过 |
| Web隐私 | 无自动GitHub APK查询、无远程字体请求、无运行异常 |
| APK | 0.2.1、versionCode2003，ARM64，minSdk24/targetSdk36，20097060字节 |
| APK静态核验 | v2签名、16KiB ZIP与四个原生库ELF对齐通过；沿用包名/测试证书；字体、OFL及NOTICES保留 |
| 权限 | 新增普通INTERNET；保留AndroidX签名域接收器保护；无安装/存储/敏感权限，备份和明文流量禁用 |
| 源码隐私 | 扫描原5条提交/115个历史独立blob及当前公开候选文件；正文未检出凭据、内部机构引用或本机用户路径。历史作者元数据按所有者明确选择保留，不宣称已匿名化 |

所有者要求公开仓库并保留历史，无需改写历史或force push。新提交使用GitHub公开用户名/noreply身份，不发布本机或全局私有Git配置。SDK、密钥、缓存、构建副本、APK和原始报告继续忽略。上游许可证及版权正文不修改。

复现入口为tools/check/check.ps1、tools/build/web.ps1、tools/check/browser-smoke.cjs。机器结果/截图放out/reports/，APK及构建/签名/权限记录放out/android/<build>/，均忽略。自有Markdown统一英文/中文并检查本地链接，许可清单生成器也保留双语说明。

真实仓库最初没有Release。测试使用合成发行元数据，不能宣称已发布可下载更新。公开之后仍须创建稳定Release并上传匹配APK才能提供实际更新，本轮不自动发布或上传。未进行真机安装、升级、内存或功耗测量；浏览器桥接经Dart测试与原生编译，未进行真机点击验证。

构建仍有框架可选CupertinoIcons字体扫描及Gradle未来版本弃用提示，不据此宣称原生兼容性已通过。新增业务源码/资源与隔离Android构建一致，环境相关wrapper/SDK位置不公开。
