import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/material.dart';
import '../../../application/settings.dart';
import '../../../shared/presentation/design.dart';
import 'configuration_fields.dart';

/// Initial setup uses separate short steps. Existing profiles edit one category.
class ConfigurationEditor extends StatefulWidget {
  const ConfigurationEditor({
    super.key,
    this.initial,
    this.section,
    required this.now,
    required this.onSave,
  });
  final Settings? initial;
  final ConfigSection? section;
  final DateTime now;
  final Future<void> Function(Settings) onSave;
  @override
  State<ConfigurationEditor> createState() => _ConfigurationEditorState();
}

class _ConfigurationEditorState extends State<ConfigurationEditor> {
  final _form = GlobalKey<FormState>();
  late final ConfigurationDraft _draft;
  late final String _original;
  int _step = 0;
  bool _saving = false, _allowPop = false, _checkingExit = false;
  String? _error;
  bool get _wizard => widget.initial == null;
  List<ConfigSection> get _stages => _wizard
      ? [
          ConfigSection.salary,
          ConfigSection.calculation,
          if (_draft.mode == AccrualMode.work) ConfigSection.schedule,
        ]
      : [widget.section!];
  bool get _review => _wizard && _step == _stages.length;
  bool get _dirty => _original != _draft.fingerprint;
  @override
  void initState() {
    super.initState();
    _draft = ConfigurationDraft(widget.initial, widget.now);
    _original = _draft.fingerprint;
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _changed() => setState(() {
    _error = null;
  });
  Future<void> _exit({bool abandon = false}) async {
    if (_saving || _checkingExit) return;
    if (_wizard && _step > 0 && !abandon) {
      setState(() => _step--);
      return;
    }
    _checkingExit = true;
    var discard = true;
    if (_dirty) {
      final l = context.l;
      discard =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l.discardTitle),
              content: Text(l.discardBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.keepEditing),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l.discard),
                ),
              ],
            ),
          ) ??
          false;
    }
    _checkingExit = false;
    if (discard && mounted) {
      setState(() => _allowPop = true);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.pop(context);
    }
  }

  void _next() {
    if (_form.currentState!.validate()) {
      setState(() => _step++);
    }
  }

  Future<void> _save() async {
    if (!_review && !_form.currentState!.validate()) return;
    final l = context.l;
    if (!_wizard && _dirty && widget.section != ConfigSection.display) {
      final yes = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.recalculateTitle),
          content: Text(l.recalculateBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.confirmSave),
            ),
          ],
        ),
      );
      if (yes != true || !mounted) return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final settings = _draft.build();
      settings.toPolicy();
      await widget.onSave(settings);
      if (mounted) {
        setState(() => _allowPop = true);
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l.saveError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final title = _review ? l.review : sectionTitle(_stages[_step], l);
    return PopScope(
      canPop: _allowPop || (!_dirty && !_saving && _step == 0),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: BackButton(onPressed: _exit),
          actions: [
            if (_wizard)
              TextButton(
                onPressed: _saving ? null : () => _exit(abandon: true),
                child: Text(l.cancel),
              ),
          ],
        ),
        body: PageBody(
          child: AbsorbPointer(
            absorbing: _saving,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_wizard) ...[
                  Row(
                    children: [
                      Text(
                        '${(_step + 1).toString().padLeft(2, '0')} / ${_stages.length + 1}',
                        style: const TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_step + 1) / (_stages.length + 1),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
                Surface(
                  child: _review
                      ? _reviewBody(context)
                      : Form(
                          key: _form,
                          child: ConfigurationFields(
                            key: ValueKey(_stages[_step]),
                            section: _stages[_step],
                            draft: _draft,
                            changed: _changed,
                          ),
                        ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    if (_wizard && _step > 0)
                      TextButton(
                        onPressed: () => setState(() => _step--),
                        child: Text(l.previous),
                      ),
                    const Spacer(),
                    FilledButton.icon(
                      key: const Key('config-submit'),
                      onPressed: _saving
                          ? null
                          : _wizard && !_review
                          ? _next
                          : _save,
                      icon: Icon(
                        _wizard && !_review ? Icons.arrow_forward : Icons.check,
                      ),
                      label: Text(
                        _saving
                            ? l.saving
                            : _wizard
                            ? (_review ? l.finish : l.next)
                            : l.save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewBody(BuildContext context) {
    final l = context.l;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.reviewHelp, style: const TextStyle(color: muted)),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.payments_outlined),
          title: Text(l.salarySection),
          subtitle: Text(
            'CNY ${grouped(_draft.salary.text)}\n${_draft.date.text}',
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calculate_outlined),
          title: Text(l.calculationSection),
          subtitle: Text(
            '${_draft.basis == SalaryBasis.annual ? l.annual : l.monthly} · ${_draft.mode == AccrualMode.calendar ? l.calendarMode : l.workMode}',
          ),
        ),
        if (_draft.mode == AccrualMode.work) ...[
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(l.scheduleSection),
            subtitle: Text('${_draft.start.text}–${_draft.end.text}'),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l.currencyNote,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }
}
