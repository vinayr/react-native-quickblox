#import "RNQuickBlox.h"

@implementation RNQuickBlox

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"chatMessage", @"rtcState"];
}


RCT_EXPORT_METHOD(initialize:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [[QBChat instance] removeAllDelegates];
    [[QBChat instance] addDelegate: self];
    
    [[QBRTCClient instance] removeDelegate:self];
    [[QBRTCClient instance] addDelegate:self];
    [QBRTCClient initializeRTC];
    
    [QBSettings setApplicationID:[[data valueForKey:@"applicationID"] unsignedIntegerValue]];
    [QBSettings setAuthKey:[data valueForKey:@"authKey"]];
    [QBSettings setAuthSecret:[data valueForKey:@"authSecret"]];
    [QBSettings setAccountKey:[data valueForKey:@"accountKey"]];
    [QBSettings setLogLevel:(QBLogLevel)QBLogLevelNothing]; //QBLogLevelDebug,QBLogLevelNothing
    //[QBSettings enableXMPPLogging];
    
    resolve(@"");
}

RCT_EXPORT_METHOD(login:(NSString *)username
                  password:(NSString *)password
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [QBRequest logInWithUserLogin:username password:password successBlock:^(QBResponse *response, QBUUser *user) {
        // Connect to chat
        [[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
            if (error) {
                //reject([NSString stringWithFormat:@"%@", error], nil, nil);
            }
            resolve(@"");
        }];
    } errorBlock:^(QBResponse *response) {
        reject([NSString stringWithFormat:@"%@", response.error], nil, nil);
    }];
}

// Join group chat dialog
RCT_EXPORT_METHOD(joinChatDialog:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSMutableDictionary *extendedRequest = [NSMutableDictionary dictionary];
    extendedRequest[@"type"] = @"2"; // group chat
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:1 skip:0];
    
    [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        QBChatDialog *chatDialog = [dialogObjects firstObject];
        
        if (!chatDialog) {
            reject(@"no dialog found", nil, nil);
        }
        
        [chatDialog joinWithCompletionBlock:^(NSError * _Nullable error) {
            if (error) {
                reject([NSString stringWithFormat:@"%@", error], nil, nil);
            } else {
                self.dialog = chatDialog;
                resolve(@"");
            }
        }];
    } errorBlock:^(QBResponse *response) {
        reject([NSString stringWithFormat:@"%@", response.error], nil, nil);
    }];
}

RCT_EXPORT_METHOD(sendMessage:(NSString *)msg
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    QBChatMessage *message = [QBChatMessage message];
    [message setText:msg];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    
    [self.dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
        if (error) {
            reject([NSString stringWithFormat:@"%@", error], nil, nil);
        } else {
            resolve(@"");
        }
    }];
}

RCT_EXPORT_METHOD(makeCall:(NSArray *)userIDs
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    self.session = [[QBRTCClient instance] createNewSessionWithOpponents:userIDs
                                                      withConferenceType:QBRTCConferenceTypeAudio];
    [self.session startCall:nil];
    resolve(@"");
}

RCT_EXPORT_METHOD(acceptCall:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.session acceptCall:nil];
    resolve(@"");
}

RCT_EXPORT_METHOD(rejectCall:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.session rejectCall:nil];
    self.session = nil;
    resolve(@"");
}

RCT_EXPORT_METHOD(hangUpCall:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.session hangUp:nil];
    self.session = nil;
    resolve(@"");
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID {
    if (message.senderID == message.recipientID) return;
    //RCTLogInfo(@"MESSAGE RECEIVED: %@", message);
    [self sendEventWithName:@"chatMessage" body:message.text];
}

- (void)session:(QBRTCSession *)session didChangeState:(QBRTCSessionState)state {
    NSString *sessionState;

    switch (state) {
        case QBRTCSessionStateNew:
            sessionState = @"CALL_NEW";
            break;
        case QBRTCSessionStatePending:
            sessionState = @"CALL_PENDING";
            break;
        case QBRTCSessionStateConnecting:
            sessionState = @"CALL_CONNECTING";
            break;
        case QBRTCSessionStateConnected:
            sessionState = @"CALL_CONNECTED";
            break;
        case QBRTCSessionStateClosed:
            sessionState = @"CALL_CLOSED";
            self.session = nil;
            break;
        default:
            break;
    }

    //RCTLogInfo(@"Session did change state to %@", sessionState);
    [self sendEventWithName:@"rtcState" body:sessionState];
}

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
    //RCTLogInfo(@"didReceiveNewSession");
    if (self.session) {
        // we already have a video/audio call session, so we reject another one
        [session rejectCall:nil];
        return;
    }
    self.session = session;
}

- (void)dealloc {
    [QBChat.instance removeDelegate:self];
    [[QBRTCClient instance] removeDelegate:self];
}

@end
