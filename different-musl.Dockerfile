FROM ubuntu:22.04 AS backend

RUN set -xeu && \
	DEBIAN_FRONTEND=noninteractive apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential curl clang libclang-dev cmake

RUN set -xeu && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile=minimal

ENV PATH="${PATH}:/root/.cargo/bin"

RUN set -xu && \
	curl -sSfL "https://musl.cc/x86_64-linux-musl-cross.tgz" | tar xz -C /root/ && \
	rustup target add x86_64-unknown-linux-musl

RUN set -xeu && \
	cargo new /root/app && \
	echo "opencv = { version = \"0.93.3\", default-features = false }" >> /root/app/Cargo.toml && \
	echo "use opencv::prelude::*; use opencv::core; fn main() {}" > /root/app/src/main.rs

ARG OPENCV_VERSION=4.8.0

RUN set -xeu && \
    mkdir -p /root/dist && \
    curl -sSfL "https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.tar.gz" | tar xz -C /root/dist

ENV CC=/root/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc
ENV CXX=/root/x86_64-linux-musl-cross/bin/x86_64-linux-musl-g++

# Most minimal build possible, can't find way to stop zlib from being built though. Tried ENABLE_PIC=OFF and =ON but no luck.
RUN set -xeu && \
    mkdir -p /root/build && \
	cmake -D CMAKE_SHARED_LINKER_FLAGS="-static -static-libgcc -static-libstdc++" -B /root/build -S "/root/dist/opencv-${OPENCV_VERSION}" -D CMAKE_INSTALL_PREFIX=/opt/opencv \
    	-D BUILD_CUDA_STUBS=OFF \
    	-D BUILD_DOCS=OFF \
    	-D BUILD_EXAMPLES=OFF \
    	-D BUILD_IPP_IW=OFF \
    	-D BUILD_ITT=OFF \
    	-D BUILD_JASPER=OFF \
    	-D BUILD_JAVA=OFF \
    	-D BUILD_JPEG=OFF \
    	-D BUILD_OPENEXR=OFF \
    	-D BUILD_PERF_TESTS=OFF \
    	-D BUILD_PNG=OFF \
    	-D BUILD_PROTOBUF=OFF \
    	-D BUILD_SHARED_LIBS=OFF \
    	-D BUILD_TBB=OFF \
    	-D BUILD_TESTS=OFF \
    	-D BUILD_TIFF=OFF \
    	-D BUILD_WEBP=OFF \
    	-D BUILD_WITH_DYNAMIC_IPP=OFF \
    	-D BUILD_ZLIB=OFF \
		-D PARALLEL_ENABLE_PLUGINS=OFF \
		-D OPJ_USE_THREAD=OFF \
		-D BUILD_opencv_alphamat=OFF \
		-D BUILD_opencv_aruco=OFF \
		-D BUILD_opencv_bgsegm=OFF \
		-D BUILD_opencv_bioinspired=OFF \
		-D BUILD_opencv_calib3d=OFF \
		-D BUILD_opencv_ccalib=OFF \
		-D BUILD_opencv_core=ON \
		-D BUILD_opencv_datasets=OFF \
		-D BUILD_opencv_dnn=OFF \
		-D BUILD_opencv_dnn_objdetect=OFF \
		-D BUILD_opencv_dnn_superres=OFF \
		-D BUILD_opencv_dpm=OFF \
		-D BUILD_opencv_face=OFF \
		-D BUILD_opencv_features2d=OFF \
		-D BUILD_opencv_flann=OFF \
		-D BUILD_opencv_fuzzy=OFF \
		-D BUILD_opencv_gapi=OFF \
		-D BUILD_opencv_hfs=OFF \
		-D BUILD_opencv_highgui=OFF \
		-D BUILD_opencv_img_hash=OFF \
		-D BUILD_opencv_imgcodecs=OFF \
		-D BUILD_opencv_imgproc=OFF \
		-D BUILD_opencv_intensity_transform=OFF \
		-D BUILD_opencv_java_bindings_generator=OFF \
		-D BUILD_opencv_js_bindings_generator=OFF \
		-D BUILD_opencv_line_descriptor=OFF \
		-D BUILD_opencv_mcc=OFF \
		-D BUILD_opencv_ml=OFF \
		-D BUILD_opencv_objc_bindings_generator=OFF \
		-D BUILD_opencv_objdetect=OFF \
		-D BUILD_opencv_optflow=OFF \
		-D BUILD_opencv_phase_unwrapping=OFF \
		-D BUILD_opencv_photo=OFF \
		-D BUILD_opencv_plot=OFF \
		-D BUILD_opencv_python_bindings_generator=OFF \
		-D BUILD_opencv_python_tests=OFF \
		-D BUILD_opencv_quality=OFF \
		-D BUILD_opencv_rapid=OFF \
		-D BUILD_opencv_reg=OFF \
		-D BUILD_opencv_rgbd=OFF \
		-D BUILD_opencv_saliency=OFF \
		-D BUILD_opencv_sfm=OFF \
		-D BUILD_opencv_shape=OFF \
		-D BUILD_opencv_stereo=OFF \
		-D BUILD_opencv_stitching=OFF \
		-D BUILD_opencv_structured_light=OFF \
		-D BUILD_opencv_superres=OFF \
		-D BUILD_opencv_surface_matching=OFF \
		-D BUILD_opencv_text=OFF \
		-D BUILD_opencv_tracking=OFF \
		-D BUILD_opencv_video=OFF \
		-D BUILD_opencv_videoio=OFF \
		-D BUILD_opencv_videostab=OFF \
		-D BUILD_opencv_wechat_qrcode=OFF \
		-D BUILD_opencv_xfeatures2d=OFF \
		-D BUILD_opencv_ximgproc=OFF \
		-D BUILD_opencv_xobjdetect=OFF \
		-D BUILD_opencv_xphoto=OFF \
		-D BUILD_opencv_freetype=OFF \
    	-D BUILD_opencv_apps=OFF \
    	-D BUILD_opencv_python2=OFF \
    	-D BUILD_opencv_python3=OFF \
    	-D CMAKE_BUILD_TYPE=Release \
    	-D ENABLE_CONFIG_VERIFICATION=OFF \
    	-D CV_ENABLE_INTRINSICS=ON \
    	-D ENABLE_PIC=OFF \
    	-D INSTALL_CREATE_DISTRIB=OFF \
    	-D INSTALL_PYTHON_EXAMPLES=OFF \
    	-D INSTALL_C_EXAMPLES=OFF \
    	-D INSTALL_TESTS=OFF \
    	-D OPENCV_ENABLE_NONFREE=OFF \
    	-D OPENCV_FORCE_3RDPARTY_BUILD=OFF \
    	-D OPENCV_GENERATE_PKGCONFIG=OFF \
    	-D PROTOBUF_UPDATE_FILES=OFF \
		-D OPENCV_DNN_OPENCL=OFF \
		-D OPENCV_DNN_TFLITE=OFF \
		-D OPENCV_TEST_DNN_TFLITE=OFF \
    	-D WITH_1394=OFF \
    	-D WITH_ADE=OFF \
    	-D WITH_ARAVIS=OFF \
    	-D WITH_CLP=OFF \
    	-D WITH_CUBLAS=OFF \
    	-D WITH_CUDA=OFF \
    	-D WITH_CUFFT=OFF \
    	-D WITH_EIGEN=OFF \
    	-D WITH_FFMPEG=OFF \
		-D WITH_FLATBUFFERS=OFF \
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
		-D WITH_IMGCODEC_HDR=OFF \
    	-D WITH_IMGCODEC_PXM=OFF \
		-D WITH_IMGCODEC_PFM=OFF \
    	-D WITH_IMGCODEC_SUNRASTER=OFF \
    	-D WITH_INF_ENGINE=OFF \
    	-D WITH_IPP=OFF \
    	-D WITH_ITT=OFF \
    	-D WITH_JASPER=OFF \
    	-D WITH_JPEG=OFF \
    	-D WITH_LAPACK=OFF \
    	-D WITH_LIBV4L=OFF \
    	-D WITH_MATLAB=OFF \
    	-D WITH_MFX=OFF \
    	-D WITH_NVCUVID=OFF \
    	-D WITH_OPENCL=OFF \
    	-D WITH_OPENCLAMDBLAS=OFF \
    	-D WITH_OPENCLAMDFFT=OFF \
    	-D WITH_OPENCL_SVM=OFF \
    	-D WITH_OPENEXR=OFF \
    	-D WITH_OPENGL=OFF \
    	-D WITH_OPENMP=OFF \
    	-D WITH_OPENNI2=OFF \
    	-D WITH_OPENNI=OFF \
    	-D WITH_OPENVX=OFF \
		-D WITH_OBSENSOR=OFF \
		-D WITH_OPENJPEG=OFF \
    	-D WITH_PNG=OFF \
    	-D WITH_PROTOBUF=OFF \
    	-D WITH_PTHREADS_PF=OFF \
    	-D WITH_PVAPI=OFF \
		-D WITH_TESSERACT=OFF \
    	-D WITH_QT=OFF \
    	-D WITH_QUIRC=OFF \
    	-D WITH_TBB=OFF \
    	-D WITH_TIFF=OFF \
		-D WITH_ZLIB=OFF \
    	-D WITH_UNICAP=OFF \
    	-D WITH_V4L=OFF \
    	-D WITH_VA=OFF \
    	-D WITH_VA_INTEL=OFF \
    	-D WITH_VTK=OFF \
    	-D WITH_WEBP=OFF \
    	-D WITH_XIMEA=OFF \
    	-D WITH_XINE=OFF && \
    make -C /root/build -j`nproc` install

ENV HOST_TRIPLE=x86_64-unknown-linux-gnu
ENV OPENCV_LINK_LIBS=opencv_core
ENV OPENCV_LINK_PATHS=/opt/opencv/lib,/root/x86_64-linux-musl-cross/x86_64-linux-musl/lib/,/root/x86_64-linux-musl-cross/lib/gcc/x86_64-linux-musl/11.2.1,/usr/lib/x86_64-linux-musl
ENV OPENCV_INCLUDE_PATHS=/opt/opencv/include,/opt/opencv/include/opencv4,/root/x86_64-linux-musl-cross/lib/gcc/x86_64-linux-musl/11.2.1/include,/root/x86_64-linux-musl-cross/x86_64-linux-musl/include,/usr/include/x86_64-linux-musl

RUN set -xu && \
	cd /root/app && \
	RUSTFLAGS="-C linker=/root/x86_64-linux-musl-cross/bin/x86_64-linux-musl-ld -C link-args=-lstdc++" cargo build --release --target=x86_64-unknown-linux-musl

RUN set -xu && \
	cd /root/app && \
	ldd target/x86_64-unknown-linux-musl/release/app
