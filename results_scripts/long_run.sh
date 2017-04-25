# Script to run outsite the tpc-drive
for j in `seq 1 5`; do
    for i in `ls /opt/VDriver/run_configs/vcfg*`;
    do 
    	cp -v $i /opt/VDriver/jar/vcfg.properties
    	bash -x run_and_report.sh
    	sleep 300
    done 
done
