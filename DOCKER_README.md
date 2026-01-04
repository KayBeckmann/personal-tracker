# Docker Deployment Guide - Personal Tracker

Dieses Dokument beschreibt, wie Personal Tracker mit Docker deployed wird.

## Voraussetzungen

- Docker (≥ 20.10)
- Docker Compose (≥ 2.0)

**Installation prüfen:**
```bash
docker --version
docker-compose --version
```

## Schnellstart

### 1. Umgebungsvariablen konfigurieren

Kopiere die Beispiel-Konfiguration:
```bash
cp .env.example .env
```

Passe `.env` bei Bedarf an (Standard-Port ist 80).

### 2. Build & Deploy

**Option A - Mit Skripten (empfohlen):**
```bash
# Build
./scripts/build.sh

# Deploy
./scripts/deploy.sh
```

**Option B - Manuell:**
```bash
# Build
docker-compose build

# Start
docker-compose up -d
```

### 3. Zugriff

Die Anwendung ist verfügbar unter:
```
http://localhost:80
```

(oder dem Port, der in `.env` als `WEB_PORT` definiert ist)

## Verwaltung

### Container-Status anzeigen
```bash
docker-compose ps
```

### Logs anzeigen
```bash
# Alle Logs
docker-compose logs

# Logs folgen (live)
docker-compose logs -f web

# Letzte 100 Zeilen
docker-compose logs --tail=100 web
```

### Container stoppen
```bash
docker-compose down
```

### Container neu starten
```bash
docker-compose restart web
```

### Container und Volumes entfernen
```bash
docker-compose down -v
```

## Architektur

### Multi-Stage Build

Das Dockerfile verwendet einen mehrstufigen Build-Prozess:

1. **Build-Stage**:
   - Verwendet `flutter:stable` Image
   - Führt `flutter pub get` aus
   - Generiert L10n und DI-Code
   - Baut Flutter Web im Release-Modus

2. **Production-Stage**:
   - Verwendet schlankes `nginx:alpine` Image
   - Kopiert nur die gebauten Dateien
   - Konfiguriert Nginx für SPA-Routing
   - Implementiert Health-Check

### Nginx-Konfiguration

Die Nginx-Konfiguration (`app/nginx.conf`) bietet:

- **SPA-Routing**: Alle Routes werden auf `index.html` gemappt
- **Caching**: Optimierte Cache-Header für Assets
- **Security**: Security-Header (X-Frame-Options, etc.)
- **Gzip**: Kompression für bessere Performance
- **Health-Check**: `/health` Endpoint für Monitoring

## Umgebungsvariablen

### Aktuell verfügbar

| Variable | Beschreibung | Standard |
|----------|--------------|----------|
| `WEB_PORT` | Port für Web-Frontend | `80` |

### Zukünftig (Backend)

Weitere Variablen werden hinzugefügt, wenn Backend implementiert wird:
- `API_PORT` - Backend API Port
- `API_URL` - Backend API URL
- `DB_HOST` - Datenbank Host
- etc.

## Troubleshooting

### Port bereits belegt

**Fehler:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:80: bind: address already in use
```

**Lösung:**
Ändere `WEB_PORT` in `.env` zu einem freien Port (z.B. 8080):
```bash
WEB_PORT=8080
```

### Build schlägt fehl

**Lösung 1 - Clean Build:**
```bash
docker-compose build --no-cache
```

**Lösung 2 - Prüfe Docker-Speicher:**
```bash
docker system df
docker system prune -a
```

### Container startet nicht

**Logs prüfen:**
```bash
docker-compose logs web
```

**Health-Check prüfen:**
```bash
docker inspect personal-tracker-web | grep -A 10 Health
```

## Production Deployment

### Empfohlene Konfiguration

Für Production solltest du:

1. **Reverse Proxy** verwenden (z.B. Traefik, Caddy)
2. **HTTPS** konfigurieren
3. **Monitoring** einrichten (Prometheus, Grafana)
4. **Backups** konfigurieren (wenn Backend mit DB)
5. **Logging** zu zentralem Service senden

### Beispiel mit Traefik

```yaml
# docker-compose.prod.yml
services:
  web:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.personal-tracker.rule=Host(`tracker.example.com`)"
      - "traefik.http.routers.personal-tracker.entrypoints=websecure"
      - "traefik.http.routers.personal-tracker.tls.certresolver=letsencrypt"
```

## Entwicklung

### Lokaler Build testen

```bash
# Web-Build ohne Docker
cd app
flutter build web --release

# Lokal servieren
python3 -m http.server --directory build/web 8080
```

### Docker-Image-Größe prüfen

```bash
docker images | grep personal-tracker
```

## Weitere Ressourcen

- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Nginx Configuration](https://nginx.org/en/docs/)
