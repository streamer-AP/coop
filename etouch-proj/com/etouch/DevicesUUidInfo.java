package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class DevicesUUidInfo {
    @Nullable
    private String uuid;

    public DevicesUUidInfo(@Nullable String uuid) {
        this.uuid = uuid;
    }

    @Nullable
    public final String getUuid() {
        return this.uuid;
    }

    public final void setUuid(@Nullable String<set-?>) {
        this.uuid = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.uuid;
    }

    @NotNull
    public final DevicesUUidInfo copy(@Nullable String uuid) {
        return new DevicesUUidInfo(uuid);
    }

    @NotNull
    public String toString() {
        return "DevicesUUidInfo(uuid=" + this.uuid + ")";
    }

    public int hashCode() {
        return (this.uuid == null) ? 0 : this.uuid.hashCode();
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof DevicesUUidInfo))
            return false;
        DevicesUUidInfo devicesUUidInfo = (DevicesUUidInfo) other;
        return !!Intrinsics.areEqual(this.uuid, devicesUUidInfo.uuid);
    }

    public DevicesUUidInfo() {
        this(null, 1, null);
    }
}


