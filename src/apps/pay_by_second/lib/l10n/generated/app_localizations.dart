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
  /// **'Earned so far'**
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
  /// **'Each complete month earns the monthly salary. The per-second rate varies by month.'**
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
  /// **'Official holiday calendars are not connected. Other dates follow your weekly schedule.'**
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
  /// **'Recalculate past income?'**
  String get recalculateTitle;

  /// No description provided for @recalculateBody.
  ///
  /// In en, this message translates to:
  /// **'Only one rule set is stored. Saving will recalculate all past estimates. Salary history is not supported yet.'**
  String get recalculateBody;

  /// No description provided for @confirmSave.
  ///
  /// In en, this message translates to:
  /// **'Save & recalculate'**
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
  /// **'Enter a valid date from 1970–2100 (YYYY-MM-DD).'**
  String get dateError;

  /// No description provided for @shiftError.
  ///
  /// In en, this message translates to:
  /// **'Use HH:mm. Start and end must be different.'**
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
  /// **'Salary and schedule will be removed permanently. Language preference is kept.'**
  String get clearBody;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear salary data'**
  String get clear;

  /// No description provided for @clearError.
  ///
  /// In en, this message translates to:
  /// **'Could not clear data. Existing data is retained.'**
  String get clearError;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Salary is stored only on this device, without encryption. Browser cleanup may erase it. Keep your own records.'**
  String get privacyBody;

  /// No description provided for @limitations.
  ///
  /// In en, this message translates to:
  /// **'Current scope'**
  String get limitations;

  /// No description provided for @limitationsBody.
  ///
  /// In en, this message translates to:
  /// **'Local preview. Accounts, official holiday calendars, salary history and sync are not connected yet.'**
  String get limitationsBody;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get licenses;

  /// No description provided for @languageHelp.
  ///
  /// In en, this message translates to:
  /// **'Changes interface language only, not currency, time zone or salary rules.'**
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
