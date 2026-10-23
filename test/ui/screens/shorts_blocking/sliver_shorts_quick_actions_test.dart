import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/services/drift_db_service.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';
import 'package:mindful/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AppLocalizations l10n;

  setUp(() async {
    // wellBeingProvider loads from DriftDbService; use in-memory DB (default state).
    db = AppDatabase(NativeDatabase.memory());
    DriftDbService.instance.driftDb = db;
    l10n = await AppLocalizations.delegate.load(const Locale('en'));

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.mindful.android.methodchannel.fg'),
      (call) async => null,
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.mindful.android.methodchannel.fg'),
      null,
    );
    await db.close();
  });

  Future<void> pumpActions(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [SliverShortsQuickActions(haveNecessaryPerms: true)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Given Instagram tile, When expanded, '
      'Then home feed option is shown', (tester) async {
    // ARRANGE
    await pumpActions(tester);

    // ACTION
    await tester.tap(find.text(l10n.instagram_features_tile_title));
    await tester.pumpAndSettle();

    // CHECK
    expect(find.text(l10n.instagram_features_block_home_feed), findsOneWidget);
  });

  testWidgets(
      'Given Facebook tile, When expanded, '
      'Then home feed and reels options are shown', (tester) async {
    // ARRANGE
    await pumpActions(tester);

    // ACTION
    await tester.tap(find.text(l10n.facebook_features_tile_title));
    await tester.pumpAndSettle();

    // CHECK
    expect(find.text(l10n.facebook_features_block_home_feed), findsOneWidget);
    expect(find.text(l10n.facebook_features_block_reels), findsOneWidget);
  });
}
