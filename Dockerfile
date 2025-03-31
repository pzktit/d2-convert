FROM ubuntu:24.04

# Ustawienia środowiskowe
ENV DEBIAN_FRONTEND=noninteractive
ENV D2_VERSION=0.6.9

# Zainstaluj potrzebne narzędzia
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        bash \
        ca-certificates \
        imagemagick \
        librsvg2-bin \
        tar \
    && rm -rf /var/lib/apt/lists/*

# Zainstaluj d2 do /usr/local/d2-<version> i dodaj symlink
RUN curl -L -o /tmp/d2.tar.gz https://github.com/terrastruct/d2/releases/download/v${D2_VERSION}/d2-v${D2_VERSION}-linux-amd64.tar.gz && \
    mkdir -p /usr/local/d2-${D2_VERSION} && \
    tar -xzf /tmp/d2.tar.gz -C /usr/local/d2-${D2_VERSION} --strip-components=1 && \
    ln -s /usr/local/d2-${D2_VERSION}/bin/d2 /usr/local/bin/d2 && \
    rm /tmp/d2.tar.gz

# Katalog roboczy
WORKDIR /data

