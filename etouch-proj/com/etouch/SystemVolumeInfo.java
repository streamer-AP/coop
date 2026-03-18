package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class SystemVolumeInfo {
    @Nullable
    private String systemVolume;

    public SystemVolumeInfo(@Nullable String systemVolume) {
        this.systemVolume = systemVolume;
    }

    @Nullable
    public final String getSystemVolume() {
        return this.systemVolume;
    }

    public final void setSystemVolume(@Nullable String<set-?>) {
        this.systemVolume = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.systemVolume;
    }

    @NotNull
    public final SystemVolumeInfo copy(@Nullable String systemVolume) {
        return new SystemVolumeInfo(systemVolume);
    }

    @NotNull
    public String toString() {
        return "SystemVolumeInfo(systemVolume=" + this.systemVolume + ")";
    }

    public int hashCode() {
        return (this.systemVolume == null) ? 0 : this.systemVolume.hashCode();
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof SystemVolumeInfo))
            return false;
        SystemVolumeInfo systemVolumeInfo = (SystemVolumeInfo) other;
        return !!Intrinsics.areEqual(this.systemVolume, systemVolumeInfo.systemVolume);
    }

    public SystemVolumeInfo() {
        this(null, 1, null);
    }
}


