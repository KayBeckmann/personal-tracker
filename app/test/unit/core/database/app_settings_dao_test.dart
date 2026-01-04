import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker/core/database/app_database.dart';
import 'package:personal_tracker/core/database/daos/app_settings_dao.dart';

void main() {
  late AppDatabase database;
  late AppSettingsDao dao;

  setUp(() {
    // Erstelle In-Memory Datenbank für Tests
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AppSettingsDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('AppSettingsDao', () {
    test('should save and retrieve setting', () async {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      await dao.setSetting(key, value);
      final result = await dao.getSetting(key);

      // Assert
      expect(result, isNotNull);
      expect(result!.key, equals(key));
      expect(result.value, equals(value));
    });

    test('should return null for non-existent key', () async {
      // Act
      final result = await dao.getSetting('non_existent');

      // Assert
      expect(result, isNull);
    });

    test('should update existing setting', () async {
      // Arrange
      const key = 'test_key';
      const initialValue = 'initial';
      const updatedValue = 'updated';

      // Act
      await dao.setSetting(key, initialValue);
      await dao.setSetting(key, updatedValue);
      final result = await dao.getSetting(key);

      // Assert
      expect(result!.value, equals(updatedValue));
    });

    test('should delete setting', () async {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      await dao.setSetting(key, value);
      final deleteCount = await dao.deleteSetting(key);
      final result = await dao.getSetting(key);

      // Assert
      expect(deleteCount, equals(1));
      expect(result, isNull);
    });

    test('should get all settings', () async {
      // Arrange
      await dao.setSetting('key1', 'value1');
      await dao.setSetting('key2', 'value2');

      // Act
      final settings = await dao.getAllSettings();

      // Assert
      expect(settings.length, equals(2));
      expect(settings.any((s) => s.key == 'key1' && s.value == 'value1'), true);
      expect(settings.any((s) => s.key == 'key2' && s.value == 'value2'), true);
    });

    test('should watch setting changes', () async {
      // Arrange
      const key = 'watch_key';
      final stream = dao.watchSetting(key);
      final values = <String?>[];

      // Act
      final subscription = stream.listen(
        (setting) => values.add(setting?.value),
      );

      // Warte kurz, damit der Stream bereit ist
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await dao.setSetting(key, 'value1');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await dao.setSetting(key, 'value2');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      // Assert
      expect(values.length, greaterThanOrEqualTo(2));
      expect(values.last, equals('value2'));
    });
  });
}
