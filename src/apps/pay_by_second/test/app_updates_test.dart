import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/application/app_updates.dart';

Map<String, dynamic> releaseJson({
  String version = '0.3.0',
  List<String> abis = const ['arm64-v8a'],
  String repository = 'UnLock-S/PayBySecond',
}) => {
  'tag_name': 'v$version',
  'draft': false,
  'prerelease': false,
  'body': 'Version notes',
  'assets': [
    for (final abi in abis)
      {
        'name': 'PayBySecond-$version-$abi-test.apk',
        'browser_download_url':
            'https://github.com/$repository/releases/download/v$version/PayBySecond-$version-$abi-test.apk',
        'state': 'uploaded',
        'size': 20000,
        'digest': 'sha256:${'a' * 64}',
      },
  ],
};

class FakeUpdatePlatform implements UpdatePlatform {
  FakeUpdatePlatform({this.android = true});
  final bool android;
  final opened = <Uri>[];
  @override
  Future<InstalledApp> installed() async => InstalledApp(
    version: '0.2.1',
    build: '2003',
    abi: 'arm64-v8a',
    android: android,
  );
  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}

class FakeReleaseTransport implements ReleaseTransport {
  int calls = 0;
  ReleaseResponse response = ReleaseResponse(
    200,
    json: releaseJson(),
    etag: '"release-3"',
  );
  Object? error;
  Completer<ReleaseResponse>? pending;
  String? receivedEtag;
  @override
  Future<ReleaseResponse> fetch(Uri endpoint, {String? etag}) async {
    calls++;
    receivedEtag = etag;
    if (error != null) throw error!;
    return pending == null ? response : await pending!.future;
  }
}

class FailingUpdatePreferences extends MemoryUpdatePreferences {
  bool fail = false;
  @override
  Future<void> save(UpdateCache cache) async {
    if (fail) throw StateError('disk failure');
    await super.save(cache);
  }
}

void main() {
  final source = ReleaseSource('UnLock-S/PayBySecond');
  test(
    'numeric semantic versions; draft/prerelease/unsupported tags rejected',
    () {
      expect(
        AppVersion.parse('v0.10.0')!.compareTo(AppVersion.parse('0.9.99')!),
        greaterThan(0),
      );
      expect(AppVersion.parse('0.2.1+3')!.toString(), '0.2.1');
      for (final value in [
        'v01.2.3',
        'v1.2',
        '1.2.3-beta',
        'latest',
        '1.2.3000000000',
      ]) {
        expect(AppVersion.parse(value), isNull);
      }
      for (final key in ['draft', 'prerelease']) {
        expect(
          () => ReleaseInfo.fromJson(
            releaseJson()..[key] = true,
            source,
            'arm64-v8a',
          ),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'prefer matching ABI, fall back to universal, never choose another ABI or redirect origin',
    () {
      final json = releaseJson(abis: ['x86_64', 'universal', 'arm64-v8a']);
      final arm = ReleaseInfo.fromJson(json, source, 'arm64-v8a');
      expect(arm.assetName, endsWith('arm64-v8a-test.apk'));
      expect(arm.sha256, 'a' * 64);
      expect(
        ReleaseInfo.fromJson(
          releaseJson(abis: ['universal']),
          source,
          'arm64-v8a',
        ).apk,
        isNotNull,
      );
      expect(
        ReleaseInfo.fromJson(
          releaseJson(abis: ['x86_64']),
          source,
          'arm64-v8a',
        ).apk,
        isNull,
      );
      for (final url in [
        'https://example.com/app.apk',
        'https://github.com/Other/repo/releases/download/v0.3.0/PayBySecond-0.3.0-arm64-v8a-test.apk',
        'https://github.com/UnLock-S/PayBySecond/releases/download/v0.3.0/other.apk',
        'https://github.com/UnLock-S/PayBySecond/releases/download/v0.3.0/PayBySecond-0.3.0-arm64-v8a-test.apk?x=1',
      ]) {
        final bad = releaseJson();
        (bad['assets'] as List).first['browser_download_url'] = url;
        expect(ReleaseInfo.fromJson(bad, source, 'arm64-v8a').apk, isNull);
      }
    },
  );
  test(
    'automatic check cached across restart, ETag 304 preserves metadata after 24 hours',
    () async {
      var now = DateTime.utc(2026, 11, 9);
      final prefs = MemoryUpdatePreferences(),
          transport = FakeReleaseTransport();
      UpdateController create() => UpdateController(
        source: source,
        transport: transport,
        preferences: prefs,
        platform: FakeUpdatePlatform(),
        now: () => now,
      );
      final first = create();
      await first.initialize();
      expect(first.status, UpdateStatus.available);
      expect(transport.calls, 1);
      final serialized =
          jsonDecode(jsonEncode(prefs.value.toJson())) as Map<String, dynamic>;
      prefs.value = UpdateCache.fromJson(serialized);
      final next = create();
      await next.initialize();
      expect(transport.calls, 1);
      expect(next.latest!.tag, 'v0.3.0');
      now = now.add(const Duration(hours: 24));
      transport.response = const ReleaseResponse(304);
      await next.check(automatic: true);
      expect(transport.calls, 2);
      expect(transport.receivedEtag, '"release-3"');
      expect(next.status, UpdateStatus.available);
      expect(next.latest!.notes, 'Version notes');
      first.dispose();
      next.dispose();
    },
  );
  test(
    '404 never means current; offline and rate limits retain earlier release with explicit status',
    () async {
      var now = DateTime.utc(2026);
      final transport = FakeReleaseTransport()
        ..response = const ReleaseResponse(404);
      final c = UpdateController(
        source: source,
        transport: transport,
        preferences: MemoryUpdatePreferences(),
        platform: FakeUpdatePlatform(),
        now: () => now,
      );
      await c.initialize();
      expect(c.status, UpdateStatus.noRelease);
      expect(c.latest, isNull);
      now = now.add(const Duration(seconds: 31));
      transport.response = ReleaseResponse(200, json: releaseJson());
      await c.check();
      expect(c.available, isTrue);
      now = now.add(const Duration(seconds: 31));
      transport.error = TimeoutException('offline');
      await c.check();
      expect(c.status, UpdateStatus.offline);
      expect(c.latest, isNotNull);
      transport.error = null;
      transport.response = const ReleaseResponse(429);
      now = now.add(const Duration(seconds: 31));
      await c.check();
      expect(c.status, UpdateStatus.rateLimited);
      c.dispose();
    },
  );
  test(
    'duplicate taps cannot start simultaneous requests; 30-second manual cooldown and rollback recover',
    () async {
      var now = DateTime.utc(2026);
      final prefs = MemoryUpdatePreferences()
        ..value = UpdateCache(automatic: false, repository: source.repository);
      final transport = FakeReleaseTransport()
        ..pending = Completer<ReleaseResponse>();
      final c = UpdateController(
        source: source,
        transport: transport,
        preferences: prefs,
        platform: FakeUpdatePlatform(),
        now: () => now,
      );
      await c.initialize();
      final pending = c.check();
      await Future<void>.delayed(Duration.zero);
      await c.check();
      expect(transport.calls, 1);
      transport.pending!.complete(
        ReleaseResponse(200, json: releaseJson(version: '0.2.1')),
      );
      await pending;
      expect(c.status, UpdateStatus.current);
      await c.check();
      expect(transport.calls, 1);
      transport.pending = null;
      now = now.subtract(const Duration(days: 1));
      await c.check();
      expect(transport.calls, 2);
      c.dispose();
    },
  );
  test(
    'disable automatic persists, repository changes invalidate cache, Web never requests',
    () async {
      final prefs = MemoryUpdatePreferences();
      final transport = FakeReleaseTransport();
      final c = UpdateController(
        source: source,
        transport: transport,
        preferences: prefs,
        platform: FakeUpdatePlatform(),
      );
      await c.initialize();
      await c.setAutomatic(false);
      final next = UpdateController(
        source: ReleaseSource('UnLock-S/NewReleaseSource'),
        transport: transport,
        preferences: prefs,
        platform: FakeUpdatePlatform(),
      );
      await next.initialize();
      expect(next.cache.automatic, isFalse);
      expect(next.latest, isNull);
      expect(transport.calls, 1);
      final web = UpdateController(
        source: source,
        transport: transport,
        preferences: prefs,
        platform: FakeUpdatePlatform(android: false),
      );
      await web.initialize();
      await web.check();
      expect(web.status, UpdateStatus.unsupported);
      expect(transport.calls, 1);
      c.dispose();
      next.dispose();
      web.dispose();
    },
  );
  test(
    'failed preference writes stop network work; URL launching stays in the configured release repository',
    () async {
      final prefs = FailingUpdatePreferences()
        ..value = UpdateCache(automatic: false, repository: source.repository);
      final transport = FakeReleaseTransport(), platform = FakeUpdatePlatform();
      final c = UpdateController(
        source: source,
        transport: transport,
        preferences: prefs,
        platform: platform,
      );
      await c.initialize();
      prefs.fail = true;
      await c.check();
      expect(c.status, UpdateStatus.storageError);
      expect(transport.calls, 0);
      expect(
        await c.open(Uri.parse('https://github.com/Other/repo/releases')),
        isFalse,
      );
      expect(
        await c.open(
          Uri.parse('http://github.com/UnLock-S/PayBySecond/releases'),
        ),
        isFalse,
      );
      expect(await c.open(source.releases), isTrue);
      expect(platform.opened.length, 1);
      c.dispose();
    },
  );
}
