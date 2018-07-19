FROM ubuntu:18.04 as builder

ENV VERSION 18.06
ENV FORCE_UNSAFE_CONFIGURE 1

ENV TERM=xterm

RUN apt-get update && apt-get install -y subversion g++ zlib1g-dev build-essential git python rsync man-db libncurses5-dev gawk gettext unzip file libssl-dev wget curl time

RUN mkdir -p /data/lede && git clone https://github.com/lede-project/source.git /data/lede && cd /data/lede && git checkout openwrt-18.06

WORKDIR /data/lede

RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

COPY .config ./
COPY .kconfig ./
COPY kconfig.sh ./


RUN chmod +x kconfig.sh
RUN ./kconfig.sh

RUN make defconfig

RUN make download

RUN make -j $(getconf _NPROCESSORS_ONLN)  tools/install
RUN make -j $(getconf _NPROCESSORS_ONLN) toolchain/install

COPY 001-procd-change-noatime-to-relatime-for-unprivileged-lx.patch ./package/system/procd/patches/001-procd-change-noatime-to-relatime-for-unprivileged-lx.patch

RUN make -j1 V=s package/procd/compile || exit 0

RUN ls -lha ./package/system/procd/ || exit 0
RUN ls -lha ./package/system/procd/initd/ || exit 0

#RUN cat ./package/system/procd/initd/early.c
