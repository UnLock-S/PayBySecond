import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../infrastructure/financial_backup.dart';
import '../../../infrastructure/recoverable_settings_repository.dart';
import '../../../infrastructure/document_integrity.dart';
import '../../../shared/presentation/design.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({
    super.key,
    required this.repository,
    required this.backup,
    required this.onReload,
  });
  final RecoverableSettingsRepository repository;
  final FinancialBackup backup;
  final Future<void> Function() onReload;
  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final text = TextEditingController();
  bool busy = false, failed = false, done = false;
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      failed = false;
      done = false;
    });
    try {
      await action();
      if (mounted) setState(() => done = true);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<bool> _confirm(String detail) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l.reviewImport),
          content: SingleChildScrollView(child: Text(detail)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l.confirmSave),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> _restore(bool legacy) async {
    final before = await widget.repository.recoveryCopies();
    if (!mounted || !await _confirm(context.l.backupWarning)) return;
    // Repository checks the same snapshot inside its exclusive write lock.
    final digest = textDigest(canonicalJson(before));
    if (legacy) {
      await widget.repository.restoreLegacy(expectedDigest: digest);
    } else {
      await widget.repository.restorePrevious(expectedDigest: digest);
    }
    await widget.onReload();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(title: Text(l.recoveryTitle)),
        body: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.backupWarning),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.output),
                    label: Text(l.exportData),
                    onPressed: busy
                        ? null
                        : () => _run(() async {
                            text.text = await widget.backup.export();
                          }),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: Text(l.copy),
                    onPressed: busy || text.text.isEmpty
                        ? null
                        : () => _run(
                            () => Clipboard.setData(
                              ClipboardData(text: text.text),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('backup-json'),
                controller: text,
                maxLines: 8,
                minLines: 3,
                maxLength: maxDocumentBytes,
                decoration: InputDecoration(labelText: l.backupJson),
                onChanged: (_) => setState(() {}),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.input),
                label: Text(l.importData),
                onPressed: busy
                    ? null
                    : () => _run(() async {
                        final preview = await widget.backup.preview(text.text);
                        if (!context.mounted) return;
                        final detail =
                            '${l.backupWarning}\n\n${l.salarySection}: ${preview.salaryRules}\n${l.scheduleSection}: ${preview.scheduleRules}\n${l.otHistory}: ${preview.overtimeEntries}';
                        if (!await _confirm(detail)) return;
                        await widget.backup.apply(preview);
                        await widget.onReload();
                      }),
              ),
              const Divider(height: 40),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => _run(() async {
                        final preview = await widget.backup
                            .previewPreviousImport();
                        if (!context.mounted ||
                            !await _confirm(context.l.backupWarning)) {
                          return;
                        }
                        await widget.backup.apply(preview);
                        await widget.onReload();
                      }),
                child: Text(l.restoreImport),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: busy ? null : () => _run(() => _restore(false)),
                child: Text(l.restorePrevious),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: busy ? null : () => _run(() => _restore(true)),
                child: Text(l.restoreLegacy),
              ),
              if (busy) const LinearProgressIndicator(),
              if (failed)
                Text(
                  l.operationFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (done) Text(l.operationDone),
            ],
          ),
        ),
      ),
    );
  }
}
