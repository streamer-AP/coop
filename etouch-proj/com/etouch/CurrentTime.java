package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class CurrentTime {
    @Nullable
    private String currentTime;

    public CurrentTime(@Nullable String currentTime) {
        this.currentTime = currentTime;
    }

    @Nullable
    public final String getCurrentTime() {
        return this.currentTime;
    }

    public final void setCurrentTime(@Nullable String<set-?>) {
        this.currentTime = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.currentTime;
    }

    @NotNull
    public final CurrentTime copy(@Nullable String currentTime) {
        return new CurrentTime(currentTime);
    }

    @NotNull
    public String toString() {
        return "CurrentTime(currentTime=" + this.currentTime + ")";
    }

    public int hashCode() {
        return (this.currentTime == null) ? 0 : this.currentTime.hashCode();
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof CurrentTime))
            return false;
        CurrentTime currentTime = (CurrentTime) other;
        return !!Intrinsics.areEqual(this.currentTime, currentTime.currentTime);
    }

    public CurrentTime() {
        this(null, 1, null);
    }
}


