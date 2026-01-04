import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker/core/database/app_database.dart';
import 'package:personal_tracker/core/database/daos/app_settings_dao.dart';
import 'package:personal_tracker/features/settings/data/repositories/settings_repository_impl.dart';

void main() {
  late AppDatabase database;
  late AppSettingsDao dao;
  late SettingsRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AppSettingsDao(database);
    repository = SettingsRepositoryImpl(dao);
  });

  tearDown(() async {
    await database.close();
  });

  group('SettingsRepositoryImpl', () {
    test('should get setting value', () async {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';
      await dao.setSetting(key, value);

      // Act
      final result = await repository.getSetting(key);

      // Assert
      expect(result, equals(value));
    });

    test('should return null for non-existent setting', () async {
      // Act
      final result = await repository.getSetting('non_existent');

      // Assert
      expect(result, isNull);
    });

    test('should set setting', () async {
      // Arrange
      const key = 'new_key';
      const value = 'new_value';

      // Act
      await repository.setSetting(key, value);
      final result = await repository.getSetting(key);

      // Assert
      expect(result, equals(value));
    });

    test('should delete setting', () async {
      // Arrange
      const key = 'delete_key';
      const value = 'delete_value';
      await repository.setSetting(key, value);

      // Act
      await repository.deleteSetting(key);
      final result = await repository.getSetting(key);

      // Assert
      expect(result, isNull);
    });

    test('should get all settings as map', () async {
      // Arrange
      await repository.setSetting('key1', 'value1');
      await repository.setSetting('key2', 'value2');

      // Act
      final settings = await repository.getAllSettings();

      // Assert
      expect(settings, isA<Map<String, String>>());
      expect(settings.length, equals(2));
      expect(settings['key1'], equals('value1'));
      expect(settings['key2'], equals('value2'));
    });

    test('should watch setting changes', () async {
      // Arrange
      const key = 'watch_key';
      final stream = repository.watchSetting(key);
      final values = <String?>[];

      // Act
      final subscription = stream.listen(values.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repository.setSetting(key, 'value1');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repository.setSetting(key, 'value2');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      // Assert
      expect(values.length, greaterThanOrEqualTo(2));
      expect(values.last, equals('value2'));
    });

    test('should watch all settings', () async {
      // Arrange
      final stream = repository.watchAllSettings();
      final maps = <Map<String, String>>[];

      // Act
      final subscription = stream.listen(maps.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repository.setSetting('key1', 'value1');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repository.setSetting('key2', 'value2');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      // Assert
      expect(maps.length, greaterThanOrEqualTo(2));
      expect(maps.last['key1'], equals('value1'));
      expect(maps.last['key2'], equals('value2'));
    });
  });
}
