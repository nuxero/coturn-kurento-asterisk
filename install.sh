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

## Configuring asterisk
sudo mv /etc/asterisk/rtp.conf /etc/asterisk/rtp.conf~
sudo mv /etc/asterisk/sip.conf /etc/asterisk/sip.conf~
sudo mv /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf~
sudo mv /etc/asterisk/http.conf /etc/asterisk/http.conf~
sudo cp confs/asterisk/* /etc/asterisk/
sudo sed -i "s/xx.xx.xx.xx/$1/q" /etc/asterisk/rtp.conf
sudo sed -i "s/xx.xx.xx.xx/$1/q" /etc/asterisk/sip.conf

## Configuring Kurento
sudo cp confs/kurento/kurento.conf.json
sudo cp confs/kurento/modules/WebRtcEndpoint.conf.ini
sudo sed -i "s/xx.xx.xx.xx/$1/q" /etc/kurento/modules/WebRtcEndpoint.conf.ini

## Generating keys
mkdir /home/ubuntu/nssl/
cd contrib/scripts
./ast_tls_cert -C $1 -O "My Super App" -d /home/ubuntu/nssl

## Starting services
sudo systemctl start kurento-media-server-6.0
sudo systemctl start asterisk