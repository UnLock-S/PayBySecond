# Historical UI/i18n results / 多页面与多语言验证记录

## English

Historical UI/i18n record, 2026-11-09, before overtime/update additions. Initial results remain in web-mvp-validation.md; later reports carry current counts.

### Results

| Item | Executed scope |
|---|---|
| Core | Original 9 tests passed; no core changes in that UI iteration |
| App/widget | 14 passed: 3 models, 1 localization contract, 10 page flows |
| Onboarding | Three calendar-mode steps; work mode adds schedule; no persistence before confirmation |
| Categories | Isolated fields, discard, recalculation confirmation, failed-save draft retention |
| Date overrides | Picker plus work/rest options preserved existing salary |
| Languages | 114 messages each in zh/en/ja; keys/nonempty/placeholders consistent |
| Persistence | Language change/restart recovery; save failure retained old language; no salary/currency/zone changes |
| Visibility | Covered/background app stopped clock queries; return recomputed; mask persisted |
| Narrow widgets | All seven categories in three languages at 360×800, no layout error |
| Browser | Edge 156.0.4314.58, 1365×1000/390×844, all languages |
| Accessibility | html lang zh/en/ja; localized Material controls |
| Static/build | Dart formatting, both analyzers and Web Release passed |

Browser flows covered first save, live totals/masking, five field categories, licenses, language reload and byte-identical salary JSON. Isolated contexts used artificial 20000 salary. Wait for route transitions before screenshots. Eighteen desktop/mobile home/settings/salary screenshots plus machine results were stored in ignored out/reports/browser/; reproduce with tools/check/browser-smoke.cjs.

### Fonts/dependencies

SC/JP regular/bold fonts totaled 885432 bytes (~865 KiB), covering 727 shared characters plus framework kana; full upstream fonts remained local. Japanese ARB messages were asserted against JP source glyphs. With Google font domains blocked, all language flows had zero runtime errors/remote font requests. Framework license-page kana were covered too.

intl/web became direct dependencies without adding versions. The inventory still covered 85 package/version combinations. JP retained OFL-1.1 with original notice/registry.

### Limits

That iteration tested Web/widgets, did not build Android or measure native resources. Language changed presentation only, not currencies/calendars/timezones. Accounts, official calendars and salary history remained deferred. Later language auto-return/overtime/APK checks are documented separately.

## 中文

历史记录：本文件反映加班与更新功能加入前的UI版本，不代表当前测试总数。



日期：2026-11-09，Asia/Shanghai。与本记录同批的UI改动一起提交；初版功能记录保留在web-mvp-validation.md。

### 验证结果

| 项目 | 实际范围 |
|---|---|
| 计算核心 | 原有9项领域测试通过；本次未修改工资计算包 |
| 应用与组件 | 14项通过，包含3项原有应用模型测试、1项三语消息契约测试及10项页面流程测试 |
| 首次配置 | 全天模式分3步；工作模式增加独立排班步骤；最后确认前不持久化 |
| 分类配置 | 字段隔离、放弃未保存修改、规则重算确认、保存失败保留草稿 |
| 日期例外 | 原生日期选择器、上班/休息类型选项，保存后保留既有薪资 |
| 三语覆盖 | 中文/英语/日语各114条消息；键集合、非空内容与占位符一致 |
| 语言持久化 | 切换和重启恢复；失败保持原语言；切换不写薪资、不改币种或时区 |
| 后台与导航 | 进入二级页面和隐藏应用时不查询时钟；返回后立即重算；金额隐藏状态保留 |
| 窄屏组件测试 | 360×800，三种语言的全部7个设置分类入口与页面无布局异常 |
| 浏览器 | Edge 156.0.4314.58，1365×1000与390×844，三种语言均通过 |
| Web辅助信息 | HTML lang属性同步zh/en/ja；返回、日期等Material控件跟随Locale |
| 静态与构建 | Dart格式、应用/计算包静态分析、Web Release编译通过 |

浏览器流程实际覆盖首次保存、实时金额、显隐、五类独立字段页面、许可页往返、刷新后的语言恢复、薪资原始JSON保持不变。测试使用隔离上下文及人工构造的20000元月薪，与用户真实数据无关。

截图前等待页面转场结束。中文/英语/日语的桌面与手机收入页、设置目录、薪资页共18张截图及机器结果在out/reports/browser/，均为本机制品，不提交Git。复现入口为tools/check/browser-smoke.cjs。

### 字体与依赖

本地SC/JP各两个静态字重，共885432字节，约865KiB；全量上游字体不入仓库。共享覆盖集合727个字符，并包含框架内置日语控件需要的假名。生成器额外断言每条日语翻译由原始JP字形支持。

浏览器测试阻断Google远程字体域名后完整运行三语流程，运行异常和远程字体请求均为0。补充假名字形也覆盖了框架许可页中的“ライセンス”等词，不只覆盖自有ARB。

intl和web从已有间接依赖提升为显式依赖，未新增包版本。许可清单仍包含85个Dart/Flutter包版本组合，JP字体沿用OFL-1.1并新增原始声明及应用内许可登记。

### 边界

本次验证Web及Flutter组件层；未生成Android APK，未测原生平台内存/电量。语言只改变显示，不提供地区币种转换、地区工作日历或新时区规则。真实账号、官方节假日、薪资历史等原有限制继续保留。
