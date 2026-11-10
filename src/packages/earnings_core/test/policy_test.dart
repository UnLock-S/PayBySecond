import 'dart:convert';
import 'package:earnings_core/earnings_core.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> source() => {
    'id': 'cn-2026-arrangements',
    'url': 'https://www.gov.cn/zhengce/content/202511/content_7047090.htm',
    'documentNumber': '2025-7',
    'publishedAt': '2025-11-04T00:00:00.000Z',
    'effectiveFrom': '2026-01-01T00:00:00.000Z',
    'effectiveUntil': '2027-01-01T00:00:00.000Z',
    'checkedAt': '2026-11-10T00:00:00.000Z',
    'region': 'CN-mainland',
    'review': 'pending',
    'reviewedAt': null,
    'reviewer': null,
  };
  test(
    'calendar serializes independent legal category and work/rest decision without promoting review',
    () {
      final days = {
        '2026-01-01': const CalendarDay(
          HolidayClassification.statutoryHoliday,
          false,
        ),
        '2026-01-04': const CalendarDay(
          HolidayClassification.adjustedWorkday,
          true,
        ),
        '2026-02-01': const CalendarDay(HolidayClassification.unknown, null),
      };
      final data = CalendarDataset(
        version: 'test.1',
        year: 2026,
        source: PolicySource.fromJson(source()),
        days: days,
      );
      days.clear();
      expect(data.days.length, 3);
      final restored = CalendarDataset.fromJson(
        jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>,
      );
      expect(restored.source.review, PolicyReview.pending);
      expect(restored.workOverrides, {'2026-01-01': false, '2026-01-04': true});
      expect(
        restored.on(DateTime.utc(2026, 1, 1)).classification,
        HolidayClassification.statutoryHoliday,
      );
      expect(
        restored.on(DateTime.utc(2027)).classification,
        HolidayClassification.unknown,
      );
      expect(() => restored.days.clear(), throwsUnsupportedError);
    },
  );
  test(
    'official provenance rejects insecure URLs, lookalikes, wrong jurisdiction and inconsistent intervals',
    () {
      final bad = <Map<String, dynamic>>[
        {'url': 'http://www.gov.cn/policy'},
        {'url': 'https://gov.cn.evil.example/policy'},
        {'url': 'https://name@www.gov.cn/policy'},
        {'url': 'https://www.gov.cn/policy?token=x'},
        {'url': 'https://www.gov.cn/policy#x'},
        {'region': 'JP'},
        {'checkedAt': '2025-01-01T00:00:00.000Z'},
        {'effectiveUntil': '2026-01-01T00:00:00.000Z'},
        {'checkedAt': '2026-11-10T00:00:00'},
        {'review': 'humanReviewed'},
        {'review': 'humanReviewed', 'reviewedAt': '2026-11-10T00:00:00.000Z'},
      ];
      for (final patch in bad) {
        expect(
          () => PolicySource.fromJson({...source(), ...patch}),
          throwsArgumentError,
          reason: patch.keys.join(','),
        );
      }
    },
  );
  test(
    'human-reviewed data requires explicit reviewer metadata and preserves it through serialization',
    () {
      final record = PolicySource.fromJson({
        ...source(),
        'review': 'humanReviewed',
        'reviewedAt': '2026-11-10T00:00:00.000Z',
        'reviewer': 'test-reviewer',
      });
      expect(record.review, PolicyReview.humanReviewed);
      expect(PolicySource.fromJson(record.toJson()).reviewer, 'test-reviewer');
      expect(
        () => PolicySource.fromJson({
          ...source(),
          'review': 'humanReviewed',
          'reviewedAt': '2024-01-01T00:00:00.000Z',
          'reviewer': 'test',
        }),
        throwsArgumentError,
      );
    },
  );
  test(
    'calendar rejects normalized impossible dates, scope escape and invalid revisions',
    () {
      for (final date in [
        '2026-02-30',
        '2026-1-1',
        '2025-12-31',
        '2027-01-01',
      ]) {
        expect(
          () => CalendarDataset(
            version: 'test.1',
            year: 2026,
            source: PolicySource.fromJson(source()),
            days: {
              date: const CalendarDay(HolidayClassification.unknown, null),
            },
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => CalendarDataset(
          version: 'bad version',
          year: 2026,
          source: PolicySource.fromJson(source()),
          days: {},
        ),
        throwsArgumentError,
      );
      expect(
        () => CalendarDataset(
          version: 'test',
          year: 2026,
          revision: 0,
          source: PolicySource.fromJson(source()),
          days: {},
        ),
        throwsArgumentError,
      );
      expect(
        () => CalendarDataset.fromJson({'schemaVersion': 99}),
        throwsFormatException,
      );
    },
  );
}
