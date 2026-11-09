import '../application/app_updates.dart';

class GitHubReleaseTransport implements ReleaseTransport {
  @override
  Future<ReleaseResponse> fetch(Uri endpoint, {String? etag}) =>
      Future.error(UnsupportedError('APK update checks run on Android only'));
}
