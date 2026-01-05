import 'package:drift/drift.dart';

/// Typ der Kategorie
enum CategoryType {
  /// Einnahme-Kategorie
  income,

  /// Ausgabe-Kategorie
  expense,
}

/// Tabelle für Kategorien
///
/// Speichert Kategorien für Buchungen mit Baumstruktur (Hauptkategorien und Unterkategorien).
/// Kategorien sind nach Typ (Einnahmen/Ausgaben) getrennt.
@DataClassName('CategoryData')
class CategoriesTable extends Table {
  @override
  String get tableName => 'categories';

  /// Primärschlüssel
  IntColumn get id => integer().autoIncrement()();

  /// Name der Kategorie (z.B. "Lebensmittel", "Gehalt")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Typ der Kategorie (income oder expense)
  IntColumn get type => intEnum<CategoryType>()();

  /// Fremdschlüssel zur Eltern-Kategorie (null = Hauptkategorie)
  IntColumn get parentId =>
      integer().nullable().references(CategoriesTable, #id)();

  /// Icon-Name aus Material Icons
  TextColumn get icon => text().withLength(min: 1, max: 50)();

  /// Farbe der Kategorie (Hex-String, z.B. "#FF5733")
  TextColumn get color =>
      text().withLength(min: 7, max: 7).nullable()();

  /// Sortierreihenfolge
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Ob dies eine Standard-Kategorie ist (kann nicht gelöscht werden)
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Zeitstempel der Erstellung
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Zeitstempel der letzten Änderung
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
