FROM node:8-jessie

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux \
    IONIC_VERSION=4.8.0 \
    CORDOVA_VERSION=8.0.0 \
    YARN_VERSION=1.10.1 \
    GRADLE_VERSION=4.10.2 \
    # Fix for the issue with Selenium, as described here:
    # https://github.com/SeleniumHQ/docker-selenium/issues/87
    DBUS_SESSION_BUS_ADDRESS=/dev/null

# Install basics
RUN apt-get update &&  \
    apt-get install -y git wget curl unzip build-essential ca-certificates ssl-cert && \
    npm install -g ionic@"$IONIC_VERSION" yarn@"$YARN_VERSION" && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg --unpack google-chrome-stable_current_amd64.deb && \
    apt-get install -y && \
    apt-get clean && \
    rm google-chrome-stable_current_amd64.deb && \
    mkdir Sources && \
    mkdir -p /root/.cache/yarn/ && \
    # Font libraries
    apt-get -qqy install fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable libfreetype6 libfontconfig && \
    # install python-software-properties (so you can do add-apt-repository)
    apt-get update && apt-get install -y -q python-software-properties software-properties-common  && \
    add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update && apt-get -y install oracle-java8-installer && \
    # System libs for android enviroment
    echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y ant wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod  && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # Install Android Tools
    cd /opt \
    && wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm android-sdk-tools.zip && \
    # Install Gradle
    mkdir  /opt/gradle && cd /opt/gradle && \
    wget --output-document=gradle.zip --quiet https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip && \
    unzip -q gradle.zip && \
    rm -f gradle.zip && \
    chown -R root. /opt

# Setup environment
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin

# Install Android SDK
RUN yes Y | ${ANDROID_HOME}/tools/bin/sdkmanager \
    "platforms;android-28" \
    # "platforms;android-27" \
    # "platforms;android-26" \
    # "platforms;android-25" \
    # "platforms;android-24" \
    # "platforms;android-23" \
    # "platforms;android-22" \
    # "platforms;android-21" \
    # "platforms;android-19" \
    # "platforms;android-17" \
    # "platforms;android-15" \
    "build-tools;28.0.3" \
    # "build-tools;28.0.2" \
    # "build-tools;28.0.1" \
    # "build-tools;28.0.0" \
    # "build-tools;27.0.3" \
    # "build-tools;27.0.2" \
    # "build-tools;27.0.1" \
    # "build-tools;27.0.0" \
    # "build-tools;26.0.2" \
    # "build-tools;26.0.1" \
    # "build-tools;25.0.3" \
    # "build-tools;24.0.3" \
    # "build-tools;23.0.3" \
    # "build-tools;22.0.1" \
    # "build-tools;21.1.2" \
    # "build-tools;19.1.0" \
    # "build-tools;17.0.0" \
    "system-images;android-28;google_apis;x86" \
    # "system-images;android-26;google_apis;x86" \
    # "system-images;android-25;google_apis;armeabi-v7a" \
    # "system-images;android-24;default;armeabi-v7a" \
    # "system-images;android-22;default;armeabi-v7a" \
    # "system-images;android-19;default;armeabi-v7a" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    "add-ons;addon-google_apis-google-23" \
    "add-ons;addon-google_apis-google-22" \
    "add-ons;addon-google_apis-google-21" \
    "platform-tools" \
    "emulator" \
    "tools"

RUN cordova telemetry off

WORKDIR /Sources
EXPOSE 8100 35729