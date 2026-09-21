import 'package:flutter/material.dart';
import '../../core/auth_service.dart';
import '../../core/theme.dart';
import 'home_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  String _pin = '';
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onNumber(String n) {
    if (_pin.length < 4) {
      setState(() => _pin += n);
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _verifyPin() async {
    final ok = await _auth.verifyPin(_pin);
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } else {
      await _shakeCtrl.forward(from: 0);
      setState(() => _pin = '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.errorRed),
                SizedBox(width: 8),
                Text('PIN incorreto. Tente novamente.'),
              ],
            ),
            backgroundColor: AppColors.surfaceCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _tryBiometric() async {
    final ok = await _auth.authenticateBiometric();
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Ícone animado
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.cyanMid, AppColors.cyanVibrant],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanVibrant.withValues(alpha: 0.45),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/beijaflor-logo.png',
                  width: 48,
                  height: 48,
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (b) => AppColors.cyanGradient.createShader(b),
                child: const Text(
                  'Hidrata',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bem-vindo de volta',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),

              const Spacer(),

              // Pontos do PIN com animação de shake
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) {
                  final offset = _shakeCtrl.isAnimating
                      ? _shakeAnim.value *
                            ((_shakeCtrl.value * 10).round().isEven ? 1 : -1)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: filled ? 20 : 16,
                      height: filled ? 20 : 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? AppColors.cyanVibrant
                            : Colors.transparent,
                        border: Border.all(
                          color: filled
                              ? AppColors.cyanVibrant
                              : AppColors.textSecondary,
                          width: 2,
                        ),
                        boxShadow: filled
                            ? [
                                BoxShadow(
                                  color: AppColors.cyanVibrant.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(),

              // Numpad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    for (final row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                      ['bio', '0', 'del'],
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: row.map((key) => _buildKey(key)).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterView()),
                ),
                child: const Text(
                  'Criar nova conta',
                  style: TextStyle(
                    color: AppColors.cyanVibrant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key == 'bio') {
      return _KeyButton(
        onTap: _tryBiometric,
        child: const Icon(
          Icons.fingerprint,
          size: 28,
          color: AppColors.cyanVibrant,
        ),
      );
    }
    if (key == 'del') {
      return _KeyButton(
        onTap: _onDelete,
        child: const Icon(
          Icons.backspace_outlined,
          size: 24,
          color: AppColors.textSecondary,
        ),
      );
    }
    return _KeyButton(
      onTap: () => _onNumber(key),
      child: Text(
        key,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _KeyButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        splashColor: AppColors.cyanVibrant.withValues(alpha: 0.2),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceCard.withValues(alpha: 0.6),
            border: Border.all(
              color: AppColors.textHint.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
