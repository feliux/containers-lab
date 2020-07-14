FROM ubuntu:18.04

RUN apt update && \
    apt install -y \
    software-properties-common \
    git \
    curl \
    p7zip-full \
    wget \
    whois \
    locales \
    python3 \
    python3-pip \
    upx \
    psmisc && \
    add-apt-repository -y ppa:longsleep/golang-backports && \
    apt update && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

WORKDIR /opt

ENV LANG en_US.utf8

ARG DEBIAN_FRONTEND=noninteractive

RUN apt install -y tinyproxy && sed -i -e '/^Allow /s/^/#/' -e '/^ConnectPort /s/^/#/' -e '/^#DisableViaHeader /s/^#//' /etc/tinyproxy/tinyproxy.conf && \
    apt install -y iptables && git clone https://github.com/Und3rf10w/kali-anonsurf.git && cd kali-anonsurf && ./installer.sh && \
    rm -rf /var/lib/apt/lists/*

CMD anonsurf start; tinyproxy -d
