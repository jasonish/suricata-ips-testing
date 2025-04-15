#! /bin/sh

set -e
set -x

if [ -e "env.sh" ]; then
    . ./env.sh
fi

IMAGE="${IMAGE:-fedora}"
TAG="private/ips"
USERNAME=$(whoami)

podman build --build-arg "USERNAME=${USERNAME}" -t "${TAG}" -f docker/Dockerfile.${IMAGE} .
