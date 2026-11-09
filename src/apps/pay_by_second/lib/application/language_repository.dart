abstract interface class LanguageRepository {
  Future<String?> load();
  Future<void> save(String language);
}

class MemoryLanguageRepository implements LanguageRepository {
  String? value;
  @override
  Future<String?> load() async => value;
  @override
  Future<void> save(String language) async {
    value = language;
  }
}
