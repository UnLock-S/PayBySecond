import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @headline.
  ///
  /// In en, this message translates to:
  /// **'Every second adds up.'**
  String get headline;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your time, made tangible.'**
  String get subtitle;

  /// No description provided for @localOnly.
  ///
  /// In en, this message translates to:
  /// **'Stored on this device'**
  String get localOnly;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with your salary'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Set your salary and calculation method in a few short steps.'**
  String get welcomeBody;

  /// No description provided for @estimateNote.
  ///
  /// In en, this message translates to:
  /// **'Estimated income, not a payslip.'**
  String get estimateNote;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @employment.
  ///
  /// In en, this message translates to:
  /// **'Since joining'**
  String get employment;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get month;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get week;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get day;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'This hour'**
  String get hour;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Simulated accrual'**
  String get earned;

  /// No description provided for @hideAmount.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get hideAmount;

  /// No description provided for @showAmount.
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get showAmount;

  /// No description provided for @accruing.
  ///
  /// In en, this message translates to:
  /// **'Income is accruing'**
  String get accruing;

  /// No description provided for @resting.
  ///
  /// In en, this message translates to:
  /// **'Outside work hours · paused'**
  String get resting;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Employment has not started'**
  String get notStarted;

  /// No description provided for @perSecond.
  ///
  /// In en, this message translates to:
  /// **'Per second'**
  String get perSecond;

  /// No description provided for @perMinute.
  ///
  /// In en, this message translates to:
  /// **'Per minute'**
  String get perMinute;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'As of {time} · UTC+08:00'**
  String updatedAt(String time);

  /// No description provided for @salarySection.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salarySection;

  /// No description provided for @salarySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly salary and start date'**
  String get salarySummary;

  /// No description provided for @calculationSection.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get calculationSection;

  /// No description provided for @calculationSummary.
  ///
  /// In en, this message translates to:
  /// **'Budget basis and paid time'**
  String get calculationSummary;

  /// No description provided for @scheduleSection.
  ///
  /// In en, this message translates to:
  /// **'Work schedule'**
  String get scheduleSection;

  /// No description provided for @scheduleSummary.
  ///
  /// In en, this message translates to:
  /// **'Workdays, shifts and lunch break'**
  String get scheduleSummary;

  /// No description provided for @calendarSection.
  ///
  /// In en, this message translates to:
  /// **'Days off & make-up work'**
  String get calendarSection;

  /// No description provided for @calendarSummary.
  ///
  /// In en, this message translates to:
  /// **'Date-specific schedule overrides'**
  String get calendarSummary;

  /// No description provided for @displaySection.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displaySection;

  /// No description provided for @displaySummary.
  ///
  /// In en, this message translates to:
  /// **'Refresh interval and decimal places'**
  String get displaySummary;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @languageSummary.
  ///
  /// In en, this message translates to:
  /// **'中文 / English / 日本語'**
  String get languageSummary;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data & information'**
  String get dataSection;

  /// No description provided for @dataSummary.
  ///
  /// In en, this message translates to:
  /// **'Privacy, licenses and local data'**
  String get dataSummary;

  /// No description provided for @salaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly salary (CNY)'**
  String get salaryLabel;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @currencyNote.
  ///
  /// In en, this message translates to:
  /// **'Currency: CNY · Fixed time zone: UTC+08:00'**
  String get currencyNote;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual average'**
  String get annual;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly average'**
  String get monthly;

  /// No description provided for @annualHelp.
  ///
  /// In en, this message translates to:
  /// **'The annual budget is salary × 12. Individual months may differ from your monthly salary.'**
  String get annualHelp;

  /// No description provided for @monthlyHelp.
  ///
  /// In en, this message translates to:
  /// **'A complete month under one unchanged rule uses one monthly budget. Mid-month rule changes use each rule’s full-month denominator.'**
  String get monthlyHelp;

  /// No description provided for @budgetBasis.
  ///
  /// In en, this message translates to:
  /// **'Budget basis'**
  String get budgetBasis;

  /// No description provided for @paidTime.
  ///
  /// In en, this message translates to:
  /// **'Accrual time'**
  String get paidTime;

  /// No description provided for @calendarMode.
  ///
  /// In en, this message translates to:
  /// **'All calendar time'**
  String get calendarMode;

  /// No description provided for @workMode.
  ///
  /// In en, this message translates to:
  /// **'Work hours only'**
  String get workMode;

  /// No description provided for @calendarHelp.
  ///
  /// In en, this message translates to:
  /// **'Accrues 24 hours a day, including weekends and holidays.'**
  String get calendarHelp;

  /// No description provided for @workHelp.
  ///
  /// In en, this message translates to:
  /// **'Accrues only during scheduled work intervals.'**
  String get workHelp;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Working weekdays'**
  String get weekdays;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @shiftStart.
  ///
  /// In en, this message translates to:
  /// **'Shift starts'**
  String get shiftStart;

  /// No description provided for @shiftEnd.
  ///
  /// In en, this message translates to:
  /// **'Shift ends'**
  String get shiftEnd;

  /// No description provided for @overnightHelp.
  ///
  /// In en, this message translates to:
  /// **'An earlier end time means an overnight shift. Each calendar date uses its own schedule.'**
  String get overnightHelp;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Deduct lunch break'**
  String get lunch;

  /// No description provided for @lunchDetail.
  ///
  /// In en, this message translates to:
  /// **'12:00–13:00, only where it overlaps the shift'**
  String get lunchDetail;

  /// No description provided for @workOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Applies only to Work hours only mode.'**
  String get workOnlyNote;

  /// No description provided for @calendarWarning.
  ///
  /// In en, this message translates to:
  /// **'Personal overrides affect simulation work time only. They never determine a statutory overtime multiplier.'**
  String get calendarWarning;

  /// No description provided for @addDate.
  ///
  /// In en, this message translates to:
  /// **'Add a date'**
  String get addDate;

  /// No description provided for @noOverrides.
  ///
  /// In en, this message translates to:
  /// **'No date overrides yet'**
  String get noOverrides;

  /// No description provided for @noOverridesHelp.
  ///
  /// In en, this message translates to:
  /// **'Add a day off or make-up workday to override the weekly schedule.'**
  String get noOverridesHelp;

  /// No description provided for @workingDay.
  ///
  /// In en, this message translates to:
  /// **'Workday'**
  String get workingDay;

  /// No description provided for @restDay.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get restDay;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh interval'**
  String get refresh;

  /// No description provided for @refreshNormal.
  ///
  /// In en, this message translates to:
  /// **'Every second'**
  String get refreshNormal;

  /// No description provided for @refreshFast.
  ///
  /// In en, this message translates to:
  /// **'Every 100 ms'**
  String get refreshFast;

  /// No description provided for @refreshHelp.
  ///
  /// In en, this message translates to:
  /// **'Updates only while visible. Higher frequency may use more power.'**
  String get refreshHelp;

  /// No description provided for @precision.
  ///
  /// In en, this message translates to:
  /// **'Decimal places'**
  String get precision;

  /// No description provided for @digitsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} decimal places'**
  String digitsLabel(int count);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'View my income'**
  String get finish;

  /// No description provided for @reviewHelp.
  ///
  /// In en, this message translates to:
  /// **'Save on this device. No background process is needed.'**
  String get reviewHelp;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @recalculateTitle.
  ///
  /// In en, this message translates to:
  /// **'Review rule change'**
  String get recalculateTitle;

  /// No description provided for @recalculateBody.
  ///
  /// In en, this message translates to:
  /// **'Save a dated rule. Earlier intervals retain their rules. A same-date correction archives the replaced value. Moving employment earlier extends the initial baseline assumption. Different rules use their own complete-period denominator; totals may differ from a fixed salary budget.'**
  String get recalculateBody;

  /// No description provided for @confirmSave.
  ///
  /// In en, this message translates to:
  /// **'Confirm change'**
  String get confirmSave;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes on this page will be lost.'**
  String get discardBody;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @salaryError.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative amount with up to two decimal places.'**
  String get salaryError;

  /// No description provided for @dateError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year-first date from 1970–2100.'**
  String get dateError;

  /// No description provided for @shiftError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time (e.g. 8 or 08:05). Start and end must differ.'**
  String get shiftError;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your input is retained; please retry.'**
  String get saveError;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load local data. Existing data is retained. Retry or configure again.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @clearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear local salary data?'**
  String get clearTitle;

  /// No description provided for @clearBody.
  ///
  /// In en, this message translates to:
  /// **'Salary, schedule and overtime records will be removed permanently. Language preference is kept.'**
  String get clearBody;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear salary data'**
  String get clear;

  /// No description provided for @clearError.
  ///
  /// In en, this message translates to:
  /// **'Cleanup did not finish. Some data may already be removed; please retry.'**
  String get clearError;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Salary is stored only on this device, without encryption. Browser cleanup may erase it; keep your own records. Optional update checks contact GitHub for version metadata only, without uploading salary.'**
  String get privacyBody;

  /// No description provided for @limitations.
  ///
  /// In en, this message translates to:
  /// **'Current scope'**
  String get limitations;

  /// No description provided for @limitationsBody.
  ///
  /// In en, this message translates to:
  /// **'Local simulation. Real accounts, cloud sync, tax/payroll settlement and verified attendance are not provided. Policy data must be reviewed separately.'**
  String get limitationsBody;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get licenses;

  /// No description provided for @languageHelp.
  ///
  /// In en, this message translates to:
  /// **'Selecting a language returns home automatically; currency, time zone and salary rules are unchanged.'**
  String get languageHelp;

  /// No description provided for @languageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save language. The current language is unchanged.'**
  String get languageSaveError;

  /// No description provided for @noWorkdays.
  ///
  /// In en, this message translates to:
  /// **'With no workdays selected, work-mode income is zero.'**
  String get noWorkdays;

  /// No description provided for @zeroSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary is zero'**
  String get zeroSalary;

  /// No description provided for @languageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load language preference; using Chinese until you choose a language.'**
  String get languageLoadError;

  /// No description provided for @dateInputHelp.
  ///
  /// In en, this message translates to:
  /// **'e.g. 20261109, 2026/11/9; year first'**
  String get dateInputHelp;

  /// No description provided for @timeInputHelp.
  ///
  /// In en, this message translates to:
  /// **'e.g. 8, 08, 805, 8:5 (24-hour clock)'**
  String get timeInputHelp;

  /// No description provided for @wheelPicker.
  ///
  /// In en, this message translates to:
  /// **'Scroll to select'**
  String get wheelPicker;

  /// No description provided for @pickerDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get pickerDone;

  /// No description provided for @otTitle.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get otTitle;

  /// No description provided for @otDetails.
  ///
  /// In en, this message translates to:
  /// **'Overtime details'**
  String get otDetails;

  /// No description provided for @otIdle.
  ///
  /// In en, this message translates to:
  /// **'Leaving on time is a win, too'**
  String get otIdle;

  /// No description provided for @otRunning.
  ///
  /// In en, this message translates to:
  /// **'Overtime in progress'**
  String get otRunning;

  /// No description provided for @otTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total overtime'**
  String get otTotalTime;

  /// No description provided for @otThisTime.
  ///
  /// In en, this message translates to:
  /// **'This session'**
  String get otThisTime;

  /// No description provided for @otExpected.
  ///
  /// In en, this message translates to:
  /// **'Selected pay estimate · known subtotal'**
  String get otExpected;

  /// No description provided for @otLegalReference.
  ///
  /// In en, this message translates to:
  /// **'Statutory reference · known subtotal'**
  String get otLegalReference;

  /// No description provided for @otJoke.
  ///
  /// In en, this message translates to:
  /// **'Time donated: about {amount}. Boss happiness +1'**
  String otJoke(String amount);

  /// No description provided for @otJokeHelp.
  ///
  /// In en, this message translates to:
  /// **'Unpaid time valued at 1× the reference hourly rate; not a payroll deduction.'**
  String get otJokeHelp;

  /// No description provided for @otStart.
  ///
  /// In en, this message translates to:
  /// **'Start overtime'**
  String get otStart;

  /// No description provided for @otStop.
  ///
  /// In en, this message translates to:
  /// **'Stop overtime'**
  String get otStop;

  /// No description provided for @otIndependent.
  ///
  /// In en, this message translates to:
  /// **'Tracked separately from regular income.'**
  String get otIndependent;

  /// No description provided for @otSettings.
  ///
  /// In en, this message translates to:
  /// **'Overtime rules'**
  String get otSettings;

  /// No description provided for @otSettingsHelp.
  ///
  /// In en, this message translates to:
  /// **'First save starts a session. After that, start or stop with one tap. Changes apply to new sessions only.'**
  String get otSettingsHelp;

  /// No description provided for @otPayMode.
  ///
  /// In en, this message translates to:
  /// **'Overtime pay'**
  String get otPayMode;

  /// No description provided for @otUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get otUnpaid;

  /// No description provided for @otStatutory.
  ///
  /// In en, this message translates to:
  /// **'Statutory reference rate'**
  String get otStatutory;

  /// No description provided for @otSingle.
  ///
  /// In en, this message translates to:
  /// **'1× hourly rate'**
  String get otSingle;

  /// No description provided for @otCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom multiplier'**
  String get otCustom;

  /// No description provided for @otDayType.
  ///
  /// In en, this message translates to:
  /// **'Session day classification'**
  String get otDayType;

  /// No description provided for @otWeekday.
  ///
  /// In en, this message translates to:
  /// **'Extended working day'**
  String get otWeekday;

  /// No description provided for @otRest.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get otRest;

  /// No description provided for @otHoliday.
  ///
  /// In en, this message translates to:
  /// **'Statutory holiday'**
  String get otHoliday;

  /// No description provided for @otCompLeave.
  ///
  /// In en, this message translates to:
  /// **'Compensatory leave arranged'**
  String get otCompLeave;

  /// No description provided for @otCompHelp.
  ///
  /// In en, this message translates to:
  /// **'Confirmed compliant compensatory leave on a rest day: cash reference may be zero; the corresponding time remains separately recorded.'**
  String get otCompHelp;

  /// No description provided for @otBase.
  ///
  /// In en, this message translates to:
  /// **'Monthly overtime wage base'**
  String get otBase;

  /// No description provided for @otMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Multiplier (0.01–100)'**
  String get otMultiplier;

  /// No description provided for @otMultiplierError.
  ///
  /// In en, this message translates to:
  /// **'Enter 0.01–100 with up to two decimal places.'**
  String get otMultiplierError;

  /// No description provided for @otLegalHelp.
  ///
  /// In en, this message translates to:
  /// **'Mainland China, standard hours: hourly base = monthly base ÷ 21.75 ÷ 8. Weekday 1.5×; rest day without compensatory leave 2×; statutory holiday 3×. Select day type manually; split sessions when day type changes. No official holiday lookup. Not for comprehensive or irregular working hours. Estimates are not received wages.'**
  String get otLegalHelp;

  /// No description provided for @otSaveDefaults.
  ///
  /// In en, this message translates to:
  /// **'Save rules for new sessions'**
  String get otSaveDefaults;

  /// No description provided for @otSaveStart.
  ///
  /// In en, this message translates to:
  /// **'Save & start overtime'**
  String get otSaveStart;

  /// No description provided for @otSaveError.
  ///
  /// In en, this message translates to:
  /// **'Not saved. Check for clock rollback, overlapping records or the 2,000-record limit, then retry.'**
  String get otSaveError;

  /// No description provided for @otLoadError.
  ///
  /// In en, this message translates to:
  /// **'Overtime data could not be loaded. Existing data is retained; retry to continue.'**
  String get otLoadError;

  /// No description provided for @otUnpaidValue.
  ///
  /// In en, this message translates to:
  /// **'Total unpaid-time value'**
  String get otUnpaidValue;

  /// No description provided for @otHistory.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get otHistory;

  /// No description provided for @otHistoryHelp.
  ///
  /// In en, this message translates to:
  /// **'Up to 2,000 sessions, never auto-deleted. Correct an end time if you forgot to stop (UTC+08:00, minute precision).'**
  String get otHistoryHelp;

  /// No description provided for @otEmpty.
  ///
  /// In en, this message translates to:
  /// **'No overtime yet. Keep up the good habit.'**
  String get otEmpty;

  /// No description provided for @otCorrectEnd.
  ///
  /// In en, this message translates to:
  /// **'Correct end time'**
  String get otCorrectEnd;

  /// No description provided for @otDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get otDeleteTitle;

  /// No description provided for @otDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the local record and updates totals.'**
  String get otDeleteBody;

  /// No description provided for @otMore.
  ///
  /// In en, this message translates to:
  /// **'Show more sessions'**
  String get otMore;

  /// No description provided for @otEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get otEndDate;

  /// No description provided for @otEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get otEndTime;

  /// No description provided for @otEndError.
  ///
  /// In en, this message translates to:
  /// **'End must be between session start and now.'**
  String get otEndError;

  /// No description provided for @otCorrectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter the end in UTC+08:00. This recalculates the session; overlaps are not allowed.'**
  String get otCorrectionHelp;

  /// No description provided for @otSaveCorrection.
  ///
  /// In en, this message translates to:
  /// **'Save & recalculate session'**
  String get otSaveCorrection;

  /// No description provided for @softwareUpdate.
  ///
  /// In en, this message translates to:
  /// **'Software update'**
  String get softwareUpdate;

  /// No description provided for @updateMenuSummary.
  ///
  /// In en, this message translates to:
  /// **'GitHub releases, notes and manual checks'**
  String get updateMenuSummary;

  /// No description provided for @updateLoading.
  ///
  /// In en, this message translates to:
  /// **'Reading installed version…'**
  String get updateLoading;

  /// No description provided for @updateInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed: {version}'**
  String updateInstalled(String version);

  /// No description provided for @updateReleaseVersion.
  ///
  /// In en, this message translates to:
  /// **'Release: {version}'**
  String updateReleaseVersion(String version);

  /// No description provided for @updateFound.
  ///
  /// In en, this message translates to:
  /// **'Update available: {version}'**
  String updateFound(String version);

  /// No description provided for @updateIdle.
  ///
  /// In en, this message translates to:
  /// **'Updates have not been checked yet.'**
  String get updateIdle;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking GitHub releases…'**
  String get updateChecking;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A newer stable release is available.'**
  String get updateAvailable;

  /// No description provided for @updateCurrent.
  ///
  /// In en, this message translates to:
  /// **'No newer stable release was found.'**
  String get updateCurrent;

  /// No description provided for @updateNoRelease.
  ///
  /// In en, this message translates to:
  /// **'No publicly accessible stable release. The repository may be private or have no published release.'**
  String get updateNoRelease;

  /// No description provided for @updateOffline.
  ///
  /// In en, this message translates to:
  /// **'This check did not complete. Check your connection and retry. Any displayed release may be cached.'**
  String get updateOffline;

  /// No description provided for @updateRateLimited.
  ///
  /// In en, this message translates to:
  /// **'GitHub has limited requests. Please try again later.'**
  String get updateRateLimited;

  /// No description provided for @updateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Release metadata does not meet update rules; this check was rejected.'**
  String get updateInvalid;

  /// No description provided for @updatePreferenceError.
  ///
  /// In en, this message translates to:
  /// **'Could not read or save update preferences. Please retry.'**
  String get updatePreferenceError;

  /// No description provided for @updateWebHelp.
  ///
  /// In en, this message translates to:
  /// **'APK checks are for Android. The Web app is updated by deployment; you can still view GitHub releases.'**
  String get updateWebHelp;

  /// No description provided for @updateLastCheck.
  ///
  /// In en, this message translates to:
  /// **'Last successful check: {time}'**
  String updateLastCheck(String time);

  /// No description provided for @updateCheckNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get updateCheckNow;

  /// No description provided for @updateFrequencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Manual checks are at least 30 seconds apart. Only stable releases are checked, not prereleases.'**
  String get updateFrequencyHelp;

  /// No description provided for @updateAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Check automatically on startup'**
  String get updateAutomatic;

  /// No description provided for @updateAutomaticHelp.
  ///
  /// In en, this message translates to:
  /// **'On by default, at most once per 24 hours. No background polling; turn off at any time.'**
  String get updateAutomaticHelp;

  /// No description provided for @updateNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No release notes were provided.'**
  String get updateNoNotes;

  /// No description provided for @updateMissingApk.
  ///
  /// In en, this message translates to:
  /// **'This release has no matching APK for this architecture. Check the release page.'**
  String get updateMissingApk;

  /// No description provided for @updateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download APK in browser'**
  String get updateDownload;

  /// No description provided for @updateInstallHelp.
  ///
  /// In en, this message translates to:
  /// **'Download with the system browser, then install manually. APKs must retain the original signing certificate. This app requests no install or storage permission. Any SHA256 shown comes from GitHub metadata; the downloaded file is not verified by this app.'**
  String get updateInstallHelp;

  /// No description provided for @updatePrivacyHelp.
  ///
  /// In en, this message translates to:
  /// **'Only the configured public GitHub API is contacted. No salary, schedule or overtime data is uploaded, and no GitHub token is bundled. Android uses the normal INTERNET permission without a runtime prompt.'**
  String get updatePrivacyHelp;

  /// No description provided for @updateOpenReleases.
  ///
  /// In en, this message translates to:
  /// **'View GitHub releases'**
  String get updateOpenReleases;

  /// No description provided for @updateOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open a browser. Copy the release URL shown on this page.'**
  String get updateOpenError;

  /// No description provided for @effectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective date'**
  String get effectiveDate;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Salary and schedule history'**
  String get historyTitle;

  /// No description provided for @historyHelp.
  ///
  /// In en, this message translates to:
  /// **'The first rule is your configured baseline, not a verified pay record. Future rules activate on their effective date. Replaced rules remain archived.'**
  String get historyHelp;

  /// No description provided for @attribution.
  ///
  /// In en, this message translates to:
  /// **'Overnight attribution'**
  String get attribution;

  /// No description provided for @calendarDate.
  ///
  /// In en, this message translates to:
  /// **'Calendar date (legacy)'**
  String get calendarDate;

  /// No description provided for @shiftStartDate.
  ///
  /// In en, this message translates to:
  /// **'Shift start date'**
  String get shiftStartDate;

  /// No description provided for @attributionHelp.
  ///
  /// In en, this message translates to:
  /// **'Calendar-date mode applies each date’s work/rest rule separately. Shift-start mode carries the starting day’s rule across midnight. Neither records actual attendance.'**
  String get attributionHelp;

  /// No description provided for @workIntervals.
  ///
  /// In en, this message translates to:
  /// **'Additional work intervals'**
  String get workIntervals;

  /// No description provided for @breakIntervals.
  ///
  /// In en, this message translates to:
  /// **'Custom breaks'**
  String get breakIntervals;

  /// No description provided for @addInterval.
  ///
  /// In en, this message translates to:
  /// **'Add interval'**
  String get addInterval;

  /// No description provided for @traceTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation details'**
  String get traceTitle;

  /// No description provided for @traceHelp.
  ///
  /// In en, this message translates to:
  /// **'CNY simulation, UTC+08:00. Exact rational arithmetic; half-up rounding is for display only. This is not a payslip, entitlement decision or bank payment.'**
  String get traceHelp;

  /// No description provided for @migrationPending.
  ///
  /// In en, this message translates to:
  /// **'Migration could not be committed. Original data is retained. Retry before editing.'**
  String get migrationPending;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and recovery'**
  String get recoveryTitle;

  /// No description provided for @backupWarning.
  ///
  /// In en, this message translates to:
  /// **'Backups contain unencrypted financial data. Store them privately. SHA-256 detects accidental corruption; it does not prove authenticity or encrypt data. Import and recovery replace current configuration only after confirmation; retained copies remain available.'**
  String get backupWarning;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importData;

  /// No description provided for @restorePrevious.
  ///
  /// In en, this message translates to:
  /// **'Restore previous configuration'**
  String get restorePrevious;

  /// No description provided for @restoreLegacy.
  ///
  /// In en, this message translates to:
  /// **'Recover legacy configuration'**
  String get restoreLegacy;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. Current data was not silently cleared. Export recovery copies or retry.'**
  String get operationFailed;

  /// No description provided for @operationDone.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get operationDone;

  /// No description provided for @backupJson.
  ///
  /// In en, this message translates to:
  /// **'Backup JSON (local only)'**
  String get backupJson;

  /// No description provided for @reviewImport.
  ///
  /// In en, this message translates to:
  /// **'Review replacement'**
  String get reviewImport;

  /// No description provided for @privacyScope.
  ///
  /// In en, this message translates to:
  /// **'Hide financial values in dashboard and detail pages. This does not block system screenshots or encrypt storage.'**
  String get privacyScope;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get moreDetails;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copy;

  /// No description provided for @policyTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar and policy data'**
  String get policyTitle;

  /// No description provided for @policyPending.
  ///
  /// In en, this message translates to:
  /// **'Pending human verification'**
  String get policyPending;

  /// No description provided for @policyReviewed.
  ///
  /// In en, this message translates to:
  /// **'Source reviewed'**
  String get policyReviewed;

  /// No description provided for @policyHelp.
  ///
  /// In en, this message translates to:
  /// **'Mainland China only. Working-day arrangements and statutory classifications are separate. Missing classifications stay unknown. Language never changes jurisdiction. No automatic policy requests or salary changes.'**
  String get policyHelp;

  /// No description provided for @policyUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check policy data online'**
  String get policyUpdate;

  /// No description provided for @policyNetwork.
  ///
  /// In en, this message translates to:
  /// **'Fetch public policy JSON from this project’s GitHub repository? No salary or attendance data is sent. Cached data remains available offline.'**
  String get policyNetwork;

  /// No description provided for @policyRollback.
  ///
  /// In en, this message translates to:
  /// **'Use previous cached version'**
  String get policyRollback;

  /// No description provided for @policyApply.
  ///
  /// In en, this message translates to:
  /// **'Apply reviewed working-day assumptions'**
  String get policyApply;

  /// No description provided for @policyConfirm.
  ///
  /// In en, this message translates to:
  /// **'I checked the official source and accept these dates as my personal simulation schedule. This does not verify statutory holiday or overtime eligibility.'**
  String get policyConfirm;

  /// No description provided for @policyUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown legal classification'**
  String get policyUnknown;

  /// No description provided for @policySource.
  ///
  /// In en, this message translates to:
  /// **'Official source and version'**
  String get policySource;

  /// No description provided for @personalOverride.
  ///
  /// In en, this message translates to:
  /// **'Personal work/rest override'**
  String get personalOverride;

  /// No description provided for @noPolicyYear.
  ///
  /// In en, this message translates to:
  /// **'No verified calendar for this year. Weekly schedule and personal overrides still apply.'**
  String get noPolicyYear;

  /// No description provided for @policyCacheFailed.
  ///
  /// In en, this message translates to:
  /// **'Update or cache read failed. Existing data remains available; use the previous cached version if needed.'**
  String get policyCacheFailed;

  /// No description provided for @legalOrdinary.
  ///
  /// In en, this message translates to:
  /// **'Ordinary workday'**
  String get legalOrdinary;

  /// No description provided for @legalRest.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get legalRest;

  /// No description provided for @legalHoliday.
  ///
  /// In en, this message translates to:
  /// **'Statutory holiday'**
  String get legalHoliday;

  /// No description provided for @legalAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Adjusted workday'**
  String get legalAdjusted;

  /// No description provided for @legalPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal leave'**
  String get legalPersonal;

  /// No description provided for @legalCompany.
  ///
  /// In en, this message translates to:
  /// **'Company day off'**
  String get legalCompany;

  /// No description provided for @otScopeConfirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm mainland China standard 8-hour working-time rules apply and the separate overtime base is appropriate.'**
  String get otScopeConfirm;

  /// No description provided for @otArrangedConfirm.
  ///
  /// In en, this message translates to:
  /// **'This overtime was arranged by the employer; the selected day classification was checked.'**
  String get otArrangedConfirm;

  /// No description provided for @otReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'I reviewed the official sources and applicability. This is my local confirmation, not an authority’s determination.'**
  String get otReviewConfirm;

  /// No description provided for @otPendingHelp.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed conditions or unclassified days remain pending. A classification applies only to the confirmed UTC+08:00 date; overnight time on other dates is not guessed. Cash amounts shown are known subtotals, not final entitlement.'**
  String get otPendingHelp;

  /// No description provided for @otPendingTime.
  ///
  /// In en, this message translates to:
  /// **'Pending reference time'**
  String get otPendingTime;

  /// No description provided for @otCompTime.
  ///
  /// In en, this message translates to:
  /// **'Recorded compensatory time'**
  String get otCompTime;

  /// No description provided for @otLegacy.
  ///
  /// In en, this message translates to:
  /// **'Legacy snapshot: unverified assumptions retained'**
  String get otLegacy;

  /// No description provided for @otCorrectionRecorded.
  ///
  /// In en, this message translates to:
  /// **'End correction recorded'**
  String get otCorrectionRecorded;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @noEligibleTime.
  ///
  /// In en, this message translates to:
  /// **'No eligible work time in this budget period'**
  String get noEligibleTime;

  /// No description provided for @restoreImport.
  ///
  /// In en, this message translates to:
  /// **'Restore state before last import'**
  String get restoreImport;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
