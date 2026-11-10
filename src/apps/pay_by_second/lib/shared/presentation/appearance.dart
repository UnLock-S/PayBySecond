import 'package:flutter/material.dart';
import '../../application/key_value_store.dart';
import 'design.dart';

class Appearance extends ChangeNotifier {
  Appearance(this.store);
  final KeyValueStore? store;
  ThemeMode mode = ThemeMode.system;
  bool failed = false;
  Future<void> load() async {
    try {
      final value = await store?.read('pay_by_second.appearance.v1');
      if (value != null) mode = ThemeMode.values.byName(value);
    } catch (_) {
      failed = true;
    }
  }

  Future<void> save(ThemeMode value) async {
    await store?.write('pay_by_second.appearance.v1', value.name);
    mode = value;
    failed = false;
    notifyListeners();
  }
}

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key, required this.appearance});
  final Appearance appearance;
  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  bool busy = false, failed = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l.appearance)),
    body: PageBody(
      child: Column(
        children: [
          for (final value in ThemeMode.values)
            ListTile(
              title: Text(switch (value) {
                ThemeMode.system => context.l.systemTheme,
                ThemeMode.light => context.l.lightTheme,
                ThemeMode.dark => context.l.darkTheme,
              }),
              trailing: widget.appearance.mode == value
                  ? const Icon(Icons.check)
                  : null,
              enabled: !busy,
              onTap: () async {
                setState(() => busy = true);
                try {
                  await widget.appearance.save(value);
                } catch (_) {
                  if (mounted) failed = true;
                }
                if (mounted) setState(() => busy = false);
              },
            ),
          if (failed || widget.appearance.failed)
            Text(context.l.operationFailed),
          const SizedBox(height: 20),
          Text(context.l.privacyScope),
        ],
      ),
    ),
  );
}
