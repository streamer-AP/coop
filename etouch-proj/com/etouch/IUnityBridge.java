package com.etouch;

import android.content.Context;
import android.net.Uri;

import java.util.List;

import kotlin.Metadata;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlinx.coroutines.CoroutineScope;
import org.jetbrains.annotations.NotNull;


public interface IUnityBridge {
    void bindBT(@NotNull String paramString);

    void doNativeWork(@NotNull String paramString);

    void importFile(@NotNull CoroutineScope paramCoroutineScope, @NotNull List<? extends Uri> paramList, @NotNull Function1<? super ParsingErrorType, Unit> paramFunction1, @NotNull Function1<? super List<AudioFile>, Unit> paramFunction11, @NotNull Context paramContext);

    void importMultiFile(@NotNull CoroutineScope paramCoroutineScope, @NotNull List<? extends Uri> paramList, @NotNull Function1<? super ParsingErrorType, Unit> paramFunction1, @NotNull Function1<? super List<AudioFile>, Unit> paramFunction11, @NotNull Context paramContext);

    int getSystemVersionCode();

    @NotNull
    String getSystemVersionName();

    @NotNull
    String getDeviceModel();

    void getSystemDeviceInfo(@NotNull Function1<? super String, Unit> paramFunction11, @NotNull Function1<? super String, Unit> paramFunction12, @NotNull Function1<? super String, Unit> paramFunction13, @NotNull Context paramContext);

    float getSystemVolume(@NotNull Context paramContext);

    void setSystemVolume(@NotNull Context paramContext, float paramFloat);

    float getScreenBrightness(@NotNull Context paramContext);

    void setScreenBrightness(@NotNull Context paramContext, float paramFloat);
}


