# Personal Tracker - Roadmap

## Workflow pro Meilenstein
Nach Abschluss jedes Meilensteins:
1. **Automatisierte Tests** durchlaufen lassen
2. Bei erfolgreichen Tests: **Git Commit** erstellen

---

## Meilenstein 1: Grundgerüst
Basis-Infrastruktur für die gesamte Anwendung.

### 1.1 Projekt-Setup
- [x] Flutter-Projekt initialisieren
- [x] Projektstruktur festlegen (Clean Architecture)
- [x] Dependency Injection einrichten (z.B. get_it)
- [x] Linting & Code-Formatierung konfigurieren

### 1.2 Lokale Datenbank
- [x] SQLite/Drift Integration
- [x] Basis-Datenbankschema erstellen
- [x] Repository-Pattern implementieren

### 1.3 Navigation & Shell
- [x] Bottom Navigation / Drawer erstellen
- [x] Routing einrichten (go_router)
- [x] Modul-System (aktivieren/deaktivieren)

### 1.4 Mehrsprachigkeit
- [x] i18n Setup (flutter_localizations + intl)
- [x] Sprachdateien für EN, DE anlegen
- [x] Sprachwechsel in Einstellungen

### 1.5 Theming
- [x] Light/Dark Theme definieren
- [x] Theme-Wechsel implementieren
- [x] Persistierung der Einstellung

### 1.6 Test-Framework
- [x] Unit-Test Setup (flutter_test)
- [x] Widget-Test Setup
- [x] Integration-Test Setup
- [x] Test-Coverage Konfiguration
- [x] CI-Pipeline vorbereiten (GitHub Actions / GitLab CI)

### 1.7 Docker für Web-Frontend
- [x] Dockerfile für Flutter Web erstellen
- [x] docker-compose.yml anlegen
- [x] .env Datei für Konfiguration
- [x] .env.example als Vorlage
- [x] Build- und Deploy-Skript

### 1.8 Material Design
- [x] Material 3 (Material You) aktivieren
- [x] Farbschema mit Dynamic Color Support
- [x] Typografie nach Material Design Guidelines
- [x] Einheitliche Komponenten (Cards, Buttons, FABs, etc.)
- [x] Responsive Layouts (Compact, Medium, Expanded)
- [x] Motion & Animationen nach Material Specs
- [x] Icon-Set festlegen (Material Symbols)
- [x] Barrierefreiheit (Accessibility) sicherstellen

### Abschluss Meilenstein 1
- [x] Alle Tests durchlaufen
- [x] Git Commit: "feat: Grundgerüst mit Navigation, i18n, Theming und Docker"

---

## Meilenstein 2: Haushaltsbuch
Komplettes Finanzmodul als erste Kernfunktion.

### 2.1 Datenmodell
- [x] Konten (Konto, Kontotyp)
- [x] Kategorien (mit Unterkategorien, Baumstruktur)
- [x] Buchungen (Einnahme/Ausgabe/Umbuchung)
- [x] Daueraufträge
- [x] Budgets

### 2.2 Konten
- [x] Kontenliste mit Gruppierung nach Typ
- [x] Konto erstellen/bearbeiten/löschen
- [x] Kontotypen verwalten
- [x] Saldo-Berechnung pro Konto & Gruppe

### 2.3 Kategorien
- [ ] Baumansicht für Kategorien
- [ ] Trennung Einnahmen/Ausgaben
- [ ] Unterkategorien anlegen
- [ ] Kategorien bearbeiten/löschen

### 2.4 Buchungen
- [ ] Buchungsliste mit Filtern (Datum, Kategorie, Empfänger, Freitext)
- [ ] Buchung erstellen (alle Felder lt. Brainstorming)
- [ ] Buchung bearbeiten/löschen
- [ ] Zukünftige/geplante Buchungen
- [ ] Als Vorlage speichern

### 2.5 Daueraufträge
- [ ] Dauerauftragsliste
- [ ] Dauerauftrag erstellen/bearbeiten/löschen
- [ ] Automatische Buchungserstellung

### 2.6 Budgets
- [ ] Budget pro Kategorie/Konto anlegen
- [ ] SOLL/IST Vergleich
- [ ] Fortschrittsanzeige

### 2.7 Finanzübersicht
- [ ] Kapitalsumme anzeigen
- [ ] Anstehende Daueraufträge
- [ ] Geplante Buchungen
- [ ] Budget-Übersicht
- [ ] Voraussichtliches Kapital am Monatsende

### Abschluss Meilenstein 2
- [ ] Unit-Tests für Haushaltsbuch-Logik
- [ ] Widget-Tests für Haushaltsbuch-UI
- [ ] Alle Tests durchlaufen
- [ ] Git Commit: "feat: Haushaltsbuch mit Konten, Buchungen, Budgets"

---

## Meilenstein 3: Notizen & Aufgaben
Produktivitäts-Module als Basis für Verlinkungen.

### 3.1 Notizen
- [ ] Datenmodell (Notiz, Tags)
- [ ] Notizliste mit Filter (Freitext, Tags)
- [ ] Markdown-Editor
- [ ] Markdown-Vorschau
- [ ] Verlinkungen zwischen Notizen
- [ ] Bilder einbetten
- [ ] Archiv-Funktion

### 3.2 Aufgaben
- [ ] Datenmodell (Aufgabe, Status, Priorität)
- [ ] Aufgabenliste mit Sortierung/Filter
- [ ] Aufgabe erstellen/bearbeiten
- [ ] Status-Wechsel (offen, in Bearbeitung, erledigt)
- [ ] Fälligkeitsdatum & Erinnerungen
- [ ] Verknüpfung zu Notizen

### Abschluss Meilenstein 3
- [ ] Unit-Tests für Notizen & Aufgaben
- [ ] Widget-Tests für Notizen & Aufgaben
- [ ] Alle Tests durchlaufen
- [ ] Git Commit: "feat: Notizen mit Markdown und Aufgaben-Management"

---

## Meilenstein 4: Gewohnheiten & Journal
Persönliche Reflexions-Module.

### 4.1 Gewohnheiten
- [ ] Datenmodell (Gewohnheit, Intervall, Wertetyp)
- [ ] Gewohnheitsliste
- [ ] Werte erfassen (heute + nachtragen)
- [ ] Graph (letzte 30 Tage)

### 4.2 Journal
- [ ] Datenmodell (Journaleintrag, Tracker)
- [ ] Kalenderansicht (privat/beruflich markiert)
- [ ] Markdown-Editor mit Verlinkungen
- [ ] Vorlagen-System
- [ ] Tracker erstellen & ausfüllen
- [ ] Tracker-Visualisierung (30 Tage)
- [ ] PIN-Schutz / Biometrie

### Abschluss Meilenstein 4
- [ ] Unit-Tests für Gewohnheiten & Journal
- [ ] Widget-Tests für Gewohnheiten & Journal
- [ ] Alle Tests durchlaufen
- [ ] Git Commit: "feat: Gewohnheiten-Tracking und Journal mit Trackern"

---

## Meilenstein 5: Zeiterfassung
Arbeitszeitmodul mit Aufgaben-Verknüpfung.

### 5.1 Grundfunktionen
- [ ] Datenmodell (Zeiteintrag, Urlaubstage, Überstunden)
- [ ] Kalenderansicht (erfasste Tage, Urlaub, Krankheit)
- [ ] Ein-/Ausstempeln mit Rundung
- [ ] Zeiten nachtragen

### 5.2 Erweiterte Funktionen
- [ ] Task wechseln während Erfassung
- [ ] Verknüpfung zu Aufgaben
- [ ] Tages- und Eintragsnotizen
- [ ] Überstunden-Übersicht (manuell setzbar)
- [ ] Resturlaub-Tracking

### 5.3 Einstellungen
- [ ] Rundungsintervalle (1/5/10/15 Min)
- [ ] Sollstunden-Vorgabe

### Abschluss Meilenstein 5
- [ ] Unit-Tests für Zeiterfassung
- [ ] Widget-Tests für Zeiterfassung
- [ ] Alle Tests durchlaufen
- [ ] Git Commit: "feat: Zeiterfassung mit Stempeln und Überstunden"

---

## Meilenstein 6: Dashboard
Zentrale Übersicht aller Module.

- [ ] Widget-System für Module
- [ ] Anpassbare Anordnung
- [ ] Schnellzugriff auf häufige Aktionen
- [ ] Zusammenfassung wichtiger Daten

### Abschluss Meilenstein 6
- [ ] Unit-Tests für Dashboard
- [ ] Widget-Tests für Dashboard
- [ ] Alle Tests durchlaufen
- [ ] Git Commit: "feat: Dashboard mit Widget-System"

---

## Meilenstein 7: Backend & Synchronisation
Server-Infrastruktur und Datensync.

### 7.1 Backend (Dart)
- [ ] Dart Backend Framework wählen (shelf/dart_frog)
- [ ] REST API definieren
- [ ] Authentifizierung (JWT)
- [ ] Datenbankanbindung (PostgreSQL)

### 7.2 Synchronisation
- [ ] Konfliktauflösung definieren
- [ ] Hintergrund-Sync implementieren
- [ ] Offline-Queue für Änderungen

### 7.3 Benutzerverwaltung
- [ ] Registrierung
- [ ] Anmeldung
- [ ] Backend-URL konfigurierbar

### Abschluss Meilenstein 7
- [ ] Unit-Tests für Backend
- [ ] Integration-Tests für API
- [ ] Sync-Tests (Online/Offline)
- [ ] Alle Tests durchlaufen
- [ ] Git Commit: "feat: Backend mit API und Synchronisation"

---

## Meilenstein 8: Deployment & Dokumentation
Produktionsreife und Veröffentlichung.

### 8.1 Docker (Backend & Datenbank)
- [ ] Dockerfile für Backend
- [ ] Datenbank-Container (PostgreSQL)
- [ ] docker-compose.yml erweitern für vollständigen Stack:
  - [ ] Web-Frontend (aus M1)
  - [ ] Backend API
  - [ ] PostgreSQL Datenbank
  - [ ] Projektwebseite
  - [ ] Wiki
- [ ] Nginx Reverse Proxy Konfiguration
- [ ] .env Erweiterung für alle Services
- [ ] Docker Volumes für persistente Daten

### 8.2 Projektwebseite
Öffentliche Präsentation des Projekts.

- [ ] Technologie wählen (Static Site Generator: Hugo/Astro/11ty)
- [ ] Landing Page mit Hero-Section
- [ ] Feature-Übersicht mit Screenshots
- [ ] Modul-Beschreibungen (Haushaltsbuch, Notizen, etc.)
- [ ] Download-Bereich
  - [ ] Links zu App Stores
  - [ ] Desktop-Downloads (Linux, Windows)
  - [ ] Link zur Web-App
- [ ] Self-Hosting Anleitung
- [ ] Changelog / Release Notes
- [ ] Spenden-Seite (BTC, Buy Me a Coffee)
- [ ] Impressum & Datenschutz
- [ ] Dockerfile für Projektwebseite
- [ ] In docker-compose integrieren

### 8.3 Wiki / Dokumentation
Technisches Wiki und Benutzerhandbuch.

#### Technische Dokumentation
- [ ] Wiki-System wählen (WikiJS / Docusaurus / MkDocs)
- [ ] Architektur-Übersicht
- [ ] Datenbank-Schema Dokumentation
- [ ] API-Dokumentation (OpenAPI/Swagger)
- [ ] Entwickler-Setup Anleitung
- [ ] Contribution Guidelines
- [ ] Code-Styleguide

#### Benutzerhandbuch
- [ ] Erste Schritte / Quickstart
- [ ] Modul-Anleitungen
  - [ ] Haushaltsbuch
  - [ ] Notizen & Aufgaben
  - [ ] Gewohnheiten & Journal
  - [ ] Zeiterfassung
  - [ ] Dashboard
- [ ] Einstellungen erklärt
- [ ] Backend-Einrichtung & Sync
- [ ] FAQ / Troubleshooting
- [ ] Mehrsprachige Dokumentation (DE, EN)

#### Deployment
- [ ] Dockerfile für Wiki
- [ ] In docker-compose integrieren

### 8.4 Plattform-Builds
- [ ] Linux Build
- [ ] Windows Build
- [ ] Android APK / Play Store
- [ ] iOS / App Store
- [ ] Web Deployment

### Abschluss Meilenstein 8
- [ ] End-to-End Tests
- [ ] Alle Tests durchlaufen
- [ ] Git Commit: "feat: Deployment-Pipeline und Dokumentation"

---

## Zusätzliche Sprachen (fortlaufend)
- [ ] Französisch
- [ ] Spanisch
- [ ] Schwedisch
- [ ] Norwegisch
