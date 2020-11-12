#!/bin/bash

export IFS=$'\n'

cat <<EOF
################################################################################

Welcome to the desktopcontainers/base-debian

################################################################################

EOF

INITALIZED="/.initialized"

if [ ! -f "$INITALIZED" ]; then
  echo ">> CONTAINER: starting initialisation"

  cp /container/config/openbox/menu.xml /etc/xdg/openbox/menu.xml

  [ -z ${SERVER_NAME+x} ] && SERVER_NAME="localhost"

  if [ ! -f "/certs/$SERVER_NAME.key" ] && [ ! -f "/certs/$SERVER_NAME.crt" ]; then
    echo ">> CONTAINER: generating server tls certs (/certs/$SERVER_NAME.[key|crt])"
    openssl req -x509 -newkey rsa:4096 \
      -days 3650 \
      -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=$SERVER_NAME" \
      -keyout "/certs/$SERVER_NAME.key" \
      -out "/certs/$SERVER_NAME.crt" \
      -nodes -sha256
  fi

  echo ">> CONTAINER: openssh sshd config"
  [ ! -f "/certs/ssh_host_rsa_key" ] && ssh-keygen -f /certs/ssh_host_rsa_key -N '' -t rsa -b 4096
  cp /certs/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key

  cp /container/config/ssh/sshd_config /etc/ssh/sshd_config
  
  if [ "$ENABLE_SUDO" = "enable" ];
  then
    echo ">> CONTAINER: enable sudo for user app"
    echo 'app ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/app
  else
    echo ">> CONTAINER: remove sudo from container"
    apk del sudo >/dev/null 2>/dev/null
  fi

  [ "$ENABLE_KIOSK" = "enable" ] && echo ">> CONTAINER: enable Kiosk-Mode" && echo -e '#!/bin/sh\nexport DISPLAY=:0\nexec /usr/local/bin/app' > /container/config/runit/openbox/run

  # INIT PHASE

  touch "$INITALIZED"
else
  echo ">> CONTAINER: already initialized - direct start of samba"
fi

# update app
cp /container/scripts/app /usr/local/bin/app

# PRE-RUN PHASE

##
# CMD
##
echo ">> CMD: exec docker CMD"
echo "$@"
exec "$@"
