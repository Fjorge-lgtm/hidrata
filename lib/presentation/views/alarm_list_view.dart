import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../providers/alarm_provider.dart';
import 'add_alarm_view.dart';

const _weekdayShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

class AlarmListView extends ConsumerWidget {
  const AlarmListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmListProvider);
    final sorted = [...alarms]
      ..sort((a, b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

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
                padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.cyanVibrant),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Despertador',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: sorted.isEmpty
                    ? const _EmptyAlarms()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                        itemCount: sorted.length,
                        itemBuilder: (context, index) {
                          final alarm = sorted[index];
                          return _AlarmCard(alarm: alarm);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cyanGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyanVibrant.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAlarmView()),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_alarm_rounded, color: AppColors.primaryDeep),
          label: const Text(
            'Novo alarme',
            style: TextStyle(
              color: AppColors.primaryDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
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
            child: Icon(
              Icons.alarm_off_rounded,
              size: 52,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum alarme cadastrado',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em "Novo alarme" para começar',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmCard extends ConsumerWidget {
  final AlarmModel alarm;
  const _AlarmCard({required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLabel =
        '${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}';
    final repeatLabel = alarm.repeatDays.isEmpty
        ? 'Uma vez'
        : (alarm.repeatDays.toList()..sort())
            .map((d) => _weekdayShort[d - 1])
            .join('  ');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddAlarmView(existing: alarm)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.cyanVibrant.withValues(alpha: 0.2),
            width: 1,
          ),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.cyanVibrant.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.cyanVibrant.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.alarm_rounded,
                  color: AppColors.cyanVibrant,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.label.isNotEmpty ? alarm.label : 'Sem nome',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      repeatLabel,
                      style: const TextStyle(
                        color: AppColors.cyanVibrant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: alarm.isEnabled,
                activeThumbColor: AppColors.cyanVibrant,
                onChanged: (value) => ref
                    .read(alarmListProvider.notifier)
                    .toggleAlarm(alarm, value),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorRed,
                  size: 22,
                ),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remover', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Remover o alarme "${alarm.label.isNotEmpty ? alarm.label : timeLabelFor(alarm)}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(alarmListProvider.notifier).deleteAlarm(alarm.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  String timeLabelFor(AlarmModel a) =>
      '${a.hour.toString().padLeft(2, '0')}:${a.minute.toString().padLeft(2, '0')}';
}
