import 'package:flutter/material.dart';
import '../../../application/app_updates.dart';
import '../../../shared/presentation/design.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key, required this.controller});
  final UpdateController controller;
  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  bool _opening = false;
  Future<void> _open(Uri uri) async {
    if (_opening) return;
    setState(() => _opening = true);
    final opened = await widget.controller.open(uri);
    if (!mounted) return;
    setState(() => _opening = false);
    if (!opened) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l.updateOpenError)));
    }
  }

  Future<void> _automatic(bool value) async {
    try {
      await widget.controller.setAutomatic(value);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l.updatePreferenceError)),
        );
      }
    }
  }

  String _status(UpdateStatus status, AppLocalizations l) => switch (status) {
    UpdateStatus.idle => l.updateIdle,
    UpdateStatus.checking => l.updateChecking,
    UpdateStatus.available => l.updateAvailable,
    UpdateStatus.current => l.updateCurrent,
    UpdateStatus.noRelease => l.updateNoRelease,
    UpdateStatus.offline => l.updateOffline,
    UpdateStatus.rateLimited => l.updateRateLimited,
    UpdateStatus.invalid => l.updateInvalid,
    UpdateStatus.storageError => l.updatePreferenceError,
    UpdateStatus.unsupported => l.updateWebHelp,
  };
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final l = context.l, c = widget.controller, release = c.latest;
      return Scaffold(
        appBar: AppBar(title: Text(l.softwareUpdate)),
        body: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.system_update_alt, color: accent, size: 36),
                    const SizedBox(height: 16),
                    Text(
                      c.installed == null
                          ? l.updateLoading
                          : l.updateInstalled(
                              '${c.installed!.version} (${c.installed!.build})',
                            ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_status(c.status, l), key: const Key('update-status')),
                    if (c.cache.checkedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          l.updateLastCheck(
                            c.cache.checkedAt!
                                .toLocal()
                                .toIso8601String()
                                .substring(0, 19)
                                .replaceFirst('T', ' '),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (c.status == UpdateStatus.checking)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      key: const Key('check-updates'),
                      onPressed: c.canCheck ? () => c.check() : null,
                      icon: Icon(Icons.refresh),
                      label: Text(l.updateCheckNow),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.updateFrequencyHelp,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (c.installed?.android == true) ...[
                const SizedBox(height: 20),
                Surface(
                  child: SwitchListTile.adaptive(
                    key: const Key('automatic-updates'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.updateAutomatic),
                    subtitle: Text(l.updateAutomaticHelp),
                    value: c.cache.automatic,
                    onChanged: c.busy || !c.ready ? null : _automatic,
                  ),
                ),
              ],
              if (release != null) ...[
                const SizedBox(height: 20),
                Surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.updateReleaseVersion(release.version.toString()),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        release.notes.isEmpty ? l.updateNoNotes : release.notes,
                      ),
                      if (c.available && release.apk == null) ...[
                        const SizedBox(height: 16),
                        Text(l.updateMissingApk),
                      ],
                      if (c.available && release.apk != null) ...[
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          key: const Key('download-update'),
                          onPressed: _opening
                              ? null
                              : () => _open(release.apk!),
                          icon: const Icon(Icons.open_in_browser),
                          label: Text(l.updateDownload),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.updateInstallHelp,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (release.sha256 != null) ...[
                          const SizedBox(height: 12),
                          SelectableText(
                            'SHA256: ${release.sha256}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                l.updatePrivacyHelp,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                c.source.releases.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('open-releases'),
                onPressed: _opening
                    ? null
                    : () => _open(release?.page ?? c.source.releases),
                child: Text(l.updateOpenReleases),
              ),
            ],
          ),
        ),
      );
    },
  );
}
