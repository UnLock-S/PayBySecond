import 'dart:convert';
import '../application/key_value_store.dart';
import '../application/overtime.dart';
import 'document_integrity.dart';
import 'profile_lock_stub.dart'
    if (dart.library.js_interop) 'profile_lock_web.dart';

class RecoverableOvertimeRepository implements OvertimeRepository {
  RecoverableOvertimeRepository(this.store);
  final KeyValueStore store;
  static const legacyKey = 'pay_by_second.overtime.v1',
      key = 'pay_by_second.overtime.v2',
      previousKey = '$key.previous';
  String? _loadedDigest;
  bool _loaded = false;
  Future<void> clear() => withProfileLock(() async {
    for (final name in [key, legacyKey, previousKey]) {
      await store.remove(name);
    }
    _loadedDigest = null;
    _loaded = true;
  });
  OvertimeBook decode(String raw) => OvertimeBook.fromJson(
    openDocument(raw)['payload'] as Map<String, dynamic>,
  );
  Future<void> _checkLegacy(String raw) async {
    final hash = openDocument(raw)['legacyDigest'];
    if (hash != null && hash != textDigest(await store.read(legacyKey) ?? '')) {
      throw StateError('Legacy overtime changed');
    }
  }

  @override
  Future<OvertimeBook> load() => withProfileLock(() async {
    var raw = await store.read(key);
    if (raw == null) {
      final legacy = await store.read(legacyKey);
      if (legacy != null) {
        final book = OvertimeBook.fromJson(
          jsonDecode(legacy) as Map<String, dynamic>,
        );
        raw = sealedDocument(book.toJson(), legacyDigest: textDigest(legacy));
        await store.write(key, raw);
        if (await store.read(key) != raw) {
          throw StateError('Overtime migration readback failed');
        }
      }
    }
    final book = raw == null ? OvertimeBook() : decode(raw);
    if (raw != null) await _checkLegacy(raw);
    _loadedDigest = raw == null ? null : textDigest(raw);
    _loaded = true;
    return book;
  });
  @override
  Future<void> save(OvertimeBook book) => withProfileLock(() async {
    if (!_loaded) throw StateError('Read overtime before editing');
    final current = await store.read(key);
    if ((current == null ? null : textDigest(current)) != _loadedDigest) {
      throw StateError('Stale overtime ledger');
    }
    String? legacyDigest;
    if (current != null) {
      decode(current);
      await _checkLegacy(current);
      legacyDigest = openDocument(current)['legacyDigest'] as String?;
      await store.write(previousKey, current);
    }
    final raw = sealedDocument(book.toJson(), legacyDigest: legacyDigest);
    await store.write(key, raw);
    if (await store.read(key) != raw) {
      throw StateError('Overtime commit readback failed');
    }
    _loadedDigest = textDigest(raw);
  });
}
