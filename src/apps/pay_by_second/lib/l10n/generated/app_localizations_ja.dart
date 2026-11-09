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
  String get dateError => '1970～2100年の有効な日付を年・月・日の順で入力してください。';

  @override
  String get shiftError => '有効な時刻（例：8、08:05）を入力し、開始と終了を別時刻にしてください。';

  @override
  String get saveError => '保存失敗。入力内容は保持されています。再試行してください。';

  @override
  String get loadError => '端末内データの読込失敗。元データは保持。再読込または再設定。';

  @override
  String get retry => '再試行';

  @override
  String get clearTitle => '端末内の給与データを削除？';

  @override
  String get clearBody => '給与・勤務時間・時間外勤務履歴を完全に削除します。言語設定は保持します。';

  @override
  String get clear => '給与データ削除';

  @override
  String get clearError => '削除が完了しませんでした。一部データは削除済みの可能性があります。再試行してください。';

  @override
  String get privacyBody =>
      '給与は端末内のみ保存し、未暗号化です。ブラウザのデータ削除で失われる場合があるため、別途保管してください。任意の更新確認はGitHubの版情報だけを取得し、給与を送信しません。';

  @override
  String get limitations => '対応範囲';

  @override
  String get limitationsBody => '端末内試用版。認証・公式祝日・給与履歴・端末間同期は未対応。';

  @override
  String get licenses => '利用許諾';

  @override
  String get languageHelp => '言語を選ぶと自動的にホームへ戻ります。通貨・時間帯・給与規則は変わりません。';

  @override
  String get languageSaveError => '言語設定の保存失敗。現在の言語を保持。';

  @override
  String get noWorkdays => '勤務曜日未選択の場合、勤務時間限定の収入は0。';

  @override
  String get zeroSalary => '月給0';

  @override
  String get languageLoadError => '言語設定の読込失敗。一時的に中国語を使用。設定から変更可能。';

  @override
  String get dateInputHelp => '例：20261109、2026/11/9、2026年11月9日';

  @override
  String get timeInputHelp => '例：8、08、805、8:5（24時間制）';

  @override
  String get wheelPicker => '回転選択';

  @override
  String get pickerDone => '確定';

  @override
  String get otTitle => '時間外勤務';

  @override
  String get otDetails => '時間外勤務集計';

  @override
  String get otIdle => '定時退勤も立派な勝利';

  @override
  String get otRunning => '時間外勤務中';

  @override
  String get otTotalTime => '累計時間';

  @override
  String get otThisTime => '今回の勤務';

  @override
  String get otExpected => '設定に基づく残業代概算';

  @override
  String get otLegalReference => '中国法定基準の参考額';

  @override
  String otJoke(String amount) {
    return '約 $amount 分の時間を寄付。上司の幸福度 +1';
  }

  @override
  String get otJokeHelp => '無給時間を参考時給の1倍で換算した目安です。給与控除ではありません。';

  @override
  String get otStart => '勤務開始';

  @override
  String get otStop => '勤務終了';

  @override
  String get otIndependent => '通常給与とは別に集計します。';

  @override
  String get otSettings => '時間外勤務設定';

  @override
  String get otSettingsHelp => '初回保存で計測開始。以後はワンタップで開始・終了できます。設定変更は新規記録に適用します。';

  @override
  String get otPayMode => '残業代';

  @override
  String get otUnpaid => '残業代なし';

  @override
  String get otStatutory => '中国法定基準の倍率';

  @override
  String get otSingle => '時給の1倍';

  @override
  String get otCustom => '倍率指定';

  @override
  String get otDayType => '勤務日の区分';

  @override
  String get otWeekday => '通常勤務日の延長';

  @override
  String get otRest => '休日';

  @override
  String get otHoliday => '中国の法定祝日';

  @override
  String get otCompLeave => '休日勤務の振替休暇あり';

  @override
  String get otCompHelp => '休日勤務の法定現金参考額を0にします。法定祝日は3倍です。';

  @override
  String get otBase => '残業代計算用の月額給与';

  @override
  String get otMultiplier => '倍率（0.01～100）';

  @override
  String get otMultiplierError => '0.01～100を小数第2位までで入力してください。';

  @override
  String get otLegalHelp =>
      '中国大陸の標準労働時間制を参照：時給＝入力月額÷21.75÷8。通常勤務日1.5倍、振替休暇なしの休日2倍、法定祝日3倍。日区分は手動指定し、区分が変わる場合は記録を分けてください。祝日の自動判定、変形・不定時労働時間制には未対応。金額は入金済み給与ではなく概算です。';

  @override
  String get otSaveDefaults => '新規勤務の設定を保存';

  @override
  String get otSaveStart => '保存して勤務開始';

  @override
  String get otSaveError => '保存できませんでした。時刻の逆行、記録の重複、2000件の上限を確認して再試行してください。';

  @override
  String get otLoadError => '時間外勤務の読込失敗。元データを保持しています。再試行してください。';

  @override
  String get otUnpaidValue => '無給時間の累計参考価値';

  @override
  String get otHistory => '勤務履歴';

  @override
  String get otHistoryHelp => '最大2000件、自動削除なし。終了忘れは終了時刻を修正できます（UTC+08:00、分単位）。';

  @override
  String get otEmpty => '勤務記録はまだありません。定時退勤を続けましょう。';

  @override
  String get otCorrectEnd => '終了時刻修正';

  @override
  String get otDeleteTitle => 'この勤務記録を削除しますか？';

  @override
  String get otDeleteBody => '端末内の記録を完全に削除し、集計を更新します。';

  @override
  String get otMore => '履歴を追加表示';

  @override
  String get otEndDate => '終了日';

  @override
  String get otEndTime => '終了時刻';

  @override
  String get otEndError => '開始以降、現在以前の終了時刻を指定してください。';

  @override
  String get otCorrectionHelp =>
      'UTC+08:00の終了日時を入力します。再計算後の勤務時間が他の記録と重複しないようにしてください。';

  @override
  String get otSaveCorrection => '保存して記録を再計算';

  @override
  String get softwareUpdate => 'ソフトウェア更新';

  @override
  String get updateMenuSummary => 'GitHub公開版・更新内容・手動確認';

  @override
  String get updateLoading => 'バージョンを読込中…';

  @override
  String updateInstalled(String version) {
    return '現在の版：$version';
  }

  @override
  String updateReleaseVersion(String version) {
    return '公開版：$version';
  }

  @override
  String updateFound(String version) {
    return '新版 $version を検出';
  }

  @override
  String get updateIdle => '更新は未確認です。';

  @override
  String get updateChecking => 'GitHub公開版を確認中…';

  @override
  String get updateAvailable => '新しい安定版があります。';

  @override
  String get updateCurrent => '現在の版より新しい安定版はありません。';

  @override
  String get updateNoRelease => '公開取得できる安定版がありません。非公開リポジトリ、または未公開の可能性があります。';

  @override
  String get updateOffline =>
      '確認できませんでした。通信状態を確認して再試行してください。表示中の公開版情報は保存済みの場合があります。';

  @override
  String get updateRateLimited => 'GitHubの要求制限中です。時間を置いて再試行してください。';

  @override
  String get updateInvalid => '公開版の情報が更新条件に合わないため、今回の確認を中止しました。';

  @override
  String get updatePreferenceError => '更新設定の読込・保存に失敗しました。再試行してください。';

  @override
  String get updateWebHelp =>
      'APK更新確認はAndroid版用です。Web版はサイトの配信で更新します。GitHub公開ページは参照できます。';

  @override
  String updateLastCheck(String time) {
    return '前回の確認成功：$time';
  }

  @override
  String get updateCheckNow => '今すぐ確認';

  @override
  String get updateFrequencyHelp => '手動確認は30秒以上の間隔で実行します。安定版のみ対象で、先行公開版は対象外です。';

  @override
  String get updateAutomatic => '起動時に自動確認';

  @override
  String get updateAutomaticHelp =>
      '初期設定は有効、24時間に最大1回。バックグラウンドで定期確認せず、いつでも無効にできます。';

  @override
  String get updateNoNotes => '更新内容の記載はありません。';

  @override
  String get updateMissingApk => '現在の構成に対応するAPKがありません。公開ページを確認してください。';

  @override
  String get updateDownload => 'ブラウザでAPK取得';

  @override
  String get updateInstallHelp =>
      'システムブラウザで取得後、手動で導入します。元と同じ署名証明書が必要です。本アプリは導入・保存権限を要求しません。表示するSHA256はGitHubの情報で、取得ファイルを本アプリが検証するものではありません。';

  @override
  String get updatePrivacyHelp =>
      '設定済みのGitHub公開APIだけに接続します。給与・勤務表・時間外勤務履歴は送信せず、GitHubトークンも含めません。Androidの通常INTERNET権限を使用し、実行時の権限要求はありません。';

  @override
  String get updateOpenReleases => 'GitHub公開ページを表示';

  @override
  String get updateOpenError => 'ブラウザを開けませんでした。表示中の公開URLをコピーしてください。';
}
