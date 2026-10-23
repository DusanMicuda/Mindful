import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';
import 'package:mindful/ui/dialogs/app_launch_limit_dialog.dart';

void main() {
  Future<void> pumpHost(WidgetTester tester, void Function(int?) onResult) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async => onResult(
                  await showAppLaunchLimitDialog(
                    context: context,
                    heroTag: 't',
                    initialCount: 0,
                    max: 300,
                    title: 'T',
                    info: 'I',
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openAndSet(WidgetTester tester, String input) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), input);
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();
  }

  testWidgets('Given custom title and info When opened Then they are shown',
      (tester) async {
    // ARRANGE
    await pumpHost(tester, (_) {});

    // ACTION
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // CHECK
    expect(find.text('T'), findsOneWidget);
    expect(find.text('I'), findsOneWidget);
  });

  for (final (input, expected) in [('999', 300), ('45', 45)]) {
    testWidgets(
        'Given max 300 When entering $input and confirming Then returns $expected',
        (tester) async {
      // ARRANGE
      int? result;
      await pumpHost(tester, (v) => result = v);

      // ACTION
      await openAndSet(tester, input);

      // CHECK
      expect(result, expected);
    });
  }
}
