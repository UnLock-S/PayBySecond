import 'package:flutter/material.dart';

/// Session-wide display preference. It never claims screenshot protection or
/// encryption, and does not change stored values or calculation rules.
class FinancialPrivacy extends InheritedNotifier<ValueNotifier<bool>> {
  const FinancialPrivacy({
    super.key,
    required ValueNotifier<bool> state,
    required super.child,
  }) : super(notifier: state);
  static ValueNotifier<bool>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FinancialPrivacy>()?.notifier;
  static bool hidden(BuildContext context) => of(context)?.value ?? false;
}
