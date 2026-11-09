import '../application/income_session.dart';

class SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now().toUtc();
}
