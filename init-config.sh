#!/usr/bin/env bash

# init-config.sh
# Propósito: preparar configuraciones base y dependencias para el stack local
# (Prometheus, Plausible y ntfy), detectando Linux/Windows y generando archivos
# mínimos funcionales si no existen.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detectar el sistema operativo
if [[ "${OSTYPE:-}" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "${OSTYPE:-}" == "msys"* || "${OSTYPE:-}" == "cygwin"* ]]; then
    OS="windows"
else
    echo "Sistema operativo no soportado: ${OSTYPE:-desconocido}"
    exit 1
fi

PROMETHEUS_CONFIG="$SCRIPT_DIR/prometheus/prometheus.yml"
PLAUSIBLE_CONFIG="$SCRIPT_DIR/plausible/plausible-config.env"
NTFY_CONFIG="$SCRIPT_DIR/ntfy/config.yml"
CACHE_FILE="$SCRIPT_DIR/ntfy/cache.db"
AUTH_FILE="$SCRIPT_DIR/ntfy/auth.db"

echo "Detectado sistema operativo: $OS"

install_dependencies_linux() {
    echo "Instalando dependencias en Linux..."
    sudo apt update
    sudo apt install -y docker.io docker-compose-plugin git curl wget openssl
    sudo systemctl enable docker
    sudo systemctl start docker
}

install_dependencies_windows() {
    echo "Instalando dependencias en Windows..."
    if ! command -v choco >/dev/null 2>&1; then
        echo "Chocolatey no está instalado. Instálalo manualmente para continuar."
        return 1
    fi
    choco install -y docker-desktop git curl wget openssl.light
}

# Instalar dependencias según el sistema (opcional)
if [[ "${1:-}" == "--install-deps" ]]; then
    if [[ "$OS" == "linux" ]]; then
        install_dependencies_linux
    else
        install_dependencies_windows
    fi
fi

mkdir -p "$(dirname "$PROMETHEUS_CONFIG")" "$(dirname "$PLAUSIBLE_CONFIG")" "$(dirname "$NTFY_CONFIG")"

if [[ ! -f "$PROMETHEUS_CONFIG" ]]; then
    cat <<EOL > "$PROMETHEUS_CONFIG"
# Prometheus scrape config para el stack docker local.
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']
EOL
    echo "Archivo prometheus.yml creado en $PROMETHEUS_CONFIG"
fi

if [[ ! -f "$PLAUSIBLE_CONFIG" ]]; then
    SECRET_KEY="$(openssl rand -hex 32)"
    cat <<EOL > "$PLAUSIBLE_CONFIG"
# Variables mínimas para Plausible en docker-compose.
BASE_URL=http://localhost:8000
SECRET_KEY_BASE=$SECRET_KEY
DATABASE_URL=postgres://plausible:plausible@plausible-db:5432/plausible
CLICKHOUSE_DATABASE_URL=http://plausible-events-db:8123/plausible_events_db
EOL
    echo "Archivo plausible-config.env creado en $PLAUSIBLE_CONFIG"
fi

if [[ ! -f "$NTFY_CONFIG" ]]; then
    cat <<EOL > "$NTFY_CONFIG"
# Config base de ntfy para entorno local.
base-url: http://localhost:2580
cache-file: $CACHE_FILE
auth-file: $AUTH_FILE
EOL
    echo "Archivo ntfy/config.yml creado en $NTFY_CONFIG"
fi

echo "✅ Configuración inicial completada."
