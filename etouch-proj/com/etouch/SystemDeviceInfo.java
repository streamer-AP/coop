package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class SystemDeviceInfo {
    @Nullable
    private String versionCode;
    @Nullable
    private String versionName;
    @Nullable
    private String modelType;

    @Nullable
    public final String getVersionCode() {
        return this.versionCode;
    }

    public final void setVersionCode(@Nullable String<set-?>) {
        this.versionCode = < set - ? >;
    }

    @Nullable
    public final String getVersionName() {
        return this.versionName;
    }

    public final void setVersionName(@Nullable String<set-?>) {
        this.versionName = < set - ? >;
    }

    public SystemDeviceInfo(@Nullable String versionCode, @Nullable String versionName, @Nullable String modelType) {
        this.versionCode = versionCode;
        this.versionName = versionName;
        this.modelType = modelType;
    }

    @Nullable
    public final String getModelType() {
        return this.modelType;
    }

    public final void setModelType(@Nullable String<set-?>) {
        this.modelType = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.versionCode;
    }

    @Nullable
    public final String component2() {
        return this.versionName;
    }

    @Nullable
    public final String component3() {
        return this.modelType;
    }

    @NotNull
    public final SystemDeviceInfo copy(@Nullable String versionCode, @Nullable String versionName, @Nullable String modelType) {
        return new SystemDeviceInfo(versionCode, versionName, modelType);
    }

    @NotNull
    public String toString() {
        return "SystemDeviceInfo(versionCode=" + this.versionCode + ", versionName=" + this.versionName + ", modelType=" + this.modelType + ")";
    }

    public int hashCode() {
        result = (this.versionCode == null) ? 0 : this.versionCode.hashCode();
        result = result * 31 + ((this.versionName == null) ? 0 : this.versionName.hashCode());
        return result * 31 + ((this.modelType == null) ? 0 : this.modelType.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof SystemDeviceInfo))
            return false;
        SystemDeviceInfo systemDeviceInfo = (SystemDeviceInfo) other;
        return !Intrinsics.areEqual(this.versionCode, systemDeviceInfo.versionCode) ? false : (!Intrinsics.areEqual(this.versionName, systemDeviceInfo.versionName) ? false : (!!Intrinsics.areEqual(this.modelType, systemDeviceInfo.modelType)));
    }

    public SystemDeviceInfo() {
        this(null, null, null, 7, null);
    }
}


