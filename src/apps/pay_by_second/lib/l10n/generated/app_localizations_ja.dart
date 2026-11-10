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
  String get earned => '収入シミュレーション';

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
  String get monthlyHelp => '同一規則が一か月を覆う場合は月予算を使用します。月中変更では規則ごとに一か月全体の分母を使います。';

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
  String get calendarWarning => '個人設定は試算の勤務時間だけに適用し、法定手当の倍率判定には使用しません。';

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
  String get recalculateTitle => '規則変更の確認';

  @override
  String get recalculateBody =>
      '適用日付きの規則を保存します。それ以前の規則は維持し、同日修正では旧値を保管します。入社日を早めると初期仮定を延長します。規則ごとに全期間の分母を使うため、合計は固定給与額と異なる場合があります。';

  @override
  String get confirmSave => '変更を確定';

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
  String get limitationsBody =>
      '端末内の試算です。実アカウント、クラウド同期、税務・給与精算、確認済み出勤管理には対応していません。政策データは別途確認が必要です。';

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
  String get otExpected => '選択した手当の試算・確認可能分の小計';

  @override
  String get otLegalReference => '法令参考額・確認可能分の小計';

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
  String get otCompHelp => '休息日に適法な代休を手配済みの場合、支払参考額がゼロとなる場合も、対応時間は別途記録します。';

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

  @override
  String get effectiveDate => '適用開始日';

  @override
  String get historyTitle => '給与・勤務履歴';

  @override
  String get historyHelp =>
      '初期規則は設定上の仮定であり、確認済み給与記録ではありません。将来の規則は適用日から有効です。変更前の規則も保存します。';

  @override
  String get attribution => '日付をまたぐ勤務の帰属';

  @override
  String get calendarDate => '暦日単位（従来規則）';

  @override
  String get shiftStartDate => '勤務開始日単位';

  @override
  String get attributionHelp =>
      '暦日単位では各日の勤務規則を適用します。開始日単位では翌日の勤務部分にも開始日の規則を適用します。実際の出勤記録ではありません。';

  @override
  String get workIntervals => '追加勤務時間帯';

  @override
  String get breakIntervals => '休憩時間帯';

  @override
  String get addInterval => '時間帯を追加';

  @override
  String get traceTitle => '計算根拠';

  @override
  String get traceHelp =>
      '人民元の試算、UTC+08:00固定。有理数で計算し、表示時のみ四捨五入します。給与明細・法的権利の判定・入金額ではありません。';

  @override
  String get migrationPending => '移行を保存できませんでした。元データは保持しています。編集前に再試行してください。';

  @override
  String get recoveryTitle => 'バックアップ・復元';

  @override
  String get backupWarning =>
      'バックアップには暗号化されていない財務情報を含みます。安全に保管してください。SHA-256は破損検知用で、真正性の証明や暗号化ではありません。読込・復元は確認後に現在の設定を置き換え、保存済みの写しは保持します。';

  @override
  String get exportData => 'バックアップ出力';

  @override
  String get importData => 'バックアップ読込';

  @override
  String get restorePrevious => '直前の設定を復元';

  @override
  String get restoreLegacy => '旧版設定を復元';

  @override
  String get operationFailed =>
      '操作に失敗しました。現在のデータを自動消去していません。復元用の写しを出力するか再試行してください。';

  @override
  String get operationDone => '完了';

  @override
  String get backupJson => 'バックアップJSON（端末内）';

  @override
  String get reviewImport => '置換内容を確認';

  @override
  String get privacyScope => 'ホームと明細の金額を非表示にします。画面撮影の禁止や保存データの暗号化は行いません。';

  @override
  String get moreDetails => '詳細表示';

  @override
  String get copy => 'JSONをコピー';

  @override
  String get policyTitle => '暦・政策データ';

  @override
  String get policyPending => '人による確認待ち';

  @override
  String get policyReviewed => '出典確認済み';

  @override
  String get policyHelp =>
      '中国本土向けです。勤務予定と法定区分を分け、未確認の区分は不明のまま表示します。言語設定で適用地域は変わりません。政策取得や給与変更は自動実行しません。';

  @override
  String get policyUpdate => '政策データを取得';

  @override
  String get policyNetwork =>
      '本プロジェクトのGitHubから公開政策JSONを取得しますか。給与・勤務情報は送信しません。保存済みデータはオフラインでも使用できます。';

  @override
  String get policyRollback => '前の保存版に戻す';

  @override
  String get policyApply => '確認した勤務日の仮定を適用';

  @override
  String get policyConfirm =>
      '公式資料を確認し、この日程を個人の試算用勤務予定として採用します。法定休日や時間外手当の適用認定には使用しません。';

  @override
  String get policyUnknown => '法定区分不明';

  @override
  String get policySource => '公式資料・版情報';

  @override
  String get personalOverride => '個人の勤務・休暇設定';

  @override
  String get noPolicyYear => 'この年の確認済み暦はありません。週間勤務と個人設定を使用します。';

  @override
  String get policyCacheFailed =>
      '取得または保存データの読込に失敗しました。既存データを維持します。必要に応じて前の保存版をご利用ください。';

  @override
  String get legalOrdinary => '通常勤務日';

  @override
  String get legalRest => '休息日';

  @override
  String get legalHoliday => '法定休日';

  @override
  String get legalAdjusted => '振替勤務日';

  @override
  String get legalPersonal => '個人休暇';

  @override
  String get legalCompany => '会社休業日';

  @override
  String get otScopeConfirm =>
      '中国本土の標準8時間労働制が適用され、別途入力した時間外手当の計算基礎が適切であることを確認します。';

  @override
  String get otArrangedConfirm => 'この時間外勤務は使用者の指示によるもので、選択した日区分を確認しました。';

  @override
  String get otReviewConfirm => '公式資料と適用条件を確認しました。端末内の個人確認であり、公的機関の認定ではありません。';

  @override
  String get otPendingHelp =>
      '未確認の条件や日区分は確認待ちとします。区分は確認したUTC+08:00の日付だけに適用し、翌日分は推定しません。金額は確認可能な部分の小計であり、最終的な請求権の額ではありません。';

  @override
  String get otPendingTime => '参考額の確認待ち時間';

  @override
  String get otCompTime => '記録した代休時間';

  @override
  String get otLegacy => '旧版記録：未確認の従来仮定を保持';

  @override
  String get otCorrectionRecorded => '終了時刻の修正履歴';

  @override
  String get appearance => '表示テーマ';

  @override
  String get systemTheme => '端末設定に従う';

  @override
  String get lightTheme => 'ライト';

  @override
  String get darkTheme => 'ダーク';

  @override
  String get noEligibleTime => 'この予算期間に有効な勤務時間がありません';

  @override
  String get restoreImport => '前回読込前の状態を復元';
}
