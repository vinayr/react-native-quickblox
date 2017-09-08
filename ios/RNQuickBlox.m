#import "RNQuickBlox.h"

@implementation RNQuickBlox {
    @private
    QBChatDialog * dialog;
}

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
                dialog = chatDialog;
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
    
    [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
        if (error) {
            reject([NSString stringWithFormat:@"%@", error], nil, nil);
        } else {
            resolve(@"");
        }
    }];
}

RCT_EXPORT_METHOD(audioCall:(NSArray *)userIDs
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSArray *opponentsIDs = userIDs;
    QBRTCSession *newSession = [[QBRTCClient instance] createNewSessionWithOpponents:opponentsIDs
                                                                  withConferenceType:QBRTCConferenceTypeAudio];
    NSDictionary *userInfo = @{ @"key" : @"value" };
    [newSession startCall:userInfo];
    
    resolve(@"");
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID {
    if (message.senderID == message.recipientID) return;
    //RCTLogInfo(@"MESSAGE RECEIVED: %@", message);
    [self sendEventWithName:@"chatMessage" body:message.text];
}

- (void)session:(QBRTCSession *)session didChangeState:(QBRTCSessionState)state {
    //RCTLogInfo(@"Session did change state to %tu", state);
    [self sendEventWithName:@"rtcState" body:[NSString stringWithFormat:@"%tu",state]];
}

- (void)dealloc {
    [QBChat.instance removeDelegate:self];
    [[QBRTCClient instance] removeDelegate:self];
}

@end
