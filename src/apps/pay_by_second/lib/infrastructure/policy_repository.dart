import 'dart:convert';
import 'package:earnings_core/earnings_core.dart';
import '../application/key_value_store.dart';
import 'document_integrity.dart';
import 'profile_lock_stub.dart'
    if (dart.library.js_interop) 'profile_lock_web.dart';
import 'policy_fetch_stub.dart'
    if (dart.library.io) 'policy_fetch_io.dart'
    if (dart.library.js_interop) 'policy_fetch_web.dart';

/// No startup/automatic network access. Update is a user gesture; a candidate
/// never rewrites salary schedules or changes its pending review state.
class PolicyRepository {
  PolicyRepository(this.store, {Future<String> Function(Uri)? fetch})
    : fetch = fetch ?? fetchPolicy;
  final KeyValueStore store;
  final Future<String> Function(Uri) fetch;
  static const key = 'pay_by_second.policy.v1', previousKey = '$key.previous';
  static final endpoint = Uri.parse(
    'https://raw.githubusercontent.com/UnLock-S/PayBySecond/main/config/policy/cn-2026.json',
  );
  Future<CalendarDataset?> load() async {
    final raw = await store.read(key);
    return raw == null ? null : decode(raw);
  }

  CalendarDataset decode(String raw) => CalendarDataset.fromJson(
    openDocument(raw)['payload'] as Map<String, dynamic>,
  );
  Future<void> cache(String raw) => withProfileLock(() async {
    final next = decode(raw), old = await store.read(key);
    if (next.source.checkedAt.isAfter(
      DateTime.now().toUtc().add(const Duration(days: 1)),
    )) {
      throw StateError('Future policy check date');
    }
    if (old != null) {
      final current = decode(old);
      if (next.year == current.year &&
          next.source.checkedAt.isBefore(current.source.checkedAt)) {
        throw StateError('Policy downgrade rejected');
      }
      if (next.version == current.version &&
          canonicalJson(next.toJson()) != canonicalJson(current.toJson())) {
        throw StateError('Immutable policy version changed');
      }
      if (old == raw) return;
      if (next.year == current.year && next.revision <= current.revision) {
        throw StateError('Policy revision did not advance');
      }
      await store.write(previousKey, old);
    }
    await store.write(key, raw);
    if (await store.read(key) != raw) {
      throw StateError('Policy readback failed');
    }
  });

  Future<CalendarDataset> update() async {
    final raw = await fetch(endpoint);
    if (utf8.encode(raw).length > 1024 * 1024) {
      throw const FormatException('Policy payload too large');
    }
    await cache(raw);
    return decode(raw);
  }

  Future<void> rollback() => withProfileLock(() async {
    final raw = await store.read(previousKey);
    if (raw == null) throw StateError('No previous policy cache');
    decode(raw);
    final current = await store.read(key);
    await store.write(key, raw);
    if (current != null) await store.write(previousKey, current);
  });
}
