# GitHub Release updates / GitHub Release 更新设计

## English

Version 0.2.1, 2026-11-09. Android GitHub Release metadata checking, independent of finance data.

### User behavior

Settings → Software update displays installed version/build, last successful check, current result, automatic toggle and release notes. Before first salary setup, the app bar also exposes the page. A newer cached/detected stable version produces a nonblocking home entry. Check at startup at most once per 24 hours; no resume/background polling or periodic task. Manual checks have a 30-second cooldown, with simultaneous clicks sharing one in-flight operation. Clock rollback does not permanently lock checking.

The browser downloads APKs after an explicit click. The app neither downloads/install files nor requests install/storage permission. Android requires ordinary INTERNET permission without a runtime prompt. Salary, schedules and overtime never enter the HTTP request. No GitHub credential is bundled. Automatic checking can be disabled.

Web displays its version and the Release-page link, explains deployment updates, and performs no automatic APK request. Desktop packaging/checking remains future scope.

### Source/release contract

config/app/updates.json stores only repository owner/name, currently UnLock-S/PayBySecond. tools/build/update-config.ps1 validates it and the pubspec version, generating infrastructure/generated/update_config.dart. Canonical check/run/Web-build scripts regenerate it. Android reads the actual installed package version/build and preferred ABI through a small MethodChannel.

Use GET https://api.github.com/repos/UnLock-S/PayBySecond/releases/latest without authentication. Accept published, non-draft, non-prerelease releases with numeric major.minor.patch tags, optionally prefixed v. Compare components numerically, not lexically. Same version/new build alone does not trigger an update: increment semantic version for each release and Android build code for installation.

Name assets `PayBySecond-<version>-arm64-v8a.apk` or `PayBySecond-<version>-arm64-v8a-test.apk`; universal may substitute for ABI. Prefer matching ABI, then universal; never select x86 assets for ARM64. Require uploaded/nonempty assets and exact tag/file path in the configured repository. An otherwise newer release without a matching APK is shown with a warning and no download button.

Only HTTPS GitHub release URLs under the configured owner/repository can be launched. Construct the notes-page URL locally; ignore arbitrary supplied links. Do not automatically follow API redirects. Future APKs must retain the package ID/signing certificate and increase versionCode. Current Debug signing is for tests, not production distribution; no signing key is committed.

Public visibility alone is insufficient: publish a stable GitHub Release and upload the matching APK to enable a real update. A private source returns an inaccessible/missing-release result. No token should be embedded to bypass that. Building does not create a release or upload artifacts automatically.

### Network/cache/failures

Use standard Dart HttpClient, five-second connect/eight-second total timeout, 512 KiB response cap and guaranteed client closure. Request only metadata, never APK bytes; User-Agent contains no identity/finance. Send ETag on later successful checks;304 reuses validated cached metadata.

Store automatic preference, source repository, attempt/success UTC timestamps, ETag and bounded release JSON in pay_by_second.updates.v1. Write the attempt before requesting so restarts cannot bypass daily throttling. Source changes invalidate cached release data. Cache never includes salary. Clearing finance retains language/update preferences.

404 means no publicly accessible stable release, not up-to-date.403/429 report limits; timeout/network errors report incomplete checking; invalid metadata is rejected. Earlier validated cache can remain visible with the result/last-success time. Storage errors are explicit and do not falsely report a successful check. SHA256, if shown, is metadata supplied by GitHub, not a verification of browser-downloaded content. Android's installer enforces package/signature upgrade constraints.

### Source boundaries

| File/group | Responsibility |
|---|---|
| application/app_updates.dart | Versions, safe asset selection, state/cache contracts and throttled controller |
| infrastructure/release_transport_* | Bounded native HTTP and unsupported-Web stub |
| infrastructure/update_preferences.dart | Separate local preference adapter |
| infrastructure/update_platform_* | Android installed-info/browser channel; Web page opening |
| infrastructure/create_updater.dart | Production composition |
| features/updates/presentation | Three-language status/settings/notes/download UI |
| android/.../MainActivity.kt | appInfo/openRelease bridge, no installer API |
| config/app/updates.json | Public source of truth |

No new Dart dependency, updater SDK, tracker, background service or sensitive runtime permission. Preserve existing legal notices. Tests use synthetic releases; fixture success is not evidence of a real uploaded release or physical-device installation.

### Official references

- [GitHub Releases REST API](https://docs.github.com/en/rest/releases/releases#get-the-latest-release)
- [Android networking permissions](https://developer.android.com/develop/connectivity/network-ops/connecting)

## 中文

0.2.1，2026-11-09。Android更新元数据检查，与个人财务数据独立。

### 用户流程

“设置 → 软件更新”显示当前版本/构建号、上次成功检查、检查状态、自动检查开关及更新说明。首次配置薪资前，顶栏也提供入口。发现较新的稳定版本后，首页提供不阻塞操作的更新入口。

启动时最多每24小时检查一次，不在恢复前台时重复请求，不使用后台轮询或周期任务。手动检查间隔至少30秒；重复点击不会发起并发请求。系统时间倒退不会永久锁死检查。

用户点击后由系统浏览器下载APK，再手动安装。应用不直接下载、安装文件，不申请安装/存储权限。联网只需普通INTERNET权限，没有运行时授权弹窗。HTTP请求不包含薪资、排班或加班数据，不内置GitHub令牌，可关闭自动检查。Web仅显示版本和发行页链接，说明由网站部署更新，不自动请求APK更新；桌面打包与自检仍待实现。

### 发布源与版本约定

config/app/updates.json仅保存owner/repository，当前为UnLock-S/PayBySecond。tools/build/update-config.ps1验证仓库名和pubspec版本，生成infrastructure/generated/update_config.dart，标准检查、运行及Web构建脚本自动调用。Android通过小型MethodChannel读取实际安装版本、构建号和首选ABI。

匿名GET https://api.github.com/repos/UnLock-S/PayBySecond/releases/latest 。只接受已发布、非草稿、非预发布的稳定版本；tag为major.minor.patch，可带v前缀。按数值比较版本，不按字符串排序。同语义版本仅增加build不会触发更新；每次发行应增加语义版本及Android构建号。

APK命名为`PayBySecond-<version>-arm64-v8a.apk`或`PayBySecond-<version>-arm64-v8a-test.apk`；支持universal替代架构名。优先匹配ABI，其次universal，不为ARM64选x86包。资源须已上传、非空，且下载路径中的仓库、tag和文件名完全匹配。新版无对应APK时提示缺少资源，不提供下载按钮。

只允许打开配置仓库下的HTTPS GitHub Release链接；发行说明页链接由本地构造，不采用任意外部跳转，不自动跟随API重定向。后续APK必须保持包名、签名证书并递增versionCode。当前Debug测试证书不用于正式应用商店发行，密钥不提交。

仓库公开后仍需发布稳定Release并上传对应APK才能提供真实更新。私有/不可访问源会提示尚无可公开访问版本，不能通过内置令牌绕过。构建不会自动创建Release或上传制品。

### 网络、缓存及失败处理

使用标准Dart HttpClient，连接超时5秒、总超时8秒、响应上限512KiB，结束时关闭客户端。只请求元数据，不请求APK字节；User-Agent不含个人身份或财务信息。后续成功检查发送ETag，304复用已验证缓存。

独立键pay_by_second.updates.v1保存自动开关、仓库、UTC尝试/成功时间、ETag和有限大小的发行元数据。请求前先保存尝试时间，重启不能绕过日限流。更换源会使旧缓存失效。缓存不含薪资；清空财务数据仍保留语言和更新偏好。

404表示尚无可公开访问稳定发行版，不等于“已是最新版”；403/429提示限流，网络/超时提示本次未完成，无效元数据拒绝。先前有效缓存可保留显示，页面同时提供本次状态与上次成功时间。存储错误显式提示，不冒充检查成功。SHA256若显示，仅来自GitHub元数据，应用未校验浏览器下载文件；Android安装器负责升级时的包名/签名约束。

### 源码职责

| 文件/模块 | 职责 |
|---|---|
| application/app_updates.dart | 版本、资源选择、状态/缓存接口、限频控制器 |
| infrastructure/release_transport_* | 原生有界HTTP及Web空适配 |
| infrastructure/update_preferences.dart | 独立偏好存储 |
| infrastructure/update_platform_* | Android版本/浏览器桥接，Web页面打开 |
| infrastructure/create_updater.dart | 生产依赖组装 |
| features/updates/presentation | 三语状态、设置、说明与下载入口 |
| android/.../MainActivity.kt | appInfo/openRelease，无安装API |
| config/app/updates.json | 公开发布源真值 |

未增加Dart依赖、更新SDK、跟踪服务、后台服务或敏感运行时权限，保留原有第三方声明。测试使用合成发行版，不能将测试桩成功当作真实发行、真机下载安装已通过。

### 官方依据

- [GitHub Releases REST API](https://docs.github.com/en/rest/releases/releases#get-the-latest-release)
- [Android联网权限](https://developer.android.com/develop/connectivity/network-ops/connecting)
