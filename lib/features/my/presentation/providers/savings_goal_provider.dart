import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../domain/models/savings_goal.dart';

part 'savings_goal_provider.g.dart';

const _kGoalsKey = 'savings_goals';

@riverpod
class SavingsGoalNotifier extends _$SavingsGoalNotifier {
  @override
  List<SavingsGoal> build() {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    if (prefs == null) return [];
    final raw = prefs.getStringList(_kGoalsKey) ?? [];
    return raw
        .map((e) => SavingsGoal.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  void add(SavingsGoal goal) {
    state = [...state, goal];
    _save();
  }

  void update(SavingsGoal goal) {
    state = [for (final g in state) g.id == goal.id ? goal : g];
    _save();
  }

  void delete(String id) {
    state = state.where((g) => g.id != id).toList();
    _save();
  }

  void _save() {
    final prefs = ref.read(sharedPreferencesProvider).valueOrNull;
    prefs?.setStringList(
      _kGoalsKey,
      state.map((g) => jsonEncode(g.toJson())).toList(),
    );
  }
}
