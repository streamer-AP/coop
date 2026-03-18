package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class TotalTime {
    @Nullable
    private String totalTime;

    public TotalTime(@Nullable String totalTime) {
        this.totalTime = totalTime;
    }

    @Nullable
    public final String getTotalTime() {
        return this.totalTime;
    }

    public final void setTotalTime(@Nullable String<set-?>) {
        this.totalTime = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.totalTime;
    }

    @NotNull
    public final TotalTime copy(@Nullable String totalTime) {
        return new TotalTime(totalTime);
    }

    @NotNull
    public String toString() {
        return "TotalTime(totalTime=" + this.totalTime + ")";
    }

    public int hashCode() {
        return (this.totalTime == null) ? 0 : this.totalTime.hashCode();
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof TotalTime))
            return false;
        TotalTime totalTime = (TotalTime) other;
        return !!Intrinsics.areEqual(this.totalTime, totalTime.totalTime);
    }

    public TotalTime() {
        this(null, 1, null);
    }
}


