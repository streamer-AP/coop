package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;


public final class ScanResultInfo {
    @Nullable
    private String scanResult;

    public ScanResultInfo(@Nullable String scanResult) {
        this.scanResult = scanResult;
    }

    @Nullable
    public final String getScanResult() {
        return this.scanResult;
    }

    public final void setScanResult(@Nullable String<set-?>) {
        this.scanResult = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.scanResult;
    }

    @NotNull
    public final ScanResultInfo copy(@Nullable String scanResult) {
        return new ScanResultInfo(scanResult);
    }

    @NotNull
    public String toString() {
        return "ScanResultInfo(scanResult=" + this.scanResult + ")";
    }

    public int hashCode() {
        return (this.scanResult == null) ? 0 : this.scanResult.hashCode();
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof ScanResultInfo))
            return false;
        ScanResultInfo scanResultInfo = (ScanResultInfo) other;
        return !!Intrinsics.areEqual(this.scanResult, scanResultInfo.scanResult);
    }

    public ScanResultInfo() {
        this(null, 1, null);
    }
}


