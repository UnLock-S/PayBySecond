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
  String get dateError => 'Enter a valid date from 1970–2100 (YYYY-MM-DD).';

  @override
  String get shiftError => 'Use HH:mm. Start and end must be different.';

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
      'Salary and schedule will be removed permanently. Language preference is kept.';

  @override
  String get clear => 'Clear salary data';

  @override
  String get clearError => 'Could not clear data. Existing data is retained.';

  @override
  String get privacyBody =>
      'Salary is stored only on this device, without encryption. Browser cleanup may erase it. Keep your own records.';

  @override
  String get limitations => 'Current scope';

  @override
  String get limitationsBody =>
      'Local preview. Accounts, official holiday calendars, salary history and sync are not connected yet.';

  @override
  String get licenses => 'Open-source licenses';

  @override
  String get languageHelp =>
      'Changes interface language only, not currency, time zone or salary rules.';

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
}
