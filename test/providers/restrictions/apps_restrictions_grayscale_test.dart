import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/services/drift_db_service.dart';
import 'package:mindful/models/app_info.dart';
import 'package:mindful/providers/apps/apps_info_provider.dart';
import 'package:mindful/providers/restrictions/apps_restrictions_provider.dart';

const _package = 'com.test';

class _FakeAppsInfoNotifier extends AppsInfoNotifier {
  @override
  Future<Map<String, AppInfo>> build() async => {
        _package: AppInfo(
          name: 'Test',
          packageName: _package,
          isImpSysApp: false,
          icon: Uint8List(0),
        ),
      };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late List<String> trackerPayloads;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DriftDbService.instance.driftDb = db;
    trackerPayloads = [];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.mindful.android.methodchannel.fg'),
      (call) async {
        if (call.method == 'updateAppRestrictions') {
          trackerPayloads.add(call.arguments as String);
        }
        return null;
      },
    );

    container = ProviderContainer(
      overrides: [appsInfoProvider.overrideWith(_FakeAppsInfoNotifier.new)],
    );
    addTearDown(container.dispose);
    await container.read(appsInfoProvider.future);
    container.read(appsRestrictionsProvider); // starts _init
    await Future<void>.delayed(const Duration(milliseconds: 100));
    trackerPayloads.clear(); // ignore init-time pushes
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.mindful.android.methodchannel.fg'),
      null,
    );
    await db.close();
  });

  test(
      'Given no restriction, When switchGrayscale true, '
      'Then grayscaleEnabled is persisted in DB', () async {
    // ACTION
    container
        .read(appsRestrictionsProvider.notifier)
        .switchGrayscale(_package, true);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // CHECK
    final rows = await db.dynamicRecordsDao.fetchAppsRestrictions();
    expect(rows.single.appPackage, _package);
    expect(rows.single.grayscaleEnabled, isTrue);
  });

  test(
      'Given grayscale-only restriction, When switchGrayscale true, '
      'Then tracker update payload contains the package with grayscale on',
      () async {
    // ACTION
    container
        .read(appsRestrictionsProvider.notifier)
        .switchGrayscale(_package, true);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // CHECK
    expect(trackerPayloads, isNotEmpty);
    final sent =
        (jsonDecode(trackerPayloads.last) as List).cast<Map<String, dynamic>>();
    expect(sent, hasLength(1));
    expect(sent.single['appPackage'], _package);
    expect(sent.single['grayscaleEnabled'], isTrue);
  });
}
