#! /bin/sh
read -p "Enter user: " user
read -p "Enter server ip: " ip
echo "---------------------------------------"
echo "ok.. please wait a few minute!"
echo "---------------------------------------"
sleep 3
apt update
apt install squid
apt install nano
apt install apache2
cd /etc/squid
rm /etc/squid/squid.conf
bash -c "cat <<EOF > /etc/squid/squid.conf


acl localnet src 0.0.0.1-0.255.255.255	# RFC 1122 "this" network (LAN)
acl localnet src 10.0.0.0/8		# RFC 1918 local private network (LAN)
acl localnet src 100.64.0.0/10		# RFC 6598 shared address space (CGN)
acl localnet src 169.254.0.0/16 	# RFC 3927 link-local (directly plugged) machines
acl localnet src 172.16.0.0/12		# RFC 1918 local private network (LAN)
acl localnet src 192.168.0.0/16		# RFC 1918 local private network (LAN)
acl localnet src fc00::/7       	# RFC 4193 local private network range
acl localnet src fe80::/10      	# RFC 4291 link-local (directly plugged) machines

acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl CONNECT method CONNECT

http_access deny !Safe_ports


http_access deny CONNECT !SSL_ports


http_access allow localhost manager
http_access deny manager

include /etc/squid/conf.d/*

visible_hostname $ip

auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid/passwords
auth_param basic realm proxy Authentication Required
acl authenticated proxy_auth REQUIRED

acl auth_users proxy_auth $user
http_access allow auth_users


http_access allow localhost

http_access deny all

http_port 3128

refresh_pattern .		0	20%	4320

EOF"
htpasswd -c /etc/squid/passwords $user
cat /etc/squid/passwords
systemctl restart squid.service
ufw allow 3128
echo "****************************************"
echo "ip: $ip  user: $user port: 3128"
echo "****************************************"
echo "made by Telegram: @ALI_T0R"
