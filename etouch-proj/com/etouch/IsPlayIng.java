package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class IsPlayIng {
    @Nullable
    private Boolean isPlaying;

    public IsPlayIng(@Nullable Boolean isPlaying) {
        this.isPlaying = isPlaying;
    }

    @Nullable
    public final Boolean isPlaying() {
        return this.isPlaying;
    }

    public final void setPlaying(@Nullable Boolean<set-?>) {
        this.isPlaying = < set - ? >;
    }


    @Nullable
    public final Boolean component1() {
        return this.isPlaying;
    }

    @NotNull
    public final IsPlayIng copy(@Nullable Boolean isPlaying) {
        return new IsPlayIng(isPlaying);
    }

    @NotNull
    public String toString() {
        return "IsPlayIng(isPlaying=" + this.isPlaying + ")";
    }

    public int hashCode() {
        return (this.isPlaying == null) ? 0 : this.isPlaying.hashCode();
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof IsPlayIng))
            return false;
        IsPlayIng isPlayIng = (IsPlayIng) other;
        return !!Intrinsics.areEqual(this.isPlaying, isPlayIng.isPlaying);
    }

    public IsPlayIng() {
        this(null, 1, null);
    }
}


