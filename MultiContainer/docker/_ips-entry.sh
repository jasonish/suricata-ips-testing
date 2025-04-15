#! /bin/sh

set -e
set -x

sudo iptables -P FORWARD DROP
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -I FORWARD -j NFQUEUE

exec /bin/bash
