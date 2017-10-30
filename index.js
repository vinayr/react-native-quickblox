import { NativeModules, NativeEventEmitter } from 'react-native';
const { RNQuickBlox } = NativeModules;
const EventEmitter = new NativeEventEmitter(RNQuickBlox);

const QuickBlox = {};

QuickBlox.initialize = data => RNQuickBlox.initialize(data);
QuickBlox.login = (username, password) => RNQuickBlox.login(username, password);
QuickBlox.joinChatDialog = () => RNQuickBlox.joinChatDialog();
QuickBlox.sendMessage = (msg, params) => RNQuickBlox.sendMessage(msg, params);
QuickBlox.getMessages = filters => RNQuickBlox.getMessages(filters);
QuickBlox.startCall = userIDs => RNQuickBlox.startCall(userIDs);
QuickBlox.hangUpCall = userIDs => RNQuickBlox.hangUpCall();
QuickBlox.acceptCall = userIDs => RNQuickBlox.acceptCall();
QuickBlox.rejectCall = userIDs => RNQuickBlox.rejectCall();

const eventsMap = {
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
