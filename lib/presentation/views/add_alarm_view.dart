import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../providers/alarm_provider.dart';

const _weekdayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

class AddAlarmView extends ConsumerStatefulWidget {
  final AlarmModel? existing;
  const AddAlarmView({super.key, this.existing});

  @override
  ConsumerState<AddAlarmView> createState() => _AddAlarmViewState();
}

class _AddAlarmViewState extends ConsumerState<AddAlarmView> {
  final _labelController = TextEditingController();
  late TimeOfDay _time;
  final Set<int> _repeatDays = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _labelController.text = existing.label;
      _time = TimeOfDay(hour: existing.hour, minute: existing.minute);
      _repeatDays.addAll(existing.repeatDays);
    } else {
      _time = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.surfaceCard,
            hourMinuteColor: AppColors.surfaceInput,
            hourMinuteTextColor: AppColors.cyanVibrant,
            dialBackgroundColor: AppColors.surfaceInput,
            dialHandColor: AppColors.cyanVibrant,
            dialTextColor: AppColors.textPrimary,
            entryModeIconColor: AppColors.cyanVibrant,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _time = time);
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final existing = widget.existing;
    final alarm = existing ?? AlarmModel();
    alarm
      ..label = _labelController.text.trim()
      ..hour = _time.hour
      ..minute = _time.minute
      ..repeatDays = _repeatDays.toList()
      ..isEnabled = true;

    final notifier = ref.read(alarmListProvider.notifier);
    if (existing != null) {
      await notifier.updateAlarm(alarm);
    } else {
      await notifier.addAlarm(alarm);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

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
                    Text(
                      isEditing ? 'Editar Alarme' : 'Novo Alarme',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 24),
                            decoration: BoxDecoration(
                              gradient: AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color:
                                    AppColors.cyanVibrant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: AppColors.cyanVibrant,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Toque para alterar o horário',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'Nome do alarme',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _labelController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Acordar, Reunião...',
                          prefixIcon: Icon(Icons.label_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Repetir',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(7, (index) {
                          final weekday = index + 1; // DateTime.weekday
                          final selected = _repeatDays.contains(weekday);
                          return GestureDetector(
                            onTap: () => setState(() {
                              selected
                                  ? _repeatDays.remove(weekday)
                                  : _repeatDays.add(weekday);
                            }),
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selected ? AppColors.cyanGradient : null,
                                color: selected
                                    ? null
                                    : AppColors.surfaceInput,
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : AppColors.textHint.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                _weekdayLabels[index],
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.primaryDeep
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Nenhum dia selecionado = alarme único',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.cyanGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanVibrant.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primaryDeep,
                                  ),
                                )
                              : const Text(
                                  'SALVAR ALARME',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: AppColors.primaryDeep,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
