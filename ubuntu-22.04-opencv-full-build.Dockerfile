# Ubuntu 22.04 container builds OpenCV from source with the maximum possible enabled amount of features

FROM node:22.12 AS frontend

RUN set -xeu && \
	git clone https://github.com/piotrpdev/oko.git /root/oko

RUN set -xeu && \
	npm --prefix=/root/oko/frontend ci && \
	npm --prefix=/root/oko/frontend run build && \
	mkdir -p /root/oko/backend/static && \
	cp -r /root/oko/frontend/dist/* /root/oko/backend/static/

FROM ubuntu:22.04 AS backend

RUN set -xeu && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    apt-get autoremove -y --purge && \
    apt-get -y autoclean

RUN set -xeu && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl clang libclang-dev \
    cmake python3-numpy libatlas-base-dev libceres-dev libeigen3-dev liblapacke-dev libprotobuf-dev protobuf-compiler nvidia-cuda-dev libtesseract-dev \
    libwebp-dev libpng-dev libtiff-dev libopenexr-dev libgdal-dev libopenjp2-7-dev libopenjpip-server libopenjpip-dec-server libopenjp2-tools libhdf5-dev \
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libgphoto2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libva-dev libdc1394-dev \
    libfreetype6-dev libharfbuzz-dev qtbase5-dev libogre-1.12-dev \
	git libssl-dev 

ARG OPENCV_VERSION=4.8.0

RUN set -xeu && \
    mkdir -p /root/dist && \
    curl -sSfL "https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.tar.gz" | tar xz -C /root/dist && \
    curl -sSfL "https://github.com/opencv/opencv_contrib/archive/refs/tags/${OPENCV_VERSION}.tar.gz" | tar xz -C /root/dist && \
    sed -ri 's/Ptr<FarnebackOpticalFlow> cv::cuda::FarnebackOpticalFlow::create/Ptr<cv::cuda::FarnebackOpticalFlow> cv::cuda::FarnebackOpticalFlow::create/' "/root/dist/opencv_contrib-${OPENCV_VERSION}/modules/cudaoptflow/src/farneback.cpp" # patch for version 4.8.0

RUN set -xeu && \
    mkdir -p /root/build && \
    cmake -B /root/build -S "/root/dist/opencv-${OPENCV_VERSION}" -D OPENCV_EXTRA_MODULES_PATH="/root/dist/opencv_contrib-${OPENCV_VERSION}/modules" -D CMAKE_INSTALL_PREFIX=/opt/opencv \
    	-D BUILD_CUDA_STUBS=OFF \
    	-D BUILD_DOCS=OFF \
    	-D BUILD_EXAMPLES=OFF \
    	-D BUILD_IPP_IW=ON \
    	-D BUILD_ITT=OFF \
    	-D BUILD_JASPER=ON \
    	-D BUILD_JAVA=OFF \
    	-D BUILD_JPEG=ON \
    	-D BUILD_OPENEXR=OFF \
    	-D BUILD_PERF_TESTS=OFF \
    	-D BUILD_PNG=ON \
    	-D BUILD_PROTOBUF=ON \
    	-D BUILD_SHARED_LIBS=OFF \
    	-D BUILD_TBB=OFF \
    	-D BUILD_TESTS=OFF \
    	-D BUILD_TIFF=OFF \
    	-D BUILD_WEBP=OFF \
    	-D BUILD_WITH_DYNAMIC_IPP=OFF \
    	-D BUILD_ZLIB=ON \
		-D BUILD_opencv_freetype=OFF \
    	-D BUILD_opencv_apps=OFF \
    	-D BUILD_opencv_python2=OFF \
    	-D BUILD_opencv_python3=OFF \
    	-D CMAKE_BUILD_TYPE=Release \
    	-D ENABLE_CONFIG_VERIFICATION=OFF \
    	-D CV_ENABLE_INTRINSICS=ON \
    	-D ENABLE_PIC=ON \
    	-D INSTALL_CREATE_DISTRIB=OFF \
    	-D INSTALL_PYTHON_EXAMPLES=OFF \
    	-D INSTALL_C_EXAMPLES=OFF \
    	-D INSTALL_TESTS=OFF \
    	-D OPENCV_ENABLE_NONFREE=ON \
    	-D OPENCV_FORCE_3RDPARTY_BUILD=ON \
    	-D OPENCV_GENERATE_PKGCONFIG=OFF \
    	-D PROTOBUF_UPDATE_FILES=OFF \
    	-D WITH_1394=OFF \
    	-D WITH_ADE=ON \
    	-D WITH_ARAVIS=OFF \
    	-D WITH_CLP=OFF \
    	-D WITH_CUBLAS=OFF \
    	-D WITH_CUDA=OFF \
    	-D WITH_CUFFT=OFF \
    	-D WITH_EIGEN=ON \
    	-D WITH_FFMPEG=ON \
		-D WITH_FREETYPE=OFF \
    	-D WITH_GDAL=OFF \
    	-D WITH_GDCM=OFF \
    	-D WITH_GIGEAPI=OFF \
    	-D WITH_GPHOTO2=OFF \
    	-D WITH_GSTREAMER=OFF \
    	-D WITH_GSTREAMER_0_10=OFF \
    	-D WITH_GTK=OFF \
    	-D WITH_GTK_2_X=OFF \
    	-D WITH_HALIDE=OFF \
    	-D WITH_IMGCODEC_HDcR=OFF \
    	-D WITH_IMGCODEC_PXM=OFF \
    	-D WITH_IMGCODEC_SUNRASTER=OFF \
    	-D WITH_INF_ENGINE=OFF \
    	-D WITH_IPP=ON \
    	-D WITH_ITT=OFF \
    	-D WITH_JASPER=ON \
    	-D WITH_JPEG=ON \
    	-D WITH_LAPACK=OFF \
    	-D WITH_LIBV4L=OFF \
    	-D WITH_MATLAB=OFF \
    	-D WITH_MFX=OFF \
    	-D WITH_NVCUVID=OFF \
    	-D WITH_OPENCL=ON \
    	-D WITH_OPENCLAMDBLAS=ON \
    	-D WITH_OPENCLAMDFFT=ON \
    	-D WITH_OPENCL_SVM=ON \
    	-D WITH_OPENEXR=OFF \
    	-D WITH_OPENGL=OFF \
    	-D WITH_OPENMP=OFF \
    	-D WITH_OPENNI2=OFF \
    	-D WITH_OPENNI=OFF \
    	-D WITH_OPENVX=OFF \
    	-D WITH_PNG=ON \
    	-D WITH_PROTOBUF=ON \
    	-D WITH_PTHREADS_PF=ON \
    	-D WITH_PVAPI=OFF \
    	-D WITH_QT=OFF \
    	-D WITH_QUIRC=OFF \
    	-D WITH_TBB=OFF \
    	-D WITH_TIFF=OFF \
    	-D WITH_UNICAP=OFF \
    	-D WITH_V4L=ON \
    	-D WITH_VA=ON \
    	-D WITH_VA_INTEL=ON \
    	-D WITH_VTK=OFF \
    	-D WITH_WEBP=OFF \
    	-D WITH_XIMEA=OFF \
    	-D WITH_XINE=OFF && \
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

ENV OPENCV_LINK_LIBS=opencv_gapi,opencv_highgui,opencv_objdetect,opencv_dnn,opencv_videostab,opencv_calib3d,opencv_features2d,opencv_stitching,opencv_flann,opencv_videoio,opencv_rgbd,opencv_video,opencv_imgcodecs,opencv_imgproc,opencv_core,ade,libavformat,libavcodec,libavutil,libswscale,liblibjpeg-turbo,liblibpng,liblibopenjp2,ippiw,ippicv,liblibprotobuf,zlib
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
