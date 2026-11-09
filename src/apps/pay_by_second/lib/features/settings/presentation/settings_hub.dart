import '../../../application/app_updates.dart';
import '../../updates/presentation/updates_page.dart';
import 'package:flutter/material.dart';
import '../../../application/settings.dart';
import '../../../shared/presentation/design.dart';
import 'configuration_editor.dart';
import 'configuration_fields.dart';

class SettingsHub extends StatefulWidget {
  const SettingsHub({
    super.key,
    required this.settings,
    this.updates,
    required this.now,
    required this.onSave,
    required this.onLanguageChanged,
    required this.onClear,
    required this.languageLoadFailed,
  });
  final Settings settings;
  final UpdateController? updates;
  final DateTime now;
  final Future<void> Function(Settings) onSave;
  final Future<void> Function(String) onLanguageChanged;
  final Future<void> Function() onClear;
  final bool languageLoadFailed;
  @override
  State<SettingsHub> createState() => _SettingsHubState();
}

class _SettingsHubState extends State<SettingsHub> {
  late Settings _settings;
  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  Future<void> _edit(ConfigSection section) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ConfigurationEditor(
        initial: _settings,
        section: section,
        now: widget.now,
        onSave: (s) async {
          await widget.onSave(s);
          if (mounted) setState(() => _settings = s);
        },
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Surface(
              child: Column(
                children: [
                  _item(
                    Icons.payments_outlined,
                    l.salarySection,
                    l.salarySummary,
                    () => _edit(ConfigSection.salary),
                  ),
                  const Divider(),
                  _item(
                    Icons.calculate_outlined,
                    l.calculationSection,
                    l.calculationSummary,
                    () => _edit(ConfigSection.calculation),
                  ),
                  const Divider(),
                  _item(
                    Icons.schedule,
                    l.scheduleSection,
                    l.scheduleSummary,
                    () => _edit(ConfigSection.schedule),
                  ),
                  const Divider(),
                  _item(
                    Icons.event_available_outlined,
                    l.calendarSection,
                    l.calendarSummary,
                    () => _edit(ConfigSection.calendar),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Surface(
              child: Column(
                children: [
                  _item(
                    Icons.tune,
                    l.displaySection,
                    l.displaySummary,
                    () => _edit(ConfigSection.display),
                  ),
                  const Divider(),
                  _item(
                    Icons.translate,
                    l.languageSection,
                    l.languageSummary,
                    () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => LanguagePage(
                          onChanged: widget.onLanguageChanged,
                          loadFailed: widget.languageLoadFailed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (widget.updates != null) ...[
              Surface(
                child: _item(
                  Icons.system_update_alt,
                  l.softwareUpdate,
                  l.updateMenuSummary,
                  () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => UpdatesPage(controller: widget.updates!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Surface(
              child: _item(
                Icons.info_outline,
                l.dataSection,
                l.dataSummary,
                () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => DataPage(onClear: widget.onClear),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: accent),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right, size: 20),
    onTap: action,
  );
}

class LanguagePage extends StatefulWidget {
  const LanguagePage({
    super.key,
    required this.onChanged,
    this.loadFailed = false,
  });
  final Future<void> Function(String) onChanged;
  final bool loadFailed;
  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  bool _saving = false, _failed = false;
  late final bool _loadWarning = widget.loadFailed;
  Future<void> _change(String value) async {
    if (_saving || value == Localizations.localeOf(context).languageCode) {
      return;
    }
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onChanged(value);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.languageSection)),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Surface(
              child: RadioGroup<String>(
                groupValue: Localizations.localeOf(context).languageCode,
                onChanged: (v) {
                  if (v != null) _change(v);
                },
                child: Column(
                  children: [
                    for (final entry in const {
                      'zh': '中文',
                      'en': 'English',
                      'ja': '日本語',
                    }.entries)
                      RadioListTile<String>(
                        key: Key('language-${entry.key}'),
                        value: entry.key,
                        title: Text(entry.value),
                        enabled: !_saving,
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(l.languageHelp, style: const TextStyle(color: muted)),
            if (_loadWarning)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  l.languageLoadError,
                  style: const TextStyle(color: muted),
                ),
              ),
            if (_failed)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  l.languageSaveError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key, required this.onClear});
  final Future<void> Function() onClear;
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool _clearing = false, _failed = false;
  Future<void> _clear() async {
    final l = context.l;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.clearTitle),
        content: Text(l.clearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.clear),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    setState(() => _clearing = true);
    try {
      await widget.onClear();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) {
        setState(() {
          _clearing = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.dataSection)),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: accent, size: 32),
                  const SizedBox(height: 20),
                  Text(
                    l.localOnly,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(l.privacyBody),
                  const Divider(height: 40),
                  Text(
                    l.limitations,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(l.limitationsBody),
                  const SizedBox(height: 20),
                  Text(l.currencyNote, style: const TextStyle(color: muted)),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            const LicensePage(applicationName: 'PayBySecond'),
                      ),
                    ),
                    icon: const Icon(Icons.description_outlined),
                    label: Text(l.licenses),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: _clearing ? null : _clear,
              icon: const Icon(Icons.delete_outline),
              label: Text(l.clear),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
            if (_failed)
              Text(
                l.clearError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}
