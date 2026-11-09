import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../application/overtime.dart';

class LocalOvertimeRepository implements OvertimeRepository {
  LocalOvertimeRepository(this.preferences);
  final SharedPreferencesAsync preferences;
  static const key = 'pay_by_second.overtime.v1';
  @override
  Future<OvertimeBook> load() async {
    final text = await preferences.getString(key);
    return text == null
        ? OvertimeBook()
        : OvertimeBook.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }

  @override
  Future<void> save(OvertimeBook book) =>
      preferences.setString(key, jsonEncode(book.toJson()));
}
