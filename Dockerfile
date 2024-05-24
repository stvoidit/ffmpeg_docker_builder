FROM ubuntu:22.04
RUN sed -Ei 's/http:\/\/[archive|security]+.ubuntu.com/http:\/\/mirror.docker.ru/gm' /etc/apt/sources.list
ENV PATH="$HOME/bin/:/usr/local/bin/:/usr/lib/llvm-18/bin/:$PATH"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib/:/usr/local/lib/x86_64-linux-gnu/:/usr/lib/:/usr/lib/x86_64-linux-gnu/"
ENV PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"
RUN mkdir /ffmpeg_sources /ffmpeg_build
WORKDIR /ffmpeg_sources
RUN apt-get update -qq && apt-get upgrade -y -qq && apt-get install -y -qq git-core wget && wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | tee /etc/apt/trusted.gpg.d/lunarg.asc && wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list && apt-get update -qq
RUN apt-get -qq -y install \
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
    libopengl-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libdrm-dev \
    liblzma-dev \
    libxcb-xfixes0-dev \
    meson \
    ninja-build \
    pkg-config \
    texinfo \
    wget \
    libtls-dev \
    yasm \
    zlib1g-dev \
    libopenjp2-7-dev \
    libpostproc-dev \
    nasm g++-12 diffutils \
    libxml2-dev \
    libx264-dev libfdk-aac-dev xxd python3.10-venv python3-pip \
    libnuma-dev libvpx-dev libopus-dev libdav1d-dev libgnutls28-dev libunistring-dev libvulkan-dev vulkan-sdk \
    lsb-release software-properties-common
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && yes | ./llvm.sh 18 && apt-get -y install lld-18 clang-18 llvm-18
ENV CC=clang-18 CXX=clang++-18 LLVM=-18 LD=lld-18 AR=llvm-ar-18 HOSTCC=clang-18 HOSTCXX=clang++-18 HOSTAR=llvm-ar-18 HOSTLD=ld.lld-18

RUN git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && cd SVT-AV1/Build/linux && ./build.sh release --enable-lto --install -x -j$(nproc)

RUN git clone --branch master https://bitbucket.org/multicoreware/x265_git.git && cd x265_git/build/linux && cmake -G"Unix Makefiles" -DENABLE_SHARED=off ../../source && make -j$(nproc) && make install

ARG AMF_VERSION=v1.4.33
RUN git clone --depth 1 --branch ${AMF_VERSION} https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git && mkdir -p /usr/local/include/AMF && cp -r AMF/amf/public/include/* /usr/local/include/AMF

# ARG VMAF_TAG=master
# RUN git clone --branch ${VMAF_TAG} https://github.com/Netflix/vmaf.git && cd vmaf && make deps && .venv/bin/meson setup libvmaf/build libvmaf --buildtype release -Denable_avx512=true -Denable_float=true --default-library=static && .venv/bin/ninja -vC libvmaf/build install

ARG FFMPEG_TAG=master
RUN git clone --depth=1 --branch ${FFMPEG_TAG} https://github.com/FFmpeg/FFmpeg.git && cd FFmpeg
WORKDIR /ffmpeg_sources/FFmpeg

# --extra-ldflags='-flto -fuse-linker-plugin -fuse-ld=lld-18'
# --enable-libvmaf --ld="g++-12" \
RUN ./configure \
    --target-os="linux" \
    --arch="x86_64" \
    --prefix="/usr/local" \
    --pkg-config-flags="--static" \
    --extra-libs="-lm -lpthread" \
    --extra-ldflags='-flto -fuse-linker-plugin -fuse-ld=lld-18' \
    --cc="clang-18" \
    --cxx="clang++-18" \
    --ar="llvm-ar-18" \
    --bindir="$HOME/bin" \
    --enable-cross-compile \
    --enable-libfdk-aac \
    --enable-pthreads \
    --enable-gpl \
    --enable-version3 \
    --enable-nonfree \
    --enable-libopenjpeg \
    --enable-openssl \
    --enable-libass \
    --enable-libtls \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libdav1d \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libsvtav1 \
    --enable-static \
    --enable-vulkan \
    --enable-libglslang \
    --enable-libdrm \
    --enable-pic \
    --enable-amf \
    --enable-opengl \
    --disable-shared \
    --disable-debug \
    --disable-doc \
    --enable-libpulse \
    --disable-shared \
    --disable-ffprobe
CMD make install -j$(nproc) && mv -v ffmpeg ffplay -t /ffmpeg_build/
