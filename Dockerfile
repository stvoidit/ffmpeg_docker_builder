FROM ubuntu:22.04
RUN apt update -qq && apt upgrade -y -qq
RUN apt install -y -qq git-core wget
RUN wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | tee /etc/apt/trusted.gpg.d/lunarg.asc && wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list
RUN apt update -qq && apt -qq -y install \
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
    libx264-dev \
    libx265-dev libnuma-dev libvpx-dev libopus-dev libdav1d-dev libgnutls28-dev libunistring-dev libvulkan-dev vulkan-sdk \
    gcc-12 g++-12 cpp-12 clang-14
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12
RUN update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-12 12
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 12
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 14
RUN mkdir ~/ffmpeg_sources ~/ffmpeg_build
ENV FFMPEG_RELEASE_VERSION=snapshot
ENV CC=clang-14
ENV CXX=clang++-14
RUN cd ~/ffmpeg_sources && wget -O ffmpeg-${FFMPEG_RELEASE_VERSION}.tar.bz2 https://ffmpeg.org//releases/ffmpeg-${FFMPEG_RELEASE_VERSION}.tar.bz2 && tar xjf ffmpeg-${FFMPEG_RELEASE_VERSION}.tar.bz2
RUN cd ~/ffmpeg_sources/ffmpeg && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" LLVM_COMPILER=clang-14 LLVM_BITCODE_GENERATION_FLAGS="-g" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --extra-libs="-lpthread" \
    --ld="g++" \
    --cc=clang-14 \
    --cxx=clang++-14 \
    --bindir="$HOME/bin" \
    --enable-cross-compile \
    --enable-runtime-cpudetect \
    --enable-pthreads \
    --target-os=linux \
    --arch=x86_64 \
    --enable-gpl \
    --enable-gnutls \
    --enable-libass \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libdav1d \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --disable-doc --disable-shared --enable-static --disable-ffplay --disable-ffprobe --enable-vulkan --enable-libglslang
RUN cd ~/ffmpeg_sources/ffmpeg && make install -j8
RUN /root/bin/ffmpeg -version
