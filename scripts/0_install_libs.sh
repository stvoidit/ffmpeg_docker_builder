#!/bin/bash

apt update -qq && apt upgrade -y -qq
apt install -y -qq git-core wget
wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | tee /etc/apt/trusted.gpg.d/lunarg.asc && wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list
apt update -qq && apt -qq -y install \
    autoconf \
    automake \
    build-essential \
    cmake \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libmp3lame-dev \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    meson \
    ninja-build \
    pkg-config \
    texinfo \
    wget \
    yasm \
    zlib1g-dev \
    nasm \
    libx264-dev libfdk-aac-dev \
    libx265-dev libnuma-dev libvpx-dev libopus-dev libdav1d-dev libgnutls28-dev libunistring-dev libvulkan-dev vulkan-sdk \
    gcc-12 g++-12 cpp-12 lsb-release software-properties-common
wget https://apt.llvm.org/llvm.sh &&
    chmod +x llvm.sh &&
    yes | ./llvm.sh 18 &&
    apt install lld-18 clang-18 llvm-18
export CC=clang-18
export CXX=clang++-18
export LLVM=-18
