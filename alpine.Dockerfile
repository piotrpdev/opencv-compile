FROM rust:alpine3.21

RUN set -xeu && \
    apk add build-base clang-dev opencv-dev

RUN set -xeu && \
	cargo new /root/app && \
	echo "opencv = { version = \"0.94.4\", default-features = false }" >> /root/app/Cargo.toml && \
	echo "use opencv::prelude::*; use opencv::core; fn main() {}" > /root/app/src/main.rs

RUN set -xu && \
	cd /root/app && \
    RUST_BACKTRACE=full cargo build -vv --release
