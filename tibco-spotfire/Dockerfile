FROM centos

# Spotfire version
ENV VERSION 11.2.0

USER root
WORKDIR /spotfire
COPY assets .
RUN ./spotfire_setup.sh

# May need to expose 5702 and 5703 for clustering
# Default client port is 80
# Default backend registration port is 9080
# Default backend communication port is 9443
EXPOSE 80
EXPOSE 9443
EXPOSE 9080
EXPOSE 5701

ENTRYPOINT ./fixservername.sh && /bin/bash
