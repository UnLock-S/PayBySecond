import '../application/app_updates.dart';
import '../features/updates/presentation/updates_page.dart';
import '../application/overtime.dart';
import '../features/overtime/presentation/overtime_pages.dart';
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
import '../shared/presentation/financial_privacy.dart';
import '../shared/presentation/appearance.dart';
import '../application/key_value_store.dart';
import '../infrastructure/financial_backup.dart';
import '../infrastructure/policy_repository.dart';
import '../infrastructure/recoverable_settings_repository.dart';
import '../infrastructure/recoverable_overtime_repository.dart';
import '../features/settings/presentation/recovery_page.dart';

class PayBySecondApp extends StatefulWidget {
  const PayBySecondApp({
    super.key,
    required this.repository,
    required this.clock,
    this.languageRepository,
    this.overtimeRepository,
    this.updates,
    this.backup,
    this.appearanceStore,
    this.policyRepository,
  });
  final SettingsRepository repository;
  final Clock clock;
  final LanguageRepository? languageRepository;
  final OvertimeRepository? overtimeRepository;
  final UpdateController? updates;
  final FinancialBackup? backup;
  final KeyValueStore? appearanceStore;
  final PolicyRepository? policyRepository;
  @override
  State<PayBySecondApp> createState() => _PayBySecondAppState();
}

class _PayBySecondAppState extends State<PayBySecondApp> {
  late final LanguageRepository _languages;
  String _language = 'zh';
  final _privacy = ValueNotifier(false);
  late final Appearance _appearance;
  bool _loading = true, _languageLoadFailed = false;
  @override
  void initState() {
    super.initState();
    _appearance = Appearance(widget.appearanceStore)
      ..addListener(_appearanceChanged);
    _languages = widget.languageRepository ?? MemoryLanguageRepository();
    widget.updates?.initialize();
    _loadLanguage();
  }

  @override
  void dispose() {
    widget.updates?.dispose();
    _privacy.dispose();
    _appearance.removeListener(_appearanceChanged);
    _appearance.dispose();
    super.dispose();
  }

  void _appearanceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLanguage() async {
    await _appearance.load();
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
    builder: (context, child) =>
        FinancialPrivacy(state: _privacy, child: child!),
    locale: Locale(_language),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    themeMode: _appearance.mode,
    darkTheme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _language == 'ja' ? 'PayBySecondJP' : 'PayBySecondSC',
      fontFamilyFallback: const ['PayBySecondSC'],
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
      ),
    ),
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
            overtimeRepository: widget.overtimeRepository,
            backup: widget.backup,
            appearance: _appearance,
            policyRepository: widget.policyRepository,
            updates: widget.updates,
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
    this.overtimeRepository,
    this.updates,
    this.backup,
    this.policyRepository,
    required this.appearance,
    required this.onLanguageChanged,
    required this.languageLoadFailed,
  });
  final Appearance appearance;
  final SettingsRepository repository;
  final OvertimeRepository? overtimeRepository;
  final UpdateController? updates;
  final FinancialBackup? backup;
  final PolicyRepository? policyRepository;
  final Clock clock;
  final Future<void> Function(String) onLanguageChanged;
  final bool languageLoadFailed;
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  Settings? _settings;
  late final OvertimeController _overtime;
  bool _loading = true, _away = false, _loadFailed = false;
  @override
  void initState() {
    super.initState();
    _overtime = OvertimeController(
      widget.overtimeRepository ?? MemoryOvertimeRepository(),
    );
    _overtime.addListener(_overtimeChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await widget.backup?.recoverInterruptedImport();
      await _overtime.load();
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
    }
  }

  void _recovery() {
    final repository = widget.repository;
    if (repository is RecoverableSettingsRepository && widget.backup != null) {
      final page = RecoveryPage(
        repository: repository,
        backup: widget.backup!,
        onReload: () async {
          await _initialize();
          if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
      if (_away) {
        Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (_) => page));
      } else {
        _navigate(page);
      }
    }
  }

  void _overtimeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _overtime.removeListener(_overtimeChanged);
    _overtime.dispose();
    super.dispose();
  }

  Future<void> _toggleOvertime() async {
    if (_overtime.busy || _overtime.failed || _overtime.loading) return;
    if (_overtime.book.active == null && _overtime.book.policy == null) {
      await _navigate(
        OvertimeSettingsPage(
          controller: _overtime,
          monthlyMinor: _settings!
              .toEngine()
              .policyAt(widget.clock.now())
              .monthlyMinor,
          startAt: widget.clock.now,
        ),
      );
      return;
    }
    try {
      await _overtime.change(
        (book) => book.active == null
            ? book.start(widget.clock.now())
            : book.stop(widget.clock.now()),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l.otSaveError)));
      }
    }
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
    final persisted = await widget.repository.load();
    if (persisted == null) {
      throw StateError('Saved profile could not be restored');
    }
    if (mounted) {
      setState(() {
        _settings = persisted;
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

  void _updatesPage() => _navigate(UpdatesPage(controller: widget.updates!));
  void _setup() =>
      _navigate(ConfigurationEditor(now: widget.clock.now(), onSave: _save));
  void _settingsPage() => _navigate(
    SettingsHub(
      settings:
          _settings!.document?.view(
            widget.clock.now().toUtc().add(const Duration(hours: 8)),
          ) ??
          _settings!,
      getCurrent: () => _settings!,
      policyRepository: widget.policyRepository,
      appearance: widget.appearance,
      onRecovery: widget.backup == null ? null : _recovery,
      updates: widget.updates,
      now: widget.clock.now(),
      onSave: _save,
      onLanguageChanged: widget.onLanguageChanged,
      languageLoadFailed: widget.languageLoadFailed,
      onClear: () async {
        if (_overtime.busy || _overtime.loading) {
          throw StateError('Operation in progress');
        }
        final repository = _overtime.repository;
        if (repository is RecoverableOvertimeRepository) {
          await repository.clear();
        } else {
          await repository.save(OvertimeBook());
        }
        await _overtime.load();
        await widget.repository.clear();
        await widget.backup?.clearRecoveryCopies();
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
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'PayBySecond',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
              ),
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
          if (_settings == null && widget.updates != null)
            IconButton(
              key: const Key('open-updates'),
              tooltip: l.softwareUpdate,
              onPressed: _away ? null : _updatesPage,
              icon: const Icon(Icons.system_update_alt),
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
            if (widget.updates != null)
              AnimatedBuilder(
                animation: widget.updates!,
                builder: (context, _) {
                  if (!widget.updates!.available) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Surface(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.system_update_alt,
                          color: accent,
                        ),
                        title: Text(
                          l.updateFound(
                            widget.updates!.latest!.version.toString(),
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _away ? null : _updatesPage,
                      ),
                    ),
                  );
                },
              ),
            Text(
              l.headline,
              style: TextStyle(
                fontSize: 30,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.subtitle,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            if (_loadFailed) ...[
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.loadError),
                    TextButton(onPressed: _load, child: Text(l.retry)),
                    if (widget.backup != null)
                      TextButton(
                        onPressed: _recovery,
                        child: Text(l.recoveryTitle),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (_settings?.migrationPending ?? false) ...[
              Text(l.migrationPending),
              TextButton(onPressed: _load, child: Text(l.retry)),
            ],
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_settings == null)
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Icon(Icons.savings_outlined, size: 44, color: accent),
                    const SizedBox(height: 28),
                    Text(
                      l.welcomeTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.welcomeBody,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      key: const Key('get-started'),
                      onPressed: _away || _loadFailed ? null : _setup,
                      icon: Icon(Icons.arrow_forward),
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
                overtimeActive: _overtime.book.active != null,
                overtimeBuilder: (now, hidden) => Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: OvertimeCard(
                    controller: _overtime,
                    now: now,
                    hidden: hidden,
                    onToggle: _toggleOvertime,
                    onDetails: () => _navigate(
                      OvertimeDetailsPage(
                        controller: _overtime,
                        clock: widget.clock,
                        monthlyMinor: _settings!
                            .toEngine()
                            .policyAt(widget.clock.now())
                            .monthlyMinor,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l.localOnly} · ${l.estimateNote}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
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
