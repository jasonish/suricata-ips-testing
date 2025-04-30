#! /bin/sh

set -e
set -x

# Set the default route.
sudo ip route add default via ${GATEWAY} dev eth0

# Overwrite the DNS server with one that works.
echo "nameserver ${PUBLIC_GATEWAY}" | sudo tee /etc/resolv.conf > /dev/null

exec /bin/bash
