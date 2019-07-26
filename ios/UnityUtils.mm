#include "RegisterMonoModules.h"
#include "RegisterFeatures.h"
#include <csignal>
#import <UIKit/UIKit.h>
#import "UnityInterface.h"
#import "UnityUtils.h"
#import "UnityAppController.h"

// Hack to work around iOS SDK 4.3 linker problem
// we need at least one __TEXT, __const section entry in main application .o files
// to get this section emitted at right time and so avoid LC_ENCRYPTION_INFO size miscalculation
static const int constsection = 0;

bool unity_inited = false;

int g_argc;
char** g_argv;

void UnityInitTrampoline();

extern "C" void InitArgs(int argc, char* argv[])
{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.InitArgs");
    g_argc = argc;
    g_argv = argv;
}

extern "C" bool UnityIsInited()
{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.UnityIsInited");
    return unity_inited;
}

extern "C" void InitUnity()
{
    NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity");
    if (unity_inited) {
     NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity, unity is inited so returning");
       return;
    }
    unity_inited = true;

     NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity, about to call UnityInitStartupTime");
    UnityInitStartupTime();

     NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity, about to call autoreleasepool block");
    @autoreleasepool
    {
     NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity, about to call UnityInitTrampoline");
        UnityInitTrampoline();
     NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity, about to call UnityInitRuntime");
        UnityInitRuntime(g_argc, g_argv);

      NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity, about to call RegisterMonoModules");
       RegisterMonoModules();
        NSLog(@"-> registered mono modules %p\n", &constsection);
      NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity, about to call RegisterFeatures");
        RegisterFeatures();

        // iOS terminates open sockets when an application enters background mode.
        // The next write to any of such socket causes SIGPIPE signal being raised,
        // even if the request has been done from scripting side. This disables the
        // signal and allows Mono to throw a proper C# exception.
      NSLog(@"UUUUUUUUUUUU In UnityUtils.InitUnity, about send SIGPIPE signal");
        std::signal(SIGPIPE, SIG_IGN);
    }
}

extern "C" void UnityPostMessage(NSString* gameObject, NSString* methodName, NSString* message)
{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.UnityPostMessage, about to call UnitySendMessage");
    UnitySendMessage([gameObject UTF8String], [methodName UTF8String], [message UTF8String]);
}

extern "C" void UnityPauseCommand()
{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.UnityPauseCommand, about to call asynchronously");
    dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.UnityPauseCommand, in async callback, about to call UnityPause");
        UnityPause(1);
    });
}

extern "C" void UnityResumeCommand()
{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.UnityResumeCommand, about to call asynchronously");
    dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.UnityResumeCommand, in async callback, about to call UnityResume");
        UnityPause(0);
    });
}

@implementation UnityUtils

static NSHashTable* mUnityEventListeners = [NSHashTable weakObjectsHashTable];
static BOOL _isUnityReady = NO;

+ (BOOL)isUnityReady
{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.isUnityReady");
    return _isUnityReady;
}

+ (void)handleAppStateDidChange:(NSNotification *)notification
{
    NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange");
    if (!_isUnityReady) {
     NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, unity is not ready so returning");
       return;
    }
     NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, unity is ready and about to call GetAppController");
    UnityAppController* unityAppController = GetAppController();

     NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, unity is ready and about to call sharedApplication");
    UIApplication* application = [UIApplication sharedApplication];

    if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
     NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, notification is UIApplicationWillResignActiveNotification");
        [unityAppController applicationWillResignActive:application];
    } else if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
      NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, notification is UIApplicationDidEnterBackgroundNotification");
       [unityAppController applicationDidEnterBackground:application];
    } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
      NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, notification is UIApplicationWillEnterForegroundNotification");
        [unityAppController applicationWillEnterForeground:application];
    } else if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
       NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, notification is UIApplicationDidBecomeActiveNotification");
       [unityAppController applicationDidBecomeActive:application];
    } else if ([notification.name isEqualToString:UIApplicationWillTerminateNotification]) {
       NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, notification is UIApplicationWillTerminateNotification");
        [unityAppController applicationWillTerminate:application];
    } else if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        NSLog(@"UUUUUUUUUUUU In UnityUtils.handleAppStateDidChange, notification is UIApplicationDidReceiveMemoryWarningNotification");
       [unityAppController applicationDidReceiveMemoryWarning:application];
    }
}

+ (void)listenAppState
{
      NSLog(@"UUUUUUUUUUUU In UnityUtils.listenAppState");
   for (NSString *name in @[UIApplicationDidBecomeActiveNotification,
                             UIApplicationDidEnterBackgroundNotification,
                             UIApplicationWillTerminateNotification,
                             UIApplicationWillResignActiveNotification,
                             UIApplicationWillEnterForegroundNotification,
                             UIApplicationDidReceiveMemoryWarningNotification]) {

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAppStateDidChange:)
                                                     name:name
                                                   object:nil];
    }
}

+ (void)createPlayer:(void (^)(void))completed
{
    NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer");
   if (_isUnityReady) {
     NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer, unity is ready already so calling completed() and returning");
        completed();
        return;
    }

    NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer, unity is not ready, calling addObserverForName");
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UnityReady" object:nil queue:[NSOperationQueue mainQueue]  usingBlock:^(NSNotification * _Nonnull note) {
     NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer UnityReady callback, about to set UnityReady and call completed()");
        _isUnityReady = YES;
        completed();
    }];

    if (UnityIsInited()) {
      NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer Unity is inited, returning");
       return;
    }

        NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer Unity is not inited, about too call async block");
  dispatch_async(dispatch_get_main_queue(), ^{
         NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer about to call sharedApplication");
       UIApplication* application = [UIApplication sharedApplication];

        // Always keep RN window in top
        application.keyWindow.windowLevel = UIWindowLevelNormal + 1;

         NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer Unity is not inited, about to call InitUnity");
       InitUnity();
         NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer Unity is not inited, called InitUnity");

          NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer about to call GetAppController");
       UnityAppController *controller = GetAppController();
           NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer about to call didFinishLaunchingWithOptions");
       [controller application:application didFinishLaunchingWithOptions:nil];
            NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer about to call applicationDidBecomeActive");
       [controller applicationDidBecomeActive:application];

            NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer about to call listenAppState");
        [UnityUtils listenAppState];

    // call completed callback
       NSLog(@"UUUUUUUUUUUU In UnityUtils.createPlayer done with async block and calling completed() now");
       completed();
    });
}

extern "C" void onUnityMessage(const char* message)
{
     NSLog(@"UUUUUUUUUUUU In UnityUtils.onUnityMessage");
    for (id<UnityEventListener> listener in mUnityEventListeners) {
        [listener onMessage:[NSString stringWithUTF8String:message]];
    }
}

+ (void)addUnityEventListener:(id<UnityEventListener>)listener
{
    NSLog(@"UUUUUUUUUUUU In UnityUtils.addUnityEventListener");
   [mUnityEventListeners addObject:listener];
}

+ (void)removeUnityEventListener:(id<UnityEventListener>)listener
{
    NSLog(@"UUUUUUUUUUUU In UnityUtils.removeUnityEventListener");
    [mUnityEventListeners removeObject:listener];
}

@end
