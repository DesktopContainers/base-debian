FROM debian:jessie

ENV MATE_PACKAGE mate-desktop-environment

ENV LANG C.UTF-8
ENV USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q -y update && \
    apt-get -q -y install $MATE_PACKAGE \
                          tightvncserver \
                          openssh-server \
                          git && \
    apt-get -q -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    \
    touch /root/.Xresources && \
    mkdir /root/.vnc && \
    echo "debian" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    \
    git clone https://github.com/kanaka/websockify.git /opt/websockify && \
    rm -rf /opt/websockify/.git && \
    \
    echo "#!/bin/bash" > /bin/ssh-app.sh && \
    chmod a+x /bin/ssh-app.sh && \
    mkdir /root/Desktop; \
    ln -s /bin/ssh-app.sh /root/Desktop/Start\ App.sh && \
    useradd -ms /bin/ssh-app.sh app

EXPOSE 5901 80 22

ADD entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["tail", "-F", "/root/.vnc/*.log"]
