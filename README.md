# docker-bitcoindc
A Simple GUI (x11-based) Docker Container for Bitcoin Development

Install Docker

Install either of the two editions: Community Edition (CE) and Enterprise Edition (EE) by following Install Docker and Post-installation steps for Linux.

Create Dockerfile and Build Docker Image

Dockerfile

# Base Image from which you are building FROM <image>[:<tag>]
FROM ubuntu:16.04

# Debian frontend
ENV DEBIAN_FRONTEND noninteractive

# Arguments
ARG user="bitcoindc"
ARG uid=1000
ARG gid=1000
ARG home="/home/bitcoindc"
ARG bitcoindb="/bitcoindb"

# Set ENV for x11 display 
ENV DISPLAY $DISPLAY
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM 1

# Install x11 apps like xclock to test (xclock &)
RUN apt-get update 
RUN apt-get -y install x11-apps

# Basic utilities
RUN apt-get update && apt-get install -y zsh screen tree sudo ssh
# Additional misc tools
RUN apt-get install -y zip unzip curl wget feh

# Basic development & others
RUN apt-get install -y git
RUN apt-get install -y build-essential autoconf libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler libqt4-dev libqrencode-dev libtool
RUN apt-get install -y libevent-dev pkg-config

# Install bitcoind from PPA
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y bitcoind

# EXPOSE rpc port for the node to allow outside container access
EXPOSE 8332 8333 18332 18333

# Make ssh available
EXPOSE 22

# Volume
VOLUME ${bitcoindb}

# Create user
RUN export uid=${uid} gid=${gid} && \
groupadd -g ${gid} ${user} && \
useradd -m -u ${uid} -g ${user} -s /bin/bash ${user} && \
passwd -d ${user} && \
usermod -aG sudo ${user}

# Copy bitcoin.conf and others if any to ${home}
ADD . ${home}

# Change ownership of home directory if needed
RUN chown -R ${uid}:${gid} ${home}

# Debian frontend
ENV DEBIAN_FRONTEND teletype

# Switch to user
USER ${user}
WORKDIR ${home}

# There can only be one CMD instruction in a Dockerfile
# CMD provides defaults for an executing container
# Drop user into bash shell by default
CMD ["/bin/bash"]

Build Docker Image

docker build -t bitcoindc:v0.0.1 .

Show Docker Image

docker images

Launch Docker Container with GUI (x11 based) Support

Launch Docker Container

docker run -it --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /etc/localtime:/etc/localtime:ro -v /mnt/hgfs/bitcoindb:/bitcoindb -p 8333:8333 bitcoindc:v0.0.1

Test GUI Support

xclock &

Install Bitcoin Core on Docker Container

Once the docker container is launched, we could either install the pre-packaged Bitcoin Core or build from the source of Bitcoin Core.

Source: aixminds.com (http://aixminds.org/2018/04/09/a-simple-docker-container-for-bitcoin-gui-apps/) and medium.com (https://medium.com/@gmhuili/a-simple-docker-container-for-bitcoin-gui-apps-d4f6f448f078)
