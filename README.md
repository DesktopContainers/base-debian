# Base Image for Desktop Applications on lightweight OpenBox Window Manager - (desktopcontainers/base-debian) [x86 + arm]

This container is created, to make it easy to use Desktop Applications on Systems that can run Docker Containers.
It is based on `_/debian` and comes with various way to use your X11 applications:

I recommend using the [desktopcontainers/base-alpine](https://github.com/DesktopContainers/base-alpine) if possible. Only if you really need debian as base image, use this container.

- VNC (port: `5900`, no password)
- HTTP VNC (port: `80`, no password)
- HTTPS VNC (port: `443`, no password)
- SSH X11 Forwarding (user: `app`, no password)
    * use it with `ssh -X -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no app@127.0.0.1 -p 2222 /container/scripts/app` (exported port `22` to `2222` on localhost)
    * use it with `ssh -X -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no app@<CONTAINER IP ADRESS> /container/scripts/app`

## Changelogs

* 2020-11-12
    * default `VNC_SCREEN_DEPTH` to `24`
* 2020-11-11
    * complete rework
* 2020-11-10
    * added kiosk mode
    * `VNC_SCREEN_DEPTH` support
* 2020-11-09
    * initial creation on debian

## Environment variables and defaults

### General

*  __SERVER\_NAME__
    * _optional_ dns name for certificate generation
    * _default:_ `localhost`

* __ENABLE\_SUDO__
    * set this to _enable_ to allow the user to use sudo
    * default: not set

* __ENABLE\_KIOSK__
    * set this to _enable_ to enable Kiosk mode
        * only run `app` and make sure it will always restart
        * it is advised to not combine with `ENABLE_SUDO` - but it's still possible to use with sudo enabled.
    * default: not set
    * perfect for (fullscreen) software like `rdesktop`, `vncviewer`, Browser etc.

### VNC Settings

* __VNC\_SCREEN\_DEPTH__
    * set the screen depth for the xfvb x-server
    * default: `24`
    * other possible values:
        * 8
        * 16
        * 24

* __VNC\_SCREEN\_RESOLUTION__
    * set this to a specific resolution like '1280x1024' if you want a specific default one
    * default: `1280x1024`
    * depth is configured with `VNC_SCREEN_DEPTH` env
    * other possible values:
        * 640x480
        * 800x600
        * 1024x768
        * 1280x1024
        * 1280x720
        * 1280x800
        * 1280x960
        * 1360x768
        * 1400x1050
        * 1600x1200
        * 1680x1050
        * 1900x1200
        * 1920x1080
        * 1920x1200

## Volumes

* __/certs/__
    * store your certs with the `$SERVER_NAME`.[key|crt] here.
    * store your ssh host key `ssh_host_rsa_key` & `ssh_host_rsa_key.pub` here.
    * if they are missing, they get created

## FAQ

* use X11 Forwarding on a new macOS
    * install XQuartz (https://www.xquartz.org/)
    * add `XAuthLocation /usr/X11/bin/xauth` to your `~/.ssh/config`

## API

If you wan't to use this container as base for your own containerized Desktop Applications, you can use the following informations to get it done.

It's best to configure everything in a Dockerfile and not at runtime.

### Your custom Application

add all your code used for starting your application/s to `/container/scripts/app`.

_Note:_ There are applications which get in trouble running in multiple instances.
Since your Application get's started on container start on the VNC X11 Server, it might collide with the one
which is started via SSH. If your application can only run once, make sure the `app` script kills all other instances before starting a new instance.

### Init Points

Add commands to init phase of of entrypoint (only on first run/creation).

```
sed -i 's/# INIT PHASE/# INIT PHASE\nYOUR_COMMANDS_HERE/g' /container/scripts/entrypoint.sh
```

Add commands to run phase of of entrypoint (on every run).

```
sed -i 's/# PRE-RUN PHASE/# PRE-RUN PHASE\nYOUR_COMMANDS_HERE/g' /container/scripts/entrypoint.sh
```

### Openbox Menu

Rename Menu Entry

```
sed -i 's/Application/NEW_ENTRY_NAME/g' /etc/xdg/openbox/menu.xml
```

Add Menu Entry

```
sed -i '0,/<item/ s,,<item label="NEW_ENTRY_NAME"><action name="Execute"><execute>NEW_ENTRY_COMMAND</execute></action></item>\n<item,' /etc/xdg/openbox/menu.xml
```
