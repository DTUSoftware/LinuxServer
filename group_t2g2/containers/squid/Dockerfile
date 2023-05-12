FROM debian
ENV TZ=UTC

RUN apt-get update
RUN apt-get install -y squid-openssl openssl

WORKDIR /etc/squid

RUN mkdir ssl_cert
RUN openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout ./squid.key -out ./squid.crt -subj "/C=US/ST=CA/L=San Francisco/O=My Org/OU=My Dept/CN=mydomain.com"

COPY . .

VOLUME [/var/log/squid /var/spool/squid]

EXPOSE 3128

ENTRYPOINT [ "/bin/sh", "entrypoint.sh" ]
CMD ["squid"]
