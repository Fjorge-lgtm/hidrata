import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/medicine_provider.dart';
import 'login_view.dart';
import 'add_medicine_view.dart';
import 'alarm_list_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(medicineListProvider);
    final user = ref.watch(userProvider).asData?.value;
    final now = DateTime.now();
    final hour = now.hour;

    // Saudação baseada no horário
    final greeting = hour < 12
        ? 'Bom dia'
        : hour < 18
        ? 'Boa tarde'
        : 'Boa noite';

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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null && user.name.isNotEmpty
                                ? '$greeting, ${user.name}! 👋'
                                : '$greeting! 👋',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Minha hidratação',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Acesso aos lembretes de água
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlarmListView(),
                        ),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceCard,
                          border: Border.all(
                            color: AppColors.cyanVibrant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.alarm_rounded,
                          color: AppColors.cyanVibrant,
                          size: 22,
                        ),
                      ),
                    ),
                    // Avatar / logout
                    GestureDetector(
                      onTap: () => _confirmLogout(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.cyanGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanVibrant.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryDeep,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Card de resumo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SummaryCard(count: medicines.length),
              ),

              const SizedBox(height: 24),

              // Label da lista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Text(
                      'Lembretes de água',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cyanVibrant.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cyanVibrant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${medicines.length} item${medicines.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.cyanVibrant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Lista
              Expanded(
                child: medicines.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          final med = medicines[index];
                          return _MedicineCard(
                            med: med,
                            onDelete: () => ref
                                .read(medicineListProvider.notifier)
                                .deleteMedicine(med.id),
                          );
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
            MaterialPageRoute(builder: (_) => const AddMedicineView()),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: AppColors.primaryDeep),
          label: const Text(
            'Adicionar',
            style: TextStyle(
              color: AppColors.primaryDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sair',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Deseja bloquear o app?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyanVibrant,
              foregroundColor: AppColors.primaryDeep,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

// Card de resumo no topo
class _SummaryCard extends StatelessWidget {
  final int count;
  const _SummaryCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D3B6E), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cyanVibrant.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBright.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.cyanVibrant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.cyanVibrant.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: AppColors.cyanVibrant,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 0
                      ? 'Nenhum lembrete'
                      : '$count lembrete${count != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'Adicione seu primeiro lembrete de água'
                      : 'de água cadastrado${count != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.cyanGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primaryDeep,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Estado vazio
class _EmptyState extends StatelessWidget {
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
              Icons.water_drop_rounded,
              size: 52,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum lembrete de água cadastrado',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em "Adicionar" para começar',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// Card de quantidade de água
class _MedicineCard extends StatelessWidget {
  final dynamic med;
  final VoidCallback onDelete;

  const _MedicineCard({required this.med, required this.onDelete});

  // Cor do ícone por letra inicial (torna cada card único)
  Color get _accentColor {
    final colors = [
      AppColors.cyanVibrant,
      AppColors.healthGreen,
      const Color(0xFFFFB300),
      const Color(0xFFFF6D00),
      const Color(0xFFE040FB),
      const Color(0xFF40C4FF),
    ];
    return colors[(med.name.codeUnitAt(0)) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final times = (med.scheduleTimes as List<DateTime>)
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .join('  •  ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.2),
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
            // Ícone colorido
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _accentColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: _accentColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.dosage.isNotEmpty ? med.dosage : 'Água',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantidade de água',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (times.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: _accentColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            times,
                            style: TextStyle(
                              color: _accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Botão deletar
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.errorRed,
                size: 22,
              ),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remover',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Remover "${med.name}" da lista?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
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
}
