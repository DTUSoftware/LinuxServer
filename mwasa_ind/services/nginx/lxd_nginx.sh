lxc launch ubuntu:18.04 nginx
lxc network attach nginx macvlan eth0
lxc stop nginx
lxc start nginx
lxc exec nginx -- apt-get update
lxc exec nginx -- apt-get install nginx -y
lxc file push -r ./www/nuclear-codes nginx/var/www
lxc file push -r ./nginx/sites-enabled nginx/etc/nginx
lxc exec nginx -- mv /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default 
lxc exec nginx -- service nginx restart
