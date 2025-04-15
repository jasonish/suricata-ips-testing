#! /bin/sh

set -e

TAG="private/ips"
NAME="protected"

if ! podman image exists "${TAG}"; then
    echo "Image ${TAG} not found. Please build the image with ./build.sh."
    exit 1
fi

GATEWAY=$(podman inspect test-ips|jq -r '.[0].NetworkSettings.Networks."ips-internal".IPAddress')

case "${GATEWAY}" in
    ""|"null")
        echo "error: ips container must be started first"
        exit 1
        ;;
    *)
esac

if podman container exists "${NAME}"; then
    podman exec --interactive --tty "${NAME}" /bin/bash
else
    podman run \
           --name "${NAME}" \
           --hostname "${NAME}" \
           -v "${HOME}":"${HOME}" \
           -w "${HOME}" \
           --privileged \
           -e "GATEWAY=${GATEWAY}" \
           --rm \
           --interactive --tty \
           --network ips-internal \
           --userns keep-id \
           --cap-add net_raw \
           "${TAG}" /_protected-entry.sh
fi
