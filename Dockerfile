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
