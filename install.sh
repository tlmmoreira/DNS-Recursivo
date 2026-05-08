#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/dns-recursivo-unbound"

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root: sudo bash install.sh"
  exit 1
fi

echo "==> Instalando dependencias..."
apt update
apt install -y ca-certificates curl wget dnsutils

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Instalando Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERRO: Docker Compose plugin nao encontrado. Atualize o Docker ou instale docker-compose-plugin."
  exit 1
fi

echo "==> Criando diretorio $APP_DIR"
mkdir -p "$APP_DIR/unbound"
cp docker-compose.yml "$APP_DIR/docker-compose.yml"
cp unbound/unbound.conf "$APP_DIR/unbound/unbound.conf"

# Baixa root hints oficial
wget -q https://www.internic.net/domain/named.root -O "$APP_DIR/unbound/root.hints"

# Evita conflito com systemd-resolved usando porta 53 local
if systemctl is-active --quiet systemd-resolved; then
  echo "==> Desativando systemd-resolved para liberar porta 53..."
  systemctl disable --now systemd-resolved || true
  rm -f /etc/resolv.conf
  echo "nameserver 127.0.0.1" > /etc/resolv.conf
fi

# Para bind9/unbound nativo caso estejam ocupando porta 53
systemctl stop bind9 2>/dev/null || true
systemctl stop unbound 2>/dev/null || true

echo "==> Subindo container Unbound..."
cd "$APP_DIR"
docker compose pull
docker compose up -d

sleep 5

echo "==> Testando DNS..."
dig google.com @127.0.0.1 +short || true
dig . NS @127.0.0.1 +short || true

echo ""
echo "Instalacao concluida."
echo "Arquivos em: $APP_DIR"
echo "Editar redes permitidas: nano $APP_DIR/unbound/unbound.conf"
echo "Reiniciar: cd $APP_DIR && docker compose restart"
echo "Logs: docker logs -f dns-recursivo-unbound"
