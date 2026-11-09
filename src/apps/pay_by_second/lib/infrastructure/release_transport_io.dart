import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../application/app_updates.dart';

class GitHubReleaseTransport implements ReleaseTransport {
  static const maxBytes = 512 * 1024;
  @override
  Future<ReleaseResponse> fetch(Uri endpoint, {String? etag}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      return await _fetch(
        client,
        endpoint,
        etag,
      ).timeout(const Duration(seconds: 8));
    } finally {
      client.close(force: true);
    }
  }

  Future<ReleaseResponse> _fetch(
    HttpClient client,
    Uri endpoint,
    String? etag,
  ) async {
    final request = await client.getUrl(endpoint);
    request.followRedirects = false;
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'PayBySecond-update-check',
    );
    if (etag != null &&
        etag.length < 512 &&
        !etag.contains(RegExp(r'[\r\n]'))) {
      request.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
    }
    final response = await request.close();
    final responseTag = response.headers.value(HttpHeaders.etagHeader);
    if (response.statusCode != 200) {
      return ReleaseResponse(response.statusCode, etag: responseTag);
    }
    if (response.contentLength > maxBytes) {
      throw const FormatException('Release response too large');
    }
    final bytes = BytesBuilder(copy: false);
    await for (final part in response) {
      if (bytes.length + part.length > maxBytes) {
        throw const FormatException('Release response too large');
      }
      bytes.add(part);
    }
    final value = jsonDecode(utf8.decode(bytes.takeBytes()));
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Release object required');
    }
    return ReleaseResponse(200, json: value, etag: responseTag);
  }
}
