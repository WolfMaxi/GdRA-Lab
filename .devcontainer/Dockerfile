# Basis-Image
FROM ubuntu:22.04

# Nicht-interaktive Installation
ENV DEBIAN_FRONTEND=noninteractive

# Abhängigkeiten installieren
RUN apt-get update && apt-get install -y \
    git \
    gnat \
    make \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# GHDL 4.1.0 klonen und bauen mit mcode
RUN git clone https://github.com/ghdl/ghdl.git /ghdl \
    && cd /ghdl \
    && git checkout v4.1.0 \
    && mkdir build \
    && cd build \
    && ../configure \
    && make \
    && make install \
    && cd / && rm -rf /ghdl