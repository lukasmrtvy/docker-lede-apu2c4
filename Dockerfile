FROM frolvlad/alpine-glibc:latest

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
RUN make defconfig

RUN  make target/linux/prepare

COPY .kconfig /tmp

RUN make target/linux/prepare

RUN ls -lha /tmp/
RUN ls -lha ./ 
RUN ls -lha ./build_dir
RUN ls -lha ./build_dir/target-x86_64_musl-1.1.16
RUN ls -lha ./build_dir/target-x86_64_musl-1.1.16/linux-x86_64
RUN ls -lha ./build_dir/target-x86_64_musl-1.1.16/linux-x86_64/linux-4.4.92/

#RUN rm -rf  /build_dir/target-x86_64_musl-1.1.16/linux-x86_64/linux-4.4.9/.config

RUN cp /tmp/.kconfig ./build_dir/target-x86_64_musl-1.1.16/linux-x86_64/linux-4.4.92/.config
RUN cd ./build_dir/target-x86_64_musl-1.1.16/linux-x86_64/linux-4.4.92/ && make defconfig



#COPY ucode.patch ./target/linux/x86/patches-4.4/
#COPY kconfig.sh ./
#RUN chmod +x kconfig.sh && ./kconfig.sh 

#RUN make -j1 V=s download
RUN echo "10.0.0.4 ftp.gnupg.org " >> /etc/hosts && make download
RUN make -j1 V=s
#RUN make -j $(getconf _NPROCESSORS_ONLN)
