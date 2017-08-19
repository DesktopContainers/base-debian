FROM debian:stretch

MAINTAINER MarvAmBass (https://github.com/DesktopContainers)

ENV LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive

RUN apt-get -q -y update \
 && apt-get -q -y install runit \
                          rsyslog \
                          wget \
                          python \
                          python-numpy \
                          \
                          openssh-server \
                          tigervnc-standalone-server \
                          \
                          mate-desktop-environment \
                          tmux \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list \
 \
 && echo ">> rsyslog" \
 && head -n $(grep -n RULES /etc/rsyslog.conf | cut -d':' -f1) /etc/rsyslog.conf > /etc/rsyslog.conf.new \
 && mv /etc/rsyslog.conf.new /etc/rsyslog.conf \
 && echo '*.*        /dev/stdout' >> /etc/rsyslog.conf \
 && sed -i '/.*imklog*/d' /etc/rsyslog.conf \
 \
 && echo ">> NoVNC" \
 && wget https://github.com/novnc/noVNC/archive/v0.6.2.tar.gz -O /novnc.tar.gz \
 && tar xvf /novnc.tar.gz \
 && mv /noVNC* /opt/novnc \
 && cp /opt/novnc/vnc_auto.html /opt/novnc/index.html \
 \
 && echo ">> Websockify" \
 && wget https://github.com/novnc/websockify/archive/v0.8.0.tar.gz -O /websockify.tar.gz \
 && tar xvf /websockify.tar.gz \
 && mv /websockify-* /opt/websockify \
 \
 && echo ">> SSHD" \
 && mkdir -p /var/run/sshd \
 && echo "X11UseLocalhost no" >> /etc/ssh/sshd_config \
 && sed -i 's,^.*PermitEmptyPasswords .*,PermitEmptyPasswords yes,' /etc/ssh/sshd_config \
 && sed -i '1iauth sufficient pam_permit.so' /etc/pam.d/sshd

COPY scripts /usr/local/bin

RUN useradd -ms /usr/local/bin/app-sh.sh app \
 && su -l -s /bin/sh -c "mkdir -p ~/.config/autostart ~/Desktop" app

VOLUME ["/config"]

EXPOSE 5901 80 443 22

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
