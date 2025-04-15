#! /bin/sh

set -e
set -x

# Set the default route.
sudo ip route add default via ${GATEWAY} dev eth0

exec /bin/bash
