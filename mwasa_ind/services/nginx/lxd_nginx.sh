lxc launch ubuntu:18.04 nginx
lxc network attach nginx macvlan eth0
lxc stop nginx
lxc start nginx
lxc exec nginx -- apt-get update
lxc exec nginx -- apt-get install nginx -y
lxc file push -r ./www/nuclear-codes nginx/var/www/nuclear-codes
lxc file push -r ./nginx/sites-enables nginx/etc/nginx/sites-enables
lxc exec nginx -- service nginx restart
