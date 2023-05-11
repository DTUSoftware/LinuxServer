FROM ubuntu/squid
ENV TZ=UTC

WORKDIR /etc/squid
COPY . .

VOLUME /var/log/squid

EXPOSE 3128
