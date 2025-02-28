#!/bin/bash

# Detectar el sistema operativo
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    PROMETHEUS_CONFIG="/etc/prometheus/prometheus.yml"
    PLAUSIBLE_CONFIG="/app/plausible/plausible-config.env"
    NTFY_CONFIG="/etc/ntfy/config.yml"
    CACHE_FILE="/var/cache/ntfy/cache.db"
    AUTH_FILE="/etc/ntfy/auth.db"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
    PROMETHEUS_CONFIG="C:/SystemS/comunity-ini/prometheus/prometheus.yml"
    PLAUSIBLE_CONFIG="C:/SystemS/comunity-ini/plausible/plausible-config.env"
    NTFY_CONFIG="C:/SystemS/comunity-ini/ntfy/config.yml"
    CACHE_FILE="C:/SystemS/comunity-ini/ntfy/cache.db"
    AUTH_FILE="C:/SystemS/comunity-ini/ntfy/auth.db"
else
    echo "Sistema operativo no soportado"
    exit 1
fi

echo "Detectado sistema operativo: $OS"

# Función para instalar dependencias en Linux
install_dependencies_linux() {
    echo "Instalando dependencias en Linux..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y docker.io docker-compose git curl wget
    sudo systemctl enable docker && sudo systemctl start docker
}

# Función para instalar dependencias en Windows (requiere Chocolatey)
install_dependencies_windows() {
    echo "Instalando dependencias en Windows..."
    
    # Instalar Chocolatey si no está instalado
    if ! choco -v &> /dev/null; then
        echo "Instalando Chocolatey..."
        powershell -NoProfile -ExecutionPolicy Bypass -Command \
        "Set-ExecutionPolicy Bypass -Scope Process -Force; \
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    fi

    # Instalar Docker, Git y dependencias
    choco install -y docker-desktop git curl wget
}

# Instalar dependencias según el sistema
if [ "$OS" == "linux" ]; then
    install_dependencies_linux
elif [ "$OS" == "windows" ]; then
    install_dependencies_windows
fi

# Clonar repositorios de software si no existen
#if [ ! -d "C:/SystemS/comunity-ini/prometheus" ] && [ "$OS" == "windows" ]; then
#    git clone https://github.com/prometheus/prometheus.git C:/SystemS/comunity-ini/prometheus
#fi

#if [ ! -d "/etc/prometheus" ] && [ "$OS" == "linux" ]; then
#    git clone https://github.com/prometheus/prometheus.git /etc/prometheus
#fi

# Crear archivo prometheus.yml si no existe
if [ ! -f "$PROMETHEUS_CONFIG" ]; then
    cat <<EOL > "$PROMETHEUS_CONFIG"
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOL
    echo "Archivo prometheus.yml creado en $PROMETHEUS_CONFIG"
fi

# Crear archivo plausible-config.env si no existe
if [ ! -f "$PLAUSIBLE_CONFIG" ]; then
    SECRET_KEY=$(openssl rand -hex 32)
    cat <<EOL > "$PLAUSIBLE_CONFIG"
BASE_URL=http://localhost:8000
SECRET_KEY_BASE=$SECRET_KEY
DATABASE_URL=postgres://plausible_user:password@db:5432/plausible_db
EOL
    echo "Archivo plausible-config.env creado en $PLAUSIBLE_CONFIG"
fi

# Crear archivo ntfy.yml si no existe
if [ ! -f "$NTFY_CONFIG" ]; then
    cat <<EOL > "$NTFY_CONFIG"
base-url: http://localhost:2580
cache-file: $CACHE_FILE
auth-file: $AUTH_FILE
EOL
    echo "Archivo ntfy.yml creado en $NTFY_CONFIG"
fi

echo "✅ Instalación y configuración completadas."
