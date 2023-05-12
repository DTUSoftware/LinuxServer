#!/bin/sh

chown -R proxy:proxy /var/log/squid
chown -R proxy:proxy /var/spool/squid
exec runuser -u proxy "$@"
