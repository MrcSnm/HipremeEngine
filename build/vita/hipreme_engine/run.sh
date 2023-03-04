export IP=192.168.0.180
export APP_ID=VSDK00007
export PORT=1337
export CMD_PORT=1338

# dub --compiler=ldc2 --arch=armv7a-unknown-unknown
#make 
# curl ftp://$IP:$PORT/ux0:/ -T ./vita_sample.vpk


make clean
make eboot.bin
echo screen on | nc $IP $CMD_PORT
curl ftp://$IP:$PORT/ux0:/app/$APP_ID/ -T ./eboot.bin
echo launch $APP_ID | nc $IP $CMD_PORT