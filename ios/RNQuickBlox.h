#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>

@interface RNQuickBlox : RCTEventEmitter <RCTBridgeModule, QBChatDelegate, QBRTCClientDelegate>
    @property (strong, nonatomic, readwrite) QBRTCSession *session;
    @property (nonatomic, copy) QBChatDialog *dialog;

@end
  
