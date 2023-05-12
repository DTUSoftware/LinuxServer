#!/bin/sh

# Check if the cache directories have been created
#if [ ! -d /var/spool/squid/00 ]; then
#  # Run the squid -z command to create the cache directories
#  /usr/sbin/squid -z
#fi

# Run the squid -z command to create the cache directories
/usr/sbin/squid -z

# Create SSL certificate database
/usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB

# Create pid file
#touch /run/squid.pid

# Set ownership of directories and files
#chown -R proxy:proxy /var/log/squid
#chown -R proxy:proxy /var/spool/squid
#chown -R proxy:proxy /etc/squid
#chown -R proxy:proxy /run/squid.pid
#chown -R proxy:proxy /var/lib/ssl_db

# Start Squid
#exec gosu proxy:proxy "$@"
exec "$@"
