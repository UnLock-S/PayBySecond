import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../application/date_time_input.dart';
import 'design.dart';

/// Text and wheel share one value. Cancelling the wheel leaves text untouched.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.time = false,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;
  final bool time;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    onChanged: (_) => onChanged(),
    keyboardType: TextInputType.datetime,
    decoration: InputDecoration(
      labelText: label,
      helperText: time ? context.l.timeInputHelp : context.l.dateInputHelp,
      suffixIcon: IconButton(
        tooltip: context.l.wheelPicker,
        icon: Icon(time ? Icons.schedule : Icons.date_range),
        onPressed: () async {
          final minute = parseFlexibleTime(controller.text) ?? 480;
          final seed = time
              ? DateTime(2026, 1, 1, minute ~/ 60, minute % 60)
              : parseFlexibleDate(controller.text) ?? DateTime(2026);
          final picked = await showWheelPicker(context, seed, time: time);
          if (picked == null) return;
          controller.text = time
              ? formatMinute(picked.hour * 60 + picked.minute)
              : EarningsPolicy.dateKey(picked);
          onChanged();
        },
      ),
    ),
    validator:
        validator ??
        (v) =>
            (time
                ? parseFlexibleTime(v ?? '') == null
                : parseFlexibleDate(v ?? '') == null)
            ? (time ? context.l.shiftError : context.l.dateError)
            : null,
  );
}

Future<DateTime?> showWheelPicker(
  BuildContext context,
  DateTime seed, {
  bool time = false,
}) {
  var value = DateTime(seed.year, seed.month, seed.day, seed.hour, seed.minute);
  return showModalBottomSheet<DateTime>(
    context: context,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: 310,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, value),
                    child: Text(context.l.pickerDone),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: value,
                mode: time
                    ? CupertinoDatePickerMode.time
                    : CupertinoDatePickerMode.date,
                use24hFormat: true,
                minimumYear: 1970,
                maximumYear: 2100,
                onDateTimeChanged: (date) => value = date,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<DateTime?> pickFlexibleDate(BuildContext context, DateTime initial) =>
    showDialog<DateTime>(
      context: context,
      builder: (_) => _DateDialog(initial),
    );

class _DateDialog extends StatefulWidget {
  const _DateDialog(this.initial);
  final DateTime initial;
  @override
  State<_DateDialog> createState() => _DateDialogState();
}

class _DateDialogState extends State<_DateDialog> {
  final _form = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: EarningsPolicy.dateKey(widget.initial),
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l.addDate),
    content: SizedBox(
      width: 350,
      child: Form(
        key: _form,
        child: DateTimeField(
          controller: _controller,
          label: context.l.startDate,
          onChanged: () {},
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l.cancel),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, parseFlexibleDate(_controller.text));
          }
        },
        child: Text(context.l.pickerDone),
      ),
    ],
  );
}
