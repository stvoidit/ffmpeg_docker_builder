FROM ubuntu:22.04
ARG VMAF_TAG=master
ARG FFMPEG_TAG=master
ENV PATH="$HOME/bin:/usr/local/bin:$PATH"
ENV LD_LIBRARY_PATH+="/usr/local/lib"
ENV PKG_CONFIG_PATH+="/usr/local/lib/pkgconfig"
RUN mkdir /ffmpeg_sources /ffmpeg_build
WORKDIR /ffmpeg_sources
RUN apt update -qq && apt upgrade -y -qq && apt install -y -qq git-core wget && wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | tee /etc/apt/trusted.gpg.d/lunarg.asc && wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list && apt update -qq && apt -qq -y install \
    autoconf \
    automake \
    build-essential \
    cmake \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    openssl \
    libssl-dev \
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
    libx264-dev libfdk-aac-dev xxd \
    libnuma-dev libvpx-dev libopus-dev libdav1d-dev libgnutls28-dev libunistring-dev libvulkan-dev vulkan-sdk \
    gcc-12 g++-12 cpp-12 lsb-release software-properties-common
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && yes | ./llvm.sh 18 && apt install lld-18 clang-18 llvm-18
ENV CC=clang-18 CXX=clang++-18 LLVM=-18
RUN git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && cd SVT-AV1/Build/linux && ./build.sh --enable-lto --install -xj$(nproc) release

RUN git clone https://github.com/Netflix/vmaf.git && cd vmaf && git checkout $VMAF_TAG && meson libvmaf/build libvmaf -Denable_tests=false -Denable_docs=false --default-library=static --buildtype release && ninja -vC libvmaf/build && ninja -vC libvmaf/build install

RUN git clone https://bitbucket.org/multicoreware/x265_git.git && cd x265_git/build/linux && cmake -G"Unix Makefiles" -DENABLE_SHARED=off ../../source && make -j$(nproc) && make install

RUN git clone --depth=1 https://github.com/FFmpeg/FFmpeg.git && cd FFmpeg && git checkout $FFMPEG_TAG
WORKDIR /ffmpeg_sources/FFmpeg
RUN ./configure \
    --target-os="linux" \
    --arch="x86_64" \
    --prefix="docker-build" \
    --pkg-config-flags="--static" \
    --extra-libs="-lm -lpthread" \
    --cc="clang-18" \
    --cxx="clang++-18" \
    --ld="g++-12" \
    --ar="llvm-ar-18" \
    --strip="llvm-strip-18" \
    --bindir="$HOME/bin" \
    --enable-cross-compile \
    --enable-libfdk-aac \
    --enable-pthreads \
    --enable-gpl \
    --enable-version3 \
    --enable-nonfree \
    --enable-pic \
    --enable-openssl \
    --enable-libass \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libdav1d \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libsvtav1 \
    --enable-libvmaf \
    --enable-static \
    --enable-vulkan \
    --enable-libglslang \
    --enable-libdrm \
    --disable-w32threads \
    --disable-debug \
    --disable-doc \
    --disable-shared \
    --disable-ffprobe
RUN make install -j$(nproc)
