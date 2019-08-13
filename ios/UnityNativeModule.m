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
        NSLog(@"UUUUUUUUUUUU In UnityNativeModule.init, self is true so about to call addUnityEventListener");
        [UnityUtils addUnityEventListener:self];
        NSLog(@"UUUUUUUUUUUU In UnityNativeModule.init, self is true, called addUnityEventListener");
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
        NSLog(@"UUUUUUUUUUUU In UnityNativeModule.supportedEvents");
    return @[@"onUnityMessage"];
}

+ (BOOL)requiresMainQueueSetup
{
        NSLog(@"UUUUUUUUUUUU In UnityNativeModule.requiresMainQueueSetup");
    return YES;
}

RCT_EXPORT_METHOD(isReady:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
        NSLog(@"UUUUUUUUUUUU In UnityNativeModule.isReady");
    resolve(@([UnityUtils isUnityReady]));
}

RCT_EXPORT_METHOD(createUnity:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"UUUUUUUUUUUU In UnityNativeModule.createUnity, about to call createPlayer");
    [UnityUtils createPlayer:^{
     NSLog(@"UUUUUUUUUUUU In UnityNativeModule.createUnity, in createPlayer callback, about to call resolve");
       resolve(@(YES));
    }];
}

RCT_EXPORT_METHOD(postMessage:(NSString *)gameObject methodName:(NSString *)methodName message:(NSString *)message)
{
    NSLog(@"UUUUUUUUUUUU In UnityNativeModule.postMessage about to call UnityPostMessage");
    UnityPostMessage(gameObject, methodName, message);
    NSLog(@"UUUUUUUUUUUU In UnityNativeModule.postMessage, called UnityPostMessage");
}

RCT_EXPORT_METHOD(pause)
{
    NSLog(@"UUUUUUUUUUUU In UnityNativeModule.pause");
    UnityPauseCommand();
}

RCT_EXPORT_METHOD(resume)
{
     NSLog(@"UUUUUUUUUUUU In UnityNativeModule.resume");
   UnityResumeCommand();
}

- (void)onMessage:(NSString *)message {
     NSLog(@"UUUUUUUUUUUU In UnityNativeModule.onMessage %@", message);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [_bridge.eventDispatcher sendDeviceEventWithName:@"onUnityMessage"
                                                body:message];
#pragma clang diagnostic pop
}

@end
