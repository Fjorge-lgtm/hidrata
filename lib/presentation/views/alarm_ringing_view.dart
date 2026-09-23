import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../providers/alarm_provider.dart';

/// Tela cheia exibida quando um alarme dispara — separada do fluxo de
/// lembretes de água, com sua própria identidade visual (acento
/// laranja/vermelho de alerta em vez do ciano do restante do app).
class AlarmRingingView extends ConsumerStatefulWidget {
  final AlarmModel alarm;
  const AlarmRingingView({super.key, required this.alarm});

  @override
  ConsumerState<AlarmRingingView> createState() => _AlarmRingingViewState();
}

class _AlarmRingingViewState extends ConsumerState<AlarmRingingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    ref.read(alarmClockServiceProvider).armAutoStop(widget.alarm);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    final alarm = widget.alarm;
    await ref.read(alarmClockServiceProvider).cancel(alarm.id);
    if (alarm.repeatDays.isEmpty) {
      alarm.isEnabled = false;
    }
    await ref.read(alarmListProvider.notifier).updateAlarm(alarm);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    await ref.read(alarmClockServiceProvider).snooze(widget.alarm);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final timeLabel =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A0A0A), Color(0xFF1B0D0D), Color(0xFF0D1B2A)],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.08).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.alertOrange.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.alertOrange.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alertOrange.withValues(alpha: 0.4),
                          blurRadius: 32,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.alarm_rounded,
                      color: AppColors.alertOrange,
                      size: 72,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.alarm.label.isNotEmpty ? widget.alarm.label : 'Alarme',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _snooze,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.cyanVibrant,
                            side: const BorderSide(
                              color: AppColors.cyanVibrant,
                              width: 1.5,
                            ),
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'SONECA',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _dismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'DESLIGAR',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
