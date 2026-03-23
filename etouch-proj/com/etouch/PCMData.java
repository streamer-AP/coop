package com.etouch;

import java.util.Arrays;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class PCMData {
    @Nullable
    private float[] pcmData;
    @Nullable
    private Integer size;

    public PCMData(@Nullable float[] pcmData, @Nullable Integer size) {
        this.pcmData = pcmData;
        this.size = size;
    }

    @Nullable
    public final float[] getPcmData() {
        return this.pcmData;
    }

    public final void setPcmData(@Nullable float[] <set-?>) {
        this.pcmData = < set - ? >;
    }

    @Nullable
    public final Integer getSize() {
        return this.size;
    }

    public final void setSize(@Nullable Integer<set-?>) {
        this.size = < set - ? >;
    }


    @Nullable
    public final float[] component1() {
        return this.pcmData;
    }

    @Nullable
    public final Integer component2() {
        return this.size;
    }

    @NotNull
    public final PCMData copy(@Nullable float[] pcmData, @Nullable Integer size) {
        return new PCMData(pcmData, size);
    }

    @NotNull
    public String toString() {
        return "PCMData(pcmData=" + Arrays.toString(this.pcmData) + ", size=" + this.size + ")";
    }

    public int hashCode() {
        result = (this.pcmData == null) ? 0 : Arrays.hashCode(this.pcmData);
        return result * 31 + ((this.size == null) ? 0 : this.size.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof PCMData))
            return false;
        PCMData pCMData = (PCMData) other;
        return !Intrinsics.areEqual(this.pcmData, pCMData.pcmData) ? false : (!!Intrinsics.areEqual(this.size, pCMData.size));
    }

    public PCMData() {
        this(null, null, 3, null);
    }
}


