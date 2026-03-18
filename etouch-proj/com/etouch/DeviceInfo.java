package com.etouch;


public final class DeviceInfo {
    @Nullable
    private Integer deviceBatteryLevel;
    @Nullable
    private String modelName;
    @Nullable
    private String deviceName;
    @Nullable
    private String currentGear;
    @Nullable
    private Integer vibrationType;
    @Nullable
    private Integer remainingTime;
    @Nullable
    private Integer controlSource;

    @Nullable
    public final Integer getDeviceBatteryLevel() {
        return this.deviceBatteryLevel;
    }

    public final void setDeviceBatteryLevel(@Nullable Integer<set-?>) {
        this.deviceBatteryLevel = < set - ? >;
    }

    @Nullable
    public final String getModelName() {
        return this.modelName;
    }

    public final void setModelName(@Nullable String<set-?>) {
        this.modelName = < set - ? >;
    }

    @Nullable
    public final String getDeviceName() {
        return this.deviceName;
    }

    public final void setDeviceName(@Nullable String<set-?>) {
        this.deviceName = < set - ? >;
    }

    public DeviceInfo(@Nullable Integer deviceBatteryLevel, @Nullable String modelName, @Nullable String deviceName, @Nullable String currentGear, @Nullable Integer vibrationType, @Nullable Integer remainingTime, @Nullable Integer controlSource) {
        this.deviceBatteryLevel = deviceBatteryLevel;
        this.modelName = modelName;
        this.deviceName = deviceName;
        this.currentGear = currentGear;
        this.vibrationType = vibrationType;
        this.remainingTime = remainingTime;
        this.controlSource = controlSource;
    }

    @Nullable
    public final String getCurrentGear() {
        return this.currentGear;
    }

    public final void setCurrentGear(@Nullable String<set-?>) {
        this.currentGear = < set - ? >;
    }

    @Nullable
    public final Integer getVibrationType() {
        return this.vibrationType;
    }

    @Nullable
    public final Integer getControlSource() {
        return this.controlSource;
    }

    public final void setVibrationType(@Nullable Integer<set-?>) {
        this.vibrationType = < set - ? >;
    }

    @Nullable
    public final Integer getRemainingTime() {
        return this.remainingTime;
    }

    public final void setRemainingTime(@Nullable Integer<set-?>) {
        this.remainingTime = < set - ? >;
    }

    public final void setControlSource(@Nullable Integer<set-?>) {
        this.controlSource = < set - ? >;
    }


    @Nullable
    public final Integer component1() {
        return this.deviceBatteryLevel;
    }

    @Nullable
    public final String component2() {
        return this.modelName;
    }

    @Nullable
    public final String component3() {
        return this.deviceName;
    }

    @Nullable
    public final String component4() {
        return this.currentGear;
    }

    @Nullable
    public final Integer component5() {
        return this.vibrationType;
    }

    @Nullable
    public final Integer component6() {
        return this.remainingTime;
    }

    @Nullable
    public final Integer component7() {
        return this.controlSource;
    }

    @NotNull
    public final DeviceInfo copy(@Nullable Integer deviceBatteryLevel, @Nullable String modelName, @Nullable String deviceName, @Nullable String currentGear, @Nullable Integer vibrationType, @Nullable Integer remainingTime, @Nullable Integer controlSource) {
        return new DeviceInfo(deviceBatteryLevel, modelName, deviceName, currentGear, vibrationType, remainingTime, controlSource);
    }

    @NotNull
    public String toString() {
        return "DeviceInfo(deviceBatteryLevel=" + this.deviceBatteryLevel + ", modelName=" + this.modelName + ", deviceName=" + this.deviceName + ", currentGear=" + this.currentGear + ", vibrationType=" + this.vibrationType + ", remainingTime=" + this.remainingTime + ", controlSource=" + this.controlSource + ")";
    }

    public int hashCode() {
        result = (this.deviceBatteryLevel == null) ? 0 : this.deviceBatteryLevel.hashCode();
        result = result * 31 + ((this.modelName == null) ? 0 : this.modelName.hashCode());
        result = result * 31 + ((this.deviceName == null) ? 0 : this.deviceName.hashCode());
        result = result * 31 + ((this.currentGear == null) ? 0 : this.currentGear.hashCode());
        result = result * 31 + ((this.vibrationType == null) ? 0 : this.vibrationType.hashCode());
        result = result * 31 + ((this.remainingTime == null) ? 0 : this.remainingTime.hashCode());
        return result * 31 + ((this.controlSource == null) ? 0 : this.controlSource.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof DeviceInfo))
            return false;
        DeviceInfo deviceInfo = (DeviceInfo) other;
        return !Intrinsics.areEqual(this.deviceBatteryLevel, deviceInfo.deviceBatteryLevel) ? false : (!Intrinsics.areEqual(this.modelName, deviceInfo.modelName) ? false : (!Intrinsics.areEqual(this.deviceName, deviceInfo.deviceName) ? false : (!Intrinsics.areEqual(this.currentGear, deviceInfo.currentGear) ? false : (!Intrinsics.areEqual(this.vibrationType, deviceInfo.vibrationType) ? false : (!Intrinsics.areEqual(this.remainingTime, deviceInfo.remainingTime) ? false : (!!Intrinsics.areEqual(this.controlSource, deviceInfo.controlSource)))))));
    }

    public DeviceInfo() {
        this(null, null, null, null, null, null, null, 127, null);
    }
}


