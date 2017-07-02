FROM debian:jessie

MAINTAINER MarvAmBass (https://github.com/DesktopContainers)

ENV LANG C.UTF-8

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q -y update && \
    apt-get -q -y install python \
                          tightvncserver \
                          openssh-server \
                          git && \
    apt-get -q -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list; \
    \
    echo "X11UseLocalhost no" >> /etc/ssh/sshd_config; \
    \
    git clone https://github.com/kanaka/websockify.git /opt/websockify && \
    rm -rf /opt/websockify/.git; \
    \
    touch /var/log/null && \
    chmod 444 /var/log/null

ADD app-sh.sh /bin/app-sh.sh
RUN useradd -ms /bin/app-sh.sh app

ADD ssh-app.sh /bin/ssh-app.sh

EXPOSE 5901 80 22

ADD entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash", "-c", "tail -F /var/log/null /home/app/.vnc/*.log"]
