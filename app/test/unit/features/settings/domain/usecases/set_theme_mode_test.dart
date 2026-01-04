import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker/core/database/app_database.dart';
import 'package:personal_tracker/core/database/daos/app_settings_dao.dart';
import 'package:personal_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:personal_tracker/features/settings/domain/usecases/set_theme_mode.dart';

void main() {
  late AppDatabase database;
  late SettingsRepositoryImpl repository;
  late SetThemeMode useCase;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final dao = AppSettingsDao(database);
    repository = SettingsRepositoryImpl(dao);
    useCase = SetThemeMode(repository);
  });

  tearDown(() async {
    await database.close();
  });

  group('SetThemeMode', () {
    test('should save light theme mode', () async {
      // Act
      await useCase('light');
      final result = await repository.getSetting('theme_mode');

      // Assert
      expect(result, equals('light'));
    });

    test('should save dark theme mode', () async {
      // Act
      await useCase('dark');
      final result = await repository.getSetting('theme_mode');

      // Assert
      expect(result, equals('dark'));
    });

    test('should save system theme mode', () async {
      // Act
      await useCase('system');
      final result = await repository.getSetting('theme_mode');

      // Assert
      expect(result, equals('system'));
    });

    test('should throw error for invalid theme mode', () async {
      // Act & Assert
      expect(
        () => useCase('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should update existing theme mode', () async {
      // Arrange
      await useCase('light');

      // Act
      await useCase('dark');
      final result = await repository.getSetting('theme_mode');

      // Assert
      expect(result, equals('dark'));
    });
  });
}
