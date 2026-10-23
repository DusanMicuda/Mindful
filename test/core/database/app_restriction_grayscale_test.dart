import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/utils/default_models_utils.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('AppRestriction grayscaleEnabled', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('Given default model, When read, Then grayscaleEnabled is false', () {
      // ARRANGE / ACTION / CHECK
      expect(defaultAppRestrictionModel.grayscaleEnabled, isFalse);
    });

    test(
        'Given restriction inserted without grayscale, When fetched, '
        'Then grayscaleEnabled is false', () async {
      // ARRANGE
      final dao = db.dynamicRecordsDao;
      await dao.insertAppRestrictionByPackage(
        defaultAppRestrictionModel.copyWith(appPackage: 'com.a'),
      );

      // ACTION
      final result = await dao.fetchAppsRestrictions();

      // CHECK
      expect(result.single.appPackage, 'com.a');
      expect(result.single.grayscaleEnabled, isFalse);
    });

    test(
        'Given restriction with grayscaleEnabled true, When fetched, '
        'Then grayscaleEnabled is true', () async {
      // ARRANGE
      final dao = db.dynamicRecordsDao;
      await dao.insertAppRestrictionByPackage(
        defaultAppRestrictionModel.copyWith(
          appPackage: 'com.a',
          grayscaleEnabled: true,
        ),
      );

      // ACTION
      final result = await dao.fetchAppsRestrictions();

      // CHECK
      expect(result.single.grayscaleEnabled, isTrue);
    });
  });

  group('Migration v9 to v10', () {
    test(
        'Given v9 database with a restriction row, When opened, '
        'Then row is kept and grayscaleEnabled is false', () async {
      // ARRANGE: raw v9 app_restriction_table (no grayscale column)
      final raw = sqlite3.openInMemory();
      raw.execute('''
        CREATE TABLE app_restriction_table (
          app_package TEXT NOT NULL,
          timer_sec INTEGER NOT NULL DEFAULT 0,
          launch_limit INTEGER NOT NULL DEFAULT 0,
          active_period_start INTEGER NOT NULL DEFAULT 0,
          active_period_end INTEGER NOT NULL DEFAULT 0,
          period_duration_in_mins INTEGER NOT NULL DEFAULT 0,
          associated_group_id INTEGER NULL DEFAULT NULL,
          can_access_internet INTEGER NOT NULL DEFAULT 1
            CHECK (can_access_internet IN (0, 1)),
          reminder_type TEXT NOT NULL DEFAULT 'toast',
          PRIMARY KEY (app_package)
        )
      ''');
      raw.execute(
        "INSERT INTO app_restriction_table "
        "(app_package, timer_sec, launch_limit, can_access_internet) "
        "VALUES ('com.old', 120, 3, 0)",
      );
      raw.execute('PRAGMA user_version = 9');

      // ACTION: AppDatabase (schema 10) opens and upgrades
      final db = AppDatabase(NativeDatabase.opened(raw));
      addTearDown(db.close);
      final result = await db.dynamicRecordsDao.fetchAppsRestrictions();

      // CHECK
      expect(result, hasLength(1));
      expect(result.single.appPackage, 'com.old');
      expect(result.single.timerSec, 120);
      expect(result.single.launchLimit, 3);
      expect(result.single.canAccessInternet, isFalse);
      expect(result.single.grayscaleEnabled, isFalse);
    });
  });
}
