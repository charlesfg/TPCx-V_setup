#IPERF_DIR=/home/charles/Downloads/iperf-master/src
IPERF_DIR=/var/tpcv/iperf-master/src

#ensure that are not running
pgrep iperf
if [ $? -eq 0 ]; then
  echo "iperf is running."
  pkill -f iperf
else
  echo "iperf is not running."
fi

cd ${IPERF_DIR}
./iperf3 -s -D
