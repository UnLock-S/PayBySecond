// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get home => '収入';

  @override
  String get settings => '設定';

  @override
  String get headline => '毎秒、積み重なる収入。';

  @override
  String get subtitle => '時間を、見える収入へ。';

  @override
  String get localOnly => '端末内保存';

  @override
  String get getStarted => '初期設定';

  @override
  String get welcomeTitle => '給与情報から開始';

  @override
  String get welcomeBody => '給与と計算方式を順に設定し、概算収入を確認。';

  @override
  String get estimateNote => '概算収入。実際の支給額とは異なります。';

  @override
  String get period => '集計期間';

  @override
  String get employment => '入社以降';

  @override
  String get year => '本年';

  @override
  String get month => '今月';

  @override
  String get week => '今週';

  @override
  String get day => '本日';

  @override
  String get hour => '現在の時間帯';

  @override
  String get earned => '累計収入';

  @override
  String get hideAmount => '金額非表示';

  @override
  String get showAmount => '金額表示';

  @override
  String get accruing => '収入加算中';

  @override
  String get resting => '勤務時間外・加算停止';

  @override
  String get notStarted => '入社前';

  @override
  String get perSecond => '毎秒';

  @override
  String get perMinute => '毎分';

  @override
  String updatedAt(String time) {
    return '計算時刻 $time・UTC+08:00';
  }

  @override
  String get salarySection => '給与情報';

  @override
  String get salarySummary => '月給・入社日';

  @override
  String get calculationSection => '計算方式';

  @override
  String get calculationSummary => '平均基準・加算時間';

  @override
  String get scheduleSection => '勤務時間';

  @override
  String get scheduleSummary => '勤務曜日・始業終業・昼休憩';

  @override
  String get calendarSection => '休日・振替出勤';

  @override
  String get calendarSummary => '日付別の勤務設定';

  @override
  String get displaySection => '表示設定';

  @override
  String get displaySummary => '更新間隔・表示精度';

  @override
  String get languageSection => '言語';

  @override
  String get languageSummary => '中文 / English / 日本語';

  @override
  String get dataSection => '情報・データ';

  @override
  String get dataSummary => '個人情報・許諾・端末内データ';

  @override
  String get salaryLabel => '月給（人民元）';

  @override
  String get startDate => '入社日';

  @override
  String get currencyNote => '通貨：人民元 CNY・表示時刻：UTC+08:00（固定）';

  @override
  String get annual => '年平均';

  @override
  String get monthly => '月平均';

  @override
  String get annualHelp => '年間予算は月給×12。各月の累計は月給と異なる場合があります。';

  @override
  String get monthlyHelp => '各月の予算は月給と同額。毎秒の加算額は月ごとに変動。';

  @override
  String get budgetBasis => '平均基準';

  @override
  String get paidTime => '加算時間';

  @override
  String get calendarMode => '全日加算';

  @override
  String get workMode => '勤務時間限定';

  @override
  String get calendarHelp => '土日祝日を含む、毎日24時間の加算。';

  @override
  String get workHelp => '勤務日の設定時間内のみ加算。';

  @override
  String get weekdays => '勤務曜日';

  @override
  String get mon => '月';

  @override
  String get tue => '火';

  @override
  String get wed => '水';

  @override
  String get thu => '木';

  @override
  String get fri => '金';

  @override
  String get sat => '土';

  @override
  String get sun => '日';

  @override
  String get shiftStart => '始業時刻';

  @override
  String get shiftEnd => '終業時刻';

  @override
  String get overnightHelp => '終業が始業より早い場合は夜勤。各日付の勤務設定を適用。';

  @override
  String get lunch => '昼休憩控除';

  @override
  String get lunchDetail => '12:00–13:00、勤務時間との重複分のみ';

  @override
  String get workOnlyNote => '勤務時間限定の計算時のみ適用。';

  @override
  String get calendarWarning => '公式祝日情報は未連携。未設定の日付は勤務曜日で概算。';

  @override
  String get addDate => '日付追加';

  @override
  String get noOverrides => '日付別設定なし';

  @override
  String get noOverridesHelp => '休日・振替出勤を追加すると、勤務曜日より優先。';

  @override
  String get workingDay => '出勤';

  @override
  String get restDay => '休日';

  @override
  String get remove => '削除';

  @override
  String get refresh => '更新間隔';

  @override
  String get refreshNormal => '1秒間隔';

  @override
  String get refreshFast => '100ms間隔';

  @override
  String get refreshHelp => '画面表示中のみ更新。高頻度更新は電力消費が増える場合があります。';

  @override
  String get precision => '表示精度';

  @override
  String digitsLabel(int count) {
    return '小数点以下$count桁';
  }

  @override
  String get save => '設定保存';

  @override
  String get saving => '保存中…';

  @override
  String get cancel => '取消';

  @override
  String get next => '次へ';

  @override
  String get previous => '前へ';

  @override
  String get review => '設定確認';

  @override
  String get finish => '収入確認';

  @override
  String get reviewHelp => '設定は端末内に保存。背景での常時実行は不要。';

  @override
  String get edit => '変更';

  @override
  String get recalculateTitle => '過去の収入を再計算？';

  @override
  String get recalculateBody => '現在は設定を1件のみ保存。変更後は過去の概算収入も再計算。給与履歴は未対応。';

  @override
  String get confirmSave => '保存・再計算';

  @override
  String get discardTitle => '未保存の変更を破棄？';

  @override
  String get discardBody => 'この画面の未保存の変更は失われます。';

  @override
  String get discard => '変更破棄';

  @override
  String get keepEditing => '編集継続';

  @override
  String get salaryError => '0以上、小数点以下2桁以内で入力。';

  @override
  String get dateError => '1970～2100年の有効な日付を入力（YYYY-MM-DD）。';

  @override
  String get shiftError => 'HH:mm形式で入力。始業と終業は別時刻に設定。';

  @override
  String get saveError => '保存失敗。入力内容は保持されています。再試行してください。';

  @override
  String get loadError => '端末内データの読込失敗。元データは保持。再読込または再設定。';

  @override
  String get retry => '再試行';

  @override
  String get clearTitle => '端末内の給与データを削除？';

  @override
  String get clearBody => '給与・勤務設定を完全削除。言語設定は保持。';

  @override
  String get clear => '給与データ削除';

  @override
  String get clearError => '削除失敗。元データは保持。';

  @override
  String get privacyBody =>
      '給与は端末内のみ保存、暗号化なし。閲覧履歴の消去等で失われる場合があります。別途記録を保管してください。';

  @override
  String get limitations => '対応範囲';

  @override
  String get limitationsBody => '端末内試用版。認証・公式祝日・給与履歴・端末間同期は未対応。';

  @override
  String get licenses => '利用許諾';

  @override
  String get languageHelp => '表示言語のみ変更。通貨・時刻基準・給与計算は変更なし。';

  @override
  String get languageSaveError => '言語設定の保存失敗。現在の言語を保持。';

  @override
  String get noWorkdays => '勤務曜日未選択の場合、勤務時間限定の収入は0。';

  @override
  String get zeroSalary => '月給0';

  @override
  String get languageLoadError => '言語設定の読込失敗。一時的に中国語を使用。設定から変更可能。';
}
