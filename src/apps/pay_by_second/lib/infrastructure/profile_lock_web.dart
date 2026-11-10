import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// New tabs share one origin-scoped lock. Unsupported browsers fail closed.
Future<T> withProfileLock<T>(Future<T> Function() operation) async {
  T? value;
  Future<JSAny?> run() async {
    value = await operation();
    return null;
  }

  await web.window.navigator.locks
      .request(
        'pay-by-second-profile-v2',
        ((web.Lock? lock) => run().toJS).toJS,
      )
      .toDart;
  return value as T;
}
