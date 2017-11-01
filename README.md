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
- Go to project's `Build Settings`->`Framework Search Paths` and add (if not already added) -
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
let appInfo = {
  applicationID: <applicationID>,
  authKey: <authKey>,
  authSecret: <authSecret>,
  accountKey: <accountKey>,
  apiEndPoint: <apiEndPoint>,
  chatEndPoint: <chatEndPoint>
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
let msg = "Hi";
let params = {
  save_to_history: 1,
  customParam: 123,
};
QuickBlox.sendMessage(msg, params);
```
```js
let filters = {
  'limit': 10,
  'skip': 10,
  'message[ne]': null,
  'sort_desc': 'date_sent',
};
QuickBlox.getMessages(filters);
```
```js
let callUserIDs = [123];
QuickBlox.startCall(callUserIDs);
QuickBlox.hangUpCall();
QuickBlox.acceptCall();
QuickBlox.rejectCall();
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
  //'CALL_NEW', 'CALL_PENDING', 'CALL_CONNECTING'
  //'CALL_CONNECTED', 'CALL_CLOSED'
});
- `disconnected` - disconnected from chat
- `reconnected` - reconnected to chat
```

Note - Don't forget to add `ios/Pods/` to `.gitignore`

Versions tested with -  
RN - 0.47.2  
QuickBlox - 2.11  
Quickblox-WebRTC - 2.6.1

References -  
https://quickblox.com/developers/IOS  
https://github.com/QuickBlox/quickblox-ios-sdk  
https://github.com/QuickBlox/q-municate-ios  
https://github.com/githubandrewd/react-native-quickblox  
