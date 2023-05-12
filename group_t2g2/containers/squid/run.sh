#useradd -r -s /sbin/nologin -u 1000 -g 1000 proxy
#groupadd -g 1000 proxy
#mkdir -p /var/log/squid
#chown -R proxy:proxy /var/log/squid
#chmod -R 755 /var/log/squid

docker build --tag "squid" .
docker stop squid
docker rm squid
docker run -d --name squid -p 3128:3128 -v /var/log/squid:/var/log/squid --restart always "squid"
