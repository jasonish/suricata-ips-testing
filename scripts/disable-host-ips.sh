#! /bin/sh

set -e
set -x

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

iptables -D INPUT -j NFQUEUE
iptables -D OUTPUT -j NFQUEUE
