for i in tpc-g1b1 tpc-g1b2 tpc-g2b1 tpc-g2b2 tpc-g3b1 tpc-g3b2 tpc-g4b1 tpc-g4b2 
do
    echo "Setup db on $i"
    scp restore_db.sh ${i}:~
    ssh $i bash restore_db.sh
done

