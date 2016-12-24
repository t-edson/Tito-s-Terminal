usuario
ping 192.168.1.30
fisql -S SILICIO1 -U sa -P sysman41 -i a.sql -n 

fpc tisql.pas
./tisql

sudo find / -name libsybdb.so

sudo ln -s /home/usuario/freetds-dev.1.00.106/src/dblib/.libs/libsybdb.so /usr/lib/libsybdb.so

su root
sysman41
tsql -C
cd freetds-dev.1.00.106
whoami
./configure --prefix=/usr/local
make
make install
cd ..
fpc prueba.pas
./prueba

