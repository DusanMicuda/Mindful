import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/services/drift_db_service.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';
import 'package:mindful/models/app_info.dart';
import 'package:mindful/ui/screens/app_dashboard/app_grayscale_tile.dart';

const _fullCmd =
    'adb shell pm grant com.mindful.android android.permission.WRITE_SECURE_SETTINGS';
const _shellCmd =
    'pm grant com.mindful.android android.permission.WRITE_SECURE_SETTINGS';
const _rootCmd =
    'su -c pm grant com.mindful.android android.permission.WRITE_SECURE_SETTINGS';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late List<String> clipboard;
  late AppLocalizations l10n;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DriftDbService.instance.driftDb = db;
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    clipboard = [];

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.mindful.android.methodchannel.fg'),
      (call) async =>
          call.method == 'hasWriteSecureSettingsPermission' ? false : null,
    );
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard.add((call.arguments as Map)['text'] as String);
      }
      return null;
    });
  });

  tearDown(() async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.mindful.android.methodchannel.fg'),
      null,
    );
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    await db.close();
  });

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppGrayscaleTile(
                appInfo: AppInfo(
                  name: 'Test',
                  packageName: 'com.test',
                  isImpSysApp: false,
                  icon: Uint8List(0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.grayscale_tile_title));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Given permission missing, When tile tapped, '
      'Then five options and all commands are shown', (tester) async {
    // ARRANGE / ACTION
    await openDialog(tester);

    // CHECK
    final titles = [
      l10n.grayscale_permission_usb_title,
      l10n.grayscale_permission_wireless_title,
      l10n.grayscale_permission_ladb_title,
      l10n.grayscale_permission_shizuku_title,
      l10n.grayscale_permission_root_title,
    ];
    for (final t in titles) {
      await tester.ensureVisible(find.text(t));
      expect(find.text(t), findsOneWidget);
    }
    expect(find.text(_fullCmd, skipOffstage: false), findsNWidgets(2));
    expect(find.text(_shellCmd, skipOffstage: false), findsNWidgets(2));
    expect(find.text(_rootCmd, skipOffstage: false), findsOneWidget);
  });

  testWidgets(
      'Given dialog open, When each copy button tapped, '
      'Then clipboard gets exact command and snack shown', (tester) async {
    // ARRANGE
    await openDialog(tester);
    final buttons = find.byTooltip(
      l10n.grayscale_permission_copy_command,
      skipOffstage: false,
    );
    expect(buttons, findsNWidgets(5));
    const expected = [_fullCmd, _fullCmd, _shellCmd, _shellCmd, _rootCmd];

    for (var i = 0; i < 5; i++) {
      // ACTION
      await tester.ensureVisible(buttons.at(i));
      await tester.pumpAndSettle();
      await tester.tap(buttons.at(i));
      await tester.pump();

      // CHECK
      expect(clipboard.last, expected[i]);
      expect(
          find.text(l10n.grayscale_command_copied_snack_alert), findsWidgets);
    }
    expect(clipboard, expected);
  });
}
