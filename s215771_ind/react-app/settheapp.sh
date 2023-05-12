# install docker
sudo apt install docker.io
# adds the user to the docker group to avoid having to use sudo
# might need to relog the user after this
sudo usermod -aG docker maizi
# Build the docker container
docker build -t countryapp .
# lists docker images
docker images
# Runs the docker container and binds the ports, and the -d option to detach the container
docker run -d -p 3000:3000 countryapp
# looks at current docker processes
docker ps
# stops the docker container
docker stop container-idd