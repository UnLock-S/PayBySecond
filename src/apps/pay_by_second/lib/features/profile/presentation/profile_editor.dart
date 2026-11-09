import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/material.dart';

import '../../../application/settings.dart';

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({
    super.key,
    this.initial,
    required this.now,
    required this.onSave,
  });
  final Settings? initial;
  final DateTime now;
  final Future<void> Function(Settings) onSave;
  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _salary, _date, _start, _end, _overrides;
  late AccrualMode _mode;
  late SalaryBasis _basis;
  late Set<int> _days;
  late bool _lunch;
  late int _refresh, _digits;
  bool _saving = false;
  String? _error;
  String _time(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _salary = TextEditingController(text: s?.salary ?? '10000');
    _date = TextEditingController(
      text: EarningsPolicy.dateKey(
        s?.start ?? widget.now.toUtc().add(const Duration(hours: 8)),
      ),
    );
    _start = TextEditingController(text: _time(s?.startMinute ?? 480));
    _end = TextEditingController(text: _time(s?.endMinute ?? 1020));
    _overrides = TextEditingController(
      text:
          s?.overrides.entries
              .map((e) => '${e.key}=${e.value ? '上班' : '休息'}')
              .join('\n') ??
          '',
    );
    _mode = s?.mode ?? AccrualMode.calendar;
    _basis = s?.basis ?? SalaryBasis.annual;
    _days = {
      ...?s?.weekdays,
      if (s == null) ...[1, 2, 3, 4, 5],
    };
    _lunch = s?.lunch ?? true;
    _refresh = s?.refreshMs ?? 1000;
    _digits = s?.digits ?? 4;
  }

  @override
  void dispose() {
    for (final c in [_salary, _date, _start, _end, _overrides]) {
      c.dispose();
    }
    super.dispose();
  }

  int _parseTime(String text) {
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(text)) {
      throw const FormatException('工作时间格式应为 HH:mm');
    }
    final p = text.split(':').map(int.parse).toList();
    if (p[0] > 23 || p[1] > 59) throw const FormatException('工作时间范围无效');
    return p[0] * 60 + p[1];
  }

  DateTime _parseDate(String text) {
    final date = DateTime.tryParse(text);
    if (date == null || EarningsPolicy.dateKey(date) != text) {
      throw const FormatException('日期格式应为 yyyy-MM-dd，且必须是真实日期');
    }
    return DateTime.utc(date.year, date.month, date.day);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    try {
      final overrides = <String, bool>{};
      for (final line
          in _overrides.text
              .split('\n')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)) {
        final parts = line.split('=');
        if (parts.length != 2 || !['上班', '休息'].contains(parts[1])) {
          throw const FormatException('日期例外格式：2026-10-01=休息，每行一条');
        }
        _parseDate(parts[0]);
        if (overrides.containsKey(parts[0])) {
          throw const FormatException('日期例外不能重复');
        }
        overrides[parts[0]] = parts[1] == '上班';
      }
      final settings = Settings(
        salary: _salary.text.trim(),
        start: _parseDate(_date.text.trim()),
        mode: _mode,
        basis: _basis,
        weekdays: Set.unmodifiable(_days),
        startMinute: _parseTime(_start.text.trim()),
        endMinute: _parseTime(_end.text.trim()),
        lunch: _lunch,
        refreshMs: _refresh,
        digits: _digits,
        overrides: Map.unmodifiable(overrides),
      );
      settings.toPolicy();
      setState(() {
        _saving = true;
        _error = null;
      });
      try {
        await widget.onSave(settings);
      } catch (_) {
        if (mounted) {
          setState(() {
            _saving = false;
            _error = '保存失败，请检查浏览器存储是否可用，再重试。输入内容已保留。';
          });
        }
        return;
      }
      if (mounted) Navigator.pop(context);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    } on ArgumentError catch (e) {
      setState(() => _error = '配置无效：${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.initial == null ? '设置我的薪资' : '调整估算配置'),
    content: SizedBox(
      width: 540,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('人民币 · 固定 UTC+08:00 · 工资为估算口径，不自动扣税。'),
              if (widget.initial != null)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    '当前版本只保存一套规则。保存将按新配置重算全部历史；薪资生效日期与历史版本尚未支持。',
                    style: TextStyle(color: Color(0xFF946124)),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _salary,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: '月薪（元）'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (s) =>
                    s == null ||
                        !RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(s.trim())
                    ? '请输入非负金额，最多两位小数'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _date,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: '入职日期',
                  hintText: '2026-01-01',
                ),
                validator: (s) {
                  try {
                    _parseDate(s!.trim());
                    return null;
                  } catch (_) {
                    return '请输入有效日期，例如 2026-01-01';
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SalaryBasis>(
                isExpanded: true,
                initialValue: _basis,
                decoration: const InputDecoration(labelText: '工资基准'),
                items: const [
                  DropdownMenuItem(
                    value: SalaryBasis.annual,
                    child: Text('按年均摊：全年预算为月薪 × 12'),
                  ),
                  DropdownMenuItem(
                    value: SalaryBasis.monthly,
                    child: Text('按月均摊：完整月累计等于月薪'),
                  ),
                ],
                onChanged: _saving ? null : (v) => setState(() => _basis = v!),
              ),
              const SizedBox(height: 10),
              Text(
                _basis == SalaryBasis.annual
                    ? '按年均摊时，完整月份可能不等于输入的月薪。'
                    : '按月均摊时，每秒速率随当月计薪时长变化。',
                style: const TextStyle(fontSize: 12),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('休息时间也累计'),
                subtitle: const Text('开启：全年每天24小时；关闭：仅工作时段'),
                value: _mode == AccrualMode.calendar,
                onChanged: _saving
                    ? null
                    : (v) => setState(
                        () =>
                            _mode = v ? AccrualMode.calendar : AccrualMode.work,
                      ),
              ),
              if (_mode == AccrualMode.work) ...[
                const Text('每周工作日'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    for (var d = 1; d <= 7; d++)
                      FilterChip(
                        label: Text(['一', '二', '三', '四', '五', '六', '日'][d - 1]),
                        selected: _days.contains(d),
                        onSelected: _saving
                            ? null
                            : (v) => setState(
                                () => v ? _days.add(d) : _days.remove(d),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _start,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          labelText: '上班 HH:mm',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _end,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          labelText: '下班 HH:mm',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '下班早于上班表示跨夜班；按实际日期分别应用周排班和日期例外。',
                  style: TextStyle(fontSize: 12),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('扣除 12:00–13:00 午休'),
                  value: _lunch,
                  onChanged: _saving ? null : (v) => setState(() => _lunch = v),
                ),
                TextFormField(
                  controller: _overrides,
                  enabled: !_saving,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '手动日期例外（可留空）',
                    hintText: '2026-10-01=休息\n2026-10-10=上班',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '尚未接入官方节假日。未填写的日期仅按周排班估算；没有有效工作时段的周期金额为0。',
                  style: TextStyle(fontSize: 12, color: Color(0xFF946124)),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _refresh,
                decoration: const InputDecoration(labelText: '前台刷新频率'),
                items: const [
                  DropdownMenuItem(value: 1000, child: Text('每秒一次（推荐）')),
                  DropdownMenuItem(value: 100, child: Text('每100ms一次')),
                ],
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _refresh = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _digits,
                decoration: const InputDecoration(labelText: '显示小数位'),
                items: [
                  for (final n in [2, 4, 6])
                    DropdownMenuItem(value: n, child: Text('$n 位小数')),
                ],
                onChanged: _saving ? null : (v) => setState(() => _digits = v!),
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
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(
          _saving
              ? '保存中…'
              : widget.initial == null
              ? '开始累计'
              : '保存并重算历史',
        ),
      ),
    ],
  );
}
