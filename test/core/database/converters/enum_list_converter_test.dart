import 'package:flutter_test/flutter_test.dart';
import 'package:mindful/core/database/converters/enum_list_converter.dart';
import 'package:mindful/core/enums/platform_features.dart';

void main() {
  const converter = EnumListConverter(PlatformFeatures.values);

  group('EnumListConverter<PlatformFeatures>', () {
    test('Given home feed features, When round-tripped, Then lists are equal',
        () {
      // ARRANGE
      const features = [
        PlatformFeatures.instagramHomeFeed,
        PlatformFeatures.facebookHomeFeed,
      ];

      // ACTION
      final result = converter.fromSql(converter.toSql(features));

      // CHECK
      expect(result, features);
    });

    test('Given home feed features, When toSql, Then output has their names',
        () {
      // ARRANGE
      const features = [
        PlatformFeatures.instagramHomeFeed,
        PlatformFeatures.facebookHomeFeed,
      ];

      // ACTION
      final sql = converter.toSql(features);

      // CHECK
      expect(sql, contains('"instagramHomeFeed"'));
      expect(sql, contains('"facebookHomeFeed"'));
    });

    test('Given legacy stored value, When fromSql, Then it still decodes', () {
      // ARRANGE
      const stored = '["instagramReels"]';

      // ACTION
      final result = converter.fromSql(stored);

      // CHECK
      expect(result, [PlatformFeatures.instagramReels]);
    });
  });
}
