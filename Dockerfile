FROM debian:7
MAINTAINER zhangyi <408012721@qq.com>

# replace sources
COPY sources.list /etc/apt/sources.list

# change timezone
RUN echo "Asia/Shanghai" > /etc/timezone && \
                dpkg-reconfigure -f noninteractive tzdata

# install package and configuration
RUN apt-get update && apt-get install -y --no-install-recommends xterm supervisor x11vnc xvfb \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get install -y software-properties-common curl \
 && apt-add-repository -y ppa:webupd8team/java \
 && echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections \
 && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections \
 && oracle-java8-set-default \
 && apt-get install -y --no-install-recommends lxde

ENV ECLIPSE eclipse-jee-luna-SR2-linux-gtk-x86_64.tar.gz
RUN curl -O http://ftp.yzu.edu.tw/eclipse/technology/epp/downloads/release/luna/SR2/"$ECLIPSE" \
 && tar -vxzf $ECLIPSE -C /usr/local/
COPY org.eclipse.ui.ide.prefs /usr/local/eclipse/configuration/.settings/org.eclipse.ui.ide.prefs

RUN rm /etc/X11/app-defaults/XTerm && rm /etc/xdg/lxsession/LXDE/autostart && rm $ECLIPSE \
 && mkdir /root/Desktop/ \
 && ln -s /usr/local/eclipse/eclipse /root/Desktop/eclipse
COPY XTerm /etc/X11/app-defaults/XTerm
COPY autostart /etc/xdg/lxsession/LXDE/autostart
COPY desktop-items-0.conf /root/.config/pcmanfm/LXDE/desktop-items-0.conf

RUN adduser --disabled-password --quiet --gecos '' eclipse \
 && chown -R root:eclipse /usr/local/eclipse \
 && chmod -R 775 /usr/local/eclipse

COPY noVNC /noVNC/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#USER eclipse
EXPOSE 6080
 
CMD ["/usr/bin/supervisord"]
