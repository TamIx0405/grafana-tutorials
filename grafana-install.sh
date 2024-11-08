#Install grafana on EC2:

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y software-properties-common wget
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana -y
sudo apt-get update
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# open port 3000 and open the ip:3000


