import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global Service Locator Instance
final getIt = GetIt.instance;

/// Initialize Dependency Injection
///
/// Dies sollte einmal beim App-Start aufgerufen werden.
/// Umgebung kann gesetzt werden für verschiedene Konfigurationen:
/// - dev (Entwicklung)
/// - prod (Produktion)
/// - test (Testing)
@InjectableInit(preferRelativeImports: true)
void configureDependencies({String? environment}) =>
    getIt.init(environment: environment);
