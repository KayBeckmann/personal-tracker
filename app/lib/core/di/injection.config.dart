// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/domain/usecases/get_locale.dart' as _i514;
import '../../features/settings/domain/usecases/get_theme_mode.dart' as _i867;
import '../../features/settings/domain/usecases/set_locale.dart' as _i729;
import '../../features/settings/domain/usecases/set_theme_mode.dart' as _i743;
import '../database/app_database.dart' as _i982;
import '../database/daos/app_settings_dao.dart' as _i16;
import '../navigation/app_router.dart' as _i630;
import '../navigation/module_service.dart' as _i261;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i982.AppDatabase>(() => _i982.AppDatabase());
    gh.lazySingleton<_i630.AppRouter>(() => _i630.AppRouter());
    gh.lazySingleton<_i16.AppSettingsDao>(
      () => _i16.AppSettingsDao(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i674.SettingsRepository>(
      () => _i955.SettingsRepositoryImpl(gh<_i16.AppSettingsDao>()),
    );
    gh.lazySingleton<_i261.ModuleService>(
      () => _i261.ModuleService(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i514.GetLocale>(
      () => _i514.GetLocale(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i867.GetThemeMode>(
      () => _i867.GetThemeMode(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i729.SetLocale>(
      () => _i729.SetLocale(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i743.SetThemeMode>(
      () => _i743.SetThemeMode(gh<_i674.SettingsRepository>()),
    );
    return this;
  }
}
