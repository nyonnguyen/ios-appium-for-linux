FROM ubuntu:latest

# setup libimobiledevice, usbmuxd, and some tools
RUN apt-get update && apt-get -y install unzip wget curl libimobiledevice-utils libimobiledevice6 usbmuxd

# set up nvm and appium
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" \
    && nvm install 20 \
    && npm install -g appium \
    && appium driver install xcuitest \
    # Detect the installed Node.js version and use it in the later command
    && NODE_VERSION=$(nvm current) \
    && echo '#!/bin/bash' > /startAppium.sh \
    # Expose port 7777 and forward to 8100 on iOS device
    && echo '/ios forward 7777 8100&' >> /startAppium.sh \
    && echo 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /startAppium.sh \
    && echo "/root/.nvm/versions/node/$NODE_VERSION/bin/appium" >> /startAppium.sh \
    && chmod +x /startAppium.sh
# Copy the go-ios tool for Linux from step 2 to the docker
COPY ios-linux ios
ENTRYPOINT ["/startAppium.sh"]