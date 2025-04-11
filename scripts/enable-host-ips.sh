#! /bin/sh

set -e
set -x

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

iptables -I INPUT -j NFQUEUE
iptables -I OUTPUT -j NFQUEUE
