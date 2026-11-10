import 'dart:convert';
import 'package:crypto/crypto.dart';

const maxDocumentBytes = 4 * 1024 * 1024;
Object? _canonical(Object? value) => switch (value) {
  Map<String, dynamic>() => {
    for (final key in value.keys.toList()..sort()) key: _canonical(value[key]),
  },
  List() => value.map(_canonical).toList(),
  _ => value,
};
String canonicalJson(Object? value) => jsonEncode(_canonical(value));
String textDigest(String value) =>
    sha256.convert(utf8.encode(value)).toString();
String sealedDocument(Map<String, dynamic> payload, {String? legacyDigest}) {
  final result = canonicalJson({
    'format': 1,
    'payload': payload,
    'sha256': textDigest(canonicalJson(payload)),
    'legacyDigest': legacyDigest,
  });
  if (utf8.encode(result).length > maxDocumentBytes) {
    throw const FormatException('Document exceeds safe size limit');
  }
  return result;
}

Map<String, dynamic> openDocument(String raw) {
  if (utf8.encode(raw).length > maxDocumentBytes) {
    throw const FormatException('Document exceeds safe size limit');
  }
  final parsed = jsonDecode(raw);
  if (parsed is! Map<String, dynamic> ||
      parsed['format'] != 1 ||
      parsed['payload'] is! Map<String, dynamic> ||
      parsed['sha256'] != textDigest(canonicalJson(parsed['payload']))) {
    throw const FormatException('Invalid document or checksum');
  }
  return parsed;
}
