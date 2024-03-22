wget https://github.com/Netflix/vmaf/archive/v2.3.1.tar.gz
tar xvf v2.3.1.tar.gz
mkdir -p vmaf-2.3.1/libvmaf/build && cd vmaf-2.3.1/libvmaf/build
meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "$HOME/ffmpeg_build" --bindir="$HOME/ffmpeg_build/bin" --libdir="$HOME/ffmpeg_build/lib"
ninja CC=clang CXX=clang++ LLVM=1
ninja install
