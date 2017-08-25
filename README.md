# Debian VNC/Websockify/SSH Desktopcontainers Base Image

A dockerfile that builds debian stretch with VNC, websockify and ssh Server.

This is build as base image for various desktop applications.

The applications will be available as VNC, Websockify VNC, Web (noVNC), SSH or Host X11.
You can change the behaviour via environment variables. So the User can decide how he wants to use the application.

Base image: _/debian:stretch_
Because I want a base system which runs nearly anything and everywhere.

# Environment variables and defaults

- __DISABLE\_SSHD__
    - set this to any value e.g. true to disable SSHD -> Port 22
    - _ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X root@$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' containername) [...]_
- __DISABLE\_VNC__
    - set this to any value e.g. true to disable VNC Server -> Port 5901
- __DISABLE\_WEBSOCKIFY__
    - set this to any value e.g. true to disable Websockify Server -> Port http 80 or https 443
    - just open a webbrowser and connect to the container

- __ENABLE\_SUDO__
    - set this to _enable_ to allow the user to use sudo
    - default: not set

- __VNC\_SCREEN\_RESOLUTION__
    - set this to a specific resolution like '1280x1024' if you want a specific default one (can also be changed at runtime)
    - default: not set
    - possible values:
        - 640x480
        - 800x600
        - 1024x768
        - 1280x1024
        - 1280x720
        - 1280x800
        - 1280x960
        - 1360x768
        - 1400x1050
        - 1600x1200
        - 1680x1050
        - 1900x1200
        - 1920x1080
        - 1920x1200

## Websockify SSL

to use a custom ssl certificate just add them as files:

- /config/
    - ssl-cert.crt
    - ssl-cert.key

If you don't provide any certificate, a self signed cert will be created on container start.

## Proxy Environment variables and defaults

- __HTTP\_PROXY__
    - set this to a value like 'http://yourproxyaddress:proxyport' to enable proxy variables HTTP_PROXY and http_proxy
- __HTTPS\_PROXY__
    - set this to a value like 'http://yourproxyaddress:proxyport' to enable proxy variables HTTPS_PROXY and https_proxy
- __FTP\_PROXY__
    - set this to a value like 'http://yourproxyaddress:proxyport' to enable proxy variables FTP_PROXY and ftp_proxy
- __NO\_PROXY__
    - set this to a value like 'http://yourproxyaddress:proxyport' to enable proxy variables NO_PROXY and no_proxy
- __APT\_PROXY__
    - set this to a value like 'http://yourproxyaddress:proxyport' to enable proxy inside apt configuration


# Usage

Run the container with this command:

    docker run -d --name debian-base-system -p 5901:5901 -p 80:80 -p 443:443 desktopcontainers/base-debian

Connect to the container.  In the vnc connection string, type this:

"localhost:1"
