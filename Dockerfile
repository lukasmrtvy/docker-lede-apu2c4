FROM ubuntu:17.10 as builder

ENV VERSION 17.01.4
ENV FORCE_UNSAFE_CONFIGURE 1

ENV TERM=xterm

RUN apt-get update && apt-get install -y subversion g++ zlib1g-dev build-essential git python rsync man-db libncurses5-dev gawk gettext unzip file libssl-dev wget curl

RUN apt-get update && apt-get install -y time

RUN mkdir -p /data/lede | curl -sSL https://github.com/lede-project/source/archive/v${VERSION}.tar.gz | tar xz -C /data/lede --strip-components=1

WORKDIR /data/lede

RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

COPY .config ./
COPY .kconfig ./
COPY ucode.patch ./target/linux/x86/patches-4.4/
RUN mkdir -p ./package/kernel/gpio-nct5104d/patches/
COPY gpio-nct5104d.patch ./package/kernel/gpio-nct5104d/patches/

RUN mkdir -p ./package/kernel/leds-apu2/patches/
COPY leds-apu2.patch ./package/kernel/leds-apu2/patches/

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

RUN apk update && apk add --no-cache curl

COPY --from=builder /data/lede/bin/* /tmp/

RUN url=$(curl --upload-file /tmp/x86/64/lede-17.01.4-x86-64-combined-ext4.img.gz https://transfer.sh/lede-17.01.4-x86-64-combined-ext4.img.gz) && \
curl -X POST -H "Content-Type: application/json" -d '{"value1":"'"${name}"'","value2":"'"${type}"'","value3":"'"${url}"'"}' https://maker.ifttt.com/trigger/upload/with/key/cPy1lybKqXvF7uT3LvDTkk





