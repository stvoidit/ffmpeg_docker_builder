FROM ubuntu:22.04
ENV SHELL="/bin/bash"
RUN sed -Ei 's/http:\/\/[archive|security]+.ubuntu.com/http:\/\/mirror.docker.ru/gm' /etc/apt/sources.list
RUN sed -Ei 's/# deb-src/deb-src/gm' /etc/apt/sources.list
ENV PATH="/usr/bin:/usr/local/bin:$PATH"
ENV LD_LIBRARY_PATH="/lib:/lib64:/usr/lib:/usr/local/lib:/usr/lib/x86_64-linux-gnu:/usr/local/lib/x86_64-linux-gnu:/usr/local/include"
ENV PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig"
ENV DEBIAN_FRONTEND="noninteractive"
ENV CC="gcc-12" \
    CXX="g++-12" \
    CPP="cpp-12" \
    CXXFLAGS="-march=native -O3" \
    CCFLAGS="-march=native -O3" \
    CFLAGS="-march=native -O3" \
    LDFLAGS="-flto -fuse-linker-plugin"
RUN mkdir /ffmpeg_sources /ffmpeg_build
WORKDIR /ffmpeg_sources
RUN apt-get update && apt-get install -y git wget lsb-release software-properties-common && wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | tee /etc/apt/trusted.gpg.d/lunarg.asc && wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list
RUN apt-get update -qq && apt-get upgrade -y && apt-get -y install \
    autoconf \
    automake \
    build-essential \
    cmake \
    libtool \
    yasm \
    xxd \
    openssl \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libpthreadpool-dev \
    libpthread-stubs0-dev \
    libssl-dev \
    libmp3lame-dev \
    libsdl2-dev \
    libopengl-dev \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libdrm-dev \
    liblzma-dev \
    libxcb-xfixes0-dev \
    libv4l-dev \
    libjpeg-dev \
    librtmp-dev \
    libgcrypt20-dev \
    libiec61883-dev \
    libdc1394-dev \
    libavc1394-dev \
    pkg-config \
    texinfo \
    libtls-dev \
    libxxhash-dev \
    zlib1g-dev \
    libopenjp2-7-dev \
    libpostproc-dev \
    libunwind-dev \
    nasm diffutils \
    libxml2-dev \
    libcodec2-dev \
    libmysofa-dev \
    libopenal-dev \
    libtheora-dev \
    libvidstab-dev \
    libwebp-dev \
    liblcms2-dev \
    libfdk-aac-dev \
    python3.10-venv \
    python3-pip \
    libnuma-dev \
    libopus-dev \
    libdav1d-dev \
    libgnutls28-dev \
    libunistring-dev \
    libvulkan-dev \
    vulkan-sdk \
    gcc-12 \
    g++-12 \
    cpp-12
RUN python3 -m pip install -U meson ninja && ldconfig

ARG OPUS_VERSION="1.5.2"
RUN wget "https://downloads.xiph.org/releases/opus/opus-${OPUS_VERSION}.tar.gz" -O - | tar xz
RUN cd opus* && meson setup \
    --buildtype=custom \
    --default-library=static \
    -Dextra-programs=disabled \
    -Ddebug=false \
    -Dtests=disabled \
    -Db_staticpic=true \
    -Dfixed-point=true \
    -Db_asneeded=true \
    -Db_pie=true \
    -Ddocs=disabled \
    -Dfixed-point=false \
    --wipe build && meson install -C build && ldconfig

RUN git clone --depth 1 https://code.videolan.org/videolan/x264.git && cd x264 && ./configure --enable-static --enable-pic --disable-asm && make -j8 && make install

RUN git clone --branch master https://bitbucket.org/multicoreware/x265_git.git && cd x265_git/build/linux && cmake -G "Ninja" -DENABLE_SHARED=off ../../source && ninja install

RUN git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && cd SVT-AV1/Build/linux && ./build.sh --release --jobs=$(nproc) --enable-lto --enable-pgo --native --enable-avx512 --install -x

RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && cd libvpx && ./configure --enable-install-srcs --enable-codec-srcs --enable-static --enable-pic --enable-vp9-highbitdepth --enable-better-hw-compatibility --disable-docs --disable-examples --disable-unit-tests --as=nasm --target=x86_64-linux-gcc && make -j8 && make install

ARG AMF_VERSION="v1.4.34"
RUN git clone --depth 1 --branch ${AMF_VERSION} https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git && mkdir -p /usr/local/include/AMF && cp -r AMF/amf/public/include/* /usr/local/include/AMF

# ARG VMAF_TAG=master
# RUN git clone --branch ${VMAF_TAG} https://github.com/Netflix/vmaf.git && cd vmaf && make deps && .venv/bin/meson setup libvmaf/build libvmaf --buildtype release -Denable_avx512=true -Denable_float=true --default-library=static && .venv/bin/ninja -vC libvmaf/build install

# RUN git clone https://github.com/google/shaderc && cd shaderc && ./utils/git-sync-deps && mkdir build && cd build && cmake -GNinja -DENABLE_SHARED=off -DCMAKE_CXX_FLAGS="-flto" -DCMAKE_BUILD_TYPE=Release .. && ninja -j 16

# ARG LIBPLACEBO_TAG="v5.264.1"
# RUN git clone --recursive --branch ${LIBPLACEBO_TAG} https://code.videolan.org/videolan/libplacebo && cd libplacebo && meson setup build --buildtype=release --default-library=static --wipe && ninja -j 16 -Cbuild install

ARG FFMPEG_TAG=master
RUN git clone --depth=1 --branch ${FFMPEG_TAG} https://github.com/FFmpeg/FFmpeg.git && cd FFmpeg && ldconfig
WORKDIR /ffmpeg_sources/FFmpeg

# # --enable-libvmaf --ld="g++-12" \
# --enable-libplacebo \
# --extra-ldflags='-flto -fuse-linker-plugin -fuse-ld=lld-18' \
# --enable-cross-compile \
# --enable-libplacebo \
RUN ./configure \
    --target-os="linux" \
    --arch="x86_64" \
    --prefix="/usr/local" \
    --pkg-config-flags="--static" \
    --extra-libs="-lm -lpthread" \
    --extra-ldflags="-flto -fuse-linker-plugin" \
    --extra-cflags='-march=native -O3' \
    --extra-cxxflags='-march=native -O3' \
    --toolchain="hardened" \
    --cc="gcc-12" \
    --cxx="g++-12" \
    --enable-lto=full \
    --enable-static \
    --enable-thumb \
    --enable-pic \
    --enable-pthreads \
    --enable-gpl \
    --enable-version3 \
    --enable-nonfree \
    --enable-amf \
    --enable-libfdk-aac \
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
    --enable-vulkan \
    --enable-libglslang \
    --enable-libdrm \
    --enable-opengl \
    --enable-libv4l2 \
    --enable-gmp \
    --enable-gcrypt \
    --enable-libpulse \
    --enable-libdc1394 \
    --enable-libiec61883 \
    --enable-libxcb \
    --enable-libxcb-shm \
    --enable-libxcb-xfixes \
    --enable-libxcb-shape \
    --disable-shared \
    --disable-debug \
    --disable-doc
CMD make -j$(nproc) && mv -v ffmpeg ffplay ffprobe -t /ffmpeg_build/
