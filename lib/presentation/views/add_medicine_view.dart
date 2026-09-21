import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../providers/medicine_provider.dart';

class AddMedicineView extends ConsumerStatefulWidget {
  const AddMedicineView({super.key});

  @override
  ConsumerState<AddMedicineView> createState() => _AddMedicineViewState();
}

class _AddMedicineViewState extends ConsumerState<AddMedicineView> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final List<TimeOfDay> _times = [];
  bool _saving = false;

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (time != null) setState(() => _times.add(time));
  }

  void _save() {
    if (_nameController.text.trim().isEmpty || _times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.alertOrange),
              SizedBox(width: 8),
              Text('Informe o nome e ao menos um horário.'),
            ],
          ),
          backgroundColor: AppColors.surfaceCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final scheduleTimes = _times
        .map((t) => DateTime(now.year, now.month, now.day, t.hour, t.minute))
        .toList();

    final medicine = MedicineModel()
      ..name = _nameController.text.trim()
      ..dosage = _dosageController.text.trim()
      ..scheduleTimes = scheduleTimes
      ..isActive = true;

    ref.read(medicineListProvider.notifier).addMedicine(medicine);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // AppBar manual
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.cyanVibrant,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Nova dose',
                      style: TextStyle(
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
                      // Card principal
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.cyanVibrant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ícone decorativo
                            Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.cyanVibrant.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.cyanVibrant.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.medication_rounded,
                                  color: AppColors.cyanVibrant,
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Nome
                            const _FieldLabel(
                              label: 'Nome da dose',
                              required: true,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Ex: Losartana, Metformina...',
                                prefixIcon: Icon(
                                  Icons.medication_liquid_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Dosagem
                            const _FieldLabel(label: 'Dosagem'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _dosageController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Ex: 500mg, 1 comprimido...',
                                prefixIcon: Icon(Icons.scale_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Card de horários
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.cyanVibrant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const _FieldLabel(
                                  label: 'Horários de dose',
                                  required: true,
                                ),
                                const Spacer(),
                                if (_times.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cyanVibrant.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_times.length} horário${_times.length != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        color: AppColors.cyanVibrant,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Chips de horários
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ..._times.map(
                                  (t) => _TimeChip(
                                    time: t,
                                    onDelete: () =>
                                        setState(() => _times.remove(t)),
                                  ),
                                ),
                                // Botão adicionar horário
                                GestureDetector(
                                  onTap: _selectTime,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.cyanVibrant,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.cyanVibrant.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_alarm_rounded,
                                          color: AppColors.cyanVibrant,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Adicionar horário',
                                          style: TextStyle(
                                            color: AppColors.cyanVibrant,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botão salvar
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.cyanGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanVibrant.withValues(
                                alpha: 0.4,
                              ),
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
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                                  'SALVAR MEDICAMENTO',
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: AppColors.cyanVibrant, fontSize: 14),
          ),
        ],
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onDelete;
  const _TimeChip({required this.time, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final label =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B6E), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyanVibrant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 14,
            color: AppColors.cyanVibrant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
