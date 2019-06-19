FROM ubuntu:19.04 as builder

RUN apt -qq update && \
    apt -qq install -y \
        git \
        build-essential \
        libncurses5-dev \
        python \
        unzip \
        gawk \
        wget


ENV VERSION 18.06
ENV FORCE_UNSAFE_CONFIGURE 1

RUN mkdir -p /cache/build && \
    cd /cache/build/ && \
    git clone https://github.com/openwrt/openwrt.git && \
    cd openwrt/ && \
    git checkout openwrt-$VERSION && \
    ./scripts/feeds update -a && \
    ./scripts/feeds install -a

WORKDIR /cache/build/openwrt

# Custom start
#COPY 301-kernel-gpio-nct5104d-remove-boardname-check.patch ./custom-patches/
#COPY 301-kernel-leds-apu2-remove-boardname-check.patch ./custom-patches/
#COPY 001-procd-change-noatime-to-relatime-for-unprivileged-lx.patch ./package/system/procd/patches/001-procd-change-noatime-to-relatime-for-unprivileged-lx.patch
#RUN git apply ./custom-patches/301-kernel-leds-apu2-remove-boardname-check.patch 
#RUN git apply ./custom-patches/301-kernel-gpio-nct5104d-remove-boardname-check.patch
#RUN git apply ./custom-patches/001-procd-change-noatime-to-relatime-for-unprivileged-lx.patch
COPY .config ./
COPY .kconfig ./
COPY kconfig.sh ./
RUN chmod +x kconfig.sh
# Custom end 

RUN make defconfig && \
    make download -j$((`nproc`+1))


#RUN make -j$((`nproc`+1))
RUN make -j1 V=s


FROM alpine:3.9

COPY --from=builder /cache/build/openwrt/bin/* /openwrt
