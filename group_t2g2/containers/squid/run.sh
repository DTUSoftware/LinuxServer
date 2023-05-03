docker build --tag "squid" .
docker rm squid
docker run -d --name squid -p 3128:3128 --restart always "squid"
