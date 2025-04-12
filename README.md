# OpenCV Building Experiments

> [!NOTE]
> If targeting `musl`, need to compile `ffmpeg` using `musl` which is a pain.

```bash
docker build -f ubuntu-22.04-opencv-full-build.Dockerfile --progress=plain . &> logs/build_ffmpeg8.log

docker build -f ubuntu-22.04-opencv-full-build.Dockerfile --no-cache-filter frontend .

docker run --rm -it 7e1ce6336850 /bin/bash -c "cd /root/oko/backend/ && cargo build --quiet --release && /usr/bin/ldd /root/oko/backend/target/release/oko" >> latest.txt

# https://github.com/rust-lang/rust/issues/78210#issuecomment-1502275713
RUSTFLAGS="-C target-feature=+crt-static" cargo build --release --target x86_64-unknown-linux-gnu

# https://stackoverflow.com/questions/73610525/how-to-find-out-which-rust-dependency-added-a-dynamically-linked-library
cargo clean && cargo build -vv 2>/dev/null | grep 'rustc-link-lib'

docker build -f different-musl.Dockerfile --progress=plain . &> "diff_musl/different-musl_$(date +"%Y-%m-%d_%H-%M-%S").log"
```

Tried adding `-D CMAKE_SHARED_LINKER_FLAGS="-static -static-libgcc -static-libstdc++"` to CMake command but `libstdc++` was still there.
