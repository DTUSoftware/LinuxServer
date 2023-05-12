docker build --tag "coredns" .
docker rm coredns
docker run -d --name coredns -p 53:53/udp --restart always -conf /coredns/Corefile "coredns"
