package com.etouch;

import java.util.Arrays;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class ReciveEquipmentControlData {
    @Nullable
    private Integer swingWaveformIndex;
    @Nullable
    private Integer vibrationWaveformIndex;
    @Nullable
    private Integer swingIntensity;
    @Nullable
    private Integer vibrationIntensity;
    @Nullable
    private int[] swingWaveformArray;
    @Nullable
    private int[] vibrationWaveformArray;
    @Nullable
    private Integer times;

    @Nullable
    public final Integer getSwingWaveformIndex() {
        return this.swingWaveformIndex;
    }

    public final void setSwingWaveformIndex(@Nullable Integer<set-?>) {
        this.swingWaveformIndex = < set - ? >;
    }

    @Nullable
    public final Integer getVibrationWaveformIndex() {
        return this.vibrationWaveformIndex;
    }

    public final void setVibrationWaveformIndex(@Nullable Integer<set-?>) {
        this.vibrationWaveformIndex = < set - ? >;
    }

    @Nullable
    public final Integer getSwingIntensity() {
        return this.swingIntensity;
    }

    public final void setSwingIntensity(@Nullable Integer<set-?>) {
        this.swingIntensity = < set - ? >;
    }

    @Nullable
    public final Integer getVibrationIntensity() {
        return this.vibrationIntensity;
    }

    public final void setVibrationIntensity(@Nullable Integer<set-?>) {
        this.vibrationIntensity = < set - ? >;
    }

    @Nullable
    public final int[] getSwingWaveformArray() {
        return this.swingWaveformArray;
    }

    public final void setSwingWaveformArray(@Nullable int[] <set-?>) {
        this.swingWaveformArray = < set - ? >;
    }

    @Nullable
    public final int[] getVibrationWaveformArray() {
        return this.vibrationWaveformArray;
    }

    public final void setVibrationWaveformArray(@Nullable int[] <set-?>) {
        this.vibrationWaveformArray = < set - ? >;
    }

    public ReciveEquipmentControlData(@Nullable Integer swingWaveformIndex, @Nullable Integer vibrationWaveformIndex, @Nullable Integer swingIntensity, @Nullable Integer vibrationIntensity, @Nullable int[] swingWaveformArray, @Nullable int[] vibrationWaveformArray, @Nullable Integer times) {
        this.swingWaveformIndex = swingWaveformIndex;
        this.vibrationWaveformIndex = vibrationWaveformIndex;
        this.swingIntensity = swingIntensity;
        this.vibrationIntensity = vibrationIntensity;
        this.swingWaveformArray = swingWaveformArray;
        this.vibrationWaveformArray = vibrationWaveformArray;
        this.times = times;
    }

    @Nullable
    public final Integer getTimes() {
        return this.times;
    }

    public final void setTimes(@Nullable Integer<set-?>) {
        this.times = < set - ? >;
    }


    @Nullable
    public final Integer component1() {
        return this.swingWaveformIndex;
    }

    @Nullable
    public final Integer component2() {
        return this.vibrationWaveformIndex;
    }

    @Nullable
    public final Integer component3() {
        return this.swingIntensity;
    }

    @Nullable
    public final Integer component4() {
        return this.vibrationIntensity;
    }

    @Nullable
    public final int[] component5() {
        return this.swingWaveformArray;
    }

    @Nullable
    public final int[] component6() {
        return this.vibrationWaveformArray;
    }

    @Nullable
    public final Integer component7() {
        return this.times;
    }

    @NotNull
    public final ReciveEquipmentControlData copy(@Nullable Integer swingWaveformIndex, @Nullable Integer vibrationWaveformIndex, @Nullable Integer swingIntensity, @Nullable Integer vibrationIntensity, @Nullable int[] swingWaveformArray, @Nullable int[] vibrationWaveformArray, @Nullable Integer times) {
        return new ReciveEquipmentControlData(swingWaveformIndex, vibrationWaveformIndex, swingIntensity, vibrationIntensity, swingWaveformArray, vibrationWaveformArray, times);
    }

    @NotNull
    public String toString() {
        return "ReciveEquipmentControlData(swingWaveformIndex=" + this.swingWaveformIndex + ", vibrationWaveformIndex=" + this.vibrationWaveformIndex + ", swingIntensity=" + this.swingIntensity + ", vibrationIntensity=" + this.vibrationIntensity + ", swingWaveformArray=" + Arrays.toString(this.swingWaveformArray) + ", vibrationWaveformArray=" + Arrays.toString(this.vibrationWaveformArray) + ", times=" + this.times + ")";
    }

    public int hashCode() {
        result = (this.swingWaveformIndex == null) ? 0 : this.swingWaveformIndex.hashCode();
        result = result * 31 + ((this.vibrationWaveformIndex == null) ? 0 : this.vibrationWaveformIndex.hashCode());
        result = result * 31 + ((this.swingIntensity == null) ? 0 : this.swingIntensity.hashCode());
        result = result * 31 + ((this.vibrationIntensity == null) ? 0 : this.vibrationIntensity.hashCode());
        result = result * 31 + ((this.swingWaveformArray == null) ? 0 : Arrays.hashCode(this.swingWaveformArray));
        result = result * 31 + ((this.vibrationWaveformArray == null) ? 0 : Arrays.hashCode(this.vibrationWaveformArray));
        return result * 31 + ((this.times == null) ? 0 : this.times.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof ReciveEquipmentControlData))
            return false;
        ReciveEquipmentControlData reciveEquipmentControlData = (ReciveEquipmentControlData) other;
        return !Intrinsics.areEqual(this.swingWaveformIndex, reciveEquipmentControlData.swingWaveformIndex) ? false : (!Intrinsics.areEqual(this.vibrationWaveformIndex, reciveEquipmentControlData.vibrationWaveformIndex) ? false : (!Intrinsics.areEqual(this.swingIntensity, reciveEquipmentControlData.swingIntensity) ? false : (!Intrinsics.areEqual(this.vibrationIntensity, reciveEquipmentControlData.vibrationIntensity) ? false : (!Intrinsics.areEqual(this.swingWaveformArray, reciveEquipmentControlData.swingWaveformArray) ? false : (!Intrinsics.areEqual(this.vibrationWaveformArray, reciveEquipmentControlData.vibrationWaveformArray) ? false : (!!Intrinsics.areEqual(this.times, reciveEquipmentControlData.times)))))));
    }

    public ReciveEquipmentControlData() {
        this(null, null, null, null, null, null, null, 127, null);
    }
}


