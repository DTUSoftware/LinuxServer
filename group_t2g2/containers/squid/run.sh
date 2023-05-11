docker build --tag "squid" .
docker rm squid
docker run -d --name squid -p 3128:3128 -v squidlogs:/var/log/squid --restart always "squid"
