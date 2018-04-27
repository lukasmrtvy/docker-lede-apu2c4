FROM ubuntu:17.10 as builder

ENV VERSION 17.01.4
ENV FORCE_UNSAFE_CONFIGURE 1

ENV TERM=xterm

RUN apt-get update && apt-get install -y subversion g++ zlib1g-dev build-essential git python rsync man-db libncurses5-dev gawk gettext unzip file libssl-dev wget curl

RUN mkdir -p /data/lede && git clone https://github.com/lede-project/source.git /data/lede && cd /data/lede && git checkout lede-17.01

WORKDIR /data/lede

RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

COPY .config ./
COPY .kconfig ./

COPY kconfig.sh ./

RUN cat ./.config
RUN cat ./.kconfig

RUN chmod +x kconfig.sh
RUN ./kconfig.sh

RUN make defconfig

#RUN yes "" | make kernel_oldconfig CONFIG_TARGET=subtarget

#RUN make download

RUN echo "10.0.0.4 ftp.gnupg.org " >> /etc/hosts && make download

#RUN make -j $(getconf _NPROCESSORS_ONLN)
RUN make -j1 V=s  2>&1

RUN ls -lha /data/lede/bin/x86/64/

FROM alpine:3.7

RUN apk update && apk add --no-cache curl

COPY --from=builder /data/lede/bin/* /tmp/

RUN ls -lha /tmp/

RUN curl --upload-file /tmp/x86/64/lede-17.01.4-x86-64-combined-ext4.img.gz https://transfer.sh/lede-17.01.4-x86-64-combined-ext4.img.gz
