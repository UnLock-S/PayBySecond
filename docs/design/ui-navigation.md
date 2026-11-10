# UI navigation and languages / 多页面与三语界面设计

## English

Implementation update: the earlier MVP single-rule/storage/overnight boundaries below are superseded for the P0/P1 upgrade by [versioned calculation and recoverable data](versioned-calculation-and-data.md). Requirements and target architecture below remain plans where not explicitly implemented there. Historical test reports retain their original revision scope.

Implemented navigation, updated through 0.2.1. Historical qualification results remain in the testing documents.

### Page responsibilities

```text
Income home
  First use → Salary → Calculation → [Work schedule] → Review/save
  Overtime → first rules/save/start; later one-tap start/stop; details/history
  Settings
    Salary                  monthly salary/employment date
    Calculation             annual/monthly and calendar/work accrual
    Work schedule           weekdays/start/end/lunch
    Days off/make-up work   date overrides and work/rest/removal
    Display                 refresh and decimal precision
    Language                Chinese / English / Japanese
    Software update         installed/release versions, checks, browser download
    Data/information        privacy, scope, licenses, clear local finance
```

Home has period selection, amount visibility, settings and a separate overtime card with start/stop/details; no overtime configuration form. Secondary month/employment cards have no edit/delete. Periods remain employment/year/month/week/day/hour.

Group settings by pay, presentation and information. Each category is a page; no long modal form. Existing settings edit one category; onboarding uses short steps and persists only at final confirmation. Calendar-time mode skips scheduling. Date overrides default to rest and can become work or be removed without language-dependent “date=type” syntax. The calendar/data pages disclose missing official holidays.

### Save/navigation

- Salary-rule saves confirm historical recalculation; display changes do not.
- Unsaved salary/configuration exit confirms discard; onboarding can step back or cancel.
- Failed saves retain draft/page; UI language does not alter formulas.
- Home refresh pauses while covered by settings, category, data, license or update pages and evaluates immediately on return.
- Preserve period/privacy state during navigation/language/config changes; no persistent forms/global refresh timer.
- Use Navigator/MaterialPageRoute, without a router dependency or configuration deep links.

### Localization

Use Flutter gen-l10n with app_en.arb as template and zh/ja translations under lib/l10n; generated files live in generated/. Tests check key sets, nonempty messages and placeholders. Include labels/help/errors/failures/dialogs and localized framework controls. Synchronize Web html lang to zh/en/ja for accessibility.

Prefer natural Japanese kanji labels such as 給与情報/計算方式/勤務時間, while keeping natural grammar. Use the local renamed Noto Sans JP subset, with original notices; see third-party-assets.md.

LanguageRepository stores pay_by_second.language.v1 independently. Salary profile.v1/schemaVersion=1 is unchanged. Language does not rewrite salary/currency/timezone/calendar region. Clearing finance keeps language. A successful language save returns directly to root home; failure keeps the previous language/page. Failed/unsupported loaded language falls back to Chinese with a warning/reselection entry.

### Source ownership

| Path | Responsibility |
|---|---|
| app/app.dart | Locale/theme/home and covered-route refresh gate |
| features/dashboard/presentation | Totals/period/privacy and snapshot subscribers |
| settings_hub.dart | Categories/language/data |
| configuration_editor.dart | Onboarding/category save/discard flow |
| configuration_fields.dart | Draft/fields, no duplicate wage formulas |
| application/language_repository.dart | Language port |
| infrastructure/language_repository.dart | Official local-preference adapter |
| infrastructure/document_language_* | Web HTML locale and native no-op |
| shared/presentation/design.dart | Colors, widths, surfaces, localization |
| features/overtime/presentation | Overtime card/rules/history/correction |
| features/updates/presentation | Update information and user actions |

intl/web were promoted from existing transitives without new versions. No online translation, commercial UI or tracker. The updater adds ordinary INTERNET permission; it does not request sensitive runtime permissions. Flexible text/wheels and overtime: [feature design](overtime-and-input.md).

## 中文

实现更新：下文早期 MVP 的单规则、存储及跨夜边界已由 P0/P1 [版本化计算与可恢复数据设计](versioned-calculation-and-data.md)更新；未在其中明确实现的需求和目标架构仍属于计划。历史验证报告保留其原版本范围。

状态：已实现的 Web UI 结构。2026-11-09。

### 页面职责

```text
收入首页
  首次使用 → 薪资信息 → 计算方式 → [工作时间] → 确认保存
  设置目录
    薪资信息         月薪、入职日期
    计算方式         年/月均摊、全天/工作时间累计
    工作时间         周排班、始业终业、午休
    休假与补班       日期选择、上班/休息类型、移除例外
    显示偏好         刷新频率、小数位数
    语言             中文 / English / 日本語
    软件更新         当前/发行版本、自动开关、手动检查和浏览器下载
    数据与说明       本机隐私、当前限制、开源许可、清空薪资
```

首页提供统计范围下拉、金额显隐、设置入口，以及独立加班卡片的一键开始/结束、统计入口；加班规则不放在首页表单。次级卡片展示本月和入职以来金额，没有编辑或删除入口。完整统计范围仍支持入职以来、年、月、周、日、小时。

设置目录按计薪配置、界面偏好、数据说明分组。每个分类打开独立页面，长表单不放在弹窗。现有配置通过当前分类编辑；首次配置按短步骤引导，最后才写入存储。全天模式跳过工作时间步骤。

日期例外通过日期选择器创建，默认休息，可改为上班或移除。无需使用“日期=中文类型”等语言相关语法。官方节假日尚未接入的限制放在对应日期页和数据说明页。

### 保存与导航

- 规则修改保存前确认重算历史；显示偏好不弹重算确认。
- 返回或取消有未保存修改的页面时确认放弃；首次设置可以逐步返回，也可以取消整个流程。
- 保存失败保留草稿和当前页面。工资规则与计算引擎沿用现有实现，不因UI语言改变。
- 首页在分类页面、设置目录、数据说明及许可页被覆盖时不刷新。返回首页立即按当前时间重算。
- 金额显隐和统计范围在普通页面往返、语言或配置变更时保持；没有使用全局计时器或常驻所有表单。
- 使用 Flutter Navigator 与 MaterialPageRoute，不增加路由依赖；当前没有配置页URL深链接。

### 多语言

使用 Flutter 自带 gen-l10n：lib/l10n/app_en.arb 为模板，app_zh.arb 与 app_ja.arb 为翻译，生成代码位于 lib/l10n/generated。每种语言的消息随功能扩展，测试检查键集合、非空值和占位符一致性。

文案包含页面、字段、帮助、验证错误、失败反馈和确认弹窗。Material 日期选择器、返回等控件使用相同语言。Web HTML lang 属性同步为 zh/en/ja，便于辅助工具识别。

日语在标签中优先采用給与情報、計算方式、勤務時間、休日、表示精度、言語等汉字词；完整句子保留自然日语语法，不将中文词直接当作日语。字体优先使用Noto Sans JP的重命名本地子集，说明见third-party-assets.md。

语言通过独立的 LanguageRepository 存储到 pay_by_second.language.v1。旧 pay_by_second.profile.v1 和 schemaVersion=1 不变；切换语言不写薪资、不更改币种/时区、不转换日历地区。清空薪资也保留语言偏好。

语言保存成功后切换并自动返回根首页，失败保持原界面语言并提示。加载失败或不支持的语言值使用中文回退，语言页提供说明与重选入口。

### 源码分工

| 位置 | 职责 |
|---|---|
| app/app.dart | Locale与主题组装、首页、路由期间刷新开关 |
| features/dashboard/presentation | 收入展示、范围选择、金额显隐；只对数字区域订阅快照 |
| features/settings/presentation/settings_hub.dart | 分类目录、语言页、数据说明页 |
| features/settings/presentation/configuration_editor.dart | 分步/分类编辑流程、保存和未保存修改确认 |
| features/settings/presentation/configuration_fields.dart | 草稿与各分类字段；不重复实现工资公式 |
| application/language_repository.dart | 语言偏好接口 |
| infrastructure/language_repository.dart | 复用官方本地存储插件保存语言 |
| infrastructure/document_language_* | Web HTML语言属性及原生空适配 |
| shared/presentation/design.dart | 色彩、页面宽度、卡片和本地化上下文入口 |

intl与web仅从已有间接依赖提升为显式依赖，未新增依赖版本。未引入在线翻译、商业UI库或跟踪服务。该UI迭代未新增权限；0.2.1更新模块另新增普通INTERNET权限，不申请敏感运行时权限。

日期时间滚轮、灵活输入及加班账本详见 [专项设计](overtime-and-input.md)。
