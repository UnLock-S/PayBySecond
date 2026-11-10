import 'engine.dart';

enum HolidayClassification {
  statutoryHoliday,
  restDay,
  adjustedWorkday,
  ordinaryWorkday,
  personalLeave,
  companyDayOff,
  unknown,
}

enum PolicyReview { pending, humanReviewed }

/// Legal classification and the work/rest override are deliberately independent.
class CalendarDay {
  const CalendarDay(this.classification, this.working);
  final HolidayClassification classification;
  final bool? working;
  Map<String, Object?> toJson() => {
    'classification': classification.name,
    'working': working,
  };
  factory CalendarDay.fromJson(Map<String, dynamic> j) => CalendarDay(
    HolidayClassification.values.byName(j['classification'] as String),
    j['working'] as bool?,
  );
}

class PolicySource {
  PolicySource({
    required this.id,
    required this.url,
    required this.documentNumber,
    required this.publishedAt,
    required this.effectiveFrom,
    required this.effectiveUntil,
    required this.checkedAt,
    required this.region,
    required this.review,
    this.reviewedAt,
    this.reviewer,
  }) {
    final uri = Uri.parse(url);
    if (id.isEmpty ||
        id.length > 80 ||
        uri.scheme != 'https' ||
        !uri.host.endsWith('.gov.cn') ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty ||
        region != 'CN-mainland' ||
        !effectiveUntil.isAfter(effectiveFrom) ||
        checkedAt.isBefore(publishedAt) ||
        [
          publishedAt,
          effectiveFrom,
          effectiveUntil,
          checkedAt,
          ?reviewedAt,
        ].any((date) => !date.isUtc) ||
        (review == PolicyReview.humanReviewed &&
            (reviewedAt == null ||
                reviewedAt!.isBefore(publishedAt) ||
                reviewer == null ||
                reviewer!.trim().isEmpty))) {
      throw ArgumentError('Invalid official policy provenance');
    }
  }
  final String id, url, documentNumber, region;
  final DateTime publishedAt, effectiveFrom, effectiveUntil, checkedAt;
  final PolicyReview review;
  final DateTime? reviewedAt;
  final String? reviewer;
  Map<String, Object?> toJson() => {
    'id': id,
    'url': url,
    'documentNumber': documentNumber,
    'publishedAt': publishedAt.toIso8601String(),
    'effectiveFrom': effectiveFrom.toIso8601String(),
    'effectiveUntil': effectiveUntil.toIso8601String(),
    'checkedAt': checkedAt.toIso8601String(),
    'region': region,
    'review': review.name,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'reviewer': reviewer,
  };
  factory PolicySource.fromJson(Map<String, dynamic> j) => PolicySource(
    id: j['id'] as String,
    url: j['url'] as String,
    documentNumber: j['documentNumber'] as String,
    publishedAt: DateTime.parse(j['publishedAt'] as String),
    effectiveFrom: DateTime.parse(j['effectiveFrom'] as String),
    effectiveUntil: DateTime.parse(j['effectiveUntil'] as String),
    checkedAt: DateTime.parse(j['checkedAt'] as String),
    region: j['region'] as String,
    review: PolicyReview.values.byName(j['review'] as String),
    reviewedAt: j['reviewedAt'] == null
        ? null
        : DateTime.parse(j['reviewedAt'] as String),
    reviewer: j['reviewer'] as String?,
  );
}

class CalendarDataset {
  CalendarDataset({
    required this.version,
    required this.year,
    required this.source,
    this.revision = 1,
    required Map<String, CalendarDay> days,
  }) : days = Map.unmodifiable(days) {
    if (revision < 1 ||
        revision > 1000000 ||
        year < 1970 ||
        year > 2100 ||
        !RegExp(r'^[a-zA-Z0-9._-]{1,80}$').hasMatch(version) ||
        days.length > 366) {
      throw ArgumentError('Invalid calendar version');
    }
    for (final key in days.keys) {
      final parsed = DateTime.tryParse(key);
      final date = parsed == null
          ? null
          : DateTime.utc(parsed.year, parsed.month, parsed.day);
      if (date == null ||
          EarningsPolicy.dateKey(date) != key ||
          date.year != year ||
          date.isBefore(source.effectiveFrom) ||
          !date.isBefore(source.effectiveUntil)) {
        throw ArgumentError('Invalid calendar date');
      }
    }
  }
  final String version;
  final int year, revision;
  final PolicySource source;
  final Map<String, CalendarDay> days;
  Map<String, bool> get workOverrides => {
    for (final entry in days.entries)
      if (entry.value.working case final bool work) entry.key: work,
  };
  CalendarDay on(DateTime civil) =>
      days[EarningsPolicy.dateKey(civil)] ??
      const CalendarDay(HolidayClassification.unknown, null);
  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'version': version,
    'year': year,
    'revision': revision,
    'source': source.toJson(),
    'days': {for (final e in days.entries) e.key: e.value.toJson()},
  };
  factory CalendarDataset.fromJson(Map<String, dynamic> j) {
    if (j['schemaVersion'] != 1) {
      throw const FormatException('Unsupported policy schema');
    }
    return CalendarDataset(
      version: j['version'] as String,
      year: j['year'] as int,
      revision: j['revision'] as int? ?? 1,
      source: PolicySource.fromJson(j['source'] as Map<String, dynamic>),
      days: (j['days'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, CalendarDay.fromJson(v as Map<String, dynamic>)),
      ),
    );
  }
}

/// Machine metadata for a conditional reference, never a payroll entitlement.
const cnStandard2025 = {
  'id': 'cn.standard-hours.2025-01.v1',
  'region': 'CN-mainland',
  'effectiveFrom': '2025-01-01',
  'sourceReview': 'pending',
  'checkedAt': '2026-11-10',
  'documentNumber': '人社部发〔2025〕2号',
  'url':
      'https://www.mohrss.gov.cn/SYrlzyhshbzb/laodongguanxi_/zcwj/202501/t20250101_533693.html',
  'laborLawUrl':
      'https://www.samr.gov.cn/zw/zfxxgk/fdzdgknr/bgt/art/2023/art_d9aa750028b14b99a776cb93726a360d.html',
  'laborLawVersion': '2018-12-29.article-44',
  'scope':
      'CN mainland labor relationship; standard 8-hour regime; employer-arranged overtime; agreed lawful base and day classification require confirmation',
  'paidDaysNumerator': '2175',
  'paidDaysDenominator': '100',
  'standardHours': '8',
  'hourDivisor': '174',
  'weekdayPercent': '150',
  'restWithoutLeavePercent': '200',
  'statutoryHolidayPercent': '300',
};
