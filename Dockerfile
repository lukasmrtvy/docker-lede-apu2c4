FROM ubuntu:17.10

ENV VERSION 17.01.4
ENV FORCE_UNSAFE_CONFIGURE 1

ENV TERM=xterm

RUN apt-get update && apt-get install -y subversion g++ zlib1g-dev build-essential git python rsync man-db libncurses5-dev gawk gettext unzip file libssl-dev wget curl

RUN mkdir -p /data/lede | curl -sSL https://github.com/lede-project/source/archive/v${VERSION}.tar.gz | tar xz -C /data/lede --strip-components=1

WORKDIR /data/lede

RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

COPY .config ./
COPY .kconfig ./
#COPY ucode.patch ./target/linux/x86/patches-4.4/
COPY kconfig.sh ./

RUN chmod +x kconfig.sh && ./kconfig.sh

RUN make defconfig
#RUN make download


RUN echo "10.0.0.4 ftp.gnupg.org " >> /etc/hosts && make download

#RUN make -j $(getconf _NPROCESSORS_ONLN)
RUN make -j1 V=s 
