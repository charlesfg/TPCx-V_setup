
declare -A SB  # Create an associative array

SB[tpc-g1b1]=3072
SB[tpc-g1b2]=1024
SB[tpc-g2b1]=8192
SB[tpc-g2b2]=2048
SB[tpc-g3b1]=12288
SB[tpc-g3b2]=3072
SB[tpc-g4b1]=15360
SB[tpc-g4b2]=3072


declare -A CP_S  # Create an associative array


CP_S[tpc-g1b1]=130
CP_S[tpc-g1b2]=66
CP_S[tpc-g2b1]=200
CP_S[tpc-g2b2]=700
CP_S[tpc-g3b1]=400
CP_S[tpc-g3b2]=740
CP_S[tpc-g4b1]=500
CP_S[tpc-g4b2]=1130


for i in tpc-g1b1 tpc-g1b2 tpc-g2b1 tpc-g2b2 tpc-g3b1 tpc-g3b2 tpc-g4b1 tpc-g4b2;
do 

ssh postgres@${i} <<EOF
sed -i 's/^shared_buffers.*/shared_buffers = ${SB[$i]}MB/g' /dbstore/tpcv-data/postgresql.conf

sed -i 's/^#checkpoint_seg.*/checkpoint_segments = ${SB[$i]}/g' /dbstore/tpcv-data/postgresql.conf

EOF

ssh ${i} "systemctl restart postgresql-9.3.service"

done


