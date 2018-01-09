#!/bin/bash

cat <<EOF
Welcome to the desktopcontainers/base-debian container
EOF

# only on container boot
INITIALIZED="/.initialized"
if [ ! -f "$INITIALIZED" ]; then
	touch "$INITIALIZED"

  echo ">> adding desktop files"
cat <<EOF > /home/app/Desktop/mate-display-properties.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Name=Displays
Comment=Change resolution and position of monitors and projectors
Exec=mate-display-properties
Icon=mate-preferences-desktop-display
Terminal=false
Type=Application
StartupNotify=true
Categories=GTK;Settings;HardwareSettings;
Keywords=mate-control-center;MATE;resolution;position;monitors;display;properties;
OnlyShowIn=MATE;
EOF

if echo "$VNC_SCREEN_RESOLUTION" | grep 'x' 2>/dev/null >/dev/null; then
echo ">> set default resolution to: $VNC_SCREEN_RESOLUTION"
cat <<EOF > /home/app/.config/autostart/autostart_custom_resolution.desktop
[Desktop Entry]
Type=Application
Icon=application-x-executable
Name=Custom Resolution
GenericName=Custom Resolution 
Exec=/bin/bash -c "xrandr --output VNC-0 --mode $VNC_SCREEN_RESOLUTION"
EOF
fi

cat <<EOF > /home/app/.config/autostart/autostart_custom_settings.desktop
[Desktop Entry]
Type=Application
Icon=application-x-executable
Name=Custom Settings
GenericName=Custom Settings
Exec=gconf-settings.sh
EOF

cat <<EOF > /home/app/.config/autostart/autostart_ssh-app.desktop
[Desktop Entry]
Type=Application
Icon=application-x-executable
Name=Start Application
GenericName=Start Application
Exec=ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -X app@localhost
EOF
  cp /home/app/.config/autostart/autostart_ssh-app.desktop /home/app/Desktop/Start\ App.desktop

	chown app:app /home/app/.config/autostart/*.desktop /home/app/Desktop/*.desktop


	if [ ! -z ${DISABLE_SSHD+x} ]; then
		echo ">> disabled sshd - fixing autostart"
		su -l -s /bin/sh -c "sed -i 's,ssh.*,/usr/local/bin/ssh-app.sh,g' ~/Desktop/Start\ App.desktop ~/.config/autostart/autostart_ssh-app.desktop" app
	fi

	echo ">> import proxy settings if set"
	if [ ! -z ${HTTP_PROXY+x} ]; then
		echo "HTTP_PROXY=$HTTP_PROXY" >> /etc/environment
		echo "http_proxy=$HTTP_PROXY" >> /etc/environment
	fi
	if [ ! -z ${HTTPS_PROXY+x} ]; then
		echo "HTTPS_PROXY=$HTTPS_PROXY" >> /etc/environment
		echo "https_proxy=$HTTPS_PROXY" >> /etc/environment
	fi
	if [ ! -z ${FTP_PROXY+x} ]; then
		echo "FTP_PROXY=$FTP_PROXY" >> /etc/environment
		echo "ftp_proxy=$FTP_PROXY" >> /etc/environment
	fi
	if [ ! -z ${NO_PROXY+x} ]; then
		echo "NO_PROXY=$NO_PROXY" >> /etc/environment
		echo "no_proxy=$NO_PROXY" >> /etc/environment
	fi
	if [ ! -z ${APT_PROXY+x} ]; then
		echo "Acquire::http::Proxy \"$APT_PROXY\";" >> /etc/apt/apt.conf.d/99custom_proxy
	fi

  if [ ! -f "/config/ssl-cert.crt" ] || [ ! -f "/config/ssl-cert.key" ]; then
		echo ">> generating self signed cert"
		mkdir -p /config
		openssl req -x509 \
			-newkey "rsa:4086" \
			-days 3650 \
			-subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=127.0.0.1" \
			-out "/config/ssl-cert.crt" \
			-keyout "/config/ssl-cert.key" \
			-nodes \
			-sha256
	fi

	if [ "enable" = "$ENABLE_SUDO" ]; then
    echo ">> SUDO enable user 'app' to use sudo without password"
		echo "app ALL = NOPASSWD: ALL" >> /etc/sudoers
  fi

	###
  # RUNIT
  ###

  echo ">> RUNIT - create services"
  mkdir -p /etc/sv/rsyslog /etc/sv/sshd /etc/sv/tigervnc /etc/sv/websockify /etc/sv/websockify-ssl
  echo -e '#!/bin/sh\nexec /usr/sbin/rsyslogd -n' > /etc/sv/rsyslog/run
    echo -e '#!/bin/sh\nrm /var/run/rsyslogd.pid' > /etc/sv/rsyslog/finish
	echo -e "#!/bin/sh\nexec /usr/sbin/sshd -D" > /etc/sv/sshd/run
	echo -e "#!/bin/sh\nexec /bin/su -s /bin/sh -c \"vncserver :1 -SecurityTypes none -depth 24 -fg --I-KNOW-THIS-IS-INSECURE\" app" > /etc/sv/tigervnc/run
  echo -e "#!/bin/sh\nexec /opt/websockify/run 443 --web /opt/novnc/ --ssl-only --cert /config/ssl-cert.crt --key /config/ssl-cert.key localhost:5901" > /etc/sv/websockify-ssl/run
  echo -e "#!/bin/sh\nexec /opt/websockify/run 80 --web /opt/novnc/ localhost:5901" > /etc/sv/websockify/run
  chmod a+x /etc/sv/*/run /etc/sv/*/finish

  echo ">> RUNIT - enable services"
	echo "  >> enabling rsyslog"
  ln -s /etc/sv/rsyslog /etc/service/rsyslog

	if [ -z ${DISABLE_SSHD+x} ]; then
		echo "  >> enabling sshd"
	  ln -s /etc/sv/sshd /etc/service/sshd
  fi

	if [ -z ${DISABLE_VNC+x} ]; then
		echo "  >> enabling tigervnc"
		sed -i 's/^1;/$localhost = "no";\n1;/g' /etc/vnc.conf
	  ln -s /etc/sv/tigervnc /etc/service/tigervnc
		if [ -z ${DISABLE_WEBSOCKIFY+x} ]; then
			echo "  >> enabling websockify"
			ln -s /etc/sv/websockify /etc/service/websockify
			ln -s /etc/sv/websockify-ssl /etc/service/websockify-ssl
	  fi
	fi
fi

echo ">> starting services"
exec runsvdir -P /etc/service
