echo "Cleaning the caches on $(hostname)"
echo "Before ++"
free -h
sync
echo 3 > /proc/sys/vm/drop_caches
for i in `df -hT | awk '{print $1}' | grep xvd`;
do
	blockdev --flushbufs $i
done
echo "After ++"
free -h
