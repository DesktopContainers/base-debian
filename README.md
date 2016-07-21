# Debian VNC/Websockify/SSH Desktopcontainers Base Image

A dockerfile that builds debian jessie with VNC, websockify and ssh Server.

This is build as base image for various desktop applications.

The applications will be available as VNC, Websockify VNC, SSH or Host X11.
You can change the behaviour via environment variables. So the User can decide how he wants to use the application.

Base image: _/debian:jessie
Because I want base system which runs nearly everywhere.

# Environment variables and defaults

* __DISABLE\_SSHD__
 * set this to any value e.g. true to disable SSHD -> Port 22 
  * _ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X root@$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' containername) [...]_
* __DISABLE\_VNC__
 * set this to any value e.g. true to disable VNC Server -> Port 5901
* __VNC\_PASSWORD__
 * default: _debian_ use custom password for VNC
* __VNC\_SCREEN\_RESOLUTION__
 * default: _1280x800_
* __DISABLE\_WEBSOCKIFY__
 * set this to any value e.g. true to disable Websockify Server -> Port 80

## Websockify SSL Environment variables and defaults

* __ENABLE\_SSL__
 * set this to any value e.g. true to enable to enable SSL Websockify Server
* __SSL\_ONLY__
 * set this to any value e.g. true to set SSL only for Websockify Server
* __SSL\_CERT__
 * default: _/opt/websockify/self.pem_ path to cert with included key
* __SSL\_SIZE__ 
 * default: _4086_ keysize
* __SSL\_DAYS__
 * default: _3650_ ssl cert lifetime in days
* __SSL\_SUBJECT__
 * default: _/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost_ ssl cert subject

# Usage

Run the container with this command:

    docker run -d --name debian-base-system -p 5901:5901 -p 80:80 desktopcontainers/base-debian

Connect to the container.  In the vnc connection string, type this:

"ipaddress:1"

The default password is "debian".
