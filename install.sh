apt update
apt -y install sudo

apt -y install dnsutils
unbound_install()
{
  apt -y install unbound
  cp /etc/unbound/unbound.conf /etc/unbound/unbound.conf.bkp
  rm /etc/unbound/root.key -f
  sudo unbound-anchor -a /etc/unbound/root.key -v
  wget -P /etc/unbound/ https://www.internic.net/domain/named.root

 chown unbound.unbound /etc/unbound/ -R
 apt -y install resolvconf
}
edit_config(){
sed -e 's/include/#include/g' -i /etc/unbound/unbound.conf

echo -e 'server:\n' \
'directory: "/etc/unbound"\n' \
'username: unbound\n' \
'interface: 0.0.0.0\n' \
'access-control: 127.0.0.0/8 allow\n' \
'access-control: 192.168.0.0/16 allow\n' \
'access-control: 172.16.0.0/12 allow\n' \
'access-control: 172.30.0.0/12 allow\n' \
'access-control: 10.0.0.0/8 allow\n' \
'access-control: 100.64.0.0/10 allow\n' \
'port: 53\n' \
'do-udp: yes\n' \
'do-tcp: yes\n' \
'do-ip4: yes\n' \
'do-ip6: no\n' \
'#DNSSEC\n' \
'auto-trust-anchor-file: "/etc/unbound/root.key"' >> /etc/unbound/unbound.conf

}

unbound_main()
{
  unbound_install
  edit_config

  systemctl enable resolvconf
  systemctl start resolvconf

  systemctl enable unbound
  systemctl start unbound

}

unbound_main
