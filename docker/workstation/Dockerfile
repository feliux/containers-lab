FROM ubuntu:20.04

USER root

WORKDIR /tmp

COPY assets/ .

RUN ./install_packages_lxde.sh && \
    mv entrypoint.sh /opt && \
    mkdir /home/ubuntu/Desktop/ && \
    mv README.md /home/ubuntu/Desktop/ && \
    rm -rf /tmp/*

USER ubuntu

WORKDIR /home/ubuntu

ENTRYPOINT /opt/entrypoint.sh && /bin/bash
