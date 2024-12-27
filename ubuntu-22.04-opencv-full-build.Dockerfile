# Ubuntu 22.04 container builds OpenCV from source with the maximum possible enabled amount of features

FROM node:22.12 AS frontend

RUN set -xeu && \
	git clone https://github.com/piotrpdev/oko.git /root/oko

RUN set -xeu && \
	npm --prefix=/root/oko/frontend ci && \
	npm --prefix=/root/oko/frontend run build && \
	mkdir -p /root/oko/backend/static && \
	cp -r /root/oko/frontend/dist/* /root/oko/backend/static/

FROM ubuntu:22.04 AS opencv_download

RUN set -xeu && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    apt-get autoremove -y --purge && \
    apt-get -y autoclean

RUN set -xeu && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y curl

ARG OPENCV_VERSION=4.8.0

RUN set -xeu && \
    mkdir -p /root/dist && \
    curl -sSfL "https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.tar.gz" | tar xz -C /root/dist && \
    curl -sSfL "https://github.com/opencv/opencv_contrib/archive/refs/tags/${OPENCV_VERSION}.tar.gz" | tar xz -C /root/dist && \
    sed -ri 's/Ptr<FarnebackOpticalFlow> cv::cuda::FarnebackOpticalFlow::create/Ptr<cv::cuda::FarnebackOpticalFlow> cv::cuda::FarnebackOpticalFlow::create/' "/root/dist/opencv_contrib-${OPENCV_VERSION}/modules/cudaoptflow/src/farneback.cpp" # patch for version 4.8.0

FROM ubuntu:22.04 AS backend

RUN set -xeu && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    apt-get autoremove -y --purge && \
    apt-get -y autoclean

RUN set -xeu && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y clang libclang-dev cmake \
    libatlas-base-dev libceres-dev libeigen3-dev libva-dev \
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev

ARG OPENCV_VERSION=4.8.0

COPY --from=opencv_download /root/dist /root/dist

RUN set -xeu && \
    mkdir -p /root/build && \
    cmake -B /root/build -S "/root/dist/opencv-${OPENCV_VERSION}" -D OPENCV_EXTRA_MODULES_PATH="/root/dist/opencv_contrib-${OPENCV_VERSION}/modules" -D CMAKE_INSTALL_PREFIX=/opt/opencv \
		-D CMAKE_BUILD_TYPE=Release \
    	-D BUILD_SHARED_LIBS=OFF \
		-D OPENCV_FORCE_3RDPARTY_BUILD=ON \
    	-D BUILD_PERF_TESTS=OFF \
    	-D BUILD_TESTS=OFF \
		-D BUILD_opencv_apps=OFF \
		-D BUILD_LIST=core,imgcodecs,imgproc,video,videoio \
    	-D WITH_1394=OFF \
		-D WITH_FLATBUFFERS=OFF \
    	-D WITH_GSTREAMER=OFF \
    	-D WITH_GTK=OFF \
		-D WITH_IMGCODEC_HDR=OFF \
    	-D WITH_IMGCODEC_PXM=OFF \
		-D WITH_IMGCODEC_PFM=OFF \
    	-D WITH_IMGCODEC_SUNRASTER=OFF \
    	-D WITH_ITT=OFF \
    	-D WITH_LAPACK=OFF \
    	-D WITH_OPENCL=OFF \
    	-D WITH_OPENCLAMDBLAS=OFF \
    	-D WITH_OPENCLAMDFFT=OFF \
    	-D WITH_OPENEXR=OFF \
		-D WITH_OBSENSOR=OFF \
    	-D WITH_PROTOBUF=OFF \
    	-D WITH_TIFF=OFF \
    	-D WITH_V4L=OFF \
    	-D WITH_VTK=OFF \
    	-D WITH_WEBP=OFF && \
    make -C /root/build -j`nproc` install

FROM ubuntu:22.04 AS test

RUN set -xeu && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    apt-get autoremove -y --purge && \
    apt-get -y autoclean

RUN set -xeu && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl clang libclang-dev \
    cmake \
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev

RUN set -xeu && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile=minimal

ENV PATH="${PATH}:/root/.cargo/bin"

COPY --from=backend /opt/opencv /opt/opencv
COPY --from=frontend /root/oko /root/oko

RUN set -xeu && \
	ls /opt/opencv/lib && \
	ls /opt/opencv/lib/opencv4/3rdparty && \
	ls /usr/lib/x86_64-linux-gnu && \
	ls /opt/opencv/include && \
	ls /opt/opencv/include/opencv4 && \
	ls /usr/include/x86_64-linux-gnu

ENV OPENCV_LINK_LIBS=opencv_videoio,opencv_video,opencv_imgcodecs,opencv_imgproc,opencv_core,libavformat,libavcodec,libavutil,libswscale,liblibjpeg-turbo,liblibpng,liblibopenjp2,ippiw,ippicv,zlib
ENV OPENCV_LINK_PATHS=/opt/opencv/lib,/opt/opencv/lib/opencv4/3rdparty,/usr/lib/x86_64-linux-gnu
ENV OPENCV_INCLUDE_PATHS=/opt/opencv/include,/opt/opencv/include/opencv4

RUN set -xeu && \
	cd /root/oko/backend && \
	cargo build

# RUN set -xeu && \
# 	npx playwright install-deps

# pkg-config needed to detect libssl-dev for some reason, libssl needed for ws_utils
# https://github.com/microsoft/playwright/blob/08644003d2a8770045e9eb3c7fa9a0f8bb812413/packages/playwright-core/src/server/registry/nativeDeps.ts#L252-L275
RUN set -xeu && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libasound2 libatk-bridge2.0-0 libatk1.0-0 \
	libatspi2.0-0 libcairo2 libcups2 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libnspr4 libnss3 \
	libpango-1.0-0 libwayland-client0 libx11-6 libxcb1 libxcomposite1 libxdamage1 libxext6 \
	libxfixes3 libxkbcommon0 libxrandr2 \
	pkg-config libssl-dev

# playwright-rs needs to install things, first time will always fail
RUN set -xu && \
	cd /root/oko/backend && \
	cargo test; exit 0

RUN set -xeu && \
	cd /root/oko/backend && \
	cargo test
