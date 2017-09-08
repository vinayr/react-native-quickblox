# react-native-quickblox  

## Install  
- `yarn add https://github.com/vinayr/react-native-quickblox`  
- `react-native link react-native-quickblox`
- `cd <yourApp>/ios/`
- `pod init`
- add pods to `Podfile`  
```
  pod 'QuickBlox'  
  pod 'Quickblox-WebRTC'
```
- `pod install`

Note - make sure latest version of QuickBlox is installed. If not -
```
  pod update QuickBlox
  pod update Quickblox-WebRTC
```
- `open <yourApp>/ios/<yourApp>.xcworkspace`
- Go to project's `Build Settings`->`Framework Search Paths` and add -
```
  $(PROJECT_DIR)/Pods/QuickBlox
  $(PROJECT_DIR)/Pods/Quickblox-WebRTC
```
- Add `NSMicrophoneUsageDescription` in `Info.plist`

## Usage  
```js
import QuickBlox from 'react-native-quickblox';
```
```js
var appInfo = {
  applicationID: <applicationID>,
  authKey: <authKey>,
  authSecret: <authSecret>,
  accountKey: <accountKey>
};
QuickBlox.initialize(appInfo);
```
```js
QuickBlox.login(username, password);
```
```js
QuickBlox.joinChatDialog();
```
```js
var callUserIDs = [123];
QuickBlox.audioCall(callUserIDs);
```
```js
QuickBlox.sendMessage("Hi");
```

### Events
- `chatMessage` - chat message received
```js
QuickBlox.on('chatMessage', (msg) => {
  console.log('QB chat message', msg);
});
```
- `rtcState` - RTC state changed
```js
QuickBlox.on('rtcState', (state) => {
  //'0'-CALL_NEW, '1'-CALL_PENDING, '2'-CALL_CONNECTING
  //'3'-CALL_CONNECTED, '4'-CALL_CLOSED
});
```

References -  
https://quickblox.com/developers/IOS  
https://github.com/QuickBlox/quickblox-ios-sdk  
https://github.com/QuickBlox/q-municate-ios  
https://github.com/githubandrewd/react-native-quickblox  
