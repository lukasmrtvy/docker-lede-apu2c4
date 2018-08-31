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

COPY gpio-nct5104d.c ./package/kernel/gpio-nct5104d/src/gpio-nct5104d.c

COPY kconfig.sh ./

RUN cat ./.config
RUN cat ./.kconfig

RUN chmod +x kconfig.sh
RUN ./kconfig.sh

RUN make defconfig
RUN make download

RUN cat ./.config

RUN make -j $(getconf _NPROCESSORS_ONLN)  V=s
##RUN make -j1 V=s  2>&1

FROM alpine:3.7
ENV TZ=Europe/Prague
RUN apk update && apk add --no-cache curl jq tzdata
RUN echo test
COPY --from=builder /data/lede/bin/* /tmp/
RUN cd /tmp/x86/64 && ls /tmp/x86/64 |grep 'combined-ext4.img.gz' | xargs -I % -n1 mv % /tmp/lede-snapshot-combined-ext4.img.gz
RUN checksum=$(sha256sum /tmp/lede-snapshot-combined-ext4.img.gz)
RUN datum=$(date +"%Y-%m-%dT%H:%M:%SZ") &&  response=$(curl -F "file=@/tmp/lede-snapshot-combined-ext4.img.gz" https://file.io) && url=$(echo $response | jq -r .link) && \
curl -X POST -H "Content-Type: application/json" -d '{"value1":"'"${checksum}"'","value2":"'"${datum}"'","value3":"'"${url}"'"}' https://maker.ifttt.com/trigger/upload/with/key/cPy1lybKqXvF7uT3LvDTkk








