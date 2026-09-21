import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';

import '../data/models/models.dart';
import 'notification_service.dart';

/// Serviço do despertador — independente do [NotificationService] usado
/// pelos lembretes de medicamento para *tocar* o alarme (o pacote `alarm`
/// garante tela cheia + som em loop mesmo com o dispositivo bloqueado ou
/// silencioso). Ainda assim, integra com o [NotificationService] para
/// avisar o usuário quando um alarme se desliga sozinho por falta de
/// interação — sem isso, esse desligamento passaria despercebido.
class AlarmClockService {
  static const _ringDuration = Duration(minutes: 5);
  static const _snoozeDuration = Duration(minutes: 5);
  static const _soundAsset = 'assets/sounds/alarm_default.wav';

  final NotificationService _notifications;
  final Map<int, Timer> _autoStopTimers = {};

  AlarmClockService(this._notifications);

  Future<void> init() => Alarm.init();

  Stream<AlarmSet> get ringingStream => Alarm.ringing;

  Future<void> schedule(AlarmModel alarm) async {
    if (!alarm.isEnabled) {
      await cancel(alarm.id);
      return;
    }

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarm.id,
        dateTime: _nextTrigger(alarm),
        assetAudioPath: _soundAsset,
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        volumeSettings: const VolumeSettings.fixed(volume: 0.9),
        notificationSettings: NotificationSettings(
          title: 'Despertador',
          body: alarm.label.isNotEmpty ? alarm.label : 'Alarme tocando',
          stopButton: 'Desligar',
        ),
      ),
    );
  }

  Future<void> cancel(int id) async {
    _autoStopTimers.remove(id)?.cancel();
    await Alarm.stop(id);
  }

  /// Chamado quando a tela de alarme tocando é exibida: arma o desligamento
  /// automático após [_ringDuration] caso o usuário não interaja. Ao
  /// disparar, notifica o usuário via [NotificationService] — do contrário
  /// o alarme simplesmente silenciaria sem nenhum aviso.
  void armAutoStop(AlarmModel alarm) {
    final id = alarm.id;
    _autoStopTimers[id]?.cancel();
    _autoStopTimers[id] = Timer(_ringDuration, () async {
      await cancel(id);
      await _notifications.notifyAlarmAutoStopped(alarm.label);
    });
  }

  Future<void> snooze(AlarmModel alarm) async {
    _autoStopTimers.remove(alarm.id)?.cancel();
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarm.id,
        dateTime: DateTime.now().add(_snoozeDuration),
        assetAudioPath: _soundAsset,
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        volumeSettings: const VolumeSettings.fixed(volume: 0.9),
        notificationSettings: NotificationSettings(
          title: 'Despertador',
          body: alarm.label.isNotEmpty ? alarm.label : 'Alarme tocando',
          stopButton: 'Desligar',
        ),
      ),
    );
  }

  DateTime _nextTrigger(AlarmModel alarm) {
    final now = DateTime.now();
    var candidate =
        DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);

    if (alarm.repeatDays.isEmpty) {
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }

    for (var i = 0; i < 8; i++) {
      final day = candidate.add(Duration(days: i));
      if (alarm.repeatDays.contains(day.weekday) && day.isAfter(now)) {
        return day;
      }
    }
    return candidate.add(const Duration(days: 7));
  }
}
