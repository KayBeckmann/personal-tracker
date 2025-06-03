# Meine Produktivitäts-App (My Productivity PWA)

Eine Progressive Web App (PWA) zur Steigerung der persönlichen Produktivität durch die Verwaltung von Aufgaben, Notizen, Gewohnheiten und täglichen Ereignissen. Erstellt mit Vue 3, Vite, Pinia und Dexie.js.

## ✨ Features

- **Dashboard:**
  - Anzeige der Anzahl offener Aufgaben mit hoher Priorität.
  - Anzeige der Aufgabe mit der kürzesten Fälligkeit.
  - (Optional: Schneller Überblick über heutige Gewohnheiten)
- **Aufgabenverwaltung (Tasks):**
  - Erstellen, Lesen, Aktualisieren, Löschen (CRUD) von Aufgaben.
  - Setzen von Prioritäten (niedrig, mittel, hoch).
  - Festlegen von Fälligkeitsdaten.
  - Markieren von Aufgaben als erledigt/offen.
- **Notizverwaltung (Notes):**
  - CRUD-Operationen für Textnotizen.
  - Titel und Inhalt für jede Notiz.
- **Gewohnheitstracker (Habit Tracker):**
  - CRUD-Operationen für Gewohnheiten.
  - Definition von Häufigkeiten (täglich, wöchentlich, etc.).
  - Verfolgung des Fortschritts (Streak-Zähler).
  - Protokollierung erledigter Gewohnheiten pro Tag.
- **Tagesereignisse (Daily Events):**
  - Erfassen und Verwalten von terminierten Ereignissen oder wichtigen Vorkommnissen des Tages.
  - CRUD-Operationen für Ereignisse mit Titel, Beschreibung, Typ und Zeitangaben.
- **Offline-Fähigkeit:** Dank PWA-Technologie und Dexie.js als lokaler Datenbank können die meisten Funktionen auch ohne Internetverbindung genutzt werden.
- **Installierbar:** Kann auf Desktop und mobilen Geräten als App "installiert" werden.

## 🛠️ Tech Stack

- **Framework:** [Vue 3](https://vuejs.org/)
- **Build-Tool:** [Vite](https://vitejs.dev/)
- **State Management:** [Pinia](https://pinia.vuejs.org/)
- **Lokale Datenbank:** [Dexie.js](https://dexie.org/) (Wrapper für IndexedDB)
- **Sprache:** TypeScript (oder JavaScript, je nach deiner Wahl beim Setup)
- **PWA:** `vite-plugin-pwa`
- **Routing:** [Vue Router](https://router.vuejs.org/) (optional, aber empfohlen für Multi-View-Apps)

## 🚀 Projekt Setup & Installation

1.  **Klone das Repository:**

    ```bash
    git clone https://github.com/KayBeckmann/personal-tracker.git
    cd DEIN_REPOSITORY_NAME
    ```

2.  **Installiere die Abhängigkeiten:**

    ```bash
    npm install
    # oder
    # yarn install
    # oder
    # pnpm install
    ```

3.  **Starte den Entwicklungsserver:**
    ```bash
    npm run dev
    ```
    Die Anwendung sollte nun unter `http://localhost:5173` (oder einem ähnlichen Port) erreichbar sein.

## 📜 Verfügbare Skripte

- `npm run dev`: Startet den Vite-Entwicklungsserver mit Hot Module Replacement (HMR).
- `npm run build`: Erstellt die Produktionsversion der App im `dist`-Verzeichnis.
- `npm run preview`: Startet einen lokalen Server, um die Produktionsversion aus dem `dist`-Verzeichnis zu testen.
- `npm run lint`: (Falls ESLint eingerichtet ist) Überprüft den Code auf Linting-Fehler.

## 📂 Projektstruktur (Kurzübersicht)

```
.
├── public/                  # Statische Assets & PWA Icons
├── src/
│   ├── assets/              # Lokale Assets (Bilder, Schriftarten)
│   ├── components/          # Wiederverwendbare Vue-Komponenten
│   │   ├── tasks/
│   │   ├── notes/
│   │   ├── habits/
│   │   └── ...
│   ├── views/               # Hauptansichten/Seiten der App (verbunden mit dem Router)
│   ├── services/
│   │   └── db.ts            # Dexie.js Datenbank-Schema und Initialisierung
│   ├── stores/              # Pinia Stores für State Management
│   │   ├── taskStore.ts
│   │   ├── noteStore.ts
│   │   └── ...
│   ├── router/              # Vue Router Konfiguration (index.ts)
│   ├── App.vue              # Haupt-Vue-Komponente
│   ├── main.ts              # Einstiegspunkt der Anwendung
│   └── style.css            # Globale Styles
├── .gitignore               # Dateien, die von Git ignoriert werden sollen
├── index.html               # Haupt-HTML-Datei
├── package.json             # Projekt-Metadaten und Abhängigkeiten
├── tsconfig.json            # TypeScript-Konfiguration
├── vite.config.ts           # Vite-Konfiguration (inkl. PWA-Plugin)
└── README.md                # Diese Datei

```

## 📱 PWA (Progressive Web App)

Diese Anwendung ist als PWA konzipiert. Das bedeutet:

- **Installierbar:** Auf unterstützten Browsern (Desktop und Mobil) wirst du aufgefordert, die App zu deinem Startbildschirm oder als Desktop-Anwendung hinzuzufügen.
- **Offline-fähig:** Dank des Service Workers und der lokalen Datenbank (Dexie.js) können Kernfunktionen auch ohne aktive Internetverbindung genutzt werden. Daten werden lokal gespeichert und können (optional) später synchronisiert werden.
- **Zuverlässig:** Lädt schnell und bietet eine App-ähnliche Erfahrung.

## 🔮 Mögliche zukünftige Erweiterungen

- [ ] Synchronisation mit einem Backend-Service.
- [ ] Benutzerdefinierte Themes/Farbschemata.
- [ ] Erinnerungen/Benachrichtigungen für fällige Aufgaben und Habits.
- [ ] Erweiterte Filter- und Sortieroptionen.
- [ ] Kalenderansicht für Events und Aufgaben.
- [ ] Drag & Drop Funktionalität für Aufgaben.

## 🤝 Beitrag (Contributing)

Beiträge sind willkommen! Wenn du Ideen für Verbesserungen hast oder Fehler findest, erstelle bitte ein Issue oder einen Pull Request.
_(Passe diesen Abschnitt an, falls es sich um ein rein privates Projekt handelt)_

## 📄 Lizenz

Dieses Projekt ist unter der [MIT-Lizenz](LICENSE) lizenziert.
_(Optional: Erstelle eine `LICENSE`-Datei mit dem MIT-Lizenztext, wenn du diese Lizenz verwenden möchtest.)_

# Kaffee

Über einen
[Kaffee](https://www.buymeacoffee.com/snuppedelua)
würde ich mich auf jeden Fall freuen.
