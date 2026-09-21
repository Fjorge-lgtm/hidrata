import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'core/theme.dart';
import 'core/notification_service.dart';
import 'core/alarm_clock_service.dart';
import 'core/auth_service.dart';
import 'data/datasources/isar_service.dart';
import 'presentation/views/login_view.dart';
import 'presentation/views/register_view.dart';
import 'presentation/views/alarm_ringing_view.dart';
import 'presentation/providers/medicine_provider.dart';
import 'presentation/providers/alarm_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // O pacote `alarm` usa o pacote `logging` para reportar erros nativos
  // (ex: permissão de alarme exato negada). Sem um listener, essas
  // mensagens somem silenciosamente e o alarme parece só "não tocar".
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '[${record.loggerName}] ${record.level.name}: ${record.message}',
    );
  });

  // Barra de status transparente para o gradiente aparecer
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final notificationService = NotificationService();
  await notificationService.init();

  final alarmClockService = AlarmClockService(notificationService);
  await alarmClockService.init();

  final isarService = IsarService();
  await isarService.init();

  final authService = AuthService();
  final hasPin = await authService.hasPin();

  final activeUserId = await authService.getActiveUserId();
  var user = activeUserId != null
      ? await isarService.getUserById(activeUserId)
      : null;

  // Instalações anteriores a este recurso não têm um usuário ativo salvo:
  // adota o primeiro usuário cadastrado como ativo para não perder o acesso.
  if (user == null && hasPin) {
    user = await isarService.getUser();
    if (user != null) await authService.setActiveUserId(user.id);
  }

  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
        notificationServiceProvider.overrideWithValue(notificationService),
        alarmClockServiceProvider.overrideWithValue(alarmClockService),
        activeUserIdProvider.overrideWith((ref) => user?.id),
      ],
      child: MyApp(startWithLogin: hasPin && user != null),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final bool startWithLogin;
  const MyApp({super.key, required this.startWithLogin});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _ringingIds = <int>{};
  StreamSubscription? _ringingSubscription;

  @override
  void initState() {
    super.initState();
    _ringingSubscription = ref
        .read(alarmClockServiceProvider)
        .ringingStream
        .listen(_onRinging);
  }

  @override
  void dispose() {
    _ringingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onRinging(dynamic alarmSet) async {
    for (final settings in alarmSet.alarms) {
      final id = settings.id as int;
      if (_ringingIds.contains(id)) continue;

      final alarm = await ref.read(isarServiceProvider).getAlarmById(id);
      if (alarm == null) continue;

      _ringingIds.add(id);
      await _navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => AlarmRingingView(alarm: alarm)),
      );
      _ringingIds.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Hidrata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: widget.startWithLogin ? const LoginView() : const RegisterView(),
    );
  }
}
