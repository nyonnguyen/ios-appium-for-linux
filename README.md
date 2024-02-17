
# ios-appium-for-linux

***Notes***: The scripts are not completely worked as expect. I'm updating...

  

Step by step is noted here https://gist.github.com/nyonnguyen/4863da7d9fb46a18854220c81ebe51a5

  <br>

## Appium With real iOS devices on Linux (without MacOS)

  

### Introduction

Appium with iOS devices only support for MacOS but with the power of go-ios (https://github.com/danielpaulus/go-ios) tools, we now can make a Linux node as Appium server for iOS automation without MacOS machine.

### How to setup
 

#### 1. Install WebDriverAgent (WDA) to target iOS device by Xcode

Open the `WebDriverAgent.xcodeproj` by Xcode.

The `WebDriverAgent` is located at `"$HOME/.appium/node_modules/appium-xcuitest-driver/node_modules/appium-webdriveragent"` after the appium driver XCUTest installed

<br>Follow this guide for full steps at https://github.com/appium/appium-xcuitest-driver/blob/master/docs/real-device-config.md.

 
Or in short, on the **Xcode**, select target **WebDriverAgent > TARGETS**  `WebDriverAgentRunner`<br>

On **Build Settings** tab, change the **Product Bundle Indentifier** to `"com.xxx.WebDriverAgentRunner"` as you want.<br>

*Example*: `com.nyon.WebDriverAgentRunner`

On **Info** tab, change the *Bundle name* to `com.xxx.WebDriverAgentRunner`.

On **Signing & Capabilities** tab, check on *Automatically manage signing*

Make sure the *Bundle Indentifier* field is `com.xxx.WebDriverAgentRunner`

At **Team**, select your account OR add new

- If you select **Add an Account**, start by login AppID, then click on **Manage Certificate** then if you don't have any certificate, try to click **+** to add one.

- Back to the **Signing** tab, at **Team**, select your account you've just added

- At the iOS section below, you should see no error/warning and the Provisioning Profile and Signing Certificate should be valid.

Plug your iOS device that you want to install WDA to the MAC. You should be asked to TRUST the MAC on your phone after connected.

Then select **Product > Test**, the Xcode will build the project then install it into your iOS device. You will se a popup saying that the WDA app on your iOS is not Trust.

On your iOS device, open **Settings > General > Device Management**. Under the Developer App, tap on Developer name then Trust the App.

***Notes***: Your iOS device should enable Developer Mode (Settings > Privacy & Security)

You will see the WDA app is installed on your iOS.
<br>
  
#### 2. Install usbmuxd (an USB daemon for iOS communication via USB)

```apt install usbmuxd```



#### 3. Build the go-ios tool

You will need to build the ***go-ios*** binary to adapt with your WebDriverAgent at ***step 1*** above. The default bundleId that go-ios tool is using with its runWdaCommand is `com.facebook.WebDriverAgentRunner` while you've just built the WDA with bundleId `com.xxx.WebDriverAgentRunner`. So, additionally, we need to make a small change to fit our setup.

- On a Linux node (mine is Ubuntu), get the source code from: https://github.com/danielpaulus/go-ios

- Find and edit `com.facebook.WebDriverAgentRunner.xctrunner` in the file `go-ios/main.go` to your bundleId in ***step 1***

	Mine is `com.nyon.WebDriverAgentRunner.xctrunner`

- At the directory go-ios, run `go build`

***Notes***: Run `sudo apt install golang-1.17` if you don't have golang on your Ubuntu

- You will have an binary `go-ios`.

  

#### 4. Build an appium docker with go-ios

Refer to the original document at https://github.com/danielpaulus/ios-appium-on-linux

Below is my modification:

  

- ***Dockerfile***:
```
FROM ubuntu:latest

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

COPY go-ios ios

ENTRYPOINT ["/startAppium.sh"]
```
  

- ***Create file startWDA.sh***
```
#!/bin/bash

CONTAINER_ID=$( docker ps | grep ios-appium-on-linux | awk '{print $1}' &)

docker exec $CONTAINER_ID /ios runwda
```
  

- ***Build the docker***

```docker build -t ios-appium```

  <br>

## How to run

  

After the setup, you are having:

- WDA installed on your iOS device

- Docker image on the Linux node: `appium-ios`

Now, step by step to start:

  

### 1. Run the USB multiplexing daemon

```sudo usbmuxd&```

### 2. Plug the iOS device into the Linux node by USB cable

### 3. Start the docker

```
docker run -p 4321:4723 -v /var/run/usbmuxd:/var/run/usbmuxd -v /var/lib/lockdown:/var/lib/lockdown ios-appium
```
where: ***4321*** is the exposed port for the default appium 4723 (feel free to change)

### 4. Start the WDA

```./startWDA.sh```

### 5. Use Appium Inspector to examine the result:

Set this Capabilities for appium
```
{

"appium:platformName": "ios",

"appium:automationName": "xcuitest",

"appium:platformVersion": "13",

"appium:deviceName": "Nyon's iPhone",

"appium:udid": "auto",

"appium:usePrebuiltWDA": true,

"appium:startIWDP": true,

"appium:webDriverAgentUrl": "http://localhost:7777"

}
```
***Remote Host***: the IP address of the Linux node

***Remote Port***: `4321`

***Remote Path***: ""

  

## Good Luck!!!

  
 ### Installation

1. Run the setup.sh script to build go-ios and dockerfile

2. Run the run.sh script to start

## References

[https://github.com/danielpaulus/go-ios](https://github.com/danielpaulus/go-ios)
<br>
[https://github.com/danielpaulus/ios-appium-on-linux](https://github.com/danielpaulus/ios-appium-on-linux)