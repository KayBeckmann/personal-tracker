#!/bin/bash

# Deploy-Skript für Personal Tracker
# Startet die Docker-Container

set -e

echo "🚀 Deploying Personal Tracker..."

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo "${YELLOW}⚠️  No .env file found. Copying from .env.example${NC}"
    cp .env.example .env
    echo "Please edit .env with your configuration and run this script again."
    exit 1
fi

# Stoppe alte Container
echo "🛑 Stopping old containers..."
docker-compose down

# Starte neue Container
echo "🐳 Starting containers..."
docker-compose up -d

# Warte auf Health-Check
echo "⏳ Waiting for health check..."
sleep 5

# Zeige Status
docker-compose ps

echo ""
echo "${GREEN}✅ Deployment completed!${NC}"
echo ""
echo "${BLUE}📱 Application is running at:${NC}"
echo "   http://localhost:${WEB_PORT:-80}"
echo ""
echo "To view logs, run:"
echo "   docker-compose logs -f web"
echo ""
echo "To stop the application, run:"
echo "   docker-compose down"
