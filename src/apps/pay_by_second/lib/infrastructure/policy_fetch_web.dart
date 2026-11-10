import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<String> fetchPolicy(Uri uri) async {
  final complete = Completer<String>(), request = web.XMLHttpRequest();
  request.open('GET', uri.toString());
  request.timeout = 15000;
  void fail() {
    if (!complete.isCompleted) {
      complete.completeError(const FormatException('Policy fetch failed'));
    }
  }

  request.onprogress = ((web.ProgressEvent event) {
    if (event.loaded > 1024 * 1024) {
      request.abort();
      fail();
    }
  }).toJS;
  request.onload = ((web.Event event) {
    if (request.status != 200 ||
        request.responseURL != uri.toString() ||
        request.responseText.length > 1024 * 1024) {
      fail();
    } else if (!complete.isCompleted) {
      complete.complete(request.responseText);
    }
  }).toJS;
  request.onerror = ((web.Event event) {
    fail();
  }).toJS;
  request.ontimeout = ((web.Event event) {
    fail();
  }).toJS;
  request.onabort = ((web.Event event) {
    fail();
  }).toJS;
  request.send();
  return complete.future;
}
