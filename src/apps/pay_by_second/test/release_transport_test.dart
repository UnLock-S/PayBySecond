import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/infrastructure/release_transport_io.dart';

void main() {
  test(
    'HTTP adapter bounds response size, closes request, and supports ETag/non-200 states',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var requests = 0;
      server.listen((request) async {
        requests++;
        expect(request.headers.value(HttpHeaders.authorizationHeader), isNull);
        switch (request.uri.path) {
          case '/latest':
            expect(
              request.headers.value(HttpHeaders.ifNoneMatchHeader),
              '"old"',
            );
            request.response.headers.set(HttpHeaders.etagHeader, '"new"');
            request.response.write(jsonEncode({'tag_name': 'v0.3.0'}));
          case '/large':
            request.response.contentLength =
                GitHubReleaseTransport.maxBytes + 1;
            request.response.write('x' * (GitHubReleaseTransport.maxBytes + 1));
          case '/invalid':
            request.response.write('not JSON');
          default:
            request.response.statusCode = 304;
        }
        await request.response.close();
      });
      final transport = GitHubReleaseTransport();
      Uri url(String path) =>
          Uri.parse('http://127.0.0.1:${server.port}/$path');
      try {
        final result = await transport.fetch(url('latest'), etag: '"old"');
        expect(result.status, 200);
        expect(result.etag, '"new"');
        expect(result.json!['tag_name'], 'v0.3.0');
        expect((await transport.fetch(url('cached'))).status, 304);
        await expectLater(transport.fetch(url('large')), throwsFormatException);
        await expectLater(
          transport.fetch(url('invalid')),
          throwsFormatException,
        );
        expect(requests, 4);
      } finally {
        await server.close(force: true);
      }
    },
  );
}
