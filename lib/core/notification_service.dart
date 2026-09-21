import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/models.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Fora da faixa usada por [_notificationId] (máx. 9999931), para não
  /// colidir com notificações de lembrete de medicamento.
  static const _alarmAutoStopNotificationId = 20000000;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleForMedicine(MedicineModel medicine) async {
    await cancelForMedicine(medicine.id);
    if (!medicine.isActive) return;

    for (var i = 0; i < medicine.scheduleTimes.length; i++) {
      final time = medicine.scheduleTimes[i];
      var scheduled = tz.TZDateTime(
        tz.local,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        _notificationId(medicine.id, i),
        'Hora da dose',
        '${medicine.name}${medicine.dosage.isNotEmpty ? ' • ${medicine.dosage}' : ''}',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hidrata_reminders',
            'Lembretes de doses',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelForMedicine(int medicineId) async {
    for (var i = 0; i < 32; i++) {
      await _plugin.cancel(_notificationId(medicineId, i));
    }
  }

  int _notificationId(int medicineId, int index) =>
      (medicineId % 100000) * 100 + index;

  /// Avisa o usuário quando o [AlarmClockService] desliga um despertador
  /// automaticamente por falta de interação (ex: app fechado/dispositivo
  /// bloqueado por tempo demais). Sem isso, o alarme silenciaria sem
  /// nenhum rastro visível para quem não viu a tela de "tocando".
  Future<void> notifyAlarmAutoStopped(String label) async {
    await _plugin.show(
      _alarmAutoStopNotificationId,
      'Alarme desligado automaticamente',
      label.isNotEmpty
          ? '"$label" parou de tocar sem resposta.'
          : 'O despertador parou de tocar sem resposta.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hidrata_alarm_autostop',
          'Alarmes desligados automaticamente',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
