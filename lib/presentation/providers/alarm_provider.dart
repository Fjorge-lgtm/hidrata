import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/alarm_clock_service.dart';
import '../../data/datasources/isar_service.dart';
import '../../data/models/models.dart';
import 'medicine_provider.dart' show isarServiceProvider, activeUserIdProvider;

final alarmClockServiceProvider = Provider<AlarmClockService>((ref) {
  throw UnimplementedError('alarmClockServiceProvider must be overridden in main()');
});

final alarmListProvider =
    StateNotifierProvider<AlarmListNotifier, List<AlarmModel>>((ref) {
  final userId = ref.watch(activeUserIdProvider);
  return AlarmListNotifier(
    ref.read(isarServiceProvider),
    ref.read(alarmClockServiceProvider),
    userId,
  );
});

class AlarmListNotifier extends StateNotifier<List<AlarmModel>> {
  final IsarService _isar;
  final AlarmClockService _alarmClock;
  final int? _userId;

  AlarmListNotifier(this._isar, this._alarmClock, this._userId) : super([]) {
    if (_userId != null) _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    state = await _isar.getAllAlarms(_userId!);
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    if (_userId == null) return;
    alarm.userId = _userId;
    final id = await _isar.saveAlarm(alarm);
    alarm.id = id;
    state = [...state, alarm];
    await _alarmClock.schedule(alarm);
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    await _isar.saveAlarm(alarm);
    state = [
      for (final a in state) a.id == alarm.id ? alarm : a,
    ];
    await _alarmClock.schedule(alarm);
  }

  Future<void> toggleAlarm(AlarmModel alarm, bool enabled) async {
    alarm.isEnabled = enabled;
    await updateAlarm(alarm);
  }

  Future<void> deleteAlarm(int id) async {
    await _isar.deleteAlarm(id);
    state = state.where((a) => a.id != id).toList();
    await _alarmClock.cancel(id);
  }
}
