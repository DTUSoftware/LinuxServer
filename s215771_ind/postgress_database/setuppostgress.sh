# up with the container
docker-compose up -d
# install sw to connect to database
sudo apt install postgresql-client-common
sudo apt-get install postgresql-client
# 
psql -h localhost -U mememe -d testdatabase
