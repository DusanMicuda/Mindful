import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/core/database/adapters/time_of_day_adapter.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/enums/reminder_type.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'Given restriction with sessionIntervalSec 900, '
    'When inserted and fetched, Then value persists and serializes',
    () async {
      // ARRANGE
      const restriction = AppRestriction(
        appPackage: 'com.example.app',
        timerSec: 0,
        launchLimit: 0,
        activePeriodStart: TimeOfDayAdapter.zero(),
        activePeriodEnd: TimeOfDayAdapter.zero(),
        periodDurationInMins: 0,
        canAccessInternet: true,
        reminderType: ReminderType.none,
        sessionIntervalSec: 900,
      );

      // ACTION
      await db.dynamicRecordsDao.insertAppRestrictionByPackage(restriction);
      final fetched = await db.dynamicRecordsDao.fetchAppsRestrictions();

      // CHECK
      expect(fetched.single.sessionIntervalSec, 900);
      expect(fetched.single.toJson()['sessionIntervalSec'], 900);
    },
  );

  test(
    'Given row inserted without sessionIntervalSec, '
    'When fetched, Then it defaults to 0',
    () async {
      // ARRANGE / ACTION
      await db.into(db.appRestrictionTable).insert(
            AppRestrictionTableCompanion(
              appPackage: const Value('com.example.app'),
            ),
          );
      final fetched = await db.dynamicRecordsDao.fetchAppsRestrictions();

      // CHECK
      expect(fetched.single.sessionIntervalSec, 0);
    },
  );

  test(
    'Given v9 database with an existing restriction row, '
    'When opened with AppDatabase, Then migration to v10 keeps row '
    'and sessionIntervalSec defaults to 0',
    () async {
      // ARRANGE
      final raw = sqlite.sqlite3.openInMemory();
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
        "INSERT INTO app_restriction_table (app_package, timer_sec) "
        "VALUES ('com.example.legacy', 120)",
      );
      raw.execute('PRAGMA user_version = 9');
      final migrated = AppDatabase(NativeDatabase.opened(raw));
      addTearDown(migrated.close);

      // ACTION
      final fetched = await migrated.dynamicRecordsDao.fetchAppsRestrictions();

      // CHECK
      expect(fetched, hasLength(1));
      expect(fetched.single.appPackage, 'com.example.legacy');
      expect(fetched.single.timerSec, 120);
      expect(fetched.single.sessionIntervalSec, 0);
    },
  );
}
