//
//  UnityNativeModule.m
//  RNUnityView
//
//  Created by xzper on 2018/12/13.
//  Copyright © 2018 xzper. All rights reserved.
//

#import "UnityNativeModule.h"

@implementation UnityNativeModule

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(UnityNativeModule);

- (id)init
{
    NSLog(@"UUUUUUUUUUUU In UnityNativeModule.init");
    self = [super init];
    if (self) {
        //NSLog(@"UUUUUUUUUUUU In UnityNativeModule.init, self is true so about to call addUnityEventListener");
        [UnityUtils addUnityEventListener:self];
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"onUnityMessage"];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXPORT_METHOD(isReady:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@([UnityUtils isUnityReady]));
}

RCT_EXPORT_METHOD(createUnity:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"UUUUUUUUUUUU In UnityNativeModule.createUnity");
    [UnityUtils createPlayer:^{
        resolve(@(YES));
    }];
}

RCT_EXPORT_METHOD(postMessage:(NSString *)gameObject methodName:(NSString *)methodName message:(NSString *)message)
{
    NSLog(@"UUUUUUUUUUUU In UnityNativeModule.postMessage");
    UnityPostMessage(gameObject, methodName, message);
}

RCT_EXPORT_METHOD(pause)
{
    UnityPauseCommand();
}

RCT_EXPORT_METHOD(resume)
{
    UnityResumeCommand();
}

- (void)onMessage:(NSString *)message {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [_bridge.eventDispatcher sendDeviceEventWithName:@"onUnityMessage"
                                                body:message];
#pragma clang diagnostic pop
}

@end
