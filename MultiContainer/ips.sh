#! /bin/sh

set -e

TAG="private/ips"
NAME="test-ips"

if ! podman image exists "${TAG}"; then
    echo "Image ${TAG} not found. Please build the image with ./build.sh."
    exit 1
fi

if ! podman network exists ips-public; then
    podman network create ips-public
fi

if ! podman network exists ips-internal; then
    podman network create --internal ips-internal
fi

if podman container exists test-ips; then
    podman exec --interactive --tty "${NAME}" /bin/bash
else
    podman run \
           --name "${NAME}" \
           --hostname ips \
           -v "${HOME}":"${HOME}" \
           -w "${HOME}" \
           --privileged \
           --rm \
           --interactive --tty \
           --detach-keys= \
           --network ips-public \
           --network ips-internal \
           --userns keep-id \
           --cap-add net_raw \
           ${TAG} /_ips-entry.sh
fi
