import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/medicine_provider.dart';
import '../../data/models/models.dart';

/// Tela que agrega os horários de todas as quantidades de água cadastradas
/// e exibe como uma lista cronológica de alarmes do dia.
class AlarmsView extends ConsumerWidget {
  const AlarmsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(medicineListProvider);
    final alarms = _buildAlarms(medicines);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF0D2B4E), Color(0xFF0D1B2A)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Alarmes',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: alarms.isEmpty
                    ? const _EmptyAlarms()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        itemCount: alarms.length,
                        itemBuilder: (context, index) =>
                            _AlarmCard(alarm: alarms[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Alarm> _buildAlarms(List<MedicineModel> medicines) {
    final list = <_Alarm>[];
    for (final med in medicines) {
      if (!med.isActive) continue;
      for (final t in med.scheduleTimes) {
        list.add(
          _Alarm(
            medicineName: med.name,
            dosage: med.dosage,
            hour: t.hour,
            minute: t.minute,
          ),
        );
      }
    }
    list.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (final a in list) {
      a.isPast = (a.hour * 60 + a.minute) < nowMinutes;
    }
    return list;
  }
}

class _Alarm {
  final String medicineName;
  final String dosage;
  final int hour;
  final int minute;
  bool isPast = false;

  _Alarm({
    required this.medicineName,
    required this.dosage,
    required this.hour,
    required this.minute,
  });

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class _EmptyAlarms extends StatelessWidget {
  const _EmptyAlarms();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textHint.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.alarm_off_rounded,
              size: 48,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum alarme agendado',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Cadastre uma quantidade de água com horário para ver os alarmes aqui',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmCard extends StatelessWidget {
  final _Alarm alarm;
  const _AlarmCard({required this.alarm});

  @override
  Widget build(BuildContext context) {
    final color = alarm.isPast ? AppColors.textHint : AppColors.cyanVibrant;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(
                alarm.isPast
                    ? Icons.check_circle_outline_rounded
                    : Icons.alarm_rounded,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.timeLabel,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alarm.dosage.isNotEmpty ? 'Água • ${alarm.dosage}' : 'Água',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (alarm.isPast)
              const Text(
                'Feito',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cyanVibrant.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pendente',
                  style: TextStyle(
                    color: AppColors.cyanVibrant,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
