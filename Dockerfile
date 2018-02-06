FROM alpine:3.7

ENV VERSION 17.01.4
ENV FORCE_UNSAFE_CONFIGURE 1

RUN apk update && apk add --no-cache \ 
                              build-base \
                              curl \
                              perl \
                              git \
                              curl \
                              perl \
                              git \
                              coreutils \
                              tar \
                              bzip2 \
                              unzip \
                              python \
                              ncurses-dev \
                              zlib-dev \
                              wget \
                              bash \
                              patch \
                              gawk \
                              grep \
                              file \
                              findutils \
                              rsync \
                              linux-headers \
                              xz \
                              sdl-dev

RUN mkdir -p /data/lede && curl -sSL https://github.com/lede-project/source/archive/v${VERSION}.tar.gz | tar xz -C /data/lede --strip-components=1

WORKDIR /data/lede

RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

COPY .config ./
COPY .kconfig ./
COPY ucode.patch ./target/linux/x86/patches-4.4/
COPY kconfig.sh ./

RUN chmod +x kconfig.sh && ./kconfig.sh 
RUN make defconfig
#RUN make -j1 V=s download
RUN make download
RUN make -j1 V=s
#RUN make -j $(getconf _NPROCESSORS_ONLN)
