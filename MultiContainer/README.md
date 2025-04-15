# Multi Container Suricata IPS Test Setup

This IPS test configuration uses 2 containers which allows for traffic
to be monitored with tools like `tcpdump` on each side of Suricata.

The basic idea:

- Your host system, ultimately this is how traffic gets to the
  external network. Typically Docker or Podman take care of the
  routing to handle this, and we rely on that here.
  
- IPS container: This container has 2 network interfaces, `eth0` and
  `eth1`. The first interface, `eth0` uses standard container
  networking to connect to your host system which typically gives it
  full internet access behind NAT. The second network interface,
  `eth1`, is part of an internal network that has no direct access to
  the external network. As this is the IPS container its job is to
  move packets from this internal network giving access to containers
  that exist only on the internal network.
  https://askubuntu.com/questions/941816/permission-denied-when-running-docker-after-installing-it-as-a-snap
- Protected container: This container has one network interface on the
  internal network, and by default has no access to the external
  network. It relies on the **IPS container** to provide it internet
  access by using `NFQUEUE` and `MASQUERADE`.

## Running

NOTE: By default these containers use Fedora. To use Ubuntu, edit
`env.sh` as needed.

This directory contains Dockerfile's and helper script, so start by
checking out this repo if you haven't already.

To continue, you will need at least 2 terminals running. One will be
the IPS system, the other will be the *protected* system.

### Build the Containers

The scripts below will complain if the containers are not built. To build, run:

```
./build.sh
```

This may take a few minutes.

### Terminal 1 - The IPS

To start the IPS "machine":

```
./ips.sh
```

As this first needs to build a Docker image, it might take a few
minutes.

This container should have full network access.

### Terminal 2 - The Protected Machine

To start the protected "machine":

```
./protected.sh
```

This container will not have any network access by default. To get
network access, go back to "Terminal 1 - The IPS" and start Suricata
in nfqueue mode: `suricata -q0`. Note that you'll probably need to
build and/or install Suricata first.

Then you should be able to run `curl http://testmyids.com` and see the
response.

NOTE: For some reason `ping` won't work if your host system is a more
or less default Ubuntu system, however `curl` and other udp/tcp tools
continue to work.
