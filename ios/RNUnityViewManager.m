//
//  RNUnityViewManager.m
//  RNUnityView
//
//  Created by xzper on 2018/2/23.
//  Copyright © 2018年 xzper. All rights reserved.
//

#import "RNUnityViewManager.h"
#import "RNUnityView.h"

@implementation RNUnityViewManager

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(UnityView)

- (UIView *)view
{
    NSLog(@"UUUUUUUUUUUU In RNUnityViewManager.view");
    self.currentView = [[RNUnityView alloc] init];
    if ([UnityUtils isUnityReady]) {
        NSLog(@"UUUUUUUUUUUU In RNUnityViewManager.view, unity is ready so about to call setUnityView");
        [self.currentView setUnityView: [GetAppController() unityView]];
    } else {
        NSLog(@"UUUUUUUUUUUU In RNUnityViewManager.view, unity is not ready so about to call createPlayer");
        [UnityUtils createPlayer:^{
            NSLog(@"UUUUUUUUUUUU In RNUnityViewManager.view, in createPlayer callback, about to call setUnityView");
        [self.currentView setUnityView: [GetAppController() unityView]];
        }];
    }
    return self.currentView;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (void)setBridge:(RCTBridge *)bridge {
     NSLog(@"UUUUUUUUUUUU In RNUnityViewManager.setBridge");
   _bridge = bridge;
}

RCT_EXPORT_METHOD(postMessage:(nonnull NSNumber *)reactTag gameObject:(NSString *)gameObject methodName:(NSString *)methodName message:(NSString *)message)
{
     NSLog(@"UUUUUUUUUUUU In RNUnityViewManager.postMessage");
    UnityPostMessage(gameObject, methodName, message);
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag)
{
    UnityPauseCommand();
}

RCT_EXPORT_METHOD(resume:(nonnull NSNumber *)reactTag)
{
    UnityResumeCommand();
}

@end
