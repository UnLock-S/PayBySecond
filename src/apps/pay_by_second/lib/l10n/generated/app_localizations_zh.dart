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
  String get earned => '累计收入';

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
  String get monthlyHelp => '每个完整月的预算等于月薪，每秒速率随月份变化。';

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
  String get calendarWarning => '尚未接入官方节假日，未覆盖日期按周排班估算。';

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
  String get recalculateTitle => '重算历史收入？';

  @override
  String get recalculateBody => '当前只保存一套规则。修改将按新配置重算全部历史，薪资历史版本尚未支持。';

  @override
  String get confirmSave => '保存并重算';

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
  String get dateError => '请输入 1970–2100 年的有效日期（YYYY-MM-DD）。';

  @override
  String get shiftError => '时间格式为 HH:mm，开始与结束不能相同。';

  @override
  String get saveError => '保存失败，输入已保留，请重试。';

  @override
  String get loadError => '本机数据读取失败。原数据已保留，可重试读取或重新设置。';

  @override
  String get retry => '重试';

  @override
  String get clearTitle => '清空本机薪资数据？';

  @override
  String get clearBody => '将删除薪资和排班，无法撤销。语言偏好保留。';

  @override
  String get clear => '清空薪资数据';

  @override
  String get clearError => '清空失败，原数据保留。';

  @override
  String get privacyBody => '薪资仅保存在此设备，未加密。浏览器清理存储后可能丢失，不应作为唯一记录。';

  @override
  String get limitations => '当前范围';

  @override
  String get limitationsBody => '本机体验版。账号、官方节假日日历、薪资历史与跨设备同步尚未接入。';

  @override
  String get licenses => '开源许可';

  @override
  String get languageHelp => '仅切换界面语言，不改变币种、时区或薪资规则。';

  @override
  String get languageSaveError => '语言保存失败，当前语言保持不变。';

  @override
  String get noWorkdays => '未选择工作日时，工作模式累计为零。';

  @override
  String get zeroSalary => '月薪为零';

  @override
  String get languageLoadError => '语言偏好读取失败，暂用中文；可在设置中重选。';
}
