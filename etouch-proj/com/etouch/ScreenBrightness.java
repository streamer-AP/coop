package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class ScreenBrightness {
    @Nullable
    private String screenBrightness;

    public ScreenBrightness(@Nullable String screenBrightness) {
        this.screenBrightness = screenBrightness;
    }

    @Nullable
    public final String getScreenBrightness() {
        return this.screenBrightness;
    }

    public final void setScreenBrightness(@Nullable String<set-?>) {
        this.screenBrightness = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.screenBrightness;
    }

    @NotNull
    public final ScreenBrightness copy(@Nullable String screenBrightness) {
        return new ScreenBrightness(screenBrightness);
    }

    @NotNull
    public String toString() {
        return "ScreenBrightness(screenBrightness=" + this.screenBrightness + ")";
    }

    public int hashCode() {
        return (this.screenBrightness == null) ? 0 : this.screenBrightness.hashCode();
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof ScreenBrightness))
            return false;
        ScreenBrightness screenBrightness = (ScreenBrightness) other;
        return !!Intrinsics.areEqual(this.screenBrightness, screenBrightness.screenBrightness);
    }

    public ScreenBrightness() {
        this(null, 1, null);
    }
}


