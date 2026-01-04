import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker/core/database/app_database.dart';
import 'package:personal_tracker/core/database/daos/app_settings_dao.dart';
import 'package:personal_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:personal_tracker/features/settings/domain/usecases/get_theme_mode.dart';

void main() {
  late AppDatabase database;
  late SettingsRepositoryImpl repository;
  late GetThemeMode useCase;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final dao = AppSettingsDao(database);
    repository = SettingsRepositoryImpl(dao);
    useCase = GetThemeMode(repository);
  });

  tearDown(() async {
    await database.close();
  });

  group('GetThemeMode', () {
    test('should return system as default when no setting exists', () async {
      // Act
      final result = await useCase();

      // Assert
      expect(result, equals('system'));
    });

    test('should return stored theme mode', () async {
      // Arrange
      await repository.setSetting('theme_mode', 'dark');

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals('dark'));
    });

    test('should watch theme mode changes', () async {
      // Arrange
      final stream = useCase.watch();
      final values = <String>[];

      // Act
      final subscription = stream.listen(values.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repository.setSetting('theme_mode', 'light');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repository.setSetting('theme_mode', 'dark');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      // Assert
      expect(values.length, greaterThanOrEqualTo(2));
      expect(values.last, equals('dark'));
    });
  });
}
