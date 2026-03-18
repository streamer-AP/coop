package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class DevicesConnectState {
    @Nullable
    private String uuid;
    @Nullable
    private Boolean isConnected;

    public DevicesConnectState(@Nullable String uuid, @Nullable Boolean isConnected) {
        this.uuid = uuid;
        this.isConnected = isConnected;
    }

    @Nullable
    public final String getUuid() {
        return this.uuid;
    }

    public final void setUuid(@Nullable String<set-?>) {
        this.uuid = < set - ? >;
    }

    @Nullable
    public final Boolean isConnected() {
        return this.isConnected;
    }

    public final void setConnected(@Nullable Boolean<set-?>) {
        this.isConnected = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.uuid;
    }

    @Nullable
    public final Boolean component2() {
        return this.isConnected;
    }

    @NotNull
    public final DevicesConnectState copy(@Nullable String uuid, @Nullable Boolean isConnected) {
        return new DevicesConnectState(uuid, isConnected);
    }

    @NotNull
    public String toString() {
        return "DevicesConnectState(uuid=" + this.uuid + ", isConnected=" + this.isConnected + ")";
    }

    public int hashCode() {
        result = (this.uuid == null) ? 0 : this.uuid.hashCode();
        return result * 31 + ((this.isConnected == null) ? 0 : this.isConnected.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof DevicesConnectState))
            return false;
        DevicesConnectState devicesConnectState = (DevicesConnectState) other;
        return !Intrinsics.areEqual(this.uuid, devicesConnectState.uuid) ? false : (!!Intrinsics.areEqual(this.isConnected, devicesConnectState.isConnected));
    }

    public DevicesConnectState() {
        this(null, null, 3, null);
    }
}


