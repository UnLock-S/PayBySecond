import 'package:flutter/material.dart';
import '../application/income_session.dart';
import '../application/language_repository.dart';
import '../application/settings.dart';
import '../infrastructure/document_language_stub.dart'
    if (dart.library.js_interop) '../infrastructure/document_language_web.dart';
import '../features/dashboard/presentation/dashboard.dart';
import '../features/settings/presentation/configuration_editor.dart';
import '../features/settings/presentation/settings_hub.dart';
import '../shared/presentation/design.dart';

class PayBySecondApp extends StatefulWidget {
  const PayBySecondApp({
    super.key,
    required this.repository,
    required this.clock,
    this.languageRepository,
  });
  final SettingsRepository repository;
  final Clock clock;
  final LanguageRepository? languageRepository;
  @override
  State<PayBySecondApp> createState() => _PayBySecondAppState();
}

class _PayBySecondAppState extends State<PayBySecondApp> {
  late final LanguageRepository _languages;
  String _language = 'zh';
  bool _loading = true, _languageLoadFailed = false;
  @override
  void initState() {
    super.initState();
    _languages = widget.languageRepository ?? MemoryLanguageRepository();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final value = await _languages.load();
      if (!mounted) return;
      if (value != null && ['zh', 'en', 'ja'].contains(value)) {
        _language = value;
      } else if (value != null) {
        _languageLoadFailed = true;
      }
    } catch (_) {
      _languageLoadFailed = true;
    }
    if (mounted) {
      setDocumentLanguage(_language);
      setState(() => _loading = false);
    }
  }

  Future<void> _changeLanguage(String language) async {
    if (!['zh', 'en', 'ja'].contains(language)) {
      throw ArgumentError('Unsupported locale');
    }
    await _languages.save(language);
    setDocumentLanguage(language);
    if (mounted) {
      setState(() {
        _language = language;
        _languageLoadFailed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PayBySecond',
    debugShowCheckedModeBanner: false,
    locale: Locale(_language),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: _language == 'ja' ? 'PayBySecondJP' : 'PayBySecondSC',
      fontFamilyFallback: const ['PayBySecondSC'],
      scaffoldBackgroundColor: const Color(0xFFF5F7F3),
      colorScheme: ColorScheme.fromSeed(seedColor: accent),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F7F3),
        foregroundColor: ink,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.all(18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: ink, height: 1.6),
        titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w600),
      ),
    ),
    home: _loading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _Home(
            repository: widget.repository,
            clock: widget.clock,
            onLanguageChanged: _changeLanguage,
            languageLoadFailed: _languageLoadFailed,
          ),
  );
}

class _Home extends StatefulWidget {
  const _Home({
    required this.repository,
    required this.clock,
    required this.onLanguageChanged,
    required this.languageLoadFailed,
  });
  final SettingsRepository repository;
  final Clock clock;
  final Future<void> Function(String) onLanguageChanged;
  final bool languageLoadFailed;
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  Settings? _settings;
  bool _loading = true, _away = false, _loadFailed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await widget.repository.load();
      if (mounted) {
        setState(() {
          _settings = s;
          _loading = false;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
    }
  }

  Future<void> _save(Settings s) async {
    await widget.repository.save(s);
    if (mounted) {
      setState(() {
        _settings = s;
        _loadFailed = false;
      });
    }
  }

  Future<void> _navigate(Widget page) async {
    if (_away) return;
    setState(() => _away = true);
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() => _away = false);
  }

  void _setup() =>
      _navigate(ConfigurationEditor(now: widget.clock.now(), onSave: _save));
  void _settingsPage() => _navigate(
    SettingsHub(
      settings: _settings!,
      now: widget.clock.now(),
      onSave: _save,
      onLanguageChanged: widget.onLanguageChanged,
      languageLoadFailed: widget.languageLoadFailed,
      onClear: () async {
        await widget.repository.clear();
        if (mounted) setState(() => _settings = null);
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timelapse_rounded, color: accent),
            SizedBox(width: 10),
            Text(
              'PayBySecond',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          if (_settings != null)
            IconButton(
              key: const Key('open-settings'),
              tooltip: l.settings,
              onPressed: _away ? null : _settingsPage,
              icon: const Icon(Icons.tune_rounded),
            )
          else
            IconButton(
              key: const Key('open-language'),
              tooltip: l.languageSection,
              onPressed: _away
                  ? null
                  : () => _navigate(
                      LanguagePage(
                        onChanged: widget.onLanguageChanged,
                        loadFailed: widget.languageLoadFailed,
                      ),
                    ),
              icon: const Icon(Icons.translate),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: PageBody(
        width: 1000,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              l.headline,
              style: const TextStyle(
                fontSize: 30,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.subtitle,
              style: const TextStyle(fontSize: 15, color: muted),
            ),
            const SizedBox(height: 32),
            if (_loadFailed) ...[
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.loadError),
                    TextButton(onPressed: _load, child: Text(l.retry)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_settings == null)
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Icon(Icons.savings_outlined, size: 44, color: accent),
                    const SizedBox(height: 28),
                    Text(
                      l.welcomeTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l.welcomeBody, style: const TextStyle(color: muted)),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      key: const Key('get-started'),
                      onPressed: _away ? null : _setup,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l.getStarted),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              )
            else
              Dashboard(
                settings: _settings!,
                clock: widget.clock,
                enabled: !_away,
              ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: muted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l.localOnly} · ${l.estimateNote}',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
