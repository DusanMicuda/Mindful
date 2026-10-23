import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/utils/default_models_utils.dart';

void main() {
  test('Given default restriction, then launchDelaySec is 0', () {
    // ARRANGE / ACTION / CHECK
    expect(defaultAppRestrictionModel.launchDelaySec, 0);
  });

  test('Given restriction with launchDelaySec, then toJson exposes it', () {
    // ARRANGE
    final restriction = defaultAppRestrictionModel.copyWith(
      appPackage: 'com.instagram.android',
      launchDelaySec: 30,
    );

    // ACTION
    final json = restriction.toJson();

    // CHECK
    expect(json['launchDelaySec'], 30);
  });

  test('Given inserted restriction, when fetched, then launchDelaySec persists',
      () async {
    // ARRANGE
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final restriction = defaultAppRestrictionModel.copyWith(
      appPackage: 'com.instagram.android',
      launchDelaySec: 30,
    );

    // ACTION
    await db.dynamicRecordsDao.insertAppRestrictionByPackage(restriction);
    final result = await db.dynamicRecordsDao.fetchAppsRestrictions();

    // CHECK
    final saved =
        result.singleWhere((r) => r.appPackage == 'com.instagram.android');
    expect(saved.launchDelaySec, 30);
  });
}
