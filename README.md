# DNS Recursivo com Unbound via Docker

Instala um servidor DNS recursivo usando Unbound com consulta direta aos root hints.

## Instalação rápida

```bash
unzip unbound-recursivo-docker.zip
cd unbound-recursivo-docker
sudo bash install.sh
```

## Testes

```bash
dig google.com @127.0.0.1
dig . NS @127.0.0.1
```

## Arquivos instalados

Depois da instalação, os arquivos ficam em:

```bash
/opt/dns-recursivo-unbound
```

## Liberar seus blocos de clientes

Edite:

```bash
nano /opt/dns-recursivo-unbound/unbound/unbound.conf
```

Adicione seus blocos:

```conf
access-control: SEU.BLOCO.IPV4/XX allow
access-control: SEU:BLOCO:IPV6::/XX allow
```

Reinicie:

```bash
cd /opt/dns-recursivo-unbound
docker compose restart
```

## Comandos úteis

```bash
docker logs -f dns-recursivo-unbound
cd /opt/dns-recursivo-unbound && docker compose ps
cd /opt/dns-recursivo-unbound && docker compose down
cd /opt/dns-recursivo-unbound && docker compose up -d
```
