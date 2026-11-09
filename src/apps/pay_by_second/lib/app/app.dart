import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../application/income_session.dart';
import '../application/settings.dart';
import '../features/dashboard/presentation/dashboard.dart';
import '../features/profile/presentation/profile_editor.dart';

const ink = Color(0xFF162D35);
const accent = Color(0xFF147B66);

class PayBySecondApp extends StatelessWidget {
  const PayBySecondApp({
    super.key,
    required this.repository,
    required this.clock,
  });
  final SettingsRepository repository;
  final Clock clock;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PayBySecond · 每秒有所得',
    debugShowCheckedModeBanner: false,
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      fontFamily: 'PayBySecondSC',
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7F2),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(color: ink),
      ),
    ),
    home: _Home(repository: repository, clock: clock),
  );
}

class _Home extends StatefulWidget {
  const _Home({required this.repository, required this.clock});
  final SettingsRepository repository;
  final Clock clock;
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  Settings? _settings;
  bool _loading = true, _editing = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await widget.repository.load();
      if (mounted) {
        setState(() {
          _settings = settings;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '本机配置暂时无法读取。原数据已保留，你可以重试，或重新设置并覆盖。';
        });
      }
    }
  }

  Future<void> _edit() async {
    setState(() => _editing = true);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfileEditor(
        initial: _settings,
        now: widget.clock.now(),
        onSave: (settings) async {
          await widget.repository.save(settings);
          if (mounted) {
            setState(() {
              _settings = settings;
              _error = null;
            });
          }
        },
      ),
    );
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _clear() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空本机数据？'),
        content: const Text('将删除此浏览器/设备保存的薪资和排班，无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await widget.repository.clear();
      if (mounted) setState(() => _settings = null);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('清空失败，原数据保留，请重试。')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timelapse_rounded, color: accent, size: 32),
                        SizedBox(width: 10),
                        Text(
                          'PayBySecond',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                      ],
                    ),
                    const Chip(
                      label: Text('本机体验版 · 无需账号'),
                      avatar: Icon(Icons.shield_outlined, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 42),
                const Text(
                  '每一秒，都有所得。',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '把工作的时间，换成看得见的积累。',
                  style: TextStyle(color: Color(0xFF687A7C), fontSize: 16),
                ),
                const SizedBox(height: 28),
                if (_error != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_error!),
                          TextButton(
                            onPressed: _load,
                            child: const Text('重试读取'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_settings == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.savings_outlined,
                          size: 44,
                          color: accent,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '从你的第一笔设置开始',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '填写月薪、入职日期和工作时间，即可看到实时估算。\n数据仅保存于此设备，关闭页面后无需后台运行。',
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _editing ? null : _edit,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('设置我的薪资'),
                        ),
                      ],
                    ),
                  )
                else
                  Dashboard(
                    key: ObjectKey(_settings),
                    settings: _settings!,
                    clock: widget.clock,
                    enabled: !_editing,
                    onEdit: _edit,
                    onClear: _clear,
                  ),
                const SizedBox(height: 28),
                const Text(
                  '预计收入 ≠ 实际到账。当前为人民币、UTC+08:00 固定时区；账号、自动法定日历与薪资历史尚未接入。',
                  style: TextStyle(fontSize: 12, color: Color(0xFF687A7C)),
                ),
                const SizedBox(height: 8),
                const Text(
                  '薪资保存在本机，未加密。浏览器清理数据后会丢失，请勿将本页作为唯一记录。',
                  style: TextStyle(fontSize: 12, color: Color(0xFF687A7C)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
