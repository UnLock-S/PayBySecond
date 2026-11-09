import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
export '../../l10n/generated/app_localizations.dart';

const ink = Color(0xFF162D35);
const accent = Color(0xFF147B66);
const muted = Color(0xFF697C7D);

extension LocalizedContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.width = 640});
  final Widget child;
  final double width;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: child,
      ),
    ),
  );
}

class Surface extends StatelessWidget {
  const Surface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE4EBE5)),
      ),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

String grouped(String text) {
  final parts = text.split('.');
  parts[0] = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return parts.join('.');
}
