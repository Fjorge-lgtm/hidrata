import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth_service.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../data/datasources/isar_service.dart';
import '../providers/medicine_provider.dart';
import 'home_view.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final AuthService _auth = AuthService();
  final IsarService _isar = IsarService();
  bool _loading = false;
  bool _pinVisible = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(() => setState(() {}));
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty || _pinController.text.length < 4) {
      return;
    }
    setState(() => _loading = true);

    final user = UserModel()
      ..name = _nameController.text.trim()
      ..age = 0
      ..biometricEnabled = true;

    await _isar.init();
    final userId = await _isar.saveUser(user);
    await _auth.savePin(_pinController.text);
    await _auth.setActiveUserId(userId);
    ref.read(activeUserIdProvider.notifier).state = userId;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Logo e título
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.cyanMid, AppColors.cyanVibrant],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanVibrant.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/beijaflor-logo.png',
                          width: 44,
                          height: 44,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.cyanGradient.createShader(bounds),
                        child: const Text(
                          'Hidrata',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sua saúde, organizada',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Card de formulário
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.cyanVibrant.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Criar conta',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Preencha os dados para começar',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Campo nome
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo PIN
                      TextField(
                        controller: _pinController,
                        decoration: InputDecoration(
                          labelText: 'Criar PIN (4 dígitos)',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _pinVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () =>
                                setState(() => _pinVisible = !_pinVisible),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: !_pinVisible,
                        maxLength: 4,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          letterSpacing: 8,
                        ),
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                      ),

                      // Indicador de força do PIN
                      const SizedBox(height: 8),
                      _PinStrengthBar(length: _pinController.text.length),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botão principal
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
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primaryDeep,
                            ),
                          )
                        : const Text(
                            'COMEÇAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                // Disclaimer LGPD
                const Center(
                  child: Text(
                    'Seus dados ficam apenas neste dispositivo.',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    textAlign: TextAlign.center,
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

/// Barra de progresso do PIN
class _PinStrengthBar extends StatelessWidget {
  final int length;
  const _PinStrengthBar({required this.length});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: i < length
                  ? AppColors.cyanVibrant
                  : AppColors.textHint.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }
}
