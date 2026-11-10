import 'dart:convert';
import 'dart:io';

Future<String> fetchPolicy(Uri uri) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client
        .getUrl(uri)
        .timeout(const Duration(seconds: 15));
    request.followRedirects = false;
    final response = await request.close().timeout(const Duration(seconds: 15));
    if (response.statusCode != 200 || response.contentLength > 1024 * 1024) {
      throw const FormatException('Policy response rejected');
    }
    final bytes = <int>[];
    await for (final chunk in response.timeout(const Duration(seconds: 15))) {
      if (bytes.length + chunk.length > 1024 * 1024) {
        throw const FormatException('Policy response too large');
      }
      bytes.addAll(chunk);
    }
    return utf8.decode(bytes);
  } finally {
    client.close(force: true);
  }
}
