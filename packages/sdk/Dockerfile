# syntax=docker.io/docker/dockerfile:1
ARG BASE_IMAGE
ARG SERVER_MANAGER_REGISTRY
ARG SERVER_MANAGER_ORG
ARG SERVER_MANAGER_VERSION
ARG CARTESI_IMAGE_KERNEL_VERSION
ARG LINUX_KERNEL_VERSION

FROM ${BASE_IMAGE} as builder

WORKDIR /usr/local/src
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    libarchive-dev \
    libtool
rm -rf /var/lib/apt/lists/*
EOF

FROM builder as genext2fs

# 1.5.4 -> 15ff1bf67b5dbdd2bbc163ca0b73df50065f00f7
WORKDIR /usr/local/src
ADD https://github.com/cartesi/genext2fs.git#15ff1bf67b5dbdd2bbc163ca0b73df50065f00f7 /usr/local/src
RUN <<EOF
set -e
./autogen.sh
./configure --enable-libarchive
make
make install
EOF

FROM builder as su-exec

# v0.2 -> f85e5bde1afef399021fbc2a99c837cf851ceafa
WORKDIR /usr/local/src
ADD https://github.com/ncopa/su-exec.git#f85e5bde1afef399021fbc2a99c837cf851ceafa /usr/local/src
RUN make

# sdk image
FROM $SERVER_MANAGER_REGISTRY/$SERVER_MANAGER_ORG/server-manager:$SERVER_MANAGER_VERSION
ARG SERVER_MANAGER_REGISTRY
ARG SERVER_MANAGER_ORG
ARG SERVER_MANAGER_VERSION
ARG CARTESI_IMAGE_KERNEL_VERSION
ARG LINUX_KERNEL_VERSION

USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libarchive-tools \
    locales \
    xz-utils
rm -rf /var/lib/apt/lists/*

sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8
EOF

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

COPY entrypoint.sh /usr/local/bin/
COPY --from=genext2fs /usr/local/bin/xgenext2fs /usr/local/bin/
COPY --from=su-exec /usr/local/src/su-exec /usr/local/bin/
RUN mkdir -p /tmp/.sunodo && chmod 1777 /tmp/.sunodo

ADD --chmod=644 \
    --checksum=sha256:1dc36e05bf04d3fff097e51408556cef4d5ac09792e245b37c470d9188a4c173 \
    https://github.com/cartesi/image-kernel/releases/download/v${CARTESI_IMAGE_KERNEL_VERSION}/linux-${LINUX_KERNEL_VERSION}.bin \
    /usr/share/cartesi-machine/images/linux.bin

ADD --chmod=644 \
    --checksum=sha256:58d1b232e6c2ed735f362ef0454802ae72a39798d472c0253cabec041703a16a \
    https://github.com/cartesi/image-kernel/releases/download/v$CARTESI_IMAGE_KERNEL_VERSION/linux-headers-$LINUX_KERNEL_VERSION.tar.xz \
    /usr/share/cartesi-machine/images/linux-headers.tar.xz
RUN tar -xJf /usr/share/cartesi-machine/images/linux-headers.tar.xz -C / && \
    rm /usr/share/cartesi-machine/images/linux-headers.tar.xz

WORKDIR /mnt
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
