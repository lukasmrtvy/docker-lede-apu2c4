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

RUN mkdir -p ./package/kernel/gpio-nct5104d/patches/
COPY gpio-nct5104d.patch ./package/kernel/gpio-nct5104d/patches/

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





FROM alpine:3.7

ENV TZ=Europe/Prague

RUN apk update && apk add --no-cache curl jq tzdata

COPY --from=builder /data/lede/bin/* /tmp/

RUN cd /tmp/x86/64 && ls /tmp/x86/64 |grep 'combined-ext4.img.gz' | xargs -I % -n1 mv % /tmp/lede-snapshot-combined-ext4.img.gz

#RUN url=$(curl --upload-file /tmp/lede-snapshot-combined-ext4.img.gz https://transfer.sh/lede-snapshot-combined-ext4.img.gz) && \
#curl -X POST -H "Content-Type: application/json" -d '{"value1":"'"${name}"'","value2":"'"${type}"'","value3":"'"${url}"'"}' https://maker.ifttt.com/trigger/upload/with/key/cPy1lybKqXvF7uT3LvDTkk

RUN checksum=$(sha256sum /tmp/lede-snapshot-combined-ext4.img.gz)

RUN datum=$(date +"%Y-%m-%dT%H:%M:%SZ") &&  response=$(curl -F "file=@/tmp/lede-snapshot-combined-ext4.img.gz" https://file.io) && url=$(echo $response | jq -r .link) && \
curl -X POST -H "Content-Type: application/json" -d '{"value1":"'"${checksum}"'","value2":"'"${datum}"'","value3":"'"${url}"'"}' https://maker.ifttt.com/trigger/upload/with/key/cPy1lybKqXvF7uT3LvDTkk








