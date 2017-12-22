#!/bin/bash
# A script made for configuring a STUN/TURN server, a kurento media server and an asterisk server on Ubuntu 16.04

if [[ -z $1 ]]; then
    echo "Usage: ./install.sh address
    
Where address is the public ip address or dns name of the server"
    exit 1
fi

echo "This may take a while, you can go get a coffee but be sure to be around when ssl keys are generated..."

## Let's do this
sudo apt update

## STUN/TURN Server
sudo apt install -y coturn
turnserver -avn -u user:password -r $1 &

## KURENTO media server
echo "deb http://ubuntu.kurento.org xenial kms6" | sudo tee /etc/apt/sources.list.d/kurento.list
wget -O - http://ubuntu.kurento.org/kurento.gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y kurento-media-server-6.0

## ASTERISK MEDIA SERVER
curl -o asterisk.tar.gz http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-15-current.tar.gz
sudo apt install -y wget gcc g++ ncurses-dev libxml2-dev libsqlite3-dev libsrtp-dev uuid-dev libssl-dev libjansson-dev build-essential
tar zxfv asterisk.tar.gz
cd asterisk*
./configure
make
sudo make install
sudo make samples
sudo make config

## Generating keys
mkdir /home/ubuntu/nssl/
./contrib/scripts/ast_tls_cert -C $1 -O "My Super App" -d /home/ubuntu/nssl

## Configuring asterisk
cd ..
sudo cp conf-asterisk/* /etc/asterisk/
sudo sed -i "s/xx.xx.xx.xx/$1/g" /etc/asterisk/rtp.conf
sudo sed -i "s/xx.xx.xx.xx/$1/g" /etc/asterisk/sip.conf

## Configuring Kurento
sudo cp conf-kurento/kurento.conf.json /etc/kurento/
sudo cp conf-kurento/WebRtcEndpoint.conf.ini /etc/kurento/modules/kurento/
sudo sed -i "s/xx.xx.xx.xx/$1/g" /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini

## Starting services
sudo systemctl start kurento-media-server-6.0
sudo systemctl start asterisk