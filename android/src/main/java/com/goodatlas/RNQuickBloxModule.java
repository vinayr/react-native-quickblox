package com.goodatlas;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.RCTNativeAppEventEmitter;

public class RNQuickBloxModule extends ReactContextBaseJavaModule {

    private final String TAG = "RNQuickBlox";
    private final ReactApplicationContext reactContext;

    public RNQuickBloxModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNQuickBlox";
    }

    @ReactMethod
    public void test(Promise promise) {
        promise.resolve("success");
    }
}
