import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidrata/core/alarm_clock_service.dart';
import 'package:hidrata/core/notification_service.dart';
import 'package:hidrata/main.dart';
import 'package:hidrata/presentation/providers/alarm_provider.dart';

void main() {
  testWidgets('App starts on RegisterView when there is no PIN yet', (
    WidgetTester tester,
  ) async {
    final alarmClockService = AlarmClockService(NotificationService());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmClockServiceProvider.overrideWithValue(alarmClockService),
        ],
        child: const MyApp(startWithLogin: false),
      ),
    );

    expect(find.text('Criar conta'), findsOneWidget);
  });
}
