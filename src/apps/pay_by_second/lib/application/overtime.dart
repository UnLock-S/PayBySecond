import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/foundation.dart';

/// One serialized value; no writes on ticks, immutable history snapshots.
class OvertimeBook {
  OvertimeBook({
    this.policy,
    this.active,
    List<OvertimeEntry> entries = const [],
    this.nextId = 1,
  }) : entries = List.unmodifiable(entries) {
    if (entries.length > 2000 ||
        nextId < 1 ||
        entries.any((e) => e.end == null || e.id >= nextId) ||
        (active != null && (active!.end != null || active!.id >= nextId))) {
      throw FormatException('Invalid overtime ledger');
    }
    final sorted = [...entries, ?active]
      ..sort((a, b) => a.start.compareTo(b.start));
    final ids = <int>{};
    for (var i = 0; i < sorted.length; i++) {
      if (!ids.add(sorted[i].id) ||
          (i > 0 &&
              (sorted[i - 1].end == null ||
                  sorted[i - 1].end!.isAfter(sorted[i].start)))) {
        throw FormatException('Duplicate or overlapping overtime');
      }
    }
  }
  final OvertimePolicy? policy;
  final OvertimeEntry? active;
  final List<OvertimeEntry> entries;
  final int nextId;
  OvertimeBook start(DateTime now) {
    if (active != null || policy == null || entries.length >= 2000) {
      throw StateError(
        'Configure first; only one active session, up to 2000 records',
      );
    }
    return OvertimeBook(
      policy: policy,
      entries: entries,
      nextId: nextId + 1,
      active: OvertimeEntry(id: nextId, start: now, policy: policy!),
    );
  }

  OvertimeBook stop(DateTime now) => OvertimeBook(
    policy: policy,
    entries: [...entries, active!.stop(now)],
    nextId: nextId,
  );
  OvertimeBook configure(OvertimePolicy value) => OvertimeBook(
    policy: value,
    active: active,
    entries: entries,
    nextId: nextId,
  );
  OvertimeBook replace(OvertimeEntry value) => OvertimeBook(
    policy: policy,
    active: active,
    nextId: nextId,
    entries: [
      for (final entry in entries) entry.id == value.id ? value : entry,
    ],
  );
  OvertimeBook remove(int id) => OvertimeBook(
    policy: policy,
    active: active,
    nextId: nextId,
    entries: entries.where((e) => e.id != id).toList(),
  );
  Map<String, dynamic> toJson() => {
    'version': 2,
    'policy': policy?.toJson(),
    'active': active?.toJson(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'nextId': nextId,
  };
  factory OvertimeBook.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 && json['version'] != 2) {
      throw FormatException('Unsupported overtime data');
    }
    return OvertimeBook(
      policy: json['policy'] == null
          ? null
          : OvertimePolicy.fromJson(json['policy'] as Map<String, dynamic>),
      active: json['active'] == null
          ? null
          : OvertimeEntry.fromJson(json['active'] as Map<String, dynamic>),
      entries: (json['entries'] as List)
          .map((e) => OvertimeEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextId: json['nextId'] as int,
    );
  }
}

abstract interface class OvertimeRepository {
  Future<OvertimeBook> load();
  Future<void> save(OvertimeBook book);
}

class MemoryOvertimeRepository implements OvertimeRepository {
  OvertimeBook value = OvertimeBook();
  @override
  Future<OvertimeBook> load() async => value;
  @override
  Future<void> save(OvertimeBook book) async => value = book;
}

class OvertimeController extends ChangeNotifier {
  OvertimeController(this.repository);
  final OvertimeRepository repository;
  bool _disposed = false, _reading = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  OvertimeBook book = OvertimeBook();
  bool loading = true, failed = false, busy = false;
  Duration closedDuration = Duration.zero,
      closedPending = Duration.zero,
      closedCompensatory = Duration.zero;
  Money closedExpected = Money.zero,
      closedStatutory = Money.zero,
      closedUnpaid = Money.zero;
  void _assign(OvertimeBook value) {
    book = value;
    closedDuration = Duration.zero;
    closedPending = Duration.zero;
    closedCompensatory = Duration.zero;
    closedExpected = Money.zero;
    closedStatutory = Money.zero;
    closedUnpaid = Money.zero;
    for (final e in book.entries) {
      final duration = e.elapsed(e.end!);
      closedDuration += duration;
      closedExpected += e.expectedAt(e.end!);
      final reference = e.reference(e.end!);
      closedStatutory += reference.knownCash;
      closedPending += reference.pendingDuration;
      closedCompensatory += reference.compensatoryDuration;
      closedUnpaid += e.policy.unpaidValue(duration);
    }
  }

  Future<void> load() async {
    if (_reading || busy || _disposed) return;
    _reading = true;
    loading = true;
    notifyListeners();
    try {
      _assign(await repository.load());
      failed = false;
    } catch (_) {
      failed = true;
    }
    loading = false;
    _reading = false;
    notifyListeners();
  }

  Future<void> change(OvertimeBook Function(OvertimeBook) update) async {
    if (loading || failed || busy) throw StateError('Overtime unavailable');
    busy = true;
    notifyListeners();
    try {
      final next = update(book);
      await repository.save(next);
      _assign(next);
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
