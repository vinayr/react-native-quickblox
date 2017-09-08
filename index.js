import { NativeModules, NativeEventEmitter } from 'react-native';
const { RNQuickBlox } = NativeModules;
const EventEmitter = new NativeEventEmitter(RNQuickBlox);

const QuickBlox = {};

QuickBlox.initialize = data => RNQuickBlox.initialize(data);
QuickBlox.login = (username, password) => RNQuickBlox.login(username, password);
QuickBlox.joinChatDialog = () => RNQuickBlox.joinChatDialog();
QuickBlox.sendMessage = msg => RNQuickBlox.sendMessage(msg);
QuickBlox.audioCall = userIDs => RNQuickBlox.audioCall(userIDs);

const eventsMap = {
  data: 'data',
  chatMessage: 'chatMessage',
  rtcState: 'rtcState',
};

QuickBlox.on = (event, callback) => {
  const nativeEvent = eventsMap[event];
  if (!nativeEvent) {
    throw new Error('Invalid event');
  }
  EventEmitter.removeAllListeners(nativeEvent);
  return EventEmitter.addListener(nativeEvent, callback);
}

module.exports = QuickBlox;
