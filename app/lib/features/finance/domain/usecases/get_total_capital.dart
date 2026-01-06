import 'package:injectable/injectable.dart';

import '../repositories/account_repository.dart';

/// Use Case zum Abrufen der Gesamtkapitalsumme
///
/// Summiert die Salden aller Konten
@lazySingleton
class GetTotalCapital {
  GetTotalCapital(this._repository);

  final AccountRepository _repository;

  /// Gibt die Gesamtkapitalsumme über alle Konten zurück
  Future<double> call() async {
    final accounts = await _repository.getAllAccounts();
    double total = 0.0;

    for (final account in accounts) {
      final balance = await _repository.calculateBalance(account.id);
      total += balance;
    }

    return total;
  }

  /// Stream der Gesamtkapitalsumme (aktualisiert sich bei Änderungen)
  Stream<double> watch() {
    return _repository.watchAllAccounts().asyncMap((accounts) async {
      double total = 0.0;

      for (final account in accounts) {
        final balance = await _repository.calculateBalance(account.id);
        total += balance;
      }

      return total;
    });
  }
}
