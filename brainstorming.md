# Personal Tracker
**Ziel**:
Persönliche Daten können lokal erfasst werden.
Bei Bedarf können die Daten zum Backend syncronisiert werden.

## Struktur
- Multilingual
  - Englisch (Default)
  - Deutsch
  - Französisch
  - Spanisch
- Flutter Frontend
  - Linux
  - Windows
  - Web-App
  - Android
  - Apple
- Dart Backend
- SQL Datenbank
- Docker Container
  - Web-Frontend
  - Backend
  - SQL Datenbank
  - Projektwebseite als Vorstellung
  - Wiki
    - Technische Beschreibung
    - Benutzerhandbuch
- Automatische Syncronisation im Hintergrund, wenn eingeloggt

## Anforderungen
Die App soll in unterschiedliche Module aufgeteilt sein.

### Dashboard

### Notizen
Notizen sollen in Markdown erstellt werden. Verlinkungen sollen möglich sein, damit auch eine Art Wiki erstellt werden kann.
Die erste Zeile der Notiz soll als Headline in der Übersicht dienen.
Es soll möglich sein Tags für Notizen zu setzen.
Wenn die Details einer Notiz geöffnet werden, soll die Notiz in der Vorschau geöffnet werden.
Bilder sollen ebenfalls verlinkt werden können.
Alte Notizen sollen entweder in ein Archiv verschoben werden können oder gelöscht werden können.
In der Übersicht der Notizen möchte ich ein Freitextfeld haben, um die Notizen Filtern zu können.
Ebenfalls soll es ein Drop-Down-Menü geben, um nach vorhandenen Tags flitern zu können.

### Aufgaben
Aufgaben:
- Titel
- Status (offen (default), in bearbeitung, erledigt)
- Priorität (niedrig, mittel (default), hoch)
- Fälligkeitsdatum
- Erinnerung (aktivieren/deaktivieren)
  - Datum und Uhrzeit der Erinnerung
- Tags (Die gleichen wie in den Notizen)
- Verknüpfung zu Notizen (Keine eigene Beschreibung)
- Verknüpfung zu Zeiterfassung
  - Zeiten zu Aufgabe als Liste aufführen (datum & erfasste Zeit)
  - Summe der Zeiten

### Gewohnheiten
Gewohnheit:
- Titel
- Beschreibung
- Intervall
  - Täglich
  - Mehrmals pro Tag
  - Wöchentlich
  - Mehrmals pro Woche
- Wertetyp
  - Erledigt / nicht erledigt
  - Ganzzahliger Wert
  - Dezimalwert

Tagesaktuelle Werte sollen erfasst werden können.
Werte der vergangen Tage sollen auch nachgetragen werden können.
Es soll einen Graphen geben, in dem die Werte der letzten 30 Tage dargestellt werden.

### Journal
Das Journal soll als eine Art "Tagebuch" dienen. Hier soll der Benutzer Tages Notizen erfassen können.
Es soll einen Kalender geben, der Anzeigt, ob für "privagt" oder/und "beruflich" schon Einträge vorhanden sind.
Zusätzlich soll es ein Eingabefeld geben, in dem man Texte mit Markdownformatierung erfassen kann und auch Links zu anderen Modulen einfügen kann, so wie Bilder.
Falls eine Vorlage in den Einstellungen hinterlegt ist, soll diese per Button eingefügt werden können.
Zusätzliche soll es einen Tracker geben:
- Titel
- Trackertyp:
  - Ja/Nein
  - Bewertung 0 bis 5 Sterne
  - Beschreibung (optional)
Ein Mustertracker als Vorlage (Titel: Stimmung, Trackertyp: Bewertung 0-5, Beschreibung: "Wie war der Tag?)
Ein Graph, in dem die Tracker visualisiert werden über die letzten 30 Tage.

### Zeiterfassung
Ich möchte einen Kalender haben, in dem ich sehen kann, für welche Tage schon Stunden erfasst wurden.
Eine Übersicht soll die Überstunden und Resturlaubstage anzeigen.
Die Überstunden sollen auch manuell gesetzt werden können, zur Initialisierung und Korrektur.
Wenn in der Zeiterfassung ein Tag als Urlaub gebucht wird, soll dieser von der Resturlaubstagen abgezogen werden.
Urlaub, Stunden abbummeln und Krankheit sollen im Kalender anders gekennzeichnet werden, als Tage mit Zeiterfassung.

Es soll folgende Button geben:
- Einstempeln
- Ausstempeln
- Task wechseln
- Zeiten nachtragen
Bei "Einstempeln" und "Ausstempeln" sollen die Zeiten gerundet werden, damit sie zu den Einstellungen passen:
- bei virtelstunden-Intervallen -> volle Stunde, virtel nach, halb, virtel vor
- Entsprechend bei 5-Minuten und 10-Minuten Intervallen

Zu den Zeiten sollen ebenfalls verlinkungen zu den Aufgaben möglich sein.
Jeder Eintrag soll ebenfalls eine Notiz enthalten können.
Tagesnotizen sollen auch möglich sein.

### Haushaltsbuch
Hier benötige ich einige Unterseiten
- Finanzübersicht
  - Kapitalsumme
  - Anstehende Daueraufträge
  - Geplante Buchungen
  - Budgets (SOLL/IST Abgleich)
  - Vorraussichtliches Kapital am Monatsende
- Buchungen
  - Übersicht der Buchungen
  - Filter
    - Datum
    - Kategorie
    - Empfänger
    - Freitextfeld
- Konten
  - Übersicht der Konten
  - Gruppiert nach Kontotyp (In den Einstellungen, kann der User die Typen bearbeiten)
    - Bargeld
    - Bankkonto
    - Depot
    - Anlagewert
    - Krypto
  - Summe des jeweiligen Kontos
  - Summe der Konten pro Gruppe
  - Einstellen, ob ein Konto in der Finanzübersicht berücksichtig werden soll oder nicht
- Budgets
  - Liste der Budgets
  - Budgets pro Konto oder über alle Konten
- Daueraufträge
  - Empfäger
  - Tag der Buchung
  - Zu belastendes Konto
  - Einnahmen/Ausgaben/Umbuchungen
- Kategorien
  - Gruppiert nach Einnahmen & Ausgaben
  - Baumansicht der Kategorien inkl Unterkategorien

Eine Buchung soll enthalten:
- Buchungstyp -> Einnahme/Ausgabe
- Konto (Default Konto kann vom User gesetzt werden)
- Kategorie -> Abhängig vom Buchungstyp
- Unterkategorie -> Abhängig von Kategorie
- Betrag
- Währung (Kann der User in den Einstellungen vorgeben als Default -> EUR)
- Buchungsdatum (Zukünftige Buchungen werden noch nicht im System gebucht)
  - Geplante Buchung -> True/False
- Beschreibung
- Als Vorlage speichern
- Als Dauerauftrag speichern -> Intervall für Dauerauftrag (default Monatlich)

### Einstellungen
In den Einstellungen möchte ich unterschiedliche Cards haben
- Spenden
  - BTC: 12QBn6eba71FtAUM4HFmSGgTY9iTPfRKLx
  - https://www.buymeacoffee.com/snuppedelua
- Sprache
  - Englisch (default)
  - Deutsch
  - Französisch
  - Spanisch
  - Schwedisch
  - Norwegisch
- Darstellung -> Auswahl des Themes
- Modulauswahl und Sortierung
  - Module aktivieren und deaktivieren
  - Navigationsleiste entsprechend der Reihenfolge sortieren
- Journal
  - Privat: Vorlage und aktivieren/deaktivieren
  - Beruflich: Vorlage und aktivieren/deaktivieren
  - Pinschutz aktivieren und Pin setzen
    - Biometrie unter Android
- Zeiterfassung
  - Rundungsintervall festlegen (minutengenau, 5-Minuten, 10-Minuten, 15-Minuten)
  - Sollstunden vorgabe (ohne, Tages Sollstunden, Wochen Sollstunden)
- Backend
  - URL eingeben für eigenes Backend (https://app.personal-tracker.life -> Vorgabe)
  - Registrieren
  - Anmelden
