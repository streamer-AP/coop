package com.etouch;

import android.content.Context;
import android.net.Uri;

import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.internal.Intrinsics;
import kotlinx.coroutines.CoroutineScope;
import org.jetbrains.annotations.NotNull;


public final class UnityBridgeUtil implements IUnityBridge {
    public void bindBT(@NotNull String deviceId) {
        Intrinsics.checkNotNullParameter(deviceId, "deviceId");
        this.$$delegate_0.bindBT(deviceId);
    }

    public void doNativeWork(@NotNull String param) {
        Intrinsics.checkNotNullParameter(param, "param");
        this.$$delegate_0.doNativeWork(param);
    }

    @NotNull
    public String getDeviceModel() {
        return this.$$delegate_0.getDeviceModel();
    }

    public float getScreenBrightness(@NotNull Context context) {
        Intrinsics.checkNotNullParameter(context, "context");
        return this.$$delegate_0.getScreenBrightness(context);
    }

    public void getSystemDeviceInfo(@NotNull Function1<? super String, Unit> getSystemVersionCode, @NotNull Function1<? super String, Unit> getSystemVersionName, @NotNull Function1<? super String, Unit> getDeviceModel, @NotNull Context context) {
        Intrinsics.checkNotNullParameter(getSystemVersionCode, "getSystemVersionCode");
        Intrinsics.checkNotNullParameter(getSystemVersionName, "getSystemVersionName");
        Intrinsics.checkNotNullParameter(getDeviceModel, "getDeviceModel");
        Intrinsics.checkNotNullParameter(context, "context");
        this.$$delegate_0.getSystemDeviceInfo(getSystemVersionCode, getSystemVersionName, getDeviceModel, context);
    }

    public int getSystemVersionCode() {
        return this.$$delegate_0.getSystemVersionCode();
    }

    @NotNull
    public String getSystemVersionName() {
        return this.$$delegate_0.getSystemVersionName();
    }

    public float getSystemVolume(@NotNull Context context) {
        Intrinsics.checkNotNullParameter(context, "context");
        return this.$$delegate_0.getSystemVolume(context);
    }

    public void importFile(@NotNull CoroutineScope scope, @NotNull List<? extends Uri> uris, @NotNull Function1<? super ParsingErrorType, Unit> onError, @NotNull Function1<? super List<AudioFile>, Unit> onSuccess, @NotNull Context mContext) {
        Intrinsics.checkNotNullParameter(scope, "scope");
        Intrinsics.checkNotNullParameter(uris, "uris");
        Intrinsics.checkNotNullParameter(onError, "onError");
        Intrinsics.checkNotNullParameter(onSuccess, "onSuccess");
        Intrinsics.checkNotNullParameter(mContext, "mContext");
        this.$$delegate_0.importFile(scope, uris, onError, onSuccess, mContext);
    }

    public void importMultiFile(@NotNull CoroutineScope scope, @NotNull List<? extends Uri> uris, @NotNull Function1<? super ParsingErrorType, Unit> onError, @NotNull Function1<? super List<AudioFile>, Unit> onSuccess, @NotNull Context mContext) {
        Intrinsics.checkNotNullParameter(scope, "scope");
        Intrinsics.checkNotNullParameter(uris, "uris");
        Intrinsics.checkNotNullParameter(onError, "onError");
        Intrinsics.checkNotNullParameter(onSuccess, "onSuccess");
        Intrinsics.checkNotNullParameter(mContext, "mContext");
        this.$$delegate_0.importMultiFile(scope, uris, onError, onSuccess, mContext);
    }

    public void setScreenBrightness(@NotNull Context context, float percent) {
        Intrinsics.checkNotNullParameter(context, "context");
        this.$$delegate_0.setScreenBrightness(context, percent);
    }

    public void setSystemVolume(@NotNull Context context, float percentage) {
        Intrinsics.checkNotNullParameter(context, "context");
        this.$$delegate_0.setSystemVolume(context, percentage);
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\024\n\002\030\002\n\002\020\000\n\002\b\002\n\002\030\002\n\002\b\003\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002R\021\020\003\032\0020\004¢\006\b\n\000\032\004\b\005\020\006¨\006\007"}, d2 = {"Lcom/etouch/UnityBridgeUtil$Companion;", "", "()V", "INSTANCE", "Lcom/etouch/UnityBridgeUtil;", "getINSTANCE", "()Lcom/etouch/UnityBridgeUtil;", "sdk_android_unity_bridge_v1_debug"})
    public static final class Companion {
        @NotNull
        public final UnityBridgeUtil getINSTANCE() {
            return UnityBridgeUtil.INSTANCE;
        }

        private Companion() {
        }
    }

    @NotNull
    public static final Companion Companion = new Companion(null);
    @NotNull
    private static final UnityBridgeUtil INSTANCE = new UnityBridgeUtil();
}


