package com.etouch.bt;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.le.BluetoothLeScanner;
import android.content.Context;

import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;


@SuppressLint({"MissingPermission"})

public final class BluetoothManager {
    private BluetoothManager(Context context) {
        this.context = context;


        Intrinsics.checkNotNull(this.context.getSystemService("bluetooth"), "null cannot be cast to non-null type android.bluetooth.BluetoothManager");
        this.bluetoothManager = (android.bluetooth.BluetoothManager) this.context.getSystemService("bluetooth");
        this.bluetoothAdapter = this.bluetoothManager.getAdapter();
        this.bleScanner = (this.bluetoothAdapter != null) ? this.bluetoothAdapter.getBluetoothLeScanner() : null;
        this.handler = new Handler(Looper.getMainLooper());


        this.discoveredDevices = new ArrayList<>();


        this.deviceName = "";


        String[] arrayOfString = new String[3];
        arrayOfString[0] = "OMAO";
        arrayOfString[1] = "ETOUCH";
        arrayOfString[2] = "744";
        this.targetPrefixes = CollectionsKt.listOf((Object[]) arrayOfString);
        this.TARGET_MANUFACTURER_IDS = CollectionsKt.listOf(Integer.valueOf(511));


        this.scanCallback = new BluetoothManager$scanCallback$1();


        this.gattCallback = new BluetoothManager$gattCallback$1();
    }


    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\0000\n\002\030\002\n\002\020\000\n\002\b\002\n\002\020\016\n\000\n\002\030\002\n\002\b\005\n\002\030\002\n\002\b\002\n\002\020 \n\002\b\005\n\002\030\002\n\000\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002J\016\020\023\032\0020\f2\006\020\024\032\0020\025R\016\020\003\032\0020\004XT¢\006\002\n\000R\026\020\005\032\n \007*\004\030\0010\0060\006X\004¢\006\002\n\000R\016\020\b\032\0020\004XT¢\006\002\n\000R\016\020\t\032\0020\004XT¢\006\002\n\000R\016\020\n\032\0020\004XT¢\006\002\n\000R\020\020\013\032\004\030\0010\fX\016¢\006\002\n\000R\016\020\r\032\0020\004XT¢\006\002\n\000R\034\020\016\032\020\022\f\022\n \007*\004\030\0010\0060\0060\017X\004¢\006\002\n\000R\016\020\020\032\0020\004XT¢\006\002\n\000R\016\020\021\032\0020\004XT¢\006\002\n\000R\016\020\022\032\0020\004XT¢\006\002\n\000¨\006\026"}, d2 = {"Lcom/etouch/bt/BluetoothManager$Companion;", "", "()V", "BATTERY_LEVEL_CHAR", "", "CLIENT_CHARACTERISTIC_CONFIG_UUID", "Ljava/util/UUID;", "kotlin.jvm.PlatformType", "CONTROL_SOURCE_CHAR", "CURRENT_GEAR_CHAR", "DEVICE_NAME_CHAR", "INSTANCE", "Lcom/etouch/bt/BluetoothManager;", "REMAINING_TIME_CHAR", "REQUIRED_SERVICE_UUIDS", "", "TAG", "VIBRATION_CONTROL_CHAR", "VIBRATION_TYPE_CHAR", "getInstance", "context", "Landroid/content/Context;", "sdk_android_unity_bridge_v1_debug"})
    @SourceDebugExtension({"SMAP\nBluetoothManager.kt\nKotlin\n*S Kotlin\n*F\n+ 1 BluetoothManager.kt\ncom/etouch/bt/BluetoothManager$Companion\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,779:1\n1#2:780\n*E\n"})
    public static final class Companion {
        private Companion() {
        }


        @NotNull
        public final BluetoothManager getInstance(@NotNull Context context) {
            Intrinsics.checkNotNullParameter(context, "context");
            if (BluetoothManager.INSTANCE == null) {
                BluetoothManager.INSTANCE;
                synchronized (this) {
                    int $i$a$ - synchronized -BluetoothManager$Companion$getInstance$1 = 0;
                    if (BluetoothManager.INSTANCE == null) {
                        BluetoothManager.INSTANCE;
                        Intrinsics.checkNotNullExpressionValue(context.getApplicationContext(), "getApplicationContext(...)");
                        BluetoothManager bluetoothManager1 = new BluetoothManager(context.getApplicationContext(), null), it = bluetoothManager1;
                        int $i$a$ -also - BluetoothManager$Companion$getInstance$1$1 = 0;
                        BluetoothManager.INSTANCE = it;
                    } BluetoothManager bluetoothManager = bluetoothManager1;
                }
            } return BluetoothManager.INSTANCE;
        }
    }

    @NotNull
    public static final Companion Companion = new Companion(null);
    @NotNull
    private final Context context;
    @NotNull
    private final android.bluetooth.BluetoothManager bluetoothManager;
    @Nullable
    private final BluetoothAdapter bluetoothAdapter;
    @Nullable
    private BluetoothLeScanner bleScanner;
    @NotNull
    private final Handler handler;
    @NotNull
    private final List<BluetoothDeviceInfo> discoveredDevices;
    @Nullable
    private BluetoothDeviceInfo targetDevice;
    @Nullable
    private BluetoothGatt connectedGatt;
    private int batteryLevel;
    @NotNull
    private String deviceName;
    @Nullable
    private byte[] currentGearState;
    private int vibrationType;
    private int remainingTime;
    private int controlSource;
    private boolean isScanning;
    private boolean isConnected;
    @Nullable
    private Function1<? super BluetoothDeviceInfo, Unit> onScanResult;
    @Nullable
    private Function1<? super BluetoothDeviceInfo, Unit> onTargetDeviceFound;
    @Nullable
    private Function1<? super Boolean, Unit> onConnectionStateChanged;
    @Nullable
    private Function1<? super Integer, Unit> onBatteryLevelUpdated;
    @Nullable
    private Function1<? super byte[], Unit> onCurrentGearUpdated;
    @Nullable
    private Function1<? super Integer, Unit> onVibrationTypeUpdated;
    @Nullable
    private Function1<? super Integer, Unit> onRemainingTimeUpdated;
    @Nullable
    private Function1<? super Integer, Unit> onControlSourceUpdated;
    @NotNull
    private final List<String> targetPrefixes;
    @NotNull
    private final List<Integer> TARGET_MANUFACTURER_IDS;
    @NotNull
    private final BluetoothManager$scanCallback$1 scanCallback;
    @NotNull
    private final BluetoothManager$gattCallback$1 gattCallback;
    @NotNull
    private static final String TAG = "BluetoothManager";
    @Nullable
    private static volatile BluetoothManager INSTANCE;
    @NotNull
    private static final List<UUID> REQUIRED_SERVICE_UUIDS;
    @NotNull
    public static final String BATTERY_LEVEL_CHAR = "00002A19-0000-1000-8000-00805F9B34FB";
    @NotNull
    public static final String DEVICE_NAME_CHAR = "00002A00-0000-1000-8000-00805F9B34FB";
    @NotNull
    public static final String CURRENT_GEAR_CHAR = "0000F220-0000-1000-8000-00805F9B34FB";
    @NotNull
    public static final String VIBRATION_TYPE_CHAR = "0000F221-0000-1000-8000-00805F9B34FB";
    @NotNull
    public static final String VIBRATION_CONTROL_CHAR = "0000F320-0000-1000-8000-00805F9B34FB";
    @NotNull
    public static final String REMAINING_TIME_CHAR = "0000F241-0000-1000-8000-00805F9B34FB";
    @NotNull
    public static final String CONTROL_SOURCE_CHAR = "0000F260-0000-1000-8000-00805F9B34FB";

    static {
        UUID[] arrayOfUUID = new UUID[8];
        arrayOfUUID[0] = UUID.fromString("0000180A-0000-1000-8000-00805F9B34FB");
        arrayOfUUID[1] = UUID.fromString("0000180F-0000-1000-8000-00805F9B34FB");
        arrayOfUUID[2] = UUID.fromString("00001800-0000-1000-8000-00805F9B34FB");
        arrayOfUUID[3] = UUID.fromString("0000F000-0000-1000-8000-00805F9B34FB");
        arrayOfUUID[4] = UUID.fromString("0000F001-0000-1000-8000-00805F9B34FB");
        arrayOfUUID[5] = UUID.fromString("0000F004-0000-1000-8000-00805F9B34FB");
        arrayOfUUID[6] = UUID.fromString("0000F005-0000-1000-8000-00805F9B34FB");
        arrayOfUUID[7] = UUID.fromString("0000F006-0000-1000-8000-00805F9B34FB");
        REQUIRED_SERVICE_UUIDS = CollectionsKt.listOf((Object[]) arrayOfUUID);
    }

    private static final UUID CLIENT_CHARACTERISTIC_CONFIG_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000.\n\002\030\002\n\002\020\000\n\000\n\002\030\002\n\000\n\002\020\016\n\002\b\002\n\002\020\b\n\000\n\002\020\013\n\002\b\003\n\002\020 \n\002\b)\b\b\030\0002\0020\001Bk\022\n\b\002\020\002\032\004\030\0010\003\022\n\b\002\020\004\032\004\030\0010\005\022\n\b\002\020\006\032\004\030\0010\005\022\n\b\002\020\007\032\004\030\0010\b\022\n\b\002\020\t\032\004\030\0010\n\022\n\b\002\020\013\032\004\030\0010\n\022\n\b\002\020\f\032\004\030\0010\n\022\020\b\002\020\r\032\n\022\004\022\0020\005\030\0010\016¢\006\002\020\017J\013\020)\032\004\030\0010\003HÆ\003J\013\020*\032\004\030\0010\005HÆ\003J\013\020+\032\004\030\0010\005HÆ\003J\020\020,\032\004\030\0010\bHÆ\003¢\006\002\020!J\020\020-\032\004\030\0010\nHÆ\003¢\006\002\020\030J\020\020.\032\004\030\0010\nHÆ\003¢\006\002\020\030J\020\020/\032\004\030\0010\nHÆ\003¢\006\002\020\030J\021\0200\032\n\022\004\022\0020\005\030\0010\016HÆ\003Jt\0201\032\0020\0002\n\b\002\020\002\032\004\030\0010\0032\n\b\002\020\004\032\004\030\0010\0052\n\b\002\020\006\032\004\030\0010\0052\n\b\002\020\007\032\004\030\0010\b2\n\b\002\020\t\032\004\030\0010\n2\n\b\002\020\013\032\004\030\0010\n2\n\b\002\020\f\032\004\030\0010\n2\020\b\002\020\r\032\n\022\004\022\0020\005\030\0010\016HÆ\001¢\006\002\0202J\023\0203\032\0020\n2\b\0204\032\004\030\0010\001HÖ\003J\t\0205\032\0020\bHÖ\001J\t\0206\032\0020\005HÖ\001R\034\020\006\032\004\030\0010\005X\016¢\006\016\n\000\032\004\b\020\020\021\"\004\b\022\020\023R\034\020\002\032\004\030\0010\003X\016¢\006\016\n\000\032\004\b\024\020\025\"\004\b\026\020\027R\036\020\013\032\004\030\0010\nX\016¢\006\020\n\002\020\033\032\004\b\013\020\030\"\004\b\031\020\032R\036\020\t\032\004\030\0010\nX\016¢\006\020\n\002\020\033\032\004\b\t\020\030\"\004\b\034\020\032R\036\020\f\032\004\030\0010\nX\016¢\006\020\n\002\020\033\032\004\b\f\020\030\"\004\b\035\020\032R\034\020\004\032\004\030\0010\005X\016¢\006\016\n\000\032\004\b\036\020\021\"\004\b\037\020\023R\036\020\007\032\004\030\0010\bX\016¢\006\020\n\002\020$\032\004\b \020!\"\004\b\"\020#R\"\020\r\032\n\022\004\022\0020\005\030\0010\016X\016¢\006\016\n\000\032\004\b%\020&\"\004\b'\020(¨\0067"}, d2 = {"Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;", "", "device", "Landroid/bluetooth/BluetoothDevice;", "name", "", "address", "rssi", "", "isPaired", "", "isConnected", "isTargetDevice", "serviceUuids", "", "(Landroid/bluetooth/BluetoothDevice;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Integer;Ljava/lang/Boolean;Ljava/lang/Boolean;Ljava/lang/Boolean;Ljava/util/List;)V", "getAddress", "()Ljava/lang/String;", "setAddress", "(Ljava/lang/String;)V", "getDevice", "()Landroid/bluetooth/BluetoothDevice;", "setDevice", "(Landroid/bluetooth/BluetoothDevice;)V", "()Ljava/lang/Boolean;", "setConnected", "(Ljava/lang/Boolean;)V", "Ljava/lang/Boolean;", "setPaired", "setTargetDevice", "getName", "setName", "getRssi", "()Ljava/lang/Integer;", "setRssi", "(Ljava/lang/Integer;)V", "Ljava/lang/Integer;", "getServiceUuids", "()Ljava/util/List;", "setServiceUuids", "(Ljava/util/List;)V", "component1", "component2", "component3", "component4", "component5", "component6", "component7", "component8", "copy", "(Landroid/bluetooth/BluetoothDevice;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Integer;Ljava/lang/Boolean;Ljava/lang/Boolean;Ljava/lang/Boolean;Ljava/util/List;)Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;", "equals", "other", "hashCode", "toString", "sdk_android_unity_bridge_v1_debug"})
    public static final class BluetoothDeviceInfo {
        @Nullable
        private BluetoothDevice device;
        @Nullable
        private String name;
        @Nullable
        private String address;
        @Nullable
        private Integer rssi;
        @Nullable
        private Boolean isPaired;
        @Nullable
        private Boolean isConnected;
        @Nullable
        private Boolean isTargetDevice;
        @Nullable
        private List<String> serviceUuids;

        public BluetoothDeviceInfo(@Nullable BluetoothDevice device, @Nullable String name, @Nullable String address, @Nullable Integer rssi, @Nullable Boolean isPaired, @Nullable Boolean isConnected, @Nullable Boolean isTargetDevice, @Nullable List<String> serviceUuids) {
            this.device = device;
            this.name = name;
            this.address = address;
            this.rssi = rssi;
            this.isPaired = isPaired;
            this.isConnected = isConnected;
            this.isTargetDevice = isTargetDevice;
            this.serviceUuids = serviceUuids;
        }

        @Nullable
        public final BluetoothDevice getDevice() {
            return this.device;
        }

        public final void setDevice(@Nullable BluetoothDevice<set-?>) {
            this.device = < set - ? >;
        }

        @Nullable
        public final String getName() {
            return this.name;
        }

        public final void setName(@Nullable String<set-?>) {
            this.name = < set - ? >;
        }

        @Nullable
        public final String getAddress() {
            return this.address;
        }

        public final void setAddress(@Nullable String<set-?>) {
            this.address = < set - ? >;
        }

        @Nullable
        public final Integer getRssi() {
            return this.rssi;
        }

        public final void setRssi(@Nullable Integer<set-?>) {
            this.rssi = < set - ? >;
        }

        @Nullable
        public final Boolean isPaired() {
            return this.isPaired;
        }

        public final void setPaired(@Nullable Boolean<set-?>) {
            this.isPaired = < set - ? >;
        }

        @Nullable
        public final Boolean isConnected() {
            return this.isConnected;
        }

        public final void setConnected(@Nullable Boolean<set-?>) {
            this.isConnected = < set - ? >;
        }

        @Nullable
        public final Boolean isTargetDevice() {
            return this.isTargetDevice;
        }

        public final void setTargetDevice(@Nullable Boolean<set-?>) {
            this.isTargetDevice = < set - ? >;
        }

        @Nullable
        public final List<String> getServiceUuids() {
            return this.serviceUuids;
        }

        public final void setServiceUuids(@Nullable List<String> <set-?>) {
            this.serviceUuids = < set - ? >;
        }

        @Nullable
        public final BluetoothDevice component1() {
            return this.device;
        }

        @Nullable
        public final String component2() {
            return this.name;
        }

        @Nullable
        public final String component3() {
            return this.address;
        }

        @Nullable
        public final Integer component4() {
            return this.rssi;
        }

        @Nullable
        public final Boolean component5() {
            return this.isPaired;
        }

        @Nullable
        public final Boolean component6() {
            return this.isConnected;
        }

        @Nullable
        public final Boolean component7() {
            return this.isTargetDevice;
        }

        @Nullable
        public final List<String> component8() {
            return this.serviceUuids;
        }

        @NotNull
        public final BluetoothDeviceInfo copy(@Nullable BluetoothDevice device, @Nullable String name, @Nullable String address, @Nullable Integer rssi, @Nullable Boolean isPaired, @Nullable Boolean isConnected, @Nullable Boolean isTargetDevice, @Nullable List<String> serviceUuids) {
            return new BluetoothDeviceInfo(device, name, address, rssi, isPaired, isConnected, isTargetDevice, serviceUuids);
        }

        @NotNull
        public String toString() {
            return "BluetoothDeviceInfo(device=" + this.device + ", name=" + this.name + ", address=" + this.address + ", rssi=" + this.rssi + ", isPaired=" + this.isPaired + ", isConnected=" + this.isConnected + ", isTargetDevice=" + this.isTargetDevice + ", serviceUuids=" + this.serviceUuids + ")";
        }

        public int hashCode() {
            result = (this.device == null) ? 0 : this.device.hashCode();
            result = result * 31 + ((this.name == null) ? 0 : this.name.hashCode());
            result = result * 31 + ((this.address == null) ? 0 : this.address.hashCode());
            result = result * 31 + ((this.rssi == null) ? 0 : this.rssi.hashCode());
            result = result * 31 + ((this.isPaired == null) ? 0 : this.isPaired.hashCode());
            result = result * 31 + ((this.isConnected == null) ? 0 : this.isConnected.hashCode());
            result = result * 31 + ((this.isTargetDevice == null) ? 0 : this.isTargetDevice.hashCode());
            return result * 31 + ((this.serviceUuids == null) ? 0 : this.serviceUuids.hashCode());
        }

        public boolean equals(@Nullable Object other) {
            if (this == other) return true;
            if (!(other instanceof BluetoothDeviceInfo)) return false;
            BluetoothDeviceInfo bluetoothDeviceInfo = (BluetoothDeviceInfo) other;
            return !Intrinsics.areEqual(this.device, bluetoothDeviceInfo.device) ? false : (!Intrinsics.areEqual(this.name, bluetoothDeviceInfo.name) ? false : (!Intrinsics.areEqual(this.address, bluetoothDeviceInfo.address) ? false : (!Intrinsics.areEqual(this.rssi, bluetoothDeviceInfo.rssi) ? false : (!Intrinsics.areEqual(this.isPaired, bluetoothDeviceInfo.isPaired) ? false : (!Intrinsics.areEqual(this.isConnected, bluetoothDeviceInfo.isConnected) ? false : (!Intrinsics.areEqual(this.isTargetDevice, bluetoothDeviceInfo.isTargetDevice) ? false : (!!Intrinsics.areEqual(this.serviceUuids, bluetoothDeviceInfo.serviceUuids))))))));
        }

        public BluetoothDeviceInfo() {
            this(null, null, null, null, null, null, null, null, 255, null);
        }
    }

    @NotNull
    public final List<BluetoothDeviceInfo> getDiscoveredDevices() {
        return this.discoveredDevices;
    }

    @Nullable
    public final BluetoothDeviceInfo getTargetDevice() {
        return this.targetDevice;
    }

    public final void setTargetDevice(@Nullable BluetoothDeviceInfo<set-?>) {
        this.targetDevice = < set - ? >;
    }

    @Nullable
    public final BluetoothGatt getConnectedGatt() {
        return this.connectedGatt;
    }

    public final void setConnectedGatt(@Nullable BluetoothGatt<set-?>) {
        this.connectedGatt = < set - ? >;
    }

    public final int getBatteryLevel() {
        return this.batteryLevel;
    }

    public final void setBatteryLevel(int <set-?>) {
        this.batteryLevel = < set - ? >;
    }

    @NotNull
    public final String getDeviceName() {
        return this.deviceName;
    }

    public final void setDeviceName(@NotNull String<set-?>) {
        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
        this.deviceName = < set - ? >;
    }

    @Nullable
    public final byte[] getCurrentGearState() {
        return this.currentGearState;
    }

    public final void setCurrentGearState(@Nullable byte[] <set-?>) {
        this.currentGearState = < set - ? >;
    }

    public final int getVibrationType() {
        return this.vibrationType;
    }

    public final void setVibrationType(int <set-?>) {
        this.vibrationType = < set - ? >;
    }

    public final int getRemainingTime() {
        return this.remainingTime;
    }

    public final void setRemainingTime(int <set-?>) {
        this.remainingTime = < set - ? >;
    }

    public final int getControlSource() {
        return this.controlSource;
    }

    public final void setControlSource(int <set-?>) {
        this.controlSource = < set - ? >;
    }

    public final boolean isScanning() {
        return this.isScanning;
    }

    public final void setScanning(boolean <set-?>) {
        this.isScanning = < set - ? >;
    }

    public final boolean isConnected() {
        return this.isConnected;
    }

    public final void setConnected(boolean <set-?>) {
        this.isConnected = < set - ? >;
    }

    @Nullable
    public final Function1<BluetoothDeviceInfo, Unit> getOnScanResult() {
        return (Function1) this.onScanResult;
    }

    public final void setOnScanResult(@Nullable Function1<? super BluetoothDeviceInfo, Unit> <set-?>) {
        this.onScanResult = < set - ? >;
    }

    @Nullable
    public final Function1<BluetoothDeviceInfo, Unit> getOnTargetDeviceFound() {
        return (Function1) this.onTargetDeviceFound;
    }

    public final void setOnTargetDeviceFound(@Nullable Function1<? super BluetoothDeviceInfo, Unit> <set-?>) {
        this.onTargetDeviceFound = < set - ? >;
    }

    @Nullable
    public final Function1<Boolean, Unit> getOnConnectionStateChanged() {
        return (Function1) this.onConnectionStateChanged;
    }

    public final void setOnConnectionStateChanged(@Nullable Function1<? super Boolean, Unit> <set-?>) {
        this.onConnectionStateChanged = < set - ? >;
    }

    @Nullable
    public final Function1<Integer, Unit> getOnBatteryLevelUpdated() {
        return (Function1) this.onBatteryLevelUpdated;
    }

    public final void setOnBatteryLevelUpdated(@Nullable Function1<? super Integer, Unit> <set-?>) {
        this.onBatteryLevelUpdated = < set - ? >;
    }

    @Nullable
    public final Function1<byte[], Unit> getOnCurrentGearUpdated() {
        return (Function1) this.onCurrentGearUpdated;
    }

    public final void setOnCurrentGearUpdated(@Nullable Function1<? super byte[], Unit> <set-?>) {
        this.onCurrentGearUpdated = < set - ? >;
    }

    @Nullable
    public final Function1<Integer, Unit> getOnVibrationTypeUpdated() {
        return (Function1) this.onVibrationTypeUpdated;
    }

    public final void setOnVibrationTypeUpdated(@Nullable Function1<? super Integer, Unit> <set-?>) {
        this.onVibrationTypeUpdated = < set - ? >;
    }

    @Nullable
    public final Function1<Integer, Unit> getOnRemainingTimeUpdated() {
        return (Function1) this.onRemainingTimeUpdated;
    }

    public final void setOnRemainingTimeUpdated(@Nullable Function1<? super Integer, Unit> <set-?>) {
        this.onRemainingTimeUpdated = < set - ? >;
    }

    @Nullable
    public final Function1<Integer, Unit> getOnControlSourceUpdated() {
        return (Function1) this.onControlSourceUpdated;
    }

    public final void setOnControlSourceUpdated(@Nullable Function1<? super Integer, Unit> <set-?>) {
        this.onControlSourceUpdated = < set - ? >;
    }

    @NotNull
    public final List<String> getTargetPrefixes() {
        return this.targetPrefixes;
    }

    public final boolean isDeviceNameMatchPrefix(@Nullable BluetoothDeviceInfo bluetoothDevice) { // Byte code:
        //   0: aload_1
        //   1: dup
        //   2: ifnull -> 12
        //   5: invokevirtual getName : ()Ljava/lang/String;
        //   8: dup
        //   9: ifnonnull -> 15
        //   12: pop
        //   13: ldc ''
        //   15: astore_2
        //   16: aload_2
        //   17: checkcast java/lang/CharSequence
        //   20: invokestatic trim : (Ljava/lang/CharSequence;)Ljava/lang/CharSequence;
        //   23: invokevirtual toString : ()Ljava/lang/String;
        //   26: astore_3
        //   27: aload_3
        //   28: checkcast java/lang/CharSequence
        //   31: invokeinterface length : ()I
        //   36: ifne -> 43
        //   39: iconst_1
        //   40: goto -> 44
        //   43: iconst_0
        //   44: ifeq -> 49
        //   47: iconst_0
        //   48: ireturn
        //   49: aload_0
        //   50: getfield targetPrefixes : Ljava/util/List;
        //   53: checkcast java/lang/Iterable
        //   56: astore #4
        //   58: iconst_0
        //   59: istore #5
        //   61: aload #4
        //   63: instanceof java/util/Collection
        //   66: ifeq -> 86
        //   69: aload #4
        //   71: checkcast java/util/Collection
        //   74: invokeinterface isEmpty : ()Z
        //   79: ifeq -> 86
        //   82: iconst_0
        //   83: goto -> 141
        //   86: aload #4
        //   88: invokeinterface iterator : ()Ljava/util/Iterator;
        //   93: astore #6
        //   95: aload #6
        //   97: invokeinterface hasNext : ()Z
        //   102: ifeq -> 140
        //   105: aload #6
        //   107: invokeinterface next : ()Ljava/lang/Object;
        //   112: astore #7
        //   114: aload #7
        //   116: checkcast java/lang/String
        //   119: astore #8
        //   121: iconst_0
        //   122: istore #9
        //   124: aload_3
        //   125: aload #8
        //   127: iconst_0
        //   128: iconst_2
        //   129: aconst_null
        //   130: invokestatic startsWith$default : (Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z
        //   133: ifeq -> 95
        //   136: iconst_1
        //   137: goto -> 141
        //   140: iconst_0
        //   141: ireturn
        // Line number table:
        //   Java source line number -> byte code offset
        //   #110	-> 0
        //   #112	-> 16
        //   #112	-> 26
        //   #113	-> 27
        //   #113	-> 44
        //   #115	-> 47
        //   #118	-> 49
        //   #780	-> 61
        //   #781	-> 86
        //   #119	-> 124
        //   #781	-> 133
        //   #782	-> 140
        //   #118	-> 141
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   124	9	9	$i$a$-any-BluetoothManager$isDeviceNameMatchPrefix$1	I
        //   121	12	8	prefix	Ljava/lang/String;
        //   114	26	7	element$iv	Ljava/lang/Object;
        //   61	80	5	$i$f$any	I
        //   58	83	4	$this$any$iv	Ljava/lang/Iterable;
        //   16	126	2	deviceName	Ljava/lang/String;
        //   27	115	3	validDeviceName	Ljava/lang/String;
        //   0	142	0	this	Lcom/etouch/bt/BluetoothManager;
        //   0	142	1	bluetoothDevice	Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo; } @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\037\n\000\n\002\030\002\n\000\n\002\020\002\n\000\n\002\020\b\n\002\b\003\n\002\030\002\n\000*\001\000\b\n\030\0002\0020\001J\020\020\002\032\0020\0032\006\020\004\032\0020\005H\026J\030\020\006\032\0020\0032\006\020\007\032\0020\0052\006\020\b\032\0020\tH\026¨\006\n"}, d2 = {"com/etouch/bt/BluetoothManager$scanCallback$1", "Landroid/bluetooth/le/ScanCallback;", "onScanFailed", "", "errorCode", "", "onScanResult", "callbackType", "result", "Landroid/bluetooth/le/ScanResult;", "sdk_android_unity_bridge_v1_debug"}) @SourceDebugExtension({"SMAP\nBluetoothManager.kt\nKotlin\n*S Kotlin\n*F\n+ 1 BluetoothManager.kt\ncom/etouch/bt/BluetoothManager$scanCallback$1\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n+ 3 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,779:1\n1549#2:780\n1620#2,3:781\n1747#2,2:784\n1747#2,3:786\n1749#2:789\n1747#2,3:790\n1#3:793\n*S KotlinDebug\n*F\n+ 1 BluetoothManager.kt\ncom/etouch/bt/BluetoothManager$scanCallback$1\n*L\n185#1:780\n185#1:781,3\n188#1:784,2\n189#1:786,3\n188#1:789\n209#1:790,3\n*E\n"}) public static final class BluetoothManager$scanCallback$1 extends ScanCallback { public void onScanResult(int callbackType, @NotNull ScanResult result) { // Byte code:
        //   0: aload_2
        //   1: ldc 'result'
        //   3: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
        //   6: nop
        //   7: aload_2
        //   8: invokevirtual getDevice : ()Landroid/bluetooth/BluetoothDevice;
        //   11: astore_3
        //   12: aload_2
        //   13: invokevirtual getRssi : ()I
        //   16: istore #4
        //   18: aload_2
        //   19: invokevirtual getScanRecord : ()Landroid/bluetooth/le/ScanRecord;
        //   22: astore #5
        //   24: aload #5
        //   26: dup
        //   27: ifnull -> 37
        //   30: invokevirtual getDeviceName : ()Ljava/lang/String;
        //   33: dup
        //   34: ifnonnull -> 49
        //   37: pop
        //   38: aload_3
        //   39: invokevirtual getName : ()Ljava/lang/String;
        //   42: dup
        //   43: ifnonnull -> 49
        //   46: pop
        //   47: ldc 'Unknown Device'
        //   49: astore #6
        //   51: iconst_0
        //   52: istore #7
        //   54: new kotlin/jvm/internal/Ref$ObjectRef
        //   57: dup
        //   58: invokespecial <init> : ()V
        //   61: astore #8
        //   63: aload #5
        //   65: dup
        //   66: ifnull -> 399
        //   69: invokevirtual getServiceUuids : ()Ljava/util/List;
        //   72: dup
        //   73: ifnull -> 399
        //   76: astore #11
        //   78: iconst_0
        //   79: istore #12
        //   81: aload #8
        //   83: aload #11
        //   85: checkcast java/lang/Iterable
        //   88: astore #13
        //   90: astore #14
        //   92: iconst_0
        //   93: istore #15
        //   95: aload #13
        //   97: astore #16
        //   99: new java/util/ArrayList
        //   102: dup
        //   103: aload #13
        //   105: bipush #10
        //   107: invokestatic collectionSizeOrDefault : (Ljava/lang/Iterable;I)I
        //   110: invokespecial <init> : (I)V
        //   113: checkcast java/util/Collection
        //   116: astore #17
        //   118: iconst_0
        //   119: istore #18
        //   121: aload #16
        //   123: invokeinterface iterator : ()Ljava/util/Iterator;
        //   128: astore #19
        //   130: aload #19
        //   132: invokeinterface hasNext : ()Z
        //   137: ifeq -> 202
        //   140: aload #19
        //   142: invokeinterface next : ()Ljava/lang/Object;
        //   147: astore #20
        //   149: aload #17
        //   151: aload #20
        //   153: checkcast android/os/ParcelUuid
        //   156: astore #21
        //   158: astore #22
        //   160: iconst_0
        //   161: istore #23
        //   163: aload #21
        //   165: invokevirtual getUuid : ()Ljava/util/UUID;
        //   168: invokevirtual toString : ()Ljava/lang/String;
        //   171: dup
        //   172: ldc 'toString(...)'
        //   174: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
        //   177: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
        //   180: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
        //   183: dup
        //   184: ldc 'toUpperCase(...)'
        //   186: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
        //   189: nop
        //   190: aload #22
        //   192: swap
        //   193: invokeinterface add : (Ljava/lang/Object;)Z
        //   198: pop
        //   199: goto -> 130
        //   202: aload #17
        //   204: checkcast java/util/List
        //   207: nop
        //   208: aload #14
        //   210: swap
        //   211: putfield element : Ljava/lang/Object;
        //   214: invokestatic access$getREQUIRED_SERVICE_UUIDS$cp : ()Ljava/util/List;
        //   217: checkcast java/lang/Iterable
        //   220: astore #13
        //   222: iconst_0
        //   223: istore #15
        //   225: aload #13
        //   227: instanceof java/util/Collection
        //   230: ifeq -> 250
        //   233: aload #13
        //   235: checkcast java/util/Collection
        //   238: invokeinterface isEmpty : ()Z
        //   243: ifeq -> 250
        //   246: iconst_0
        //   247: goto -> 388
        //   250: aload #13
        //   252: invokeinterface iterator : ()Ljava/util/Iterator;
        //   257: astore #16
        //   259: aload #16
        //   261: invokeinterface hasNext : ()Z
        //   266: ifeq -> 387
        //   269: aload #16
        //   271: invokeinterface next : ()Ljava/lang/Object;
        //   276: astore #17
        //   278: aload #17
        //   280: checkcast java/util/UUID
        //   283: astore #18
        //   285: iconst_0
        //   286: istore #19
        //   288: aload #11
        //   290: checkcast java/lang/Iterable
        //   293: astore #20
        //   295: iconst_0
        //   296: istore #21
        //   298: aload #20
        //   300: instanceof java/util/Collection
        //   303: ifeq -> 323
        //   306: aload #20
        //   308: checkcast java/util/Collection
        //   311: invokeinterface isEmpty : ()Z
        //   316: ifeq -> 323
        //   319: iconst_0
        //   320: goto -> 379
        //   323: aload #20
        //   325: invokeinterface iterator : ()Ljava/util/Iterator;
        //   330: astore #23
        //   332: aload #23
        //   334: invokeinterface hasNext : ()Z
        //   339: ifeq -> 378
        //   342: aload #23
        //   344: invokeinterface next : ()Ljava/lang/Object;
        //   349: astore #24
        //   351: aload #24
        //   353: checkcast android/os/ParcelUuid
        //   356: astore #25
        //   358: iconst_0
        //   359: istore #26
        //   361: aload #25
        //   363: invokevirtual getUuid : ()Ljava/util/UUID;
        //   366: aload #18
        //   368: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
        //   371: ifeq -> 332
        //   374: iconst_1
        //   375: goto -> 379
        //   378: iconst_0
        //   379: nop
        //   380: ifeq -> 259
        //   383: iconst_1
        //   384: goto -> 388
        //   387: iconst_0
        //   388: istore #7
        //   390: iload #7
        //   392: ifeq -> 395
        //   395: nop
        //   396: goto -> 401
        //   399: pop
        //   400: nop
        //   401: new com/etouch/bt/BluetoothManager$BluetoothDeviceInfo
        //   404: dup
        //   405: aload_3
        //   406: aload #6
        //   408: aload_3
        //   409: invokevirtual getAddress : ()Ljava/lang/String;
        //   412: iload #4
        //   414: invokestatic valueOf : (I)Ljava/lang/Integer;
        //   417: aload_3
        //   418: invokevirtual getBondState : ()I
        //   421: bipush #12
        //   423: if_icmpne -> 430
        //   426: iconst_1
        //   427: goto -> 431
        //   430: iconst_0
        //   431: invokestatic valueOf : (Z)Ljava/lang/Boolean;
        //   434: iconst_0
        //   435: invokestatic valueOf : (Z)Ljava/lang/Boolean;
        //   438: iload #7
        //   440: invokestatic valueOf : (Z)Ljava/lang/Boolean;
        //   443: aload #8
        //   445: getfield element : Ljava/lang/Object;
        //   448: checkcast java/util/List
        //   451: invokespecial <init> : (Landroid/bluetooth/BluetoothDevice;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Integer;Ljava/lang/Boolean;Ljava/lang/Boolean;Ljava/lang/Boolean;Ljava/util/List;)V
        //   454: astore #9
        //   456: aload_0
        //   457: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
        //   460: invokevirtual getDiscoveredDevices : ()Ljava/util/List;
        //   463: checkcast java/lang/Iterable
        //   466: astore #10
        //   468: iconst_0
        //   469: istore #11
        //   471: aload #10
        //   473: instanceof java/util/Collection
        //   476: ifeq -> 496
        //   479: aload #10
        //   481: checkcast java/util/Collection
        //   484: invokeinterface isEmpty : ()Z
        //   489: ifeq -> 496
        //   492: iconst_0
        //   493: goto -> 554
        //   496: aload #10
        //   498: invokeinterface iterator : ()Ljava/util/Iterator;
        //   503: astore #12
        //   505: aload #12
        //   507: invokeinterface hasNext : ()Z
        //   512: ifeq -> 553
        //   515: aload #12
        //   517: invokeinterface next : ()Ljava/lang/Object;
        //   522: astore #13
        //   524: aload #13
        //   526: checkcast com/etouch/bt/BluetoothManager$BluetoothDeviceInfo
        //   529: astore #14
        //   531: iconst_0
        //   532: istore #15
        //   534: aload #14
        //   536: invokevirtual getAddress : ()Ljava/lang/String;
        //   539: aload_3
        //   540: invokevirtual getAddress : ()Ljava/lang/String;
        //   543: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
        //   546: ifeq -> 505
        //   549: iconst_1
        //   550: goto -> 554
        //   553: iconst_0
        //   554: ifne -> 647
        //   557: aload_0
        //   558: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
        //   561: aload #9
        //   563: invokevirtual isDeviceNameMatchPrefix : (Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;)Z
        //   566: ifeq -> 811
        //   569: aload_0
        //   570: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
        //   573: invokevirtual getDiscoveredDevices : ()Ljava/util/List;
        //   576: aload #9
        //   578: invokeinterface add : (Ljava/lang/Object;)Z
        //   583: pop
        //   584: aload_0
        //   585: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
        //   588: invokevirtual getOnScanResult : ()Lkotlin/jvm/functions/Function1;
        //   591: dup
        //   592: ifnull -> 606
        //   595: aload #9
        //   597: invokeinterface invoke : (Ljava/lang/Object;)Ljava/lang/Object;
        //   602: pop
        //   603: goto -> 607
        //   606: pop
        //   607: iload #7
        //   609: ifeq -> 811
        //   612: aload_0
        //   613: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
        //   616: aload #9
        //   618: invokevirtual setTargetDevice : (Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;)V
        //   621: aload_0
        //   622: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
        //   625: invokevirtual getOnTargetDeviceFound : ()Lkotlin/jvm/functions/Function1;
        //   628: dup
        //   629: ifnull -> 643
        //   632: aload #9
        //   634: invokeinterface invoke : (Ljava/lang/Object;)Ljava/lang/Object;
        //   639: pop
        //   640: goto -> 811
        //   643: pop
        //   644: goto -> 811
        //   647: aload_0
        //   648: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
        //   651: invokevirtual getDiscoveredDevices : ()Ljava/util/List;
        //   654: checkcast java/lang/Iterable
        //   657: astore #12
        //   659: aload #12
        //   661: invokeinterface iterator : ()Ljava/util/Iterator;
        //   666: astore #13
        //   668: aload #13
        //   670: invokeinterface hasNext : ()Z
        //   675: ifeq -> 717
        //   678: aload #13
        //   680: invokeinterface next : ()Ljava/lang/Object;
        //   685: astore #14
        //   687: aload #14
        //   689: checkcast com/etouch/bt/BluetoothManager$BluetoothDeviceInfo
        //   692: astore #15
        //   694: iconst_0
        //   695: istore #16
        //   697: aload #15
        //   699: invokevirtual getAddress : ()Ljava/lang/String;
        //   702: aload_3
        //   703: invokevirtual getAddress : ()Ljava/lang/String;
        //   706: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
        //   709: ifeq -> 668
        //   712: aload #14
        //   714: goto -> 718
        //   717: aconst_null
        //   718: checkcast com/etouch/bt/BluetoothManager$BluetoothDeviceInfo
        //   721: dup
        //   722: ifnull -> 805
        //   725: astore #11
        //   727: aload_0
        //   728: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
        //   731: astore #12
        //   733: aload #11
        //   735: astore #13
        //   737: iconst_0
        //   738: istore #14
        //   740: aload #13
        //   742: iload #4
        //   744: invokestatic valueOf : (I)Ljava/lang/Integer;
        //   747: invokevirtual setRssi : (Ljava/lang/Integer;)V
        //   750: aload #13
        //   752: iload #7
        //   754: invokestatic valueOf : (Z)Ljava/lang/Boolean;
        //   757: invokevirtual setTargetDevice : (Ljava/lang/Boolean;)V
        //   760: iload #7
        //   762: ifeq -> 801
        //   765: aload #12
        //   767: invokevirtual getTargetDevice : ()Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
        //   770: ifnonnull -> 801
        //   773: aload #12
        //   775: aload #13
        //   777: invokevirtual setTargetDevice : (Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;)V
        //   780: aload #12
        //   782: invokevirtual getOnTargetDeviceFound : ()Lkotlin/jvm/functions/Function1;
        //   785: dup
        //   786: ifnull -> 800
        //   789: aload #13
        //   791: invokeinterface invoke : (Ljava/lang/Object;)Ljava/lang/Object;
        //   796: pop
        //   797: goto -> 801
        //   800: pop
        //   801: nop
        //   802: goto -> 811
        //   805: pop
        //   806: nop
        //   807: goto -> 811
        //   810: astore_3
        //   811: return
        // Line number table:
        //   Java source line number -> byte code offset
        //   #173	-> 6
        //   #174	-> 7
        //   #175	-> 12
        //   #176	-> 18
        //   #178	-> 24
        //   #181	-> 51
        //   #182	-> 54
        //   #184	-> 63
        //   #185	-> 81
        //   #780	-> 95
        //   #781	-> 121
        //   #782	-> 149
        //   #185	-> 163
        //   #185	-> 189
        //   #782	-> 193
        //   #783	-> 202
        //   #780	-> 207
        //   #185	-> 211
        //   #188	-> 214
        //   #784	-> 225
        //   #785	-> 250
        //   #189	-> 288
        //   #786	-> 298
        //   #787	-> 323
        //   #189	-> 361
        //   #787	-> 371
        //   #788	-> 378
        //   #189	-> 379
        //   #785	-> 380
        //   #789	-> 387
        //   #188	-> 388
        //   #192	-> 390
        //   #195	-> 395
        //   #184	-> 396
        //   #184	-> 399
        //   #197	-> 401
        //   #198	-> 405
        //   #199	-> 406
        //   #200	-> 408
        //   #201	-> 412
        //   #202	-> 417
        //   #203	-> 434
        //   #204	-> 438
        //   #205	-> 443
        //   #197	-> 451
        //   #209	-> 456
        //   #790	-> 471
        //   #791	-> 496
        //   #209	-> 534
        //   #791	-> 546
        //   #792	-> 553
        //   #209	-> 554
        //   #210	-> 557
        //   #211	-> 569
        //   #212	-> 584
        //   #214	-> 607
        //   #215	-> 612
        //   #216	-> 621
        //   #221	-> 647
        //   #793	-> 694
        //   #221	-> 697
        //   #221	-> 709
        //   #221	-> 718
        //   #222	-> 740
        //   #223	-> 750
        //   #224	-> 760
        //   #225	-> 773
        //   #226	-> 780
        //   #228	-> 801
        //   #221	-> 802
        //   #221	-> 805
        //   #230	-> 810
        //   #233	-> 811
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   163	27	23	$i$a$-map-BluetoothManager$scanCallback$1$onScanResult$1$1	I
        //   160	30	21	it	Landroid/os/ParcelUuid;
        //   149	50	20	item$iv$iv	Ljava/lang/Object;
        //   121	83	18	$i$f$mapTo	I
        //   118	86	16	$this$mapTo$iv$iv	Ljava/lang/Iterable;
        //   118	86	17	destination$iv$iv	Ljava/util/Collection;
        //   95	113	15	$i$f$map	I
        //   92	116	13	$this$map$iv	Ljava/lang/Iterable;
        //   361	10	26	$i$a$-any-BluetoothManager$scanCallback$1$onScanResult$1$2$1	I
        //   358	13	25	it	Landroid/os/ParcelUuid;
        //   351	27	24	element$iv	Ljava/lang/Object;
        //   298	81	21	$i$f$any	I
        //   295	84	20	$this$any$iv	Ljava/lang/Iterable;
        //   288	92	19	$i$a$-any-BluetoothManager$scanCallback$1$onScanResult$1$2	I
        //   285	95	18	requiredUuid	Ljava/util/UUID;
        //   278	109	17	element$iv	Ljava/lang/Object;
        //   225	163	15	$i$f$any	I
        //   222	166	13	$this$any$iv	Ljava/lang/Iterable;
        //   81	315	12	$i$a$-let-BluetoothManager$scanCallback$1$onScanResult$1	I
        //   78	318	11	uuids	Ljava/util/List;
        //   534	12	15	$i$a$-any-BluetoothManager$scanCallback$1$onScanResult$2	I
        //   531	15	14	it	Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
        //   524	29	13	element$iv	Ljava/lang/Object;
        //   471	83	11	$i$f$any	I
        //   468	86	10	$this$any$iv	Ljava/lang/Iterable;
        //   697	12	16	$i$a$-find-BluetoothManager$scanCallback$1$onScanResult$3	I
        //   694	15	15	it	Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
        //   740	62	14	$i$a$-apply-BluetoothManager$scanCallback$1$onScanResult$4	I
        //   737	65	13	$this$onScanResult_u24lambda_u246	Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
        //   12	795	3	device	Landroid/bluetooth/BluetoothDevice;
        //   18	789	4	rssi	I
        //   24	783	5	scanRecord	Landroid/bluetooth/le/ScanRecord;
        //   51	756	6	deviceName	Ljava/lang/String;
        //   54	753	7	isTargetDevice	Z
        //   63	744	8	serviceUuidList	Lkotlin/jvm/internal/Ref$ObjectRef;
        //   456	351	9	bluetoothDevice	Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
        //   0	812	0	this	Lcom/etouch/bt/BluetoothManager$scanCallback$1;
        //   0	812	1	callbackType	I
        //   0	812	2	result	Landroid/bluetooth/le/ScanResult;
        // Exception table:
        //   from	to	target	type
        //   6	807	810	java/lang/Exception } public void onScanFailed(int errorCode) {} } @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000'\n\000\n\002\030\002\n\000\n\002\020\002\n\000\n\002\030\002\n\000\n\002\030\002\n\002\b\002\n\002\020\b\n\002\b\004*\001\000\b\n\030\0002\0020\001J\030\020\002\032\0020\0032\006\020\004\032\0020\0052\006\020\006\032\0020\007H\026J \020\b\032\0020\0032\006\020\004\032\0020\0052\006\020\006\032\0020\0072\006\020\t\032\0020\nH\026J \020\013\032\0020\0032\006\020\004\032\0020\0052\006\020\t\032\0020\n2\006\020\f\032\0020\nH\026J\030\020\r\032\0020\0032\006\020\004\032\0020\0052\006\020\t\032\0020\nH\026¨\006\016"}, d2 = {"com/etouch/bt/BluetoothManager$gattCallback$1", "Landroid/bluetooth/BluetoothGattCallback;", "onCharacteristicChanged", "", "gatt", "Landroid/bluetooth/BluetoothGatt;", "characteristic", "Landroid/bluetooth/BluetoothGattCharacteristic;", "onCharacteristicRead", "status", "", "onConnectionStateChange", "newState", "onServicesDiscovered", "sdk_android_unity_bridge_v1_debug"}) @SourceDebugExtension({"SMAP\nBluetoothManager.kt\nKotlin\n*S Kotlin\n*F\n+ 1 BluetoothManager.kt\ncom/etouch/bt/BluetoothManager$gattCallback$1\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,779:1\n1855#2:780\n1855#2,2:781\n1856#2:783\n*S KotlinDebug\n*F\n+ 1 BluetoothManager.kt\ncom/etouch/bt/BluetoothManager$gattCallback$1\n*L\n275#1:780\n279#1:781,2\n275#1:783\n*E\n"}) public static final class BluetoothManager$gattCallback$1 extends BluetoothGattCallback { public void onConnectionStateChange(@NotNull BluetoothGatt gatt, int status, int newState) { Intrinsics.checkNotNullParameter(gatt, "gatt"); switch (newState) { case 2: BluetoothManager.this.setConnected(true); BluetoothManager.this.setConnectedGatt(gatt); if (BluetoothManager.this.getTargetDevice() == null) { BluetoothManager.this.getTargetDevice(); } else { BluetoothManager.this.getTargetDevice().setConnected(Boolean.valueOf(true)); }  BluetoothManager.this.handler.post(BluetoothManager.this::onConnectionStateChange$lambda$0); BluetoothManager.this.handler.postDelayed(gatt::onConnectionStateChange$lambda$1, 1500L); break;case 0: BluetoothManager.this.setConnected(false); gatt.close(); BluetoothManager.this.setConnectedGatt(null); if (BluetoothManager.this.getTargetDevice() == null) { BluetoothManager.this.getTargetDevice(); } else { BluetoothManager.this.getTargetDevice().setConnected(Boolean.valueOf(false)); }  BluetoothManager.this.handler.post(BluetoothManager.this::onConnectionStateChange$lambda$2); break; }  } private static final void onConnectionStateChange$lambda$0(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnConnectionStateChanged() != null) { BluetoothManager.this.getOnConnectionStateChanged().invoke(Boolean.valueOf(true)); } else { BluetoothManager.this.getOnConnectionStateChanged(); }  } public void onServicesDiscovered(@NotNull BluetoothGatt gatt, int status) { Iterator iterator; Intrinsics.checkNotNullParameter(gatt, "gatt"); if (status == 0) { Intrinsics.checkNotNullExpressionValue(gatt.getServices(), "getServices(...)"); List list = gatt.getServices(); BluetoothManager bluetoothManager = BluetoothManager.this; int $i$f$forEach = 0; iterator = list.iterator(); } else { return; }  if (iterator.hasNext()) { Object element$iv = iterator.next(); BluetoothGattService service = (BluetoothGattService)element$iv; int $i$a$-forEach-BluetoothManager$gattCallback$1$onServicesDiscovered$1 = 0; Intrinsics.checkNotNullExpressionValue(service.getCharacteristics(), "getCharacteristics(...)"); Iterable $this$forEach$iv = service.getCharacteristics(); int $i$f$forEach = 0;
        Iterator iterator1 = $this$forEach$iv.iterator();
    }

    BluetoothManager .this.handler.postDelayed(BluetoothManager .this::onServicesDiscovered$lambda$5,500L);
}

private static final void onConnectionStateChange$lambda$1(BluetoothGatt $gatt) {
    Intrinsics.checkNotNullParameter($gatt, "$gatt");
    $gatt.discoverServices();
}

private static final void onConnectionStateChange$lambda$2(BluetoothManager this$0) {
    Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0");
    if (BluetoothManager.this.getOnConnectionStateChanged() != null) {
        BluetoothManager.this.getOnConnectionStateChanged().invoke(Boolean.valueOf(false));
    } else {
        BluetoothManager.this.getOnConnectionStateChanged();
    }
}

private static final void onServicesDiscovered$lambda$5(BluetoothManager this$0) {
    Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0");
    BluetoothManager.this.readDeviceInfo();
}

public void onCharacteristicRead(@NotNull BluetoothGatt gatt, @NotNull BluetoothGattCharacteristic characteristic, int status) { // Byte code:
    //   0: aload_1
    //   1: ldc 'gatt'
    //   3: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
    //   6: aload_2
    //   7: ldc 'characteristic'
    //   9: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
    //   12: iload_3
    //   13: ifne -> 572
    //   16: aload_2
    //   17: invokevirtual getUuid : ()Ljava/util/UUID;
    //   20: invokevirtual toString : ()Ljava/lang/String;
    //   23: dup
    //   24: ldc 'toString(...)'
    //   26: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   29: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   32: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   35: dup
    //   36: ldc 'toUpperCase(...)'
    //   38: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   41: astore #4
    //   43: aload #4
    //   45: ldc '00002A19-0000-1000-8000-00805F9B34FB'
    //   47: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   50: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   53: dup
    //   54: ldc 'toUpperCase(...)'
    //   56: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   59: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   62: ifeq -> 135
    //   65: aload_2
    //   66: invokevirtual getValue : ()[B
    //   69: dup
    //   70: ldc 'getValue(...)'
    //   72: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   75: arraylength
    //   76: ifne -> 83
    //   79: iconst_1
    //   80: goto -> 84
    //   83: iconst_0
    //   84: ifne -> 91
    //   87: iconst_1
    //   88: goto -> 92
    //   91: iconst_0
    //   92: ifeq -> 572
    //   95: aload_0
    //   96: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   99: aload_2
    //   100: invokevirtual getValue : ()[B
    //   103: iconst_0
    //   104: baload
    //   105: sipush #255
    //   108: iand
    //   109: invokevirtual setBatteryLevel : (I)V
    //   112: aload_0
    //   113: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   116: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   119: aload_0
    //   120: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   123: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;)Ljava/lang/Runnable;
    //   128: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   131: pop
    //   132: goto -> 572
    //   135: aload #4
    //   137: ldc '00002A00-0000-1000-8000-00805F9B34FB'
    //   139: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   142: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   145: dup
    //   146: ldc 'toUpperCase(...)'
    //   148: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   151: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   154: ifeq -> 191
    //   157: aload_0
    //   158: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   161: aload_2
    //   162: invokevirtual getValue : ()[B
    //   165: dup
    //   166: ldc 'getValue(...)'
    //   168: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   171: astore #5
    //   173: new java/lang/String
    //   176: dup
    //   177: aload #5
    //   179: getstatic kotlin/text/Charsets.UTF_8 : Ljava/nio/charset/Charset;
    //   182: invokespecial <init> : ([BLjava/nio/charset/Charset;)V
    //   185: invokevirtual setDeviceName : (Ljava/lang/String;)V
    //   188: goto -> 572
    //   191: aload #4
    //   193: ldc '0000F220-0000-1000-8000-00805F9B34FB'
    //   195: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   198: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   201: dup
    //   202: ldc 'toUpperCase(...)'
    //   204: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   207: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   210: ifeq -> 278
    //   213: aload_2
    //   214: invokevirtual getValue : ()[B
    //   217: dup
    //   218: ldc 'getValue(...)'
    //   220: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   223: arraylength
    //   224: ifne -> 231
    //   227: iconst_1
    //   228: goto -> 232
    //   231: iconst_0
    //   232: ifne -> 239
    //   235: iconst_1
    //   236: goto -> 240
    //   239: iconst_0
    //   240: ifeq -> 572
    //   243: aload_0
    //   244: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   247: aload_2
    //   248: invokevirtual getValue : ()[B
    //   251: invokevirtual setCurrentGearState : ([B)V
    //   254: aload_0
    //   255: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   258: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   261: aload_0
    //   262: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   265: aload_2
    //   266: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;Landroid/bluetooth/BluetoothGattCharacteristic;)Ljava/lang/Runnable;
    //   271: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   274: pop
    //   275: goto -> 572
    //   278: aload #4
    //   280: ldc '0000F221-0000-1000-8000-00805F9B34FB'
    //   282: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   285: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   288: dup
    //   289: ldc 'toUpperCase(...)'
    //   291: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   294: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   297: ifeq -> 370
    //   300: aload_2
    //   301: invokevirtual getValue : ()[B
    //   304: dup
    //   305: ldc 'getValue(...)'
    //   307: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   310: arraylength
    //   311: ifne -> 318
    //   314: iconst_1
    //   315: goto -> 319
    //   318: iconst_0
    //   319: ifne -> 326
    //   322: iconst_1
    //   323: goto -> 327
    //   326: iconst_0
    //   327: ifeq -> 572
    //   330: aload_0
    //   331: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   334: aload_2
    //   335: invokevirtual getValue : ()[B
    //   338: iconst_0
    //   339: baload
    //   340: sipush #255
    //   343: iand
    //   344: invokevirtual setVibrationType : (I)V
    //   347: aload_0
    //   348: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   351: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   354: aload_0
    //   355: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   358: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;)Ljava/lang/Runnable;
    //   363: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   366: pop
    //   367: goto -> 572
    //   370: aload #4
    //   372: ldc_w '0000F241-0000-1000-8000-00805F9B34FB'
    //   375: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   378: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   381: dup
    //   382: ldc 'toUpperCase(...)'
    //   384: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   387: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   390: ifeq -> 463
    //   393: aload_2
    //   394: invokevirtual getValue : ()[B
    //   397: dup
    //   398: ldc 'getValue(...)'
    //   400: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   403: arraylength
    //   404: ifne -> 411
    //   407: iconst_1
    //   408: goto -> 412
    //   411: iconst_0
    //   412: ifne -> 419
    //   415: iconst_1
    //   416: goto -> 420
    //   419: iconst_0
    //   420: ifeq -> 572
    //   423: aload_0
    //   424: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   427: aload_2
    //   428: invokevirtual getValue : ()[B
    //   431: iconst_0
    //   432: baload
    //   433: sipush #255
    //   436: iand
    //   437: invokevirtual setRemainingTime : (I)V
    //   440: aload_0
    //   441: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   444: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   447: aload_0
    //   448: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   451: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;)Ljava/lang/Runnable;
    //   456: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   459: pop
    //   460: goto -> 572
    //   463: aload #4
    //   465: ldc_w '0000F260-0000-1000-8000-00805F9B34FB'
    //   468: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   471: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   474: dup
    //   475: ldc 'toUpperCase(...)'
    //   477: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   480: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   483: ifeq -> 572
    //   486: aload_2
    //   487: invokevirtual getValue : ()[B
    //   490: dup
    //   491: ldc 'getValue(...)'
    //   493: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   496: arraylength
    //   497: ifne -> 504
    //   500: iconst_1
    //   501: goto -> 505
    //   504: iconst_0
    //   505: ifne -> 512
    //   508: iconst_1
    //   509: goto -> 513
    //   512: iconst_0
    //   513: ifeq -> 572
    //   516: aload_0
    //   517: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   520: aload_2
    //   521: invokevirtual getValue : ()[B
    //   524: iconst_0
    //   525: baload
    //   526: iconst_1
    //   527: iand
    //   528: invokevirtual setControlSource : (I)V
    //   531: aload_0
    //   532: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   535: invokevirtual getControlSource : ()I
    //   538: ifne -> 547
    //   541: ldc_w '物理按钮'
    //   544: goto -> 550
    //   547: ldc_w 'APP控制'
    //   550: astore #5
    //   552: aload_0
    //   553: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   556: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   559: aload_0
    //   560: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   563: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;)Ljava/lang/Runnable;
    //   568: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   571: pop
    //   572: return
    // Line number table:
    //   Java source line number -> byte code offset
    //   #310	-> 12
    //   #311	-> 16
    //   #311	-> 41
    //   #312	-> 43
    //   #312	-> 59
    //   #313	-> 65
    //   #313	-> 92
    //   #314	-> 95
    //   #316	-> 112
    //   #322	-> 135
    //   #322	-> 151
    //   #323	-> 157
    //   #323	-> 185
    //   #327	-> 191
    //   #327	-> 207
    //   #328	-> 213
    //   #328	-> 240
    //   #329	-> 243
    //   #338	-> 254
    //   #344	-> 278
    //   #344	-> 294
    //   #345	-> 300
    //   #345	-> 327
    //   #346	-> 330
    //   #348	-> 347
    //   #354	-> 370
    //   #354	-> 387
    //   #355	-> 393
    //   #355	-> 420
    //   #356	-> 423
    //   #358	-> 440
    //   #364	-> 463
    //   #364	-> 480
    //   #365	-> 486
    //   #365	-> 513
    //   #366	-> 516
    //   #367	-> 531
    //   #369	-> 552
    //   #378	-> 572
    // Local variable table:
    //   start	length	slot	name	descriptor
    //   552	20	5	sourceName	Ljava/lang/String;
    //   0	573	0	this	Lcom/etouch/bt/BluetoothManager$gattCallback$1;
    //   0	573	1	gatt	Landroid/bluetooth/BluetoothGatt;
    //   0	573	2	characteristic	Landroid/bluetooth/BluetoothGattCharacteristic;
    //   0	573	3	status	I } private static final void onCharacteristicRead$lambda$6(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnBatteryLevelUpdated() != null) { BluetoothManager.this.getOnBatteryLevelUpdated().invoke(Integer.valueOf(BluetoothManager.this.getBatteryLevel())); } else { BluetoothManager.this.getOnBatteryLevelUpdated(); }  } private static final void onCharacteristicRead$lambda$7(BluetoothManager this$0, BluetoothGattCharacteristic $characteristic) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); Intrinsics.checkNotNullParameter($characteristic, "$characteristic"); if (BluetoothManager.this.getOnCurrentGearUpdated() != null) { Intrinsics.checkNotNullExpressionValue($characteristic.getValue(), "getValue(...)"); BluetoothManager.this.getOnCurrentGearUpdated().invoke($characteristic.getValue()); } else { BluetoothManager.this.getOnCurrentGearUpdated(); }  } private static final void onCharacteristicRead$lambda$8(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnVibrationTypeUpdated() != null) { BluetoothManager.this.getOnVibrationTypeUpdated().invoke(Integer.valueOf(BluetoothManager.this.getVibrationType())); } else { BluetoothManager.this.getOnVibrationTypeUpdated(); }  } private static final void onCharacteristicRead$lambda$9(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnRemainingTimeUpdated() != null) { BluetoothManager.this.getOnRemainingTimeUpdated().invoke(Integer.valueOf(BluetoothManager.this.getRemainingTime())); } else { BluetoothManager.this.getOnRemainingTimeUpdated(); }  } private static final void onCharacteristicRead$lambda$10(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnControlSourceUpdated() != null) { BluetoothManager.this.getOnControlSourceUpdated().invoke(Integer.valueOf(BluetoothManager.this.getControlSource())); } else { BluetoothManager.this.getOnControlSourceUpdated(); }  } public void onCharacteristicChanged(@NotNull BluetoothGatt gatt, @NotNull BluetoothGattCharacteristic characteristic) { // Byte code:
    //   0: aload_1
    //   1: ldc 'gatt'
    //   3: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
    //   6: aload_2
    //   7: ldc 'characteristic'
    //   9: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
    //   12: aload_2
    //   13: invokevirtual getValue : ()[B
    //   16: astore_3
    //   17: aload_2
    //   18: invokevirtual getUuid : ()Ljava/util/UUID;
    //   21: invokevirtual toString : ()Ljava/lang/String;
    //   24: dup
    //   25: ldc 'toString(...)'
    //   27: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   30: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   33: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   36: dup
    //   37: ldc 'toUpperCase(...)'
    //   39: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   42: astore #4
    //   44: aload #4
    //   46: ldc '00002A19-0000-1000-8000-00805F9B34FB'
    //   48: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   51: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   54: dup
    //   55: ldc 'toUpperCase(...)'
    //   57: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   60: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   63: ifeq -> 128
    //   66: aload_3
    //   67: ifnull -> 477
    //   70: aload_3
    //   71: arraylength
    //   72: ifne -> 79
    //   75: iconst_1
    //   76: goto -> 80
    //   79: iconst_0
    //   80: ifne -> 87
    //   83: iconst_1
    //   84: goto -> 88
    //   87: iconst_0
    //   88: ifeq -> 477
    //   91: aload_0
    //   92: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   95: aload_3
    //   96: iconst_0
    //   97: baload
    //   98: sipush #255
    //   101: iand
    //   102: invokevirtual setBatteryLevel : (I)V
    //   105: aload_0
    //   106: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   109: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   112: aload_0
    //   113: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   116: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;)Ljava/lang/Runnable;
    //   121: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   124: pop
    //   125: goto -> 477
    //   128: aload #4
    //   130: ldc '0000F220-0000-1000-8000-00805F9B34FB'
    //   132: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   135: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   138: dup
    //   139: ldc 'toUpperCase(...)'
    //   141: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   144: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   147: ifeq -> 207
    //   150: aload_3
    //   151: ifnull -> 477
    //   154: aload_3
    //   155: arraylength
    //   156: ifne -> 163
    //   159: iconst_1
    //   160: goto -> 164
    //   163: iconst_0
    //   164: ifne -> 171
    //   167: iconst_1
    //   168: goto -> 172
    //   171: iconst_0
    //   172: ifeq -> 477
    //   175: aload_0
    //   176: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   179: aload_3
    //   180: invokevirtual setCurrentGearState : ([B)V
    //   183: aload_0
    //   184: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   187: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   190: aload_0
    //   191: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   194: aload_3
    //   195: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;[B)Ljava/lang/Runnable;
    //   200: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   203: pop
    //   204: goto -> 477
    //   207: aload #4
    //   209: ldc '0000F221-0000-1000-8000-00805F9B34FB'
    //   211: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   214: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   217: dup
    //   218: ldc 'toUpperCase(...)'
    //   220: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   223: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   226: ifeq -> 291
    //   229: aload_3
    //   230: ifnull -> 477
    //   233: aload_3
    //   234: arraylength
    //   235: ifne -> 242
    //   238: iconst_1
    //   239: goto -> 243
    //   242: iconst_0
    //   243: ifne -> 250
    //   246: iconst_1
    //   247: goto -> 251
    //   250: iconst_0
    //   251: ifeq -> 477
    //   254: aload_0
    //   255: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   258: aload_3
    //   259: iconst_0
    //   260: baload
    //   261: sipush #255
    //   264: iand
    //   265: invokevirtual setVibrationType : (I)V
    //   268: aload_0
    //   269: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   272: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   275: aload_0
    //   276: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   279: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;)Ljava/lang/Runnable;
    //   284: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   287: pop
    //   288: goto -> 477
    //   291: aload #4
    //   293: ldc_w '0000F241-0000-1000-8000-00805F9B34FB'
    //   296: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   299: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   302: dup
    //   303: ldc 'toUpperCase(...)'
    //   305: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   308: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   311: ifeq -> 376
    //   314: aload_3
    //   315: ifnull -> 477
    //   318: aload_3
    //   319: arraylength
    //   320: ifne -> 327
    //   323: iconst_1
    //   324: goto -> 328
    //   327: iconst_0
    //   328: ifne -> 335
    //   331: iconst_1
    //   332: goto -> 336
    //   335: iconst_0
    //   336: ifeq -> 477
    //   339: aload_0
    //   340: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   343: aload_3
    //   344: iconst_0
    //   345: baload
    //   346: sipush #255
    //   349: iand
    //   350: invokevirtual setRemainingTime : (I)V
    //   353: aload_0
    //   354: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   357: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   360: aload_0
    //   361: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   364: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;)Ljava/lang/Runnable;
    //   369: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   372: pop
    //   373: goto -> 477
    //   376: aload #4
    //   378: ldc_w '0000F260-0000-1000-8000-00805F9B34FB'
    //   381: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
    //   384: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
    //   387: dup
    //   388: ldc 'toUpperCase(...)'
    //   390: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
    //   393: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
    //   396: ifeq -> 477
    //   399: aload_3
    //   400: ifnull -> 477
    //   403: aload_3
    //   404: arraylength
    //   405: ifne -> 412
    //   408: iconst_1
    //   409: goto -> 413
    //   412: iconst_0
    //   413: ifne -> 420
    //   416: iconst_1
    //   417: goto -> 421
    //   420: iconst_0
    //   421: ifeq -> 477
    //   424: aload_0
    //   425: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   428: aload_3
    //   429: iconst_0
    //   430: baload
    //   431: iconst_1
    //   432: iand
    //   433: invokevirtual setControlSource : (I)V
    //   436: aload_0
    //   437: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   440: invokevirtual getControlSource : ()I
    //   443: ifne -> 452
    //   446: ldc_w '物理按钮'
    //   449: goto -> 455
    //   452: ldc_w 'APP控制'
    //   455: astore #5
    //   457: aload_0
    //   458: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   461: invokestatic access$getHandler$p : (Lcom/etouch/bt/BluetoothManager;)Landroid/os/Handler;
    //   464: aload_0
    //   465: getfield this$0 : Lcom/etouch/bt/BluetoothManager;
    //   468: <illegal opcode> run : (Lcom/etouch/bt/BluetoothManager;)Ljava/lang/Runnable;
    //   473: invokevirtual post : (Ljava/lang/Runnable;)Z
    //   476: pop
    //   477: return
    // Line number table:
    //   Java source line number -> byte code offset
    //   #385	-> 12
    //   #389	-> 17
    //   #389	-> 42
    //   #390	-> 44
    //   #390	-> 60
    //   #391	-> 66
    //   #391	-> 88
    //   #392	-> 91
    //   #394	-> 105
    //   #400	-> 128
    //   #400	-> 144
    //   #401	-> 150
    //   #401	-> 172
    //   #402	-> 175
    //   #407	-> 183
    //   #413	-> 207
    //   #413	-> 223
    //   #414	-> 229
    //   #414	-> 251
    //   #415	-> 254
    //   #417	-> 268
    //   #423	-> 291
    //   #423	-> 308
    //   #424	-> 314
    //   #424	-> 336
    //   #425	-> 339
    //   #427	-> 353
    //   #433	-> 376
    //   #433	-> 393
    //   #434	-> 399
    //   #434	-> 421
    //   #435	-> 424
    //   #436	-> 436
    //   #438	-> 457
    //   #448	-> 477
    // Local variable table:
    //   start	length	slot	name	descriptor
    //   457	20	5	sourceName	Ljava/lang/String;
    //   17	461	3	data	[B
    //   0	478	0	this	Lcom/etouch/bt/BluetoothManager$gattCallback$1;
    //   0	478	1	gatt	Landroid/bluetooth/BluetoothGatt;
    //   0	478	2	characteristic	Landroid/bluetooth/BluetoothGattCharacteristic; } private static final void onCharacteristicChanged$lambda$11(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnBatteryLevelUpdated() != null) { BluetoothManager.this.getOnBatteryLevelUpdated().invoke(Integer.valueOf(BluetoothManager.this.getBatteryLevel())); } else { BluetoothManager.this.getOnBatteryLevelUpdated(); }  } private static final void onCharacteristicChanged$lambda$12(BluetoothManager this$0, byte[] $data) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnCurrentGearUpdated() != null) { Intrinsics.checkNotNull($data); BluetoothManager.this.getOnCurrentGearUpdated().invoke($data); } else { BluetoothManager.this.getOnCurrentGearUpdated(); }  } private static final void onCharacteristicChanged$lambda$13(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnVibrationTypeUpdated() != null) { BluetoothManager.this.getOnVibrationTypeUpdated().invoke(Integer.valueOf(BluetoothManager.this.getVibrationType())); } else { BluetoothManager.this.getOnVibrationTypeUpdated(); }  } private static final void onCharacteristicChanged$lambda$14(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnRemainingTimeUpdated() != null) { BluetoothManager.this.getOnRemainingTimeUpdated().invoke(Integer.valueOf(BluetoothManager.this.getRemainingTime())); } else { BluetoothManager.this.getOnRemainingTimeUpdated(); }  } private static final void onCharacteristicChanged$lambda$15(BluetoothManager this$0) { Intrinsics.checkNotNullParameter(BluetoothManager.this, "this$0"); if (BluetoothManager.this.getOnControlSourceUpdated() != null) { BluetoothManager.this.getOnControlSourceUpdated().invoke(Integer.valueOf(BluetoothManager.this.getControlSource())); } else { BluetoothManager.this.getOnControlSourceUpdated(); }  } }
    private final void enableCharacteristicNotification (BluetoothGatt gatt, BluetoothGattCharacteristic characteristic)
    {
        try {
            int charaProp = characteristic.getProperties();
            if ((charaProp & 0x10) == 0) return;
            boolean success = gatt.setCharacteristicNotification(characteristic, true);
            if (!success) return;
            BluetoothGattDescriptor descriptor = characteristic.getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID);
            if (descriptor != null) {
                descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                boolean writeSuccess = gatt.writeDescriptor(descriptor);
                if (writeSuccess) ;
            }
        } catch (Exception exception) {
        }
    }
    public final void startScanning () {
        if (!hasPermission()) return;
        if (this.bluetoothAdapter == null || !this.bluetoothAdapter.isEnabled()) return;
        BluetoothLeScanner bleScanner = this.bluetoothAdapter.getBluetoothLeScanner();
        if (bleScanner == null) return;
        if (this.isScanning) {
            bleScanner.stopScan(this.scanCallback);
            Thread.sleep(200L);
        }
        this.isScanning = true;
        this.discoveredDevices.clear();
        this.targetDevice = null;
        ScanSettings scanSettings = (new ScanSettings.Builder()).setScanMode(2).setReportDelay(0L).setCallbackType(1).setMatchMode(1).setNumOfMatches(3).build();
        try {
            bleScanner.startScan(null, scanSettings, this.scanCallback);
        } catch (Exception e) {
            this.isScanning = false;
        }
    }
    public final void stopScanning () {
        if (!hasPermission()) return;
        this.isScanning = false;
        try {
            BluetoothLeScanner bluetoothLeScanner = this.bleScanner;
            if (bluetoothLeScanner != null) {
                bluetoothLeScanner.stopScan(this.scanCallback);
            } else {
            }
        } catch (Exception exception) {
        }
    }
    public final boolean hasScanPermission (@NotNull Context context){
        Intrinsics.checkNotNullParameter(context, "context");
        return (Build.VERSION.SDK_INT >= 31) ? ((ContextCompat.checkSelfPermission(context, "android.permission.BLUETOOTH_SCAN") == 0)) : ((ContextCompat.checkSelfPermission(context, "android.permission.ACCESS_FINE_LOCATION") == 0));
    }
    public final boolean hasConnectPermission (@NotNull Context context){
        Intrinsics.checkNotNullParameter(context, "context");
        return (Build.VERSION.SDK_INT >= 31) ? ((ContextCompat.checkSelfPermission(context, "android.permission.BLUETOOTH_CONNECT") == 0)) : true;
    }
    public final void connect (@NotNull BluetoothDeviceInfo device){
        Intrinsics.checkNotNullParameter(device, "device");
        if (!hasPermission()) return;
        BluetoothGatt it = this.connectedGatt;
        int $i$a$ -let - BluetoothManager$connect$1 = 0;
        it.disconnect();
        it.close();
        this.connectedGatt = null;
        this.targetDevice = device;
        BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
        BluetoothDevice freshDevice = adapter.getRemoteDevice(device.getAddress());
        try {
            this.connectedGatt = freshDevice.connectGatt(this.context, false, this.gattCallback, 2);
        } catch (IllegalArgumentException e) {
            if (this.onConnectionStateChanged != null) {
                this.onConnectionStateChanged.invoke(Boolean.valueOf(false));
            } else {
            }
        }
    } public final void disconnect () {
        if (this.connectedGatt != null) {
            this.connectedGatt.disconnect();
        } else {
        }
        if (this.connectedGatt != null) {
            this.connectedGatt.close();
        } else {
        }
        this.connectedGatt = null;
        this.isConnected = false;
        if (this.targetDevice == null) {
        } else {
            this.targetDevice.setConnected(Boolean.valueOf(false));
        }
    }
    private final void readDeviceInfo () {
        Iterator iterator;
        if (this.connectedGatt != null) {
            BluetoothGatt gatt = this.connectedGatt;
            int $i$a$ -let - BluetoothManager$readDeviceInfo$1 = 0;
            Intrinsics.checkNotNullExpressionValue(gatt.getServices(), "getServices(...)");
            Iterable $this$forEach$iv = gatt.getServices();
            int $i$f$forEach = 0;
            iterator = $this$forEach$iv.iterator();
        } else {
            return;
        } if (iterator.hasNext()) {
            Object element$iv = iterator.next();
            BluetoothGattService service = (BluetoothGattService) element$iv;
            int $i$a$ -forEach - BluetoothManager$readDeviceInfo$1$1 = 0;
            Intrinsics.checkNotNullExpressionValue(service.getCharacteristics(), "getCharacteristics(...)");
            Iterable $this$forEach$iv = service.getCharacteristics();
            int $i$f$forEach = 0;
            Iterator iterator1 = $this$forEach$iv.iterator();
        }
        this.handler.postDelayed(this::readDeviceInfo$lambda$5$lambda$4, 1000L);
    } private static final void readDeviceInfo$lambda$5$lambda$4 (BluetoothManager this$0){
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        this$0.setControlSourceToApp();
    }
    public final void setControlSourceToApp () {
        Iterator iterator;
        if (this.connectedGatt != null) {
            BluetoothGatt gatt = this.connectedGatt;
            int $i$a$ -let - BluetoothManager$setControlSourceToApp$1 = 0;
            Intrinsics.checkNotNullExpressionValue(gatt.getServices(), "getServices(...)");
            Iterable $this$forEach$iv = gatt.getServices();
            int $i$f$forEach = 0;
            iterator = $this$forEach$iv.iterator();
        } else {
            return;
        } if (iterator.hasNext()) {
            Object element$iv = iterator.next();
            BluetoothGattService service = (BluetoothGattService) element$iv;
            int $i$a$ -forEach - BluetoothManager$setControlSourceToApp$1$1 = 0;
            Intrinsics.checkNotNullExpressionValue(service.getCharacteristics(), "getCharacteristics(...)");
            Iterable $this$forEach$iv = service.getCharacteristics();
            int $i$f$forEach = 0;
            Iterator iterator1 = $this$forEach$iv.iterator();
        }
    }


    public final void sendVibrationControl ( int swingLevel, int vibrationLevel, int duration, int delay){
        // Byte code:
        //   0: aload_0
        //   1: getfield connectedGatt : Landroid/bluetooth/BluetoothGatt;
        //   4: ifnonnull -> 8
        //   7: return
        //   8: aload_0
        //   9: getfield connectedGatt : Landroid/bluetooth/BluetoothGatt;
        //   12: dup
        //   13: ifnull -> 330
        //   16: astore #5
        //   18: iconst_0
        //   19: istore #6
        //   21: iconst_0
        //   22: istore #7
        //   24: aload #5
        //   26: invokevirtual getServices : ()Ljava/util/List;
        //   29: dup
        //   30: ldc_w 'getServices(...)'
        //   33: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
        //   36: checkcast java/lang/Iterable
        //   39: astore #8
        //   41: iconst_0
        //   42: istore #9
        //   44: aload #8
        //   46: invokeinterface iterator : ()Ljava/util/Iterator;
        //   51: astore #10
        //   53: aload #10
        //   55: invokeinterface hasNext : ()Z
        //   60: ifeq -> 320
        //   63: aload #10
        //   65: invokeinterface next : ()Ljava/lang/Object;
        //   70: astore #11
        //   72: aload #11
        //   74: checkcast android/bluetooth/BluetoothGattService
        //   77: astore #12
        //   79: iconst_0
        //   80: istore #13
        //   82: aload #12
        //   84: invokevirtual getCharacteristics : ()Ljava/util/List;
        //   87: dup
        //   88: ldc_w 'getCharacteristics(...)'
        //   91: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
        //   94: checkcast java/lang/Iterable
        //   97: astore #14
        //   99: iconst_0
        //   100: istore #15
        //   102: aload #14
        //   104: invokeinterface iterator : ()Ljava/util/Iterator;
        //   109: astore #16
        //   111: aload #16
        //   113: invokeinterface hasNext : ()Z
        //   118: ifeq -> 314
        //   121: aload #16
        //   123: invokeinterface next : ()Ljava/lang/Object;
        //   128: astore #17
        //   130: aload #17
        //   132: checkcast android/bluetooth/BluetoothGattCharacteristic
        //   135: astore #18
        //   137: iconst_0
        //   138: istore #19
        //   140: aload #18
        //   142: invokevirtual getUuid : ()Ljava/util/UUID;
        //   145: invokevirtual toString : ()Ljava/lang/String;
        //   148: dup
        //   149: ldc_w 'toString(...)'
        //   152: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
        //   155: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
        //   158: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
        //   161: dup
        //   162: ldc_w 'toUpperCase(...)'
        //   165: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
        //   168: ldc_w '0000F320-0000-1000-8000-00805F9B34FB'
        //   171: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
        //   174: invokevirtual toUpperCase : (Ljava/util/Locale;)Ljava/lang/String;
        //   177: dup
        //   178: ldc_w 'toUpperCase(...)'
        //   181: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
        //   184: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
        //   187: ifeq -> 309
        //   190: iconst_1
        //   191: istore #7
        //   193: aload #18
        //   195: invokevirtual getProperties : ()I
        //   198: istore #20
        //   200: iload #20
        //   202: bipush #8
        //   204: iand
        //   205: ifne -> 218
        //   208: iload #20
        //   210: iconst_4
        //   211: iand
        //   212: ifne -> 218
        //   215: goto -> 310
        //   218: iconst_5
        //   219: newarray byte
        //   221: astore #21
        //   223: iload_1
        //   224: bipush #8
        //   226: ishl
        //   227: iload_2
        //   228: ior
        //   229: istore #22
        //   231: aload #21
        //   233: iconst_0
        //   234: iload #22
        //   236: bipush #8
        //   238: ishr
        //   239: i2b
        //   240: bastore
        //   241: aload #21
        //   243: iconst_1
        //   244: iload #22
        //   246: i2b
        //   247: bastore
        //   248: aload #21
        //   250: iconst_2
        //   251: iload_3
        //   252: bipush #8
        //   254: ishr
        //   255: i2b
        //   256: bastore
        //   257: aload #21
        //   259: iconst_3
        //   260: iload_3
        //   261: i2b
        //   262: bastore
        //   263: aload #21
        //   265: iconst_4
        //   266: iload #4
        //   268: i2b
        //   269: bastore
        //   270: aload #18
        //   272: iload #20
        //   274: iconst_4
        //   275: iand
        //   276: ifeq -> 283
        //   279: iconst_1
        //   280: goto -> 284
        //   283: iconst_2
        //   284: invokevirtual setWriteType : (I)V
        //   287: aload #18
        //   289: aload #21
        //   291: invokevirtual setValue : ([B)Z
        //   294: pop
        //   295: aload #5
        //   297: aload #18
        //   299: invokevirtual writeCharacteristic : (Landroid/bluetooth/BluetoothGattCharacteristic;)Z
        //   302: istore #23
        //   304: iload #23
        //   306: ifeq -> 309
        //   309: nop
        //   310: nop
        //   311: goto -> 111
        //   314: nop
        //   315: nop
        //   316: nop
        //   317: goto -> 53
        //   320: nop
        //   321: iload #7
        //   323: ifne -> 326
        //   326: nop
        //   327: goto -> 332
        //   330: pop
        //   331: nop
        //   332: return
        // Line number table:
        //   Java source line number -> byte code offset
        //   #679	-> 0
        //   #681	-> 7
        //   #684	-> 8
        //   #685	-> 21
        //   #687	-> 24
        //   #791	-> 44
        //   #688	-> 82
        //   #792	-> 102
        //   #689	-> 140
        //   #690	-> 155
        //   #690	-> 168
        //   #690	-> 184
        //   #692	-> 190
        //   #695	-> 193
        //   #696	-> 200
        //   #697	-> 208
        //   #700	-> 215
        //   #704	-> 218
        //   #705	-> 223
        //   #706	-> 231
        //   #707	-> 241
        //   #708	-> 248
        //   #709	-> 257
        //   #710	-> 263
        //   #713	-> 270
        //   #714	-> 272
        //   #715	-> 279
        //   #717	-> 283
        //   #713	-> 284
        //   #721	-> 287
        //   #722	-> 295
        //   #723	-> 304
        //   #732	-> 309
        //   #792	-> 310
        //   #793	-> 314
        //   #733	-> 315
        //   #791	-> 316
        //   #794	-> 320
        //   #735	-> 321
        //   #738	-> 326
        //   #684	-> 327
        //   #684	-> 330
        //   #739	-> 332
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   200	109	20	properties	I
        //   223	86	21	data	[B
        //   231	78	22	controlLevel	I
        //   304	5	23	success	Z
        //   140	170	19	$i$a$-forEach-BluetoothManager$sendVibrationControl$1$1$1	I
        //   137	173	18	characteristic	Landroid/bluetooth/BluetoothGattCharacteristic;
        //   130	181	17	element$iv	Ljava/lang/Object;
        //   102	213	15	$i$f$forEach	I
        //   99	216	14	$this$forEach$iv	Ljava/lang/Iterable;
        //   82	234	13	$i$a$-forEach-BluetoothManager$sendVibrationControl$1$1	I
        //   79	237	12	service	Landroid/bluetooth/BluetoothGattService;
        //   72	245	11	element$iv	Ljava/lang/Object;
        //   44	277	9	$i$f$forEach	I
        //   41	280	8	$this$forEach$iv	Ljava/lang/Iterable;
        //   21	306	6	$i$a$-let-BluetoothManager$sendVibrationControl$1	I
        //   24	303	7	foundCharacteristic	Z
        //   18	309	5	gatt	Landroid/bluetooth/BluetoothGatt;
        //   0	333	0	this	Lcom/etouch/bt/BluetoothManager;
        //   0	333	1	swingLevel	I
        //   0	333	2	vibrationLevel	I
        //   0	333	3	duration	I
        //   0	333	4	delay	I
    }

    public final void sendControlSignal ( int swingIntensity, int vibrationIntensity){
        sendVibrationControl(swingIntensity, vibrationIntensity, 200, 0);
    }

    private final boolean hasPermission () {
        if (ActivityCompat.checkSelfPermission(this.context, "android.permission.BLUETOOTH_CONNECT") == 0)
            if (ActivityCompat.checkSelfPermission(this.context, "android.permission.BLUETOOTH_SCAN") == 0) ;
        return (Build.VERSION.SDK_INT >= 31) ? false : ((ActivityCompat.checkSelfPermission(this.context, "android.permission.BLUETOOTH") == 0));
    }

    public final void cleanup () {
        disconnect();
    }
}
