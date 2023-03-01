FROM ubuntu:20.04

MAINTAINER jmonlong@ucsc.edu

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    curl \
    gcc \ 
    make \
    cmake \
    autoconf \
    build-essential \
    bzip2 \
    git \
    sudo \
    pigz \
    pkg-config \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libbz2-dev \
    libncurses5-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

## minimap2
RUN wget --no-check-certificate https://github.com/lh3/minimap2/releases/download/v2.24/minimap2-2.24_x64-linux.tar.bz2 && \
    tar -jxvf minimap2-2.24_x64-linux.tar.bz2 && \
    rm minimap2-2.24_x64-linux.tar.bz2

ENV PATH=/build/minimap2-2.24_x64-linux/:$PATH

## samtools
RUN wget --no-check-certificate https://github.com/samtools/samtools/releases/download/1.16.1/samtools-1.16.1.tar.bz2 && \
    tar -jxvf samtools-1.16.1.tar.bz2 && \
    cd samtools-1.16.1 && \
    ./configure &&  make && make install

WORKDIR /home
