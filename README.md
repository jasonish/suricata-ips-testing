# Suricata IPS Testing

This repo contains documentation and support scripts to aid in testing
Suricata IPS modes, with a particular attention on the
developer. Automated testing strategies are currently not in scope.

The methods are documented below:

- Host Based IPS with NFQ: Applies the IPS to your workstation, but
  that can make it hard for isolated testing.
- Distrobox: Convenient; allows for isolating testing; lacks
  visibility of traffic with tcpdump on both sides of the traffic.
- MultiContainer: Uses 2 containers, one as the IPS and one as the
  protected node. Gives you visibility on the network interfaces on
  both sides of Suricata. See [MultiContainer](./MultiContainer).

## Host Based IPS with NFQ

This is the simplest way to test Suricata IPS mode but it does have an
impact on your hosts network connectivity which could be intrusive
during development.

In short, the steps to enable host based IPS is to setup `iptables`
rules like so:

```
sudo iptables -I INPUT -j NFQUEUE
sudo iptables -I OUTPUT -j NFQUEUE
```

Now all traffic to and from your host will be blocked until you enable
Suricata in IPS mode:

```
suricata -q 0
```

Now Suricata will `verdict` all packets, applying drops as needed.

**Pros:** Simple to get started with; your own host environment.

**Cons:** Affects all the network traffic on your host; no ability to
run `tcpdump` on the traffic between your host and Suricata which can
be useful for debugging.

*Note:* `iptables` has an optional command, `--queue-bypass` that will
pass all packets if no application like Suricata is processing the
queue. This will keep host network connectivity while Suricata is not
running even with the `iptables` NFQUEUE rules in place.

This method of host based IPS is documented in the Suriata user
manual:
https://docs.suricata.io/en/latest/setting-up-ipsinline-for-linux.html

## Testing With Distrobox

[Distrobox](https://github.com/89luca89/distrobox) is a wrapper around
Podman or Docker that lets you run a variety of Linux distributions in
your terminal, while keeping access to your home directory. Optionally
it can run that distribution in an isolated network where you can run
Suricata in NFQ IPS mode affecting only the traffic in and out of the
Distrobox "terminal".

The main benefit over the host NFQ IPS documented above is you can
isolate the affected traffic to that coming in and out of the distrbox
container, leaving your host network traffic untouched. In short its
like a virtual environment without the overhead or hassles of a
virtual machine.

**Pros:** Testing in an isolated environment with only the traffic you
generate and not all background traffic your workstation normally has;
can still run apps like Firefox which can be hard in normal
containers.

**Cons:** You still can't sniff the traffic between the test
applications and Suricata.

Even with the cons, this can still be a very useful testing
environment for quick behavior tests.

### Create the Distrobox Container

This usually only needs to be done once. After initial creation you
can repeatedly `enter` the distrobox environment.

For an Ubuntu Distrobox:

```
distrobox create --root --unshare-netns \
    --absolutely-disable-root-password-i-am-really-positively-sure \
    --name nfqueue-ips --image ubuntu:24.04
```

Or if you prefer Fedora:

```
distrobox create --root --unshare-netns \
    --absolutely-disable-root-password-i-am-really-positively-sure \
    --name nfqueue-ips --image fedora:41
```

Basically any Linux distribution base image can be used, choose the
one that closest matches your host development environment for
familiarity reasons.

### Initial Setup of the Container

To enter the Distrobox environment run:

```
distrobox enter --root nfqueue-ips
```

You will notice that you appear to be in the same directory as you
were before entering. This is because Distrobox attempts to keep your
home directory and most of your environment, just in an isolated Linux
distribution.

You will not want to setup your development tools. This includes your
build tools. You don't need to install editors as such, you can just
use your normal editor as you have access to all the files in your
home directory.

Alternatively you could install a pre-packaged binary of Suricata that
you don't have to build, but as this guide is aimed to help
developers, its useful to have all your build tools. available.

### Testing Inside the Container

To test with a Distrobox container its best to open two terminals that
are using the container.

- Open 2 terminals.
- In each terminal, run: `distrobox enter --root nfqueue-ips`

One terminal can be your Suricata workspace, where you build and run
Suricata. The other terminal is where you can run tools like `curl`,
or even launch graphical applications like a browser to test streaming
videos, etc.

On first entering the container, it should have full network
access. Test with commands like:

- `curl http://testmyids.org`
- `ping 1.1.1.1`

Then you can setup a host based NFQ IPS, just be sure to do while
entered into Distrobox, otherwise you'll be setting up a host NFQ IPS
on your host system.

For example, first setup NFQ:

```
sudo iptables -I INPUT -j NFQUEUE
sudo iptables -I OUTPUT -j NFQUEUE
```

Commands like `curl` and `ping` above should now timeout or fail.

Not start Suricata:

```
sudo suricata -q 0
```

Once all the rules are loaded, etc the `ping` and `curl` commands
should now succeed. Verify by looking at your Suricata logs.

The main benefit with this setup is that you are testing in an
isolated environment which show mostly only see the network traffic
you create as part of testing, and not all the other traffic your host
environment creates, which makes it much easier to reason about.

