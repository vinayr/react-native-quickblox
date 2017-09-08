import React, { Component } from 'react';
import { AppRegistry, StyleSheet, Text, View, Button, TextInput } from 'react-native';
import QuickBlox from 'react-native-quickblox';

const config = require('./config.json');

export default class QBTest extends Component {
  state = {
    msgSend: '',
    msgRecv: '',
    status: 'LOGGED_OUT',
  }

  async componentDidMount() {
    var appInfo = {
      applicationID: config.applicationID,
      authKey: config.authKey,
      authSecret: config.authSecret,
      accountKey: config.accountKey
    };

    try {
      await QuickBlox.initialize(appInfo);
    } catch(err) {
      throw err;
    }

    QuickBlox.on('chatMessage', (msg) => {
      console.log('QB chat message', msg);
      this.setState({
        msgRecv: this.state.msgRecv+'\n'+msg,
        status: 'RECEIVED_MESSAGE',
      });
    });

    QuickBlox.on('rtcState', (state) => {
      switch (state) {
        case '0': return this.setState({status: 'CALL_NEW'});
        case '1': return this.setState({status: 'CALL_PENDING'});
        case '2': return this.setState({status: 'CALL_CONNECTING'});
        case '3': return this.setState({status: 'CALL_CONNECTED'});
        case '4': return this.setState({status: 'CALL_CLOSED'});
      }
    });
  }

  onLogin = async () => {
    this.setState({status: 'LOGGING_IN'});
    try {
      await QuickBlox.login(config.username, config.password)
      this.setState({status: 'LOGGED_IN'});
    } catch(err) {
      throw err;
    }
  }

  onJoin = async () => {
    this.setState({status: 'JOINING_CHAT'});
    try {
      await QuickBlox.joinChatDialog();
      this.setState({status: 'JOINED_CHAT'});
    } catch(err) {
      throw err;
    }
  }

  onCall = async () => {
    try {
      await QuickBlox.audioCall(config.callUserIDs);
    } catch(err) {
      throw err;
    }
  }

  onSend = async () => {
    this.setState({status: 'SENDING_MESSAGE'});
    try {
      await QuickBlox.sendMessage(this.state.msgSend);
      this.setState({status: 'SENT_MESSAGE'});
    } catch(err) {
      throw err;
    }
  }

  render() {
    return (
      <View style={styles.container}>
        <Text>{this.state.status}</Text>
        <Button title="Login" onPress={this.onLogin}/>
        <Button title="Join" onPress={this.onJoin}/>
        <Button title="Call" onPress={this.onCall}/>
        <TextInput
          style={{width:200,height:40,borderWidth:1}}
          onChangeText={(text) => this.setState({msgSend:text})}
          value={this.state.msgSend}
        />
        <Button title="Send" onPress={this.onSend}/>
        <TextInput
          multiline
          style={{width:200,height:200,borderWidth:1}}
          value={this.state.msgRecv}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 50,
    alignItems: 'center',
  },
});

AppRegistry.registerComponent('QBTest', () => QBTest);
