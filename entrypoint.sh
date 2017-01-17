#!/bin/bash

cat <<EOF
Welcome to the desktopcontainers/base-debian container
EOF

# only on container boot
INITIALIZED="/.initialized"
if [ ! -f "$INITIALIZED" ]; then
	touch "$INITIALIZED"

	if [ -z ${DISABLE_SSHD+x} ]; then
		echo ">> preparations for SSHD"
		mkdir /var/run/sshd
		sed -i 's,^ *PermitEmptyPasswords .*,PermitEmptyPasswords yes,' /etc/ssh/sshd_config
		sed -i '1iauth sufficient pam_permit.so' /etc/pam.d/sshd
	fi

	if [ -z ${VNC_PASSWORD+x} ]; then
		VNC_PASSWORD="debian"
	fi

	if [ -z ${DISABLE_VNC+x} ]; then
		echo ">> setting new VNC password"
		su -l -s /bin/sh -c "touch ~/.Xresources; mkdir ~/.vnc; echo \"$VNC_PASSWORD\" | vncpasswd -f > ~/.vnc/passwd; chmod 600 ~/.vnc/passwd " app
		chown app:app /home/app/.config/autostart/autostart_ssh-app.desktop
		su -l -s /bin/sh -c "mkdir ~/Desktop; cp ~/.config/autostart/autostart_ssh-app.desktop ~/Desktop/Start\ App.desktop" app

		if [ ! -z ${DISABLE_SSHD+x} ]; then
			echo ">> disabled sshd - fixing autostart"
			su -l -s /bin/sh -c "sed -i 's,ssh.*,/bin/ssh-app.sh,g' ~/Desktop/Start\ App.desktop ~/.config/autostart/autostart_ssh-app.desktop" app
		fi
	fi

	unset VNC_PASSWORD

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

	if [ -z ${DISABLE_VNC+x} ] && [ -z ${DISABLE_WEBSOCKIFY+x} ] && [ ! -z ${ENABLE_SSL+x} ]; then
		echo ">> enabling SSL"

		if [ ! -z ${SSL_ONLY+x} ]; then
			echo ">> enable SSL only"
			SSL_ONLY="--ssl-only"
		fi

		if [ -z ${SSL_SUBJECT+x} ]; then
			SSL_SUBJECT="/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost";
		fi

		if [ -z ${SSL_DAYS+x} ]; then
			SSL_DAYS="3650";
		fi

		if [ -z ${SSL_SIZE+x} ]; then
			SSL_SIZE="4086";
		fi

		if [ -z ${SSL_CERT+x} ]; then
			SSL_CERT="/opt/websockify/self.pem";
		fi

		if [ ! -f "$SSL_CERT" ]; then
			echo ">> generating self signed cert"
			echo ">> >>    DAYS: $SSL_DAYS"
			echo ">> >>    SIZE: $SSL_SIZE"
			echo ">> >> SUBJECT: $SSL_SUBJECT"
			echo ">> >>    CERT: $SSL_CERT"
			openssl req -x509 \
				-newkey "rsa:$SSL_SIZE" \
				-days "$SSL_DAYS" \
				-subj "$SSL_SUBJECT" \
				-out "$SSL_CERT" \
				-keyout "$SSL_CERT" \
				-nodes \
				-sha256
		fi
	fi
fi

if [ -z ${DISABLE_SSHD+x} ]; then
	echo ">> starting sshd on port 22"
	/usr/sbin/sshd
fi

if [ -z ${DISABLE_VNC+x} ]; then
	if [ -z ${VNC_SCREEN_RESOLUTION+x} ]; then
		export VNC_SCREEN_RESOLUTION="1280x800"
	fi

	echo ">> staring vncserver ($VNC_SCREEN_RESOLUTION) :1 on port 5901"
	su -s /bin/sh -c "vncserver :1 -geometry \"$VNC_SCREEN_RESOLUTION\" -depth 24" app

	sleep 2

	if [ -z ${DISABLE_WEBSOCKIFY+x} ]; then
		echo ">> starting websockify on port 80"
		/opt/websockify/run 80 $SSL_ONLY ${SSL_CERT:+--cert ${SSL_CERT}} localhost:5901 &
	fi
fi

# exec CMD
echo ">> run docker CMD as user 'app'"
echo "su -s /bin/sh -c \"$@\" app"
su -s /bin/sh -c "$@" app
echo "exit code: $?"
