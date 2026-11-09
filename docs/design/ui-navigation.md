# 多页面与三语界面设计

状态：已实现的 Web UI 结构。2026-11-09。

## 页面职责

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
    数据与说明       本机隐私、当前限制、开源许可、清空薪资
```

首页只保留三类操作：统计范围下拉、金额显隐、设置入口。次级卡片展示本月和入职以来金额，没有编辑或删除入口。完整统计范围仍支持入职以来、年、月、周、日、小时。

设置目录按计薪配置、界面偏好、数据说明分组。每个分类打开独立页面，长表单不放在弹窗。现有配置通过当前分类编辑；首次配置按短步骤引导，最后才写入存储。全天模式跳过工作时间步骤。

日期例外通过日期选择器创建，默认休息，可改为上班或移除。无需使用“日期=中文类型”等语言相关语法。官方节假日尚未接入的限制放在对应日期页和数据说明页。

## 保存与导航

- 规则修改保存前确认重算历史；显示偏好不弹重算确认。
- 返回或取消有未保存修改的页面时确认放弃；首次设置可以逐步返回，也可以取消整个流程。
- 保存失败保留草稿和当前页面。工资规则与计算引擎沿用现有实现，不因UI语言改变。
- 首页在分类页面、设置目录、数据说明及许可页被覆盖时不刷新。返回首页立即按当前时间重算。
- 金额显隐和统计范围在普通页面往返、语言或配置变更时保持；没有使用全局计时器或常驻所有表单。
- 使用 Flutter Navigator 与 MaterialPageRoute，不增加路由依赖；当前没有配置页URL深链接。

## 多语言

使用 Flutter 自带 gen-l10n：lib/l10n/app_en.arb 为模板，app_zh.arb 与 app_ja.arb 为翻译，生成代码位于 lib/l10n/generated。当前每个语言114条消息，测试检查键集合、非空值和占位符一致性。

文案包含页面、字段、帮助、验证错误、失败反馈和确认弹窗。Material 日期选择器、返回等控件使用相同语言。Web HTML lang 属性同步为 zh/en/ja，便于辅助工具识别。

日语在标签中优先采用給与情報、計算方式、勤務時間、休日、表示精度、言語等汉字词；完整句子保留自然日语语法，不将中文词直接当作日语。字体优先使用Noto Sans JP的重命名本地子集，说明见third-party-assets.md。

语言通过独立的 LanguageRepository 存储到 pay_by_second.language.v1。旧 pay_by_second.profile.v1 和 schemaVersion=1 不变；切换语言不写薪资、不更改币种/时区、不转换日历地区。清空薪资也保留语言偏好。

语言保存成功后切换，失败保持原界面语言并提示。加载失败或不支持的语言值使用中文回退，语言页提供说明与重选入口。

## 源码分工

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

intl与web仅从已有间接依赖提升为显式依赖，未新增依赖版本。未引入在线翻译、商业UI库、跟踪服务或新的系统权限。
