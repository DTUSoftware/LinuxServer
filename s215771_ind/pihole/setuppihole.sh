# installs docker compose
sudo apt install docker-compose
# pulls the latest pihole image
docker pull pihole/pihole
# ups the docker compose
sudo docker-compose up -d