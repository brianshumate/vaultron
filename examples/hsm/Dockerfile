# Docker SoftHSM/PKCS#11-Proxy Setup
# Based on the original work of Roland Shoemaker
# https://github.com/rolandshoemaker/docker-hsm/blob/master/Dockerfile

FROM ubuntu:16.04
MAINTAINER Brian Shumate <brian@brianshumate.com>

RUN apt-get update \
    && apt-get install -y softhsm git-core build-essential cmake libssl-dev libseccomp-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/SUNET/pkcs11-proxy \
    && cd pkcs11-proxy \
    && cmake . \
    && make \
    && make install

RUN echo "0:/var/lib/softhsm/slot0.db" > /etc/softhsm/softhsm.conf \
    && softhsm \
       --init-token \
       --slot 0 \
       --label key \
       --pin 1234 \
       --so-pin 0000

EXPOSE 5657

ENV PKCS11_DAEMON_SOCKET="tcp://0.0.0.0:5657"

CMD [ "/usr/local/bin/pkcs11-daemon", "/usr/lib/softhsm/libsofthsm.so" ]

