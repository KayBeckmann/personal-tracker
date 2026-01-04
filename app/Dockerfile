# Multi-stage Dockerfile für Flutter Web
# Stage 1: Build der Flutter Web App
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Arbeitsverzeichnis setzen
WORKDIR /app

# Dependencies kopieren und installieren
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Gesamten Source-Code kopieren
COPY . .

# L10n generieren
RUN flutter gen-l10n

# Code generieren (DI, Drift)
RUN dart run build_runner build --delete-conflicting-outputs

# Flutter Web Build erstellen (Release-Modus)
RUN flutter build web --release

# Stage 2: Nginx Server für statische Dateien
FROM nginx:alpine

# Flutter Web Build von Build-Stage kopieren
COPY --from=build /app/build/web /usr/share/nginx/html

# Nginx-Konfiguration kopieren
COPY nginx.conf /etc/nginx/nginx.conf

# Health-Check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Port exponieren
EXPOSE 80

# Nginx starten
CMD ["nginx", "-g", "daemon off;"]
