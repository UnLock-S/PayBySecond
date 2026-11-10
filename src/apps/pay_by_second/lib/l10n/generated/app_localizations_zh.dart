// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get home => '收入';

  @override
  String get settings => '设置';

  @override
  String get headline => '让每一秒，有所积累。';

  @override
  String get subtitle => '你的时间，正在转化为收入。';

  @override
  String get localOnly => '仅本机保存';

  @override
  String get getStarted => '开始设置';

  @override
  String get welcomeTitle => '从一份薪资开始';

  @override
  String get welcomeBody => '分步填写薪资与计算方式，随时查看预计收入。';

  @override
  String get estimateNote => '预计收入，不代表实际到账。';

  @override
  String get period => '统计范围';

  @override
  String get employment => '入职以来';

  @override
  String get year => '本年';

  @override
  String get month => '本月';

  @override
  String get week => '本周';

  @override
  String get day => '本日';

  @override
  String get hour => '本小时';

  @override
  String get earned => '模拟累计';

  @override
  String get hideAmount => '隐藏金额';

  @override
  String get showAmount => '显示金额';

  @override
  String get accruing => '收入累计中';

  @override
  String get resting => '休息时间 · 暂停累计';

  @override
  String get notStarted => '尚未入职';

  @override
  String get perSecond => '每秒';

  @override
  String get perMinute => '每分钟';

  @override
  String updatedAt(String time) {
    return '计算至 $time · UTC+08:00';
  }

  @override
  String get salarySection => '薪资信息';

  @override
  String get salarySummary => '月薪与入职日期';

  @override
  String get calculationSection => '计算方式';

  @override
  String get calculationSummary => '均摊基准与累计时间';

  @override
  String get scheduleSection => '工作时间';

  @override
  String get scheduleSummary => '工作周、上下班与午休';

  @override
  String get calendarSection => '休假与补班';

  @override
  String get calendarSummary => '按日期覆盖每周排班';

  @override
  String get displaySection => '显示偏好';

  @override
  String get displaySummary => '刷新频率与金额精度';

  @override
  String get languageSection => '语言';

  @override
  String get languageSummary => '中文 / English / 日本語';

  @override
  String get dataSection => '数据与说明';

  @override
  String get dataSummary => '隐私、许可与本机数据管理';

  @override
  String get salaryLabel => '月薪（人民币）';

  @override
  String get startDate => '入职日期';

  @override
  String get currencyNote => '币种：人民币 CNY · 固定时区：UTC+08:00';

  @override
  String get annual => '按年均摊';

  @override
  String get monthly => '按月均摊';

  @override
  String get annualHelp => '全年预算为月薪 × 12，单月累计可能与月薪不同。';

  @override
  String get monthlyHelp => '同一规则覆盖完整月份时使用一份月预算；月中变更时各规则使用完整月份分母。';

  @override
  String get budgetBasis => '均摊基准';

  @override
  String get paidTime => '累计时间';

  @override
  String get calendarMode => '全天累计';

  @override
  String get workMode => '仅工作时段';

  @override
  String get calendarHelp => '全年每天 24 小时累计，包含周末和节假日。';

  @override
  String get workHelp => '只在有效工作日的排班时间累计。';

  @override
  String get weekdays => '每周工作日';

  @override
  String get mon => '一';

  @override
  String get tue => '二';

  @override
  String get wed => '三';

  @override
  String get thu => '四';

  @override
  String get fri => '五';

  @override
  String get sat => '六';

  @override
  String get sun => '日';

  @override
  String get shiftStart => '上班时间';

  @override
  String get shiftEnd => '下班时间';

  @override
  String get overnightHelp => '下班早于上班表示跨夜班，按实际日期应用排班。';

  @override
  String get lunch => '扣除午休';

  @override
  String get lunchDetail => '12:00–13:00，仅扣除与班次重叠部分';

  @override
  String get workOnlyNote => '此设置仅在“仅工作时段”模式生效。';

  @override
  String get calendarWarning => '个人覆盖仅影响模拟工作时间，不用于判定法定加班倍数。';

  @override
  String get addDate => '添加日期';

  @override
  String get noOverrides => '暂无日期例外';

  @override
  String get noOverridesHelp => '添加休假或补班日期，优先于每周排班。';

  @override
  String get workingDay => '上班';

  @override
  String get restDay => '休息';

  @override
  String get remove => '移除';

  @override
  String get refresh => '刷新频率';

  @override
  String get refreshNormal => '每秒一次';

  @override
  String get refreshFast => '每 100ms 一次';

  @override
  String get refreshHelp => '仅在前台更新，较高频率可能增加耗电。';

  @override
  String get precision => '金额精度';

  @override
  String digitsLabel(int count) {
    return '$count 位小数';
  }

  @override
  String get save => '保存设置';

  @override
  String get saving => '保存中…';

  @override
  String get cancel => '取消';

  @override
  String get next => '下一步';

  @override
  String get previous => '上一步';

  @override
  String get review => '确认设置';

  @override
  String get finish => '开始查看收入';

  @override
  String get reviewHelp => '确认后保存到本机，后台无需持续运行。';

  @override
  String get edit => '修改';

  @override
  String get recalculateTitle => '确认规则变更';

  @override
  String get recalculateBody =>
      '保存带生效日的规则，之前区间保留原规则。同日修正会归档旧值。提前入职日会延伸初始假设。不同规则各用完整周期分母，合计可能不同于固定薪资预算。';

  @override
  String get confirmSave => '确认变更';

  @override
  String get discardTitle => '放弃未保存修改？';

  @override
  String get discardBody => '返回后，本页未保存的修改将丢失。';

  @override
  String get discard => '放弃修改';

  @override
  String get keepEditing => '继续编辑';

  @override
  String get salaryError => '请输入非负金额，最多两位小数。';

  @override
  String get dateError => '请输入1970至2100年的有效日期，年份在前。';

  @override
  String get shiftError => '请输入有效时间（如8、08:05），开始和结束不能相同。';

  @override
  String get saveError => '保存失败，输入已保留，请重试。';

  @override
  String get loadError => '本机数据读取失败。原数据已保留，可重试读取或重新设置。';

  @override
  String get retry => '重试';

  @override
  String get clearTitle => '清空本机薪资数据？';

  @override
  String get clearBody => '薪资、工作时间和加班记录将永久移除，语言偏好保留。';

  @override
  String get clear => '清空薪资数据';

  @override
  String get clearError => '清理未完成，部分数据可能已移除，请重试。';

  @override
  String get privacyBody =>
      '薪资仅保存在本机，尚未加密，清理浏览器数据可能丢失，请自行备份。可选的更新检查只访问GitHub版本信息，不上传薪资。';

  @override
  String get limitations => '当前范围';

  @override
  String get limitationsBody => '本地模拟。不提供真实账号、云同步、税务或工资结算、已核实考勤。政策数据须单独核验。';

  @override
  String get licenses => '开源许可';

  @override
  String get languageHelp => '选择语言后自动返回首页；不改币种、时区或薪资规则。';

  @override
  String get languageSaveError => '语言保存失败，当前语言保持不变。';

  @override
  String get noWorkdays => '未选择工作日时，工作模式累计为零。';

  @override
  String get zeroSalary => '月薪为零';

  @override
  String get languageLoadError => '语言偏好读取失败，暂用中文；可在设置中重选。';

  @override
  String get dateInputHelp => '如 20261109、2026/11/9、2026年11月9日';

  @override
  String get timeInputHelp => '如 8、08、805、8:5（24小时制）';

  @override
  String get wheelPicker => '滑动选择';

  @override
  String get pickerDone => '确定';

  @override
  String get otTitle => '加班账本';

  @override
  String get otDetails => '加班统计';

  @override
  String get otIdle => '准点下班，也是一种胜利';

  @override
  String get otRunning => '加班中';

  @override
  String get otTotalTime => '累计加班';

  @override
  String get otThisTime => '本次加班';

  @override
  String get otExpected => '所选工资估值 · 已知部分小计';

  @override
  String get otLegalReference => '法规参考 · 已知部分小计';

  @override
  String otJoke(String amount) {
    return '这波约亏 $amount，老板快乐 +1';
  }

  @override
  String get otJokeHelp => '仅按1倍参考时薪估算无薪时间价值，不是实际扣薪。';

  @override
  String get otStart => '一键加班';

  @override
  String get otStop => '结束加班';

  @override
  String get otIndependent => '加班单独统计，不叠加到首页正常工资。';

  @override
  String get otSettings => '加班规则';

  @override
  String get otSettingsHelp => '首次保存并开始；以后首页一键开始或结束。规则只用于新记录，已有记录保留原规则。';

  @override
  String get otPayMode => '加班工资';

  @override
  String get otUnpaid => '无加班工资';

  @override
  String get otStatutory => '法定参考倍数';

  @override
  String get otSingle => '1倍工资';

  @override
  String get otCustom => '自定义倍数';

  @override
  String get otDayType => '本次加班日期性质';

  @override
  String get otWeekday => '工作日延时';

  @override
  String get otRest => '休息日';

  @override
  String get otHoliday => '法定节假日';

  @override
  String get otCompLeave => '休息日已安排补休';

  @override
  String get otCompHelp => '休息日已确认合规安排补休：现金参考可能为零，对应工时仍单独记录。';

  @override
  String get otBase => '加班计算月工资基数';

  @override
  String get otMultiplier => '工资倍数（0.01至100）';

  @override
  String get otMultiplierError => '请输入0.01至100，最多两位小数。';

  @override
  String get otLegalHelp =>
      '中国大陆标准工时参考：时薪=所填月基数÷21.75÷8。工作日1.5倍、休息日未补休2倍、法定节假日3倍。日期性质需手选，跨日性质变化请分段记录；不自动识别官方节假日。不适用于综合或不定时工时，金额为估算而非已到账工资。';

  @override
  String get otSaveDefaults => '保存新加班规则';

  @override
  String get otSaveStart => '保存并开始加班';

  @override
  String get otSaveError => '操作未保存。请检查时间是否倒退、记录是否重叠或达到2000条上限，然后重试。';

  @override
  String get otLoadError => '加班数据读取失败，已保留原数据。重试前禁止覆盖。';

  @override
  String get otUnpaidValue => '累计无薪时间参考价值';

  @override
  String get otHistory => '加班记录';

  @override
  String get otHistoryHelp => '上限2000条，不自动删除；忘记结束可修正结束时间（UTC+08:00，精确到分钟）。';

  @override
  String get otEmpty => '还没有加班记录，保持这个好习惯。';

  @override
  String get otCorrectEnd => '修正结束时间';

  @override
  String get otDeleteTitle => '删除这条加班记录？';

  @override
  String get otDeleteBody => '该记录会从本地永久删除，统计随之更新。';

  @override
  String get otMore => '加载更多记录';

  @override
  String get otEndDate => '结束日期';

  @override
  String get otEndTime => '结束时间';

  @override
  String get otEndError => '结束时间不能早于开始，不能晚于现在。';

  @override
  String get otCorrectionHelp => '按UTC+08:00输入结束日期和时间。修正将重算这条记录；不能与其他加班重叠。';

  @override
  String get otSaveCorrection => '保存并重算本条记录';

  @override
  String get softwareUpdate => '软件更新';

  @override
  String get updateMenuSummary => 'GitHub发行版、版本说明与手动检查';

  @override
  String get updateLoading => '正在读取版本信息…';

  @override
  String updateInstalled(String version) {
    return '当前版本 $version';
  }

  @override
  String updateReleaseVersion(String version) {
    return '发行版本 $version';
  }

  @override
  String updateFound(String version) {
    return '发现新版 $version';
  }

  @override
  String get updateIdle => '尚未检查更新';

  @override
  String get updateChecking => '正在检查GitHub发行版…';

  @override
  String get updateAvailable => '有较新的稳定发行版';

  @override
  String get updateCurrent => '未发现比当前版本更新的稳定发行版';

  @override
  String get updateNoRelease => '尚无可公开访问的稳定发行版。仓库可能仍为私有，或尚未发布Release。';

  @override
  String get updateOffline => '本次检查未完成，请检查网络后重试。已有版本信息可能来自缓存。';

  @override
  String get updateRateLimited => 'GitHub限制了请求，请稍后再试。';

  @override
  String get updateInvalid => '发行版信息不符合更新规则，已停止本次更新提示。';

  @override
  String get updatePreferenceError => '无法读取或保存更新设置，请重试。';

  @override
  String get updateWebHelp => 'APK更新检查用于Android版；Web版由网站部署更新。可打开GitHub发行页查看。';

  @override
  String updateLastCheck(String time) {
    return '上次成功检查：$time';
  }

  @override
  String get updateCheckNow => '立即检查';

  @override
  String get updateFrequencyHelp => '手动检查间隔至少30秒；只检查正式稳定版，不跟随测试预发布。';

  @override
  String get updateAutomatic => '启动时自动检查';

  @override
  String get updateAutomaticHelp => '默认开启，最多每24小时一次；后台不轮询，可随时关闭。';

  @override
  String get updateNoNotes => '该发行版没有填写更新说明。';

  @override
  String get updateMissingApk => '发行版中没有匹配当前架构的APK。请到发行页确认。';

  @override
  String get updateDownload => '用浏览器下载APK';

  @override
  String get updateInstallHelp =>
      '由系统浏览器下载后手动安装；安装包需沿用原签名。此应用不申请安装或存储权限。SHA256若显示，来自GitHub元数据，本应用未校验下载文件。';

  @override
  String get updatePrivacyHelp =>
      '仅向配置的GitHub公开接口检查版本，不上传薪资、排班或加班记录，不内置GitHub令牌。联网使用普通INTERNET权限，不弹出授权框。';

  @override
  String get updateOpenReleases => '查看GitHub发行页';

  @override
  String get updateOpenError => '无法打开浏览器，请复制页面中的发行链接。';

  @override
  String get effectiveDate => '生效日期';

  @override
  String get historyTitle => '薪资与排班历史';

  @override
  String get historyHelp => '首条规则为配置的初始假设，并非核实的工资记录。未来规则按生效日启用；被替换规则保留归档。';

  @override
  String get attribution => '跨日班次归属';

  @override
  String get calendarDate => '按日历日（原有规则）';

  @override
  String get shiftStartDate => '按班次起始日';

  @override
  String get attributionHelp =>
      '日历日模式分别应用每天的工作规则；起始日模式将开始当天规则延续至跨日部分。两者均非实际考勤。';

  @override
  String get workIntervals => '额外工作时段';

  @override
  String get breakIntervals => '自定义休息时段';

  @override
  String get addInterval => '添加时段';

  @override
  String get traceTitle => '计算依据';

  @override
  String get traceHelp =>
      '人民币模拟，固定 UTC+08:00。有理数精确计算，仅显示时四舍五入。不是工资单、权益认定或银行入账。';

  @override
  String get migrationPending => '迁移尚未写入成功，原始数据已保留。请重试后再编辑。';

  @override
  String get recoveryTitle => '备份与恢复';

  @override
  String get backupWarning =>
      '备份包含未加密的财务数据，请妥善保管。SHA-256 只能检测意外损坏，不证明真实性，也不加密。导入与恢复须确认后替换当前配置，保留副本仍可使用。';

  @override
  String get exportData => '导出备份';

  @override
  String get importData => '导入备份';

  @override
  String get restorePrevious => '恢复上次有效配置';

  @override
  String get restoreLegacy => '恢复旧版配置';

  @override
  String get operationFailed => '操作失败，未静默清空当前数据。请导出恢复副本或重试。';

  @override
  String get operationDone => '操作完成';

  @override
  String get backupJson => '备份 JSON（仅本地）';

  @override
  String get reviewImport => '预览替换内容';

  @override
  String get privacyScope => '隐藏首页及明细财务金额；不阻止系统截图，也不加密存储。';

  @override
  String get moreDetails => '更多明细';

  @override
  String get copy => '复制 JSON';

  @override
  String get policyTitle => '日历与政策数据';

  @override
  String get policyPending => '待人工核验';

  @override
  String get policyReviewed => '来源已核验';

  @override
  String get policyHelp =>
      '仅适用中国大陆。工作安排与法定分类分别管理，缺失分类保持未知。语言不改变适用地区；不自动请求政策或变更薪资。';

  @override
  String get policyUpdate => '联网检查政策数据';

  @override
  String get policyNetwork => '从本项目 GitHub 仓库获取公开政策 JSON？不发送薪资或工时数据，缓存可离线使用。';

  @override
  String get policyRollback => '使用上个缓存版本';

  @override
  String get policyApply => '应用已核对的工作日假设';

  @override
  String get policyConfirm => '我已核对官方来源，同意将这些日期作为个人模拟排班；不据此认定法定节日或加班资格。';

  @override
  String get policyUnknown => '法定分类未知';

  @override
  String get policySource => '官方来源与版本';

  @override
  String get personalOverride => '个人工作或休息覆盖';

  @override
  String get noPolicyYear => '本年缺少已核验日历，仍按周排班和个人覆盖计算。';

  @override
  String get policyCacheFailed => '更新或缓存读取失败，保留已有数据；必要时使用上个缓存版本。';

  @override
  String get legalOrdinary => '普通工作日';

  @override
  String get legalRest => '休息日';

  @override
  String get legalHoliday => '法定节假日';

  @override
  String get legalAdjusted => '调休补班日';

  @override
  String get legalPersonal => '个人休假';

  @override
  String get legalCompany => '公司休假';

  @override
  String get otScopeConfirm => '我确认适用中国大陆标准八小时工时制度，并确认独立加班工资基数适用。';

  @override
  String get otArrangedConfirm => '此次加班由单位安排，且已核对所选日期分类。';

  @override
  String get otReviewConfirm => '我已核对官方来源及适用条件。这只是本地个人确认，不代表主管机关认定。';

  @override
  String get otPendingHelp =>
      '条件未确认或日期分类未知时保留待核验。分类仅适用于确认的 UTC+08:00 日期，跨日部分不猜测。显示现金为已知部分小计，并非最终权益金额。';

  @override
  String get otPendingTime => '参考待核验工时';

  @override
  String get otCompTime => '已记录补休工时';

  @override
  String get otLegacy => '旧版快照：保留未核验的原有假设';

  @override
  String get otCorrectionRecorded => '结束时间修正已留痕';

  @override
  String get appearance => '外观';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get noEligibleTime => '当前预算周期无有效工作时间';

  @override
  String get restoreImport => '恢复上次导入前状态';
}
