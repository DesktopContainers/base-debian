FROM debian:jessie

ENV MATE_PACKAGE mate-desktop-environment

ENV LANG C.UTF-8

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q -y update && \
    apt-get -q -y install $MATE_PACKAGE \
                          tightvncserver \
                          openssh-server \
                          git && \
    apt-get -q -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    \
    git clone https://github.com/kanaka/websockify.git /opt/websockify && \
    rm -rf /opt/websockify/.git

ADD app-sh.sh /bin/app-sh.sh
RUN useradd -ms /bin/app-sh.sh app && \
    su - app -s /bin/sh -c "mkdir -p ~/.config/autostart"
ADD autostart_ssh-app.desktop /home/app/.config/autostart/autostart_ssh-app.desktop

ADD ssh-app.sh /bin/ssh-app.sh

EXPOSE 5901 80 22

ADD entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["tail", "-F", "/home/app/.vnc/*.log", "/var/log/*.log"]
