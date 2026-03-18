package com.etouch.service;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class IsPlaying {
    private final boolean isPlaying;

    public IsPlaying(boolean isPlaying) {
        this.isPlaying = isPlaying;
    }

    public final boolean isPlaying() {
        return this.isPlaying;
    }


    public final boolean component1() {
        return this.isPlaying;
    }

    @NotNull
    public final IsPlaying copy(boolean isPlaying) {
        return new IsPlaying(isPlaying);
    }

    @NotNull
    public String toString() {
        return "IsPlaying(isPlaying=" + this.isPlaying + ")";
    }

    public int hashCode() {
        return Boolean.hashCode(this.isPlaying);
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof IsPlaying))
            return false;
        IsPlaying isPlaying = (IsPlaying) other;
        return !(this.isPlaying != isPlaying.isPlaying);
    }

    public IsPlaying() {
        this(false, 1, null);
    }
}


