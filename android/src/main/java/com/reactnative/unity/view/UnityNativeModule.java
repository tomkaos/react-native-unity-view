package com.reactnative.unity.view;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class UnityNativeModule extends ReactContextBaseJavaModule implements UnityEventListener {

    public UnityNativeModule(ReactApplicationContext reactContext) {
        super(reactContext);
        UnityUtils.addUnityEventListener(this);
    }

    @Override
    public String getName() {
        return "UnityNativeModule";
    }

    @ReactMethod
    public void isReady(Promise promise) {
        promise.resolve(UnityUtils.isUnityReady());
    }

    @ReactMethod
    public void createUnity(final Promise promise) {
         System.out.println("UUUUUUUUUUUU In UnityNativeModule.createUnity");
       UnityUtils.createPlayer(getCurrentActivity(), new UnityUtils.CreateCallback() {
            @Override
            public void onReady() {
                promise.resolve(true);
            }
        });
    }

    @ReactMethod
    public void postMessage(String gameObject, String methodName, String message) {
          System.out.println("UUUUUUUUUUUU In UnityNativeModule.postMessage: " + message);
       UnityUtils.postMessage(gameObject, methodName, message);
    }

    @ReactMethod
    public void pause() {
         System.out.println("UUUUUUUUUUUU In UnityNativeModule.pause");
        UnityUtils.pause();
    }

    @ReactMethod
    public void resume() {
         System.out.println("UUUUUUUUUUUU In UnityNativeModule.resume");
        UnityUtils.resume();
    }

    @Override
    public void onMessage(String message) {
          System.out.println("UUUUUUUUUUUU In UnityNativeModule.onMessage: " + message);
        ReactContext context = getReactApplicationContext();
        context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onUnityMessage", message);
    }
}
