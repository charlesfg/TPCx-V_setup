echo "Setting up stress-ng"
apt-get install -y wget
wget http://launchpadlibrarian.net/198405172/stress-ng_0.03.15-1~ubuntu14.04.1_amd64.deb
dpkg -i stress-ng_0.03.15-1~ubuntu14.04.1_amd64.deb 
echo "Performing a 10s test"
stress-ng -v --cpu 1 --cpu-load 50 --io 2 --vm 1 --vm-bytes 256m --timeout 10s
echo "done"
