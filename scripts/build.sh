#!/bin/bash

# Build-Skript für Personal Tracker
# Baut das Docker-Image für das Web-Frontend

set -e

echo "🏗️  Building Personal Tracker Web Frontend..."

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Prüfe ob Docker läuft
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Lade Umgebungsvariablen
if [ -f .env ]; then
    echo "📋 Loading environment variables from .env"
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "${YELLOW}⚠️  No .env file found. Using defaults.${NC}"
fi

# Build das Docker-Image
echo "🐳 Building Docker image..."
docker-compose build web

echo "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo "To start the application, run:"
echo "  ./scripts/deploy.sh"
