# ZEGOCLOUD Live Audio Room

ZEGOCLOUD's Live Audio Room solution is a one-stop solution for building full-featured live audio rooms into your apps, including interactive live audio streaming, instant messaging, room management, and in-room controls.

In live audio rooms, users can host, listen in, and join live audio conversations. Users can also interact with each other via text chat, virtual gifting, "bullet screen" messages, and other features. In a single room, there can be up to 50 speakers at the same time and an unlimited number of listeners.

With ZEGOCLOUD's Live Audio Room, you can build different types of live audio apps, such as online werewolf (a voice-based social deduction game), online karaoke, and more.

## Getting started

Before you begin, contact us to activate the Live Audio Room (RTC + IM) service first, and then do the following:

### Prerequisites

#### Basic requirements

* [Android Studio 2020.3.1 or later\|_blank](https://developer.android.com/studio)
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* Create a project in [ZEGOCLOUD Admin Console\|_blank](https://zegocloud.com/). For details, see [Admin Console - Project management\|_blank](https://docs.zegocloud.com/article/1271).

The platform-specific requirements are as follows:

#### To build an Android app: 

* Android SDK packages: Android SDK 30, Android SDK Platform-Tools 30.x.x or later.
* An Android device or Simulator that is running on Android 4.1 or later and supports audio and video. We recommend you use a real device (Remember to enable **USB debugging** for the device).

#### To build an iOS app:

* [Xcode 7.0 or later\|_blank](https://developer.apple.com/xcode/download)
* [CocoaPods\|_blank](https://guides.cocoapods.org/using/getting-started.html#installation)
* An iOS device or Simulator that is running on iOS 13.0 or later and supports audio and video. We recommend you use a real device.

#### Check the development environment

After all the requirements required in the previous step are met, run the following command to check whether your development environment is ready: 

```
$ flutter doctor
```

![image](docs/images/flutter_doctor.png)
* If the Android development environment is ready, the **Android toolchain** item shows a ready state.
* If the iOS development environment is ready, the **Xcode**  item shows a ready state.

### Modify the project configurations

1. Clone the Live Audio Room Github repository.
2. Open Terminal, navigate to the cloned project repository.
3. Run the configuration script with the `./configure.sh` command. And fill in the AppID, AppSign, and ServerSecret, which can be obtained in the [ZEGO Admin Console\|_blank](https://console.zego.im/).  
**Note**: If you are using Windows system, double-click the `configure.bat` to run the configuration script. 
<img width="700px" src="docs/images/configure_script.png"/>

### Run the sample code

1. Open the Live Audio Room project in Android Studio.
2. Make sure the developer mode and USB debugging are enabled for the Android device, and connect the Android device to your computer.
3. If the **Running Devices** box in the upper area changes to the device name you are using, which means you are ready to run the sample code.  
4. Run the sample code on your device to experience the Live Audio Room service.

## How it work

### Understand the process
The following diagram shows the basic process of creating a live audio room and taking speaker seats to speak:
![image](docs/images/main_process.png)

### UI logic

As shown below, all the UI logic is in the `live_audio_room_flutter/lib/page` directory. And all the room related UI logic is in the `room` directory. 
![image](docs/images/code_to_page.png)

### How to make API calls

The following shows the process of taking a speaker seat with an API call:

1. Call the corresponding method of the service you want to use after making triggering action on the UI. The following is a sample call: 
```js
var seats = context.read<ZegoSpeakerSeatService>();
seats.takeSeat(index);
```
2. The SDK sends a broadcast notification to all users in the room, and the users receive the notification through callback. As shown below: 
```js
ZegoSpeakerSeatService._onRoomSpeakerSeatUpdate(
      String roomID, Map<String, dynamic> speakerSeat)
```
3. After the event callback is triggered, the related callback handling logic you set will be executed.
![image](docs/images/ui_call_sdk.png)

## More documentation
You can find more documentation on our official website: [Live Audio Room (RTC+ IM)](https://doc-en.zego.im/article/13746).
