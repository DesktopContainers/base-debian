FROM debian:buster

ENV PATH="/container/scripts:${PATH}"

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -q -y update \
 && apt-get -q -y install --no-install-recommends runit \
                       \
                       xvfb \
                       x11vnc \
                       \
 && apt-get -q -y install openbox \
                       ttf-dejavu \
                       \
                       haproxy \
                       openssl \
                       openssh-server \
                       sudo \
                       \
                       python3 \
                       python3-numpy \
                       sed \
                       wget \
                       rsyslog \
 \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 \
 && ln -s /usr/bin/python3 /usr/bin/python \
 \
 && head -n $(grep -n RULES /etc/rsyslog.conf | cut -d':' -f1) /etc/rsyslog.conf > /etc/rsyslog.conf.new \
 && mv /etc/rsyslog.conf.new /etc/rsyslog.conf \
 && echo '*.*        /dev/stdout' >> /etc/rsyslog.conf \
 && sed -i '/.*imklog*/d' /etc/rsyslog.conf \
 \
 && mkdir -p /run/sshd \
 \
 && adduser --disabled-password -q --gecos '' app \
 && passwd -d app \
 \
 && wget -O novnc.tar.gz https://github.com/novnc/noVNC/archive/v1.2.0.tar.gz \
 && tar xvf novnc.tar.gz \
 && ln -s noVNC-* novnc \
 \
 && ln -s /novnc/vnc_lite.html /novnc/index.html \
 \
 && wget -O websockify.tar.gz https://github.com/novnc/websockify/archive/v0.9.0.tar.gz \
 && tar xvf websockify.tar.gz \
 && ln -s websockify-* websockify \
 \
 && chown app -R /websockify* \
 && chown app -R /no*

VOLUME ["/certs"]

EXPOSE 22 80 443 5900

COPY . /container/

HEALTHCHECK CMD ["docker-healthcheck.sh"]
ENTRYPOINT ["entrypoint.sh"]

CMD [ "runsvdir","-P", "/container/config/runit" ]
