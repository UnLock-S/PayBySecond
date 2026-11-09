// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Income';

  @override
  String get settings => 'Settings';

  @override
  String get headline => 'Every second adds up.';

  @override
  String get subtitle => 'Your time, made tangible.';

  @override
  String get localOnly => 'Stored on this device';

  @override
  String get getStarted => 'Get started';

  @override
  String get welcomeTitle => 'Start with your salary';

  @override
  String get welcomeBody =>
      'Set your salary and calculation method in a few short steps.';

  @override
  String get estimateNote => 'Estimated income, not a payslip.';

  @override
  String get period => 'Period';

  @override
  String get employment => 'Since joining';

  @override
  String get year => 'This year';

  @override
  String get month => 'This month';

  @override
  String get week => 'This week';

  @override
  String get day => 'Today';

  @override
  String get hour => 'This hour';

  @override
  String get earned => 'Earned so far';

  @override
  String get hideAmount => 'Hide amounts';

  @override
  String get showAmount => 'Show amounts';

  @override
  String get accruing => 'Income is accruing';

  @override
  String get resting => 'Outside work hours · paused';

  @override
  String get notStarted => 'Employment has not started';

  @override
  String get perSecond => 'Per second';

  @override
  String get perMinute => 'Per minute';

  @override
  String updatedAt(String time) {
    return 'As of $time · UTC+08:00';
  }

  @override
  String get salarySection => 'Salary';

  @override
  String get salarySummary => 'Monthly salary and start date';

  @override
  String get calculationSection => 'Calculation';

  @override
  String get calculationSummary => 'Budget basis and paid time';

  @override
  String get scheduleSection => 'Work schedule';

  @override
  String get scheduleSummary => 'Workdays, shifts and lunch break';

  @override
  String get calendarSection => 'Days off & make-up work';

  @override
  String get calendarSummary => 'Date-specific schedule overrides';

  @override
  String get displaySection => 'Display';

  @override
  String get displaySummary => 'Refresh interval and decimal places';

  @override
  String get languageSection => 'Language';

  @override
  String get languageSummary => '中文 / English / 日本語';

  @override
  String get dataSection => 'Data & information';

  @override
  String get dataSummary => 'Privacy, licenses and local data';

  @override
  String get salaryLabel => 'Monthly salary (CNY)';

  @override
  String get startDate => 'Start date';

  @override
  String get currencyNote => 'Currency: CNY · Fixed time zone: UTC+08:00';

  @override
  String get annual => 'Annual average';

  @override
  String get monthly => 'Monthly average';

  @override
  String get annualHelp =>
      'The annual budget is salary × 12. Individual months may differ from your monthly salary.';

  @override
  String get monthlyHelp =>
      'Each complete month earns the monthly salary. The per-second rate varies by month.';

  @override
  String get budgetBasis => 'Budget basis';

  @override
  String get paidTime => 'Accrual time';

  @override
  String get calendarMode => 'All calendar time';

  @override
  String get workMode => 'Work hours only';

  @override
  String get calendarHelp =>
      'Accrues 24 hours a day, including weekends and holidays.';

  @override
  String get workHelp => 'Accrues only during scheduled work intervals.';

  @override
  String get weekdays => 'Working weekdays';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get shiftStart => 'Shift starts';

  @override
  String get shiftEnd => 'Shift ends';

  @override
  String get overnightHelp =>
      'An earlier end time means an overnight shift. Each calendar date uses its own schedule.';

  @override
  String get lunch => 'Deduct lunch break';

  @override
  String get lunchDetail => '12:00–13:00, only where it overlaps the shift';

  @override
  String get workOnlyNote => 'Applies only to Work hours only mode.';

  @override
  String get calendarWarning =>
      'Official holiday calendars are not connected. Other dates follow your weekly schedule.';

  @override
  String get addDate => 'Add a date';

  @override
  String get noOverrides => 'No date overrides yet';

  @override
  String get noOverridesHelp =>
      'Add a day off or make-up workday to override the weekly schedule.';

  @override
  String get workingDay => 'Workday';

  @override
  String get restDay => 'Day off';

  @override
  String get remove => 'Remove';

  @override
  String get refresh => 'Refresh interval';

  @override
  String get refreshNormal => 'Every second';

  @override
  String get refreshFast => 'Every 100 ms';

  @override
  String get refreshHelp =>
      'Updates only while visible. Higher frequency may use more power.';

  @override
  String get precision => 'Decimal places';

  @override
  String digitsLabel(int count) {
    return '$count decimal places';
  }

  @override
  String get save => 'Save changes';

  @override
  String get saving => 'Saving…';

  @override
  String get cancel => 'Cancel';

  @override
  String get next => 'Continue';

  @override
  String get previous => 'Previous';

  @override
  String get review => 'Review';

  @override
  String get finish => 'View my income';

  @override
  String get reviewHelp =>
      'Save on this device. No background process is needed.';

  @override
  String get edit => 'Edit';

  @override
  String get recalculateTitle => 'Recalculate past income?';

  @override
  String get recalculateBody =>
      'Only one rule set is stored. Saving will recalculate all past estimates. Salary history is not supported yet.';

  @override
  String get confirmSave => 'Save & recalculate';

  @override
  String get discardTitle => 'Discard unsaved changes?';

  @override
  String get discardBody => 'Your unsaved changes on this page will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get salaryError =>
      'Enter a non-negative amount with up to two decimal places.';

  @override
  String get dateError => 'Enter a valid year-first date from 1970–2100.';

  @override
  String get shiftError =>
      'Enter a valid time (e.g. 8 or 08:05). Start and end must differ.';

  @override
  String get saveError =>
      'Could not save. Your input is retained; please retry.';

  @override
  String get loadError =>
      'Could not load local data. Existing data is retained. Retry or configure again.';

  @override
  String get retry => 'Retry';

  @override
  String get clearTitle => 'Clear local salary data?';

  @override
  String get clearBody =>
      'Salary, schedule and overtime records will be removed permanently. Language preference is kept.';

  @override
  String get clear => 'Clear salary data';

  @override
  String get clearError =>
      'Cleanup did not finish. Some data may already be removed; please retry.';

  @override
  String get privacyBody =>
      'Salary is stored only on this device, without encryption. Browser cleanup may erase it; keep your own records. Optional update checks contact GitHub for version metadata only, without uploading salary.';

  @override
  String get limitations => 'Current scope';

  @override
  String get limitationsBody =>
      'Local preview. Accounts, official holiday calendars, salary history and sync are not connected yet.';

  @override
  String get licenses => 'Open-source licenses';

  @override
  String get languageHelp =>
      'Selecting a language returns home automatically; currency, time zone and salary rules are unchanged.';

  @override
  String get languageSaveError =>
      'Could not save language. The current language is unchanged.';

  @override
  String get noWorkdays =>
      'With no workdays selected, work-mode income is zero.';

  @override
  String get zeroSalary => 'Salary is zero';

  @override
  String get languageLoadError =>
      'Could not load language preference; using Chinese until you choose a language.';

  @override
  String get dateInputHelp => 'e.g. 20261109, 2026/11/9; year first';

  @override
  String get timeInputHelp => 'e.g. 8, 08, 805, 8:5 (24-hour clock)';

  @override
  String get wheelPicker => 'Scroll to select';

  @override
  String get pickerDone => 'Done';

  @override
  String get otTitle => 'Overtime';

  @override
  String get otDetails => 'Overtime details';

  @override
  String get otIdle => 'Leaving on time is a win, too';

  @override
  String get otRunning => 'Overtime in progress';

  @override
  String get otTotalTime => 'Total overtime';

  @override
  String get otThisTime => 'This session';

  @override
  String get otExpected => 'Expected overtime pay';

  @override
  String get otLegalReference => 'Statutory reference';

  @override
  String otJoke(String amount) {
    return 'Time donated: about $amount. Boss happiness +1';
  }

  @override
  String get otJokeHelp =>
      'Unpaid time valued at 1× the reference hourly rate; not a payroll deduction.';

  @override
  String get otStart => 'Start overtime';

  @override
  String get otStop => 'Stop overtime';

  @override
  String get otIndependent => 'Tracked separately from regular income.';

  @override
  String get otSettings => 'Overtime rules';

  @override
  String get otSettingsHelp =>
      'First save starts a session. After that, start or stop with one tap. Changes apply to new sessions only.';

  @override
  String get otPayMode => 'Overtime pay';

  @override
  String get otUnpaid => 'Unpaid';

  @override
  String get otStatutory => 'Statutory reference rate';

  @override
  String get otSingle => '1× hourly rate';

  @override
  String get otCustom => 'Custom multiplier';

  @override
  String get otDayType => 'Session day classification';

  @override
  String get otWeekday => 'Extended working day';

  @override
  String get otRest => 'Rest day';

  @override
  String get otHoliday => 'Statutory holiday';

  @override
  String get otCompLeave => 'Compensatory leave arranged';

  @override
  String get otCompHelp =>
      'Rest-day statutory cash reference becomes zero; statutory holidays remain 3×.';

  @override
  String get otBase => 'Monthly overtime wage base';

  @override
  String get otMultiplier => 'Multiplier (0.01–100)';

  @override
  String get otMultiplierError =>
      'Enter 0.01–100 with up to two decimal places.';

  @override
  String get otLegalHelp =>
      'Mainland China, standard hours: hourly base = monthly base ÷ 21.75 ÷ 8. Weekday 1.5×; rest day without compensatory leave 2×; statutory holiday 3×. Select day type manually; split sessions when day type changes. No official holiday lookup. Not for comprehensive or irregular working hours. Estimates are not received wages.';

  @override
  String get otSaveDefaults => 'Save rules for new sessions';

  @override
  String get otSaveStart => 'Save & start overtime';

  @override
  String get otSaveError =>
      'Not saved. Check for clock rollback, overlapping records or the 2,000-record limit, then retry.';

  @override
  String get otLoadError =>
      'Overtime data could not be loaded. Existing data is retained; retry to continue.';

  @override
  String get otUnpaidValue => 'Total unpaid-time value';

  @override
  String get otHistory => 'Session history';

  @override
  String get otHistoryHelp =>
      'Up to 2,000 sessions, never auto-deleted. Correct an end time if you forgot to stop (UTC+08:00, minute precision).';

  @override
  String get otEmpty => 'No overtime yet. Keep up the good habit.';

  @override
  String get otCorrectEnd => 'Correct end time';

  @override
  String get otDeleteTitle => 'Delete this session?';

  @override
  String get otDeleteBody =>
      'This permanently removes the local record and updates totals.';

  @override
  String get otMore => 'Show more sessions';

  @override
  String get otEndDate => 'End date';

  @override
  String get otEndTime => 'End time';

  @override
  String get otEndError => 'End must be between session start and now.';

  @override
  String get otCorrectionHelp =>
      'Enter the end in UTC+08:00. This recalculates the session; overlaps are not allowed.';

  @override
  String get otSaveCorrection => 'Save & recalculate session';

  @override
  String get softwareUpdate => 'Software update';

  @override
  String get updateMenuSummary => 'GitHub releases, notes and manual checks';

  @override
  String get updateLoading => 'Reading installed version…';

  @override
  String updateInstalled(String version) {
    return 'Installed: $version';
  }

  @override
  String updateReleaseVersion(String version) {
    return 'Release: $version';
  }

  @override
  String updateFound(String version) {
    return 'Update available: $version';
  }

  @override
  String get updateIdle => 'Updates have not been checked yet.';

  @override
  String get updateChecking => 'Checking GitHub releases…';

  @override
  String get updateAvailable => 'A newer stable release is available.';

  @override
  String get updateCurrent => 'No newer stable release was found.';

  @override
  String get updateNoRelease =>
      'No publicly accessible stable release. The repository may be private or have no published release.';

  @override
  String get updateOffline =>
      'This check did not complete. Check your connection and retry. Any displayed release may be cached.';

  @override
  String get updateRateLimited =>
      'GitHub has limited requests. Please try again later.';

  @override
  String get updateInvalid =>
      'Release metadata does not meet update rules; this check was rejected.';

  @override
  String get updatePreferenceError =>
      'Could not read or save update preferences. Please retry.';

  @override
  String get updateWebHelp =>
      'APK checks are for Android. The Web app is updated by deployment; you can still view GitHub releases.';

  @override
  String updateLastCheck(String time) {
    return 'Last successful check: $time';
  }

  @override
  String get updateCheckNow => 'Check now';

  @override
  String get updateFrequencyHelp =>
      'Manual checks are at least 30 seconds apart. Only stable releases are checked, not prereleases.';

  @override
  String get updateAutomatic => 'Check automatically on startup';

  @override
  String get updateAutomaticHelp =>
      'On by default, at most once per 24 hours. No background polling; turn off at any time.';

  @override
  String get updateNoNotes => 'No release notes were provided.';

  @override
  String get updateMissingApk =>
      'This release has no matching APK for this architecture. Check the release page.';

  @override
  String get updateDownload => 'Download APK in browser';

  @override
  String get updateInstallHelp =>
      'Download with the system browser, then install manually. APKs must retain the original signing certificate. This app requests no install or storage permission. Any SHA256 shown comes from GitHub metadata; the downloaded file is not verified by this app.';

  @override
  String get updatePrivacyHelp =>
      'Only the configured public GitHub API is contacted. No salary, schedule or overtime data is uploaded, and no GitHub token is bundled. Android uses the normal INTERNET permission without a runtime prompt.';

  @override
  String get updateOpenReleases => 'View GitHub releases';

  @override
  String get updateOpenError =>
      'Could not open a browser. Copy the release URL shown on this page.';
}
