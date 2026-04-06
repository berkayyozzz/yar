import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, double?>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<double?> {
  late Box _box;

  @override
  double? build() {
    _box = Hive.box('settings');
    // return null if no budget is set
    final limit = _box.get('budgetLimit');
    return limit != null ? (limit as num).toDouble() : null;
  }

  Future<void> setBudgetLimit(double? newLimit) async {
    if (newLimit == null) {
      await _box.delete('budgetLimit');
    } else {
      await _box.put('budgetLimit', newLimit);
    }
    state = newLimit;
  }
}
