#!/bin/bash

echo "[+] Verificando porta 53..."

# parar serviços comuns que usam DNS
systemctl stop systemd-resolved 2>/dev/null
systemctl disable systemd-resolved 2>/dev/null
systemctl mask systemd-resolved 2>/dev/null

systemctl stop bind9 2>/dev/null
systemctl disable bind9 2>/dev/null

systemctl stop dnsmasq 2>/dev/null
systemctl disable dnsmasq 2>/dev/null

# matar processos na porta 53
PID=$(lsof -t -i:53)
if [ ! -z "$PID" ]; then
  echo "[!] Matando processo na porta 53: $PID"
  kill -9 $PID
fi

# corrigir resolv.conf
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf

echo "[+] Subindo containers..."
docker compose down
docker compose up -d

echo "[+] Finalizado!"
