FROM ubuntu:20.04
LABEL Description="Android docker image for Nawb"

RUN apt update  && apt install  -y --no-install-recommends \
    git \
    openjdk-11-jdk-headless \
    python-setuptools \
    python3-setuptools

ENV DEBIAN_FRONTEND=noninteractive

ARG SDK_TOOLS_PACKAGE=commandlinetools-linux-7583922_latest.zip
ARG ANDROID_BUILD_VERSION=30
ARG ANDROID_TOOLS_VERSION=30.0.2
ARG NDK_VERSION=21.4.7075529
ARG NODE_VERSION=16.x
ARG WATCHMAN_VERSION=4.9.0

ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=~/Android/Sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

ENV PATH=${ANDROID_NDK}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:/opt/buck/bin/:${PATH}

RUN apt update -qq && apt install -qq -y --no-install-recommends \
        apt-transport-https \
        curl \
        file \
        gcc \
        git \
        g++ \
        gnupg2 \
        libc++1-10 \
        libgl1 \
        libtcmalloc-minimal4 \
        make \
        openjdk-11-jdk-headless \
        openssh-client \
        patch \
        python3 \
        python3-distutils \
        rsync \
        ruby \
        ruby-dev \
        tzdata \
        unzip \
        sudo \
        ninja-build \
        zip \
        # Emulator & video bridge dependencies
        libc6 \
        libdbus-1-3 \
        libfontconfig1 \
        libgcc1 \
        libpulse0 \
        libtinfo5 \
        libx11-6 \
        libxcb1 \
        libxdamage1 \
        libnss3 \
        libxcomposite1 \
        libxcursor1 \
        libxi6 \
        libxext6 \
        libxfixes3 \
        zlib1g \
        libgl1 \
        pulseaudio \
        socat \
    && gem install bundler \
    && rm -rf /var/lib/apt/lists/*;

# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends nodejs \
    && npm i -g yarn@latest \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://dl.google.com/android/repository/${SDK_TOOLS_PACKAGE} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "cmake;3.18.1" \
        "system-images;android-21;google_apis;armeabi-v7a" \
        "ndk;$NDK_VERSION" \
    && rm -rf ${ANDROID_HOME}/.android \
    && ln -s ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.9 ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.8