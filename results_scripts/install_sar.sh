wget https://github.com/sysstat/sysstat/archive/v12.1.1.tar.gz
tar -xvzf v12.1.1.tar.gz
cd sysstat-12.1.1
./configure
make
make install
sar -V
/usr/local/bin/sar -V
/usr/local/bin/sar 1 5
