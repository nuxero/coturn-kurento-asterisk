# Coturn + Kurento + Asterisk

A small bash script for installing and configuring a STUN/TURN server, a Kurento media server and an Asterisk server on Ubuntu 16.04.

The final result features an standard STUN/TURN server, Kurento listening on 8111 and Asterisk with 4 extensions enabled: 2001 & 2002 for web-based user agents and 3000 & 3001 for legacy clients. Further configuration can be added on `confs` folder.

## Installation

Clone this repo on a server running Ubuntu 16.04 and run the script as follows, replacing `1.2.3.4` with your actual ip address or server domain name:

    chmod +x install.sh
    ./install.sh 1.2.3.4

## DISCLAIMER

Not intended for use in production. If you wish to do so you will want to secure the configuration properly.