FROM ubuntu:22.04
RUN mkdir ~/ffmpeg_sources ~/ffmpeg_build
WORKDIR ~/ffmpeg_sources
COPY scripts/0_install_libs.sh .
RUN /bin/bash 0_install_libs.sh
COPY scripts/1_compile_libsvtav1.sh .
RUN /bin/bash 1_compile_libsvtav1.sh
COPY scripts/2_compile_libvmaf.sh .
RUN /bin/bash 2_compile_libvmaf.sh
RUN cd ~/ffmpeg_sources && wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org//releases/ffmpeg-snapshot.tar.bz2 && tar xjf ffmpeg-snapshot.tar.bz2
RUN cd ~/ffmpeg_sources/ffmpeg && PATH="$HOME/bin:$PATH" \
    PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" \
    LLVM_COMPILER=clang-18 LLVM_BITCODE_GENERATION_FLAGS="-g" \
    ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --extra-libs="-lpthread" \
    --ld="g++-12" \
    --cc=clang-18 \
    --cxx=clang++-18 \
    --bindir="$HOME/bin" \
    --enable-cross-compile \
    --enable-runtime-cpudetect \
    --enable-libfdk-aac \
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
    --enable-libsvtav1 \
    --enable-libvmaf \
    --disable-doc \
    --disable-shared \
    --enable-static \
    --disable-ffplay \
    --disable-ffprobe \
    --enable-vulkan \
    --enable-libglslang
RUN cd ~/ffmpeg_sources/ffmpeg && make install -j8
RUN /root/bin/ffmpeg -version
