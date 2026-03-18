package com.etouch.activity;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContract;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.core.content.ContextCompat;
import androidx.documentfile.provider.DocumentFile;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleOwnerKt;
import com.arthenica.ffmpegkit.FFmpegSession;
import com.etouch.AudioEnergyStream;
import com.etouch.AudioFile;
import com.etouch.CurrentTime;
import com.etouch.DeviceInfo;
import com.etouch.DevicesUUidInfo;
import com.etouch.ExPortFileResult;
import com.etouch.MultiFileInfo;
import com.etouch.ParsingErrorType;
import com.etouch.ReciveEquipmentControlData;
import com.etouch.SPUtils;
import com.etouch.ScanResultInfo;
import com.etouch.ScreenBrightness;
import com.etouch.SystemDeviceInfo;
import com.etouch.SystemVolumeInfo;
import com.etouch.TotalTime;
import com.etouch.UnityBridgeImpl;
import com.etouch.bt.BluetoothManager;
import com.etouch.service.IsPlaying;
import com.etouch.service.MusicInfo;
import com.etouch.service.MusicService;
import com.google.gson.Gson;
import com.unity3d.player.UnityPlayer;

import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Type;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;

import kotlin.Lazy;
import kotlin.LazyKt;
import kotlin.Metadata;
import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.collections.CollectionsKt;
import kotlin.collections.SetsKt;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.CoroutineContext;
import kotlin.coroutines.intrinsics.IntrinsicsKt;
import kotlin.coroutines.jvm.internal.Boxing;
import kotlin.coroutines.jvm.internal.ContinuationImpl;
import kotlin.coroutines.jvm.internal.DebugMetadata;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.io.ByteStreamsKt;
import kotlin.io.CloseableKt;
import kotlin.io.FilesKt;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Lambda;
import kotlin.jvm.internal.Ref;
import kotlin.jvm.internal.SourceDebugExtension;
import kotlin.ranges.RangesKt;
import kotlin.sequences.SequencesKt;
import kotlin.text.StringsKt;
import kotlinx.coroutines.BuildersKt;
import kotlinx.coroutines.CoroutineScope;
import kotlinx.coroutines.CoroutineScopeKt;
import kotlinx.coroutines.Dispatchers;
import kotlinx.coroutines.Job;
import kotlinx.coroutines.JobKt;
import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.model.FileHeader;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;



public final class UnityBridgeActivity extends AppCompatActivity {
    private final String TAG = UnityBridgeActivity.class.getName();
    @Nullable
    private UnityPlayer unityPlayer;
    private boolean isScanning;
    public BluetoothManager bluetoothManager;

    public final String getTAG() {
        return this.TAG;
    }

    @Nullable
    public final UnityPlayer getUnityPlayer() {
        return this.unityPlayer;
    }

    public final void setUnityPlayer(@Nullable UnityPlayer<set-?>) {
        this.unityPlayer = < set - ? >;
    }

    public final boolean isScanning() {
        return this.isScanning;
    }

    public final void setScanning(boolean <set-?>) {
        this.isScanning = < set - ? >;
    }

    @NotNull
    public final BluetoothManager getBluetoothManager() {
        if (this.bluetoothManager != null) return this.bluetoothManager;
        Intrinsics.throwUninitializedPropertyAccessException("bluetoothManager");
        return null;
    }

    public final void setBluetoothManager(@NotNull BluetoothManager<set-?>) {
        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
        this.bluetoothManager = < set - ? >;
    }

    @NotNull
    private List<BluetoothManager.BluetoothDeviceInfo> discoveredDevicesList = CollectionsKt.emptyList();

    @NotNull
    public final List<BluetoothManager.BluetoothDeviceInfo> getDiscoveredDevicesList() {
        return this.discoveredDevicesList;
    }

    public final void setDiscoveredDevicesList(@NotNull List<BluetoothManager.BluetoothDeviceInfo> <set-?>) {
        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
        this.discoveredDevicesList = < set - ? >;
    }

    @NotNull
    private List<BluetoothManager.BluetoothDeviceInfo> connectedDevicesList = new ArrayList<>();

    @NotNull
    public final List<BluetoothManager.BluetoothDeviceInfo> getConnectedDevicesList() {
        return this.connectedDevicesList;
    }

    public final void setConnectedDevicesList(@NotNull List<BluetoothManager.BluetoothDeviceInfo> <set-?>) {
        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
        this.connectedDevicesList = < set - ? >;
    }

    @NotNull
    private String connectedDeviceName = "Device name";
    @Nullable
    private String connectedDeviceAddress;

    @NotNull
    public final String getConnectedDeviceName() {
        return this.connectedDeviceName;
    }

    public final void setConnectedDeviceName(@NotNull String<set-?>) {
        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
        this.connectedDeviceName = < set - ? >;
    }

    @Nullable
    public final String getConnectedDeviceAddress() {
        return this.connectedDeviceAddress;
    }

    public final void setConnectedDeviceAddress(@Nullable String<set-?>) {
        this.connectedDeviceAddress = < set - ? >;
    }

    private int deviceBatteryLevel = 100;
    @Nullable
    private byte[] currentGear;

    public final int getDeviceBatteryLevel() {
        return this.deviceBatteryLevel;
    }

    public final void setDeviceBatteryLevel(int <set-?>) {
        this.deviceBatteryLevel = < set - ? >;
    }

    @Nullable
    public final byte[] getCurrentGear() {
        return this.currentGear;
    }

    public final void setCurrentGear(@Nullable byte[] <set-?>) {
        this.currentGear = < set - ? >;
    }

    private int vibrationType = 100;

    public final int getVibrationType() {
        return this.vibrationType;
    }

    public final void setVibrationType(int <set-?>) {
        this.vibrationType = < set - ? >;
    }

    private int controlSource = 100;

    public final int getControlSource() {
        return this.controlSource;
    }

    public final void setControlSource(int <set-?>) {
        this.controlSource = < set - ? >;
    }


    private int selectedWaveform = 1;

    public final int getSelectedWaveform() {
        return this.selectedWaveform;
    }

    public final void setSelectedWaveform(int <set-?>) {
        this.selectedWaveform = < set - ? >;
    }


    private int selectedSwingPreset = -1;

    public final int getSelectedSwingPreset() {
        return this.selectedSwingPreset;
    }

    public final void setSelectedSwingPreset(int <set-?>) {
        this.selectedSwingPreset = < set - ? >;
    }


    private int selectedVibrationPreset = -1;

    public final int getSelectedVibrationPreset() {
        return this.selectedVibrationPreset;
    }

    public final void setSelectedVibrationPreset(int <set-?>) {
        this.selectedVibrationPreset = < set - ? >;
    }


    private int intensityLevel = 1;
    private final int intensity;
    private int selectedComboPreset;
    private boolean isPlaying;
    @NotNull
    private final List<Integer> presetIntensities;
    private ScanResultAdapter scanResultAdapter;
    private int fileType;
    private int multiFileType;
    @NotNull
    private final ActivityResultLauncher<String[]> pickFileLauncher;
    @NotNull
    private final ActivityResultLauncher<String[]> pickMultipleFilesLauncher;
    @NotNull
    private final ActivityResultLauncher<String[]> pickMultipleFilesLauncher2;
    @NotNull
    private final ActivityResultLauncher<String[]> pickZipLauncher;
    private Button tvZhendong1;
    private Button tvZhendong3;
    private Button tvYaobai1;
    private Button tvYaobai3;
    private boolean isZhendong1;
    private boolean isZhendong3;
    private boolean isYaobai1;
    private boolean isYaobai3;
    @NotNull
    private String sourceLocalPath;
    @NotNull
    private String targetSavePath;
    @Nullable
    private Uri selectedFolderUri;
    @NotNull
    private final ActivityResultLauncher<String[]> requestStoragePermissionLauncher;
    @Nullable
    private MusicService musicService;
    private boolean bound;
    @Nullable
    private Function0<Unit> pendingAction;
    @Nullable
    private Function0<Unit> pendingPlayTask;
    @Nullable
    private Function0<Unit> pendingSetPlaylistTask;
    @NotNull
    private final UnityBridgeActivity$connection$1 connection;
    @NotNull
    private final ActivityResultLauncher<String> requestNotificationPermission;
    @NotNull
    private final String deleteJson;
    private boolean pendingStartScan;
    private final int REQUEST_CODE_BLUETOOTH_PERMISSIONS;
    private final int REQUEST_CODE_ENABLE_BLUETOOTH;
    private final int REQUEST_CODE_CAMERA;
    private final int REQUEST_SCAN_CODE;
    @Nullable
    private String mVersionCode;
    @Nullable
    private String mVersionName;
    @Nullable
    private String mModelType;
    @NotNull
    private final Lazy activityMultiCoroutineScope$delegate;
    @NotNull
    private List<AudioFile> mMultiNewFiles;
    @NotNull
    private List<AudioFile> mMultiTypeNewFiles;
    @NotNull
    private final Lazy activityCoroutineScope$delegate;
    @NotNull
    private List<AudioFile> mNewFiles;
    @NotNull
    private final Set<String> videoSuffixSet;
    @NotNull
    private final Set<String> audioSuffixSet;
    @NotNull
    private final Set<String> imageSuffixSet;
    @NotNull
    private final Set<String> lyricSuffixSet;
    @Nullable
    private DocumentFile selectedFolderDoc;
    @NotNull
    private final ActivityResultLauncher<Uri> selectFolderLauncher;
    @NotNull
    private final CoroutineScope playbackScope;
    @Nullable
    private Job currentPlaybackJob;
    @NotNull
    private final AtomicBoolean isCoroutineActive;
    @NotNull
    private final Handler mainHandler;
    @Nullable
    private Runnable vibrationRunnable;
    @Nullable
    private ReciveEquipmentControlData cachedEquipmentData;
    @Nullable
    private AudioEnergyStream audioEnergyStream;
    private int times;
    private long waveformStartTime;
    private final long intervalMs;
    @Nullable
    private Runnable analyzeRunnable;
    @Nullable
    private Runnable sendRunnable;
    private int latestSwing;
    private int latestVibration;
    private int latestDuration;
    private int waveformStep;
    private boolean deviceStopped;
    @Nullable
    private Runnable controlRunnable;
    private boolean stopRequested;
    private long lastSendTime;

    public final int getIntensityLevel() {
        return this.intensityLevel;
    }

    public final void setIntensityLevel(int <set-?>) {
        this.intensityLevel = < set - ? >;
    }

    public final int getIntensity() {
        return this.intensity;
    }

    public final int getSelectedComboPreset() {
        return this.selectedComboPreset;
    }

    public final void setSelectedComboPreset(int <set-?>) {
        this.selectedComboPreset = < set - ? >;
    }

    public final boolean isPlaying() {
        return this.isPlaying;
    }

    public final void setPlaying(boolean <set-?>) {
        this.isPlaying = < set - ? >;
    }

    @NotNull
    public final List<Integer> getPresetIntensities() {
        return this.presetIntensities;
    }

    @NotNull
    public final ActivityResultLauncher<String[]> getPickFileLauncher() {
        return this.pickFileLauncher;
    }

    private static final void pickFileLauncher$lambda$0(UnityBridgeActivity this$0, Uri uri) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (uri != null) {
            this$0.handleUris(CollectionsKt.listOf(uri), this$0.fileType);
        } else {
            UnityPlayer.UnitySendMessage("Boot", "unSelectedFile", "未选择文件");
        }
    }

    @NotNull
    public final ActivityResultLauncher<String[]> getPickMultipleFilesLauncher() {
        return this.pickMultipleFilesLauncher;
    }

    private static final void pickMultipleFilesLauncher$lambda$1(UnityBridgeActivity this$0, List<? extends Uri> uris) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (uris != null && (!uris.isEmpty())) {
            this$0.handleMultiUris(uris);
        } else {
            UnityPlayer.UnitySendMessage("Boot", "unSelectedFile", "未选择多个文件");
        }
    }

    @NotNull
    public final ActivityResultLauncher<String[]> getPickMultipleFilesLauncher2() {
        return this.pickMultipleFilesLauncher2;
    }

    private static final void pickMultipleFilesLauncher2$lambda$2(UnityBridgeActivity this$0, List<? extends Uri> uris) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (uris != null && (!uris.isEmpty())) {
            this$0.handleMultiUris2(uris);
        } else {
            UnityPlayer.UnitySendMessage("Boot", "unSelectedFile", "未选择多个文件");
        }
    }

    @NotNull
    public final ActivityResultLauncher<String[]> getPickZipLauncher() {
        return this.pickZipLauncher;
    }

    private static final void pickZipLauncher$lambda$3(UnityBridgeActivity this$0, Uri uri) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (uri != null) {
            this$0.handleZip(uri);
        } else {
            UnityPlayer.UnitySendMessage("Boot", "unSelectedFile", "未选择ZIP");
        }
    }

    @NotNull
    public final ActivityResultLauncher<String[]> getRequestStoragePermissionLauncher() {
        return this.requestStoragePermissionLauncher;
    }

    private static final void requestStoragePermissionLauncher$lambda$5(Map permissionsMap) { // Byte code:
        //   0: aload_0
        //   1: ldc_w 'permissionsMap'
        //   4: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
        //   7: aload_0
        //   8: astore_2
        //   9: iconst_0
        //   10: istore_3
        //   11: aload_2
        //   12: invokeinterface isEmpty : ()Z
        //   17: ifeq -> 24
        //   20: iconst_1
        //   21: goto -> 87
        //   24: aload_2
        //   25: invokeinterface entrySet : ()Ljava/util/Set;
        //   30: invokeinterface iterator : ()Ljava/util/Iterator;
        //   35: astore #4
        //   37: aload #4
        //   39: invokeinterface hasNext : ()Z
        //   44: ifeq -> 86
        //   47: aload #4
        //   49: invokeinterface next : ()Ljava/lang/Object;
        //   54: checkcast java/util/Map$Entry
        //   57: astore #5
        //   59: aload #5
        //   61: astore #6
        //   63: iconst_0
        //   64: istore #7
        //   66: aload #6
        //   68: invokeinterface getValue : ()Ljava/lang/Object;
        //   73: checkcast java/lang/Boolean
        //   76: invokevirtual booleanValue : ()Z
        //   79: ifne -> 37
        //   82: iconst_0
        //   83: goto -> 87
        //   86: iconst_1
        //   87: istore_1
        //   88: iload_1
        //   89: ifne -> 104
        //   92: ldc_w 'Boot'
        //   95: ldc_w 'exportFile'
        //   98: ldc_w '存储权限被拒绝，可能无法保存到公共目录'
        //   101: invokestatic UnitySendMessage : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
        //   104: return
        // Line number table:
        //   Java source line number -> byte code offset
        //   #233	-> 7
        //   #3541	-> 11
        //   #3542	-> 24
        //   #3542	-> 35
        //   #233	-> 66
        //   #3542	-> 79
        //   #3543	-> 86
        //   #233	-> 87
        //   #234	-> 88
        //   #236	-> 92
        //   #235	-> 101
        //   #239	-> 104
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   66	13	7	$i$a$-all-UnityBridgeActivity$requestStoragePermissionLauncher$1$allGranted$1	I
        //   63	16	6	it	Ljava/util/Map$Entry;
        //   59	27	5	element$iv	Ljava/util/Map$Entry;
        //   11	76	3	$i$f$all	I
        //   9	78	2	$this$all$iv	Ljava/util/Map;
        //   88	17	1	allGranted	Z
        //   0	105	0	permissionsMap	Ljava/util/Map; } @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\037\n\000\n\002\030\002\n\000\n\002\020\002\n\000\n\002\030\002\n\000\n\002\030\002\n\002\b\002*\001\000\b\n\030\0002\0020\001J\034\020\002\032\0020\0032\b\020\004\032\004\030\0010\0052\b\020\006\032\004\030\0010\007H\026J\022\020\b\032\0020\0032\b\020\004\032\004\030\0010\005H\026¨\006\t"}, d2 = {"com/etouch/activity/UnityBridgeActivity$connection$1", "Landroid/content/ServiceConnection;", "onServiceConnected", "", "name", "Landroid/content/ComponentName;", "service", "Landroid/os/IBinder;", "onServiceDisconnected", "sdk_android_unity_bridge_v1_debug"}) public static final class UnityBridgeActivity$connection$1 implements ServiceConnection {
        public void onServiceConnected (@Nullable ComponentName name, @Nullable IBinder service){
            Intrinsics.checkNotNull(service, "null cannot be cast to non-null type com.etouch.service.MusicService.MusicBinder");
            UnityBridgeActivity.this.musicService = ((MusicService.MusicBinder) service).getService();
            UnityBridgeActivity.this.bound = true;
            Function0 function01 = UnityBridgeActivity.this.pendingPlayTask;
            UnityBridgeActivity unityBridgeActivity = UnityBridgeActivity.this;
            Function0 task = function01;
            int $i$a$ -let - UnityBridgeActivity$connection$1$onServiceConnected$1 = 0;
            task.invoke();
            unityBridgeActivity.pendingPlayTask = null;
            UnityBridgeActivity.this.pendingPlayTask;
            function01 = UnityBridgeActivity.this.pendingSetPlaylistTask;
            unityBridgeActivity = UnityBridgeActivity.this;
            task = function01;
            int $i$a$ -let - UnityBridgeActivity$connection$1$onServiceConnected$2 = 0;
            task.invoke();
            unityBridgeActivity.pendingSetPlaylistTask = null;
            UnityBridgeActivity.this.pendingSetPlaylistTask;
        } public void onServiceDisconnected (@Nullable ComponentName name){
            UnityBridgeActivity.this.bound = false;
            UnityBridgeActivity.this.musicService = null;
        }
    }

    private static final void requestNotificationPermission$lambda$6(UnityBridgeActivity this$0, boolean granted) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (granted) {
            if (this$0.pendingPlayTask != null) {
                this$0.pendingPlayTask.invoke();
            } else {
            }
            this$0.pendingPlayTask = null;
        } else {
            this$0.openNotificationSettings();
        }
    }

    private final void checkNotificationPermission(Function0<Unit> onGranted) {
        if (Build.VERSION.SDK_INT >= 33) {
            int granted = checkSelfPermission("android.permission.POST_NOTIFICATIONS");
            if (granted != 0) {
                this.pendingPlayTask = onGranted;
                this.requestNotificationPermission.launch("android.permission.POST_NOTIFICATIONS");
            } else {
                onGranted.invoke();
            }
        } else {
            onGranted.invoke();
        }
    }

    private final void openNotificationSettings() {
        Intent intent1 = new Intent("android.settings.APP_NOTIFICATION_SETTINGS"), $this$openNotificationSettings_u24lambda_u247 = intent1;
        int $i$a$ -apply - UnityBridgeActivity$openNotificationSettings$intent$1 = 0;
        $this$openNotificationSettings_u24lambda_u247.putExtra("android.provider.extra.APP_PACKAGE", getPackageName());
        Intent intent = intent1;
        startActivity(intent);
    }

    public final void audioPlayerPlayItem(@NotNull String json) {
        Intrinsics.checkNotNullParameter(json, "json");
        runOnUiThread(UnityBridgeActivity::audioPlayerPlayItem$lambda$8);
        Function0<Unit> playTask = new UnityBridgeActivity$audioPlayerPlayItem$playTask$1(json);
        checkNotificationPermission(playTask);
    }

    private static final void audioPlayerPlayItem$lambda$8() {
    }

    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\b\n\000\n\002\020\002\n\000\020\000\032\0020\001H\n¢\006\002\b\002"}, d2 = {"<anonymous>", "", "invoke"})
    static final class UnityBridgeActivity$audioPlayerPlayItem$playTask$1 extends Lambda implements Function0<Unit> {
        public final void invoke() {
            UnityBridgeActivity.this.musicService.audioPlayerPlayItem(this.$json, new MusicService.PlayItemCallback() {
                public void onSuccess() {
                    UnityBridgeActivity.this.runOnUiThread(null::onSuccess$lambda$0);
                }

                private static final void onSuccess$lambda$0() {
                }

                public void onError(@NotNull String message) {
                    Intrinsics.checkNotNullParameter(message, "message");
                    UnityBridgeActivity.this.runOnUiThread(null::onError$lambda$1);
                }

                private static final void onError$lambda$1() {
                }
            });
            UnityBridgeActivity.this.musicService;
            UnityBridgeActivity $this$invoke_u24lambda_u241 = UnityBridgeActivity.this;
            int $i$a$ -run - UnityBridgeActivity$audioPlayerPlayItem$playTask$1$2 = 0;
            $this$invoke_u24lambda_u241.runOnUiThread(UnityBridgeActivity$audioPlayerPlayItem$playTask$1::invoke$lambda$1$lambda$0);
        }

        private static final void invoke$lambda$1$lambda$0() {
        }

        UnityBridgeActivity$audioPlayerPlayItem$playTask$1(String $json) {
            super(0);
        }
    }

    public final void audioPlayerSetPlaylist(@NotNull String json, int index) {
        Intrinsics.checkNotNullParameter(json, "json");
        runOnUiThread(UnityBridgeActivity::audioPlayerSetPlaylist$lambda$9);
        Function0<Unit> setPlaylistTask = new UnityBridgeActivity$audioPlayerSetPlaylist$setPlaylistTask$1(json, index);
        if (index == -1) {
            executeSetPlaylistTask(setPlaylistTask);
        } else {
            checkNotificationPermission(new UnityBridgeActivity$audioPlayerSetPlaylist$2(setPlaylistTask));
        }
    }

    private static final void audioPlayerSetPlaylist$lambda$9() {
    }

    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\b\n\000\n\002\020\002\n\000\020\000\032\0020\001H\n¢\006\002\b\002"}, d2 = {"<anonymous>", "", "invoke"})
    static final class UnityBridgeActivity$audioPlayerSetPlaylist$setPlaylistTask$1 extends Lambda implements Function0<Unit> {
        public final void invoke() {
            UnityBridgeActivity.this.musicService.audioPlayerSetPlaylist(this.$json, this.$index, new MusicService.PlaylistCallback() {
                public void onSuccess() {
                    UnityBridgeActivity.this.runOnUiThread(null::onSuccess$lambda$0);
                }

                private static final void onSuccess$lambda$0() {
                }

                public void onError(@NotNull String message) {
                    Intrinsics.checkNotNullParameter(message, "message");
                    UnityBridgeActivity.this.runOnUiThread(null::onError$lambda$1);
                }

                private static final void onError$lambda$1() {
                }
            });
            UnityBridgeActivity.this.musicService;
            UnityBridgeActivity $this$invoke_u24lambda_u241 = UnityBridgeActivity.this;
            int $i$a$ -run - UnityBridgeActivity$audioPlayerSetPlaylist$setPlaylistTask$1$2 = 0;
            $this$invoke_u24lambda_u241.runOnUiThread(UnityBridgeActivity$audioPlayerSetPlaylist$setPlaylistTask$1::invoke$lambda$1$lambda$0);
        }

        private static final void invoke$lambda$1$lambda$0() {
        }

        UnityBridgeActivity$audioPlayerSetPlaylist$setPlaylistTask$1(String $json, int $index) {
            super(0);
        }
    }

    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\b\n\000\n\002\020\002\n\000\020\000\032\0020\001H\n¢\006\002\b\002"}, d2 = {"<anonymous>", "", "invoke"})
    static final class UnityBridgeActivity$audioPlayerSetPlaylist$2 extends Lambda implements Function0<Unit> {
        public final void invoke() {
            UnityBridgeActivity.this.executeSetPlaylistTask(this.$setPlaylistTask);
        }

        UnityBridgeActivity$audioPlayerSetPlaylist$2(Function0<Unit> $setPlaylistTask) {
            super(0);
        }
    }

    public final void audioPlayerUpdateMarkAudio(int index, @NotNull String json) {
        Intrinsics.checkNotNullParameter(json, "json");
        if (this.bound && this.musicService != null) if (this.musicService != null) {
            this.musicService.audioPlayerUpdateMarkAudio(index, json);
        } else {
        }
    }

    private final void executeSetPlaylistTask(Function0<Unit> task) {
        if (this.bound) {
            task.invoke();
        } else {
            this.pendingSetPlaylistTask = task;
            Intent intent = new Intent((Context) this, MusicService.class);
            if (!this.bound) if (Build.VERSION.SDK_INT >= 26) {
                startForegroundService(intent);
            } else {
                startService(intent);
            }
        }
    }

    public final void audioPlayerPause() {
        runOnUiThread(this::audioPlayerPause$lambda$10);
    }

    private static final void audioPlayerPause$lambda$10(UnityBridgeActivity this$0) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (this$0.bound && this$0.musicService != null) if (this$0.musicService != null) {
            this$0.musicService.pause();
        } else {
        }
    }

    public final void audioPlayerResume() {
        runOnUiThread(this::audioPlayerResume$lambda$11);
    }

    private static final void audioPlayerResume$lambda$11(UnityBridgeActivity this$0) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (this$0.bound && this$0.musicService != null) if (this$0.musicService != null) {
            this$0.musicService.play();
        } else {
        }
    }

    public final void audioPlayerPlayNext() {
        runOnUiThread(this::audioPlayerPlayNext$lambda$12);
    }

    private static final void audioPlayerPlayNext$lambda$12(UnityBridgeActivity this$0) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (this$0.bound && this$0.musicService != null) if (this$0.musicService != null) {
            this$0.musicService.next();
        } else {
        }
    }

    public final void audioPlayerPlayPrevious() {
        runOnUiThread(this::audioPlayerPlayPrevious$lambda$13);
    }

    private static final void audioPlayerPlayPrevious$lambda$13(UnityBridgeActivity this$0) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (this$0.bound && this$0.musicService != null) if (this$0.musicService != null) {
            this$0.musicService.prev();
        } else {
        }
    }

    public final void audioPlayerSetPlayMode(int mode) { // Byte code:
        //   0: aload_0
        //   1: aload_0
        //   2: iload_1
        //   3: <illegal opcode> run : (Lcom/etouch/activity/UnityBridgeActivity;I)Ljava/lang/Runnable;
        //   8: invokevirtual runOnUiThread : (Ljava/lang/Runnable;)V
        //   11: return
        // Line number table:
        //   Java source line number -> byte code offset
        //   #489	-> 0
        //   #495	-> 11
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   0	12	0	this	Lcom/etouch/activity/UnityBridgeActivity;
        //   0	12	1	mode	I } public UnityBridgeActivity() { switch (this.intensityLevel) { case 0: case 1: case 2: default: break; }  this.intensity =


        60;


        this.selectedComboPreset = -1;


        Integer[] arrayOfInteger = new Integer[10];
        arrayOfInteger[0] = Integer.valueOf(10);
        arrayOfInteger[1] = Integer.valueOf(20);
        arrayOfInteger[2] = Integer.valueOf(30);
        arrayOfInteger[3] = Integer.valueOf(40);
        arrayOfInteger[4] = Integer.valueOf(50);
        arrayOfInteger[5] = Integer.valueOf(60);
        arrayOfInteger[6] = Integer.valueOf(70);
        arrayOfInteger[7] = Integer.valueOf(80);
        arrayOfInteger[8] = Integer.valueOf(90);
        arrayOfInteger[9] = Integer.valueOf(100);
        this.presetIntensities = CollectionsKt.listOf((Object[]) arrayOfInteger);


        this.fileType = -1;
        this.multiFileType = -1;


        this.pickFileLauncher = registerForActivityResult(
                (ActivityResultContract) new ActivityResultContracts.OpenDocument(), this::pickFileLauncher$lambda$0);


        this.pickMultipleFilesLauncher = registerForActivityResult(
                (ActivityResultContract) new ActivityResultContracts.OpenMultipleDocuments(), this::pickMultipleFilesLauncher$lambda$1);


        this.pickMultipleFilesLauncher2 = registerForActivityResult(
                (ActivityResultContract) new ActivityResultContracts.OpenMultipleDocuments(), this::pickMultipleFilesLauncher2$lambda$2);


        this.pickZipLauncher = registerForActivityResult((ActivityResultContract) new ActivityResultContracts.OpenDocument(), this::pickZipLauncher$lambda$3);


        this.sourceLocalPath = "";


        this.targetSavePath = "/sdcard/Android/data/com.etouch/files/Media/Target/saved_target_video.mp4";


        this.requestStoragePermissionLauncher = registerForActivityResult(
                (ActivityResultContract) new ActivityResultContracts.RequestMultiplePermissions(), UnityBridgeActivity::requestStoragePermissionLauncher$lambda$5);


        this.connection = new UnityBridgeActivity$connection$1();


        this.requestNotificationPermission = registerForActivityResult((ActivityResultContract) new ActivityResultContracts.RequestPermission(), this::requestNotificationPermission$lambda$6);


        this.deleteJson = "{\"deleteIndexArr\": [1,2]}";


        this.REQUEST_CODE_BLUETOOTH_PERMISSIONS = 2001;


        this.REQUEST_CODE_ENABLE_BLUETOOTH = 1002;
        this.REQUEST_CODE_CAMERA = 1003;
        this.REQUEST_SCAN_CODE = 1004;


        this.activityMultiCoroutineScope$delegate = LazyKt.lazy(UnityBridgeActivity$activityMultiCoroutineScope$2.INSTANCE);


        this.mMultiNewFiles = new ArrayList<>();
        this.mMultiTypeNewFiles = new ArrayList<>();


        this.activityCoroutineScope$delegate = LazyKt.lazy(UnityBridgeActivity$activityCoroutineScope$2.INSTANCE);


        this.mNewFiles = new ArrayList<>();


        String[] arrayOfString = new String[4];
        arrayOfString[0] = "mp4";
        arrayOfString[1] = "mkv";
        arrayOfString[2] = "avi";
        arrayOfString[3] = "mov";
        this.videoSuffixSet = SetsKt.setOf((Object[]) arrayOfString);
        arrayOfString = new String[6];
        arrayOfString[0] = "mp3";
        arrayOfString[1] = "wav";
        arrayOfString[2] = "aac";
        arrayOfString[3] = "flac";
        arrayOfString[4] = "m4a";
        arrayOfString[5] = "ogg";
        this.audioSuffixSet = SetsKt.setOf((Object[]) arrayOfString);

        arrayOfString = new String[10];
        arrayOfString[0] = "jpeg";
        arrayOfString[1] = "jpg";
        arrayOfString[2] = "png";
        arrayOfString[3] = "tiff";
        arrayOfString[4] = "gif";
        arrayOfString[5] = "webp";
        arrayOfString[6] = "bmp";
        arrayOfString[7] = "heif";
        arrayOfString[8] = "heic";
        arrayOfString[9] = "hdr";
        this.imageSuffixSet = SetsKt.setOf((Object[]) arrayOfString);
        arrayOfString = new String[5];
        arrayOfString[0] = "srt";
        arrayOfString[1] = "vtt";
        arrayOfString[2] = "lrc";
        arrayOfString[3] = "sub";
        arrayOfString[4] = "stl";
        this.lyricSuffixSet = SetsKt.setOf((Object[]) arrayOfString);


        this.selectFolderLauncher = registerForActivityResult(
                (ActivityResultContract) new ActivityResultContracts.OpenDocumentTree(), this::selectFolderLauncher$lambda$42);


        this.playbackScope = CoroutineScopeKt.CoroutineScope(SupervisorKt.SupervisorJob$default(null, 1, null).plus((CoroutineContext) Dispatchers.getDefault()));


        this.isCoroutineActive = new AtomicBoolean(false);


        this.mainHandler = new Handler(Looper.getMainLooper());


        this.intervalMs = 250L;
    }

    private static final void audioPlayerSetPlayMode$lambda$14(UnityBridgeActivity this$0, int $mode) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (this$0.bound && this$0.musicService != null)
            if (this$0.musicService != null) {
                this$0.musicService.audioPlayerSetPlayMode($mode);
            } else {

            }
    }

    public final int audioPlayerGetPlayMode() {
        return (this.bound && this.musicService != null) ? ((this.musicService != null) ? this.musicService.audioPlayerGetPlayMode() : 0) : 0;
    }

    public final void audioPlayerSeekTo(double time) { // Byte code:
        //   0: aload_0
        //   1: aload_0
        //   2: dload_1
        //   3: <illegal opcode> run : (Lcom/etouch/activity/UnityBridgeActivity;D)Ljava/lang/Runnable;
        //   8: invokevirtual runOnUiThread : (Ljava/lang/Runnable;)V
        //   11: return
        // Line number table:
        //   Java source line number -> byte code offset
        //   #514	-> 0
        //   #520	-> 11
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   0	12	0	this	Lcom/etouch/activity/UnityBridgeActivity;
        //   0	12	1	time	D }
        private static final void audioPlayerSeekTo$lambda$15 (UnityBridgeActivity this$0,double $time){
            Intrinsics.checkNotNullParameter(this$0, "this$0");
            if (this$0.bound && this$0.musicService != null)
                if (this$0.musicService != null) {
                    this$0.musicService.audioPlayerSeekTo($time * 'Ϩ');
                } else {

                }
        }
        public final void audioPlayerGetPlayingListInfo () {
            runOnUiThread(this::audioPlayerGetPlayingListInfo$lambda$16);
        }
        private static final void audioPlayerGetPlayingListInfo$lambda$16 (UnityBridgeActivity this$0){
            Intrinsics.checkNotNullParameter(this$0, "this$0");
            if (this$0.bound && this$0.musicService != null)
                if (this$0.musicService != null) {
                    this$0.musicService.audioPlayerGetPlayingListInfo();
                } else {

                }
        }
        public final void audioPlayerGetPlayingAudioCurrentTime () {
            BuildersKt.launch$default((CoroutineScope) LifecycleOwnerKt.getLifecycleScope((LifecycleOwner) this), null, null, new UnityBridgeActivity$audioPlayerGetPlayingAudioCurrentTime$1(null), 3, null);
        }
        @DebugMetadata(f = "UnityBridgeActivity.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$audioPlayerGetPlayingAudioCurrentTime$1")
        @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
        static final class UnityBridgeActivity$audioPlayerGetPlayingAudioCurrentTime$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
            int label;

            UnityBridgeActivity$audioPlayerGetPlayingAudioCurrentTime$1(Continuation $completion) {
                super(2, $completion);
            }

            @Nullable
            public final Object invokeSuspend(@NotNull Object $result) {
                IntrinsicsKt.getCOROUTINE_SUSPENDED();
                switch (this.label) {
                    case 0:
                        ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                        if (UnityBridgeActivity.this.bound && UnityBridgeActivity.this.musicService != null) {
                            Intrinsics.checkNotNull(UnityBridgeActivity.this.musicService);
                            double currentTimeValue = UnityBridgeActivity.this.musicService.audioPlayerGetPlayingAudioCurrentTime();
                            CurrentTime currentTime1 = new CurrentTime(null, 1, null), $this$invokeSuspend_u24lambda_u240 = currentTime1;
                            int $i$a$
                            -apply - UnityBridgeActivity$audioPlayerGetPlayingAudioCurrentTime$1$currentTime$1 = 0;
                            $this$invokeSuspend_u24lambda_u240.setCurrentTime(String.valueOf(currentTimeValue));
                            CurrentTime currentTime = currentTime1;
                            String jsonStr = (new Gson()).toJson(currentTime);
                            UnityPlayer.UnitySendMessage("Boot", "audioPlayerGetPlayingAudioCurrentTime", jsonStr);
                        } return Unit.INSTANCE;
                } throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }

            @NotNull
            public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$audioPlayerGetPlayingAudioCurrentTime$1> $completion) {
                return (Continuation<Unit>) new UnityBridgeActivity$audioPlayerGetPlayingAudioCurrentTime$1($completion);
            }

            @Nullable
            public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                return ((UnityBridgeActivity$audioPlayerGetPlayingAudioCurrentTime$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
            }
        }
        public final void audioPlayerGetPlayingAudioTotalTime () {
            BuildersKt.launch$default((CoroutineScope) LifecycleOwnerKt.getLifecycleScope((LifecycleOwner) this), null, null, new UnityBridgeActivity$audioPlayerGetPlayingAudioTotalTime$1(null), 3, null);
        }
        @DebugMetadata(f = "UnityBridgeActivity.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$audioPlayerGetPlayingAudioTotalTime$1")
        @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
        static final class UnityBridgeActivity$audioPlayerGetPlayingAudioTotalTime$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
            int label;

            UnityBridgeActivity$audioPlayerGetPlayingAudioTotalTime$1(Continuation $completion) {
                super(2, $completion);
            }

            @Nullable
            public final Object invokeSuspend(@NotNull Object $result) {
                IntrinsicsKt.getCOROUTINE_SUSPENDED();
                switch (this.label) {
                    case 0:
                        ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                        if (UnityBridgeActivity.this.bound && UnityBridgeActivity.this.musicService != null) {
                            Intrinsics.checkNotNull(UnityBridgeActivity.this.musicService);
                            double totalTimeValue = UnityBridgeActivity.this.musicService.audioPlayerGetPlayingAudioTotalTime();
                            TotalTime totalTime1 = new TotalTime(null, 1, null), $this$invokeSuspend_u24lambda_u240 = totalTime1;
                            int $i$a$
                            -apply - UnityBridgeActivity$audioPlayerGetPlayingAudioTotalTime$1$totalTime$1 = 0;
                            $this$invokeSuspend_u24lambda_u240.setTotalTime(String.valueOf(totalTimeValue));
                            TotalTime totalTime = totalTime1;
                            String jsonStr = (new Gson()).toJson(totalTime);
                            UnityPlayer.UnitySendMessage("Boot", "audioPlayerGetPlayingAudioTotalTime", jsonStr);
                        } return Unit.INSTANCE;
                } throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }

            @NotNull
            public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$audioPlayerGetPlayingAudioTotalTime$1> $completion) {
                return (Continuation<Unit>) new UnityBridgeActivity$audioPlayerGetPlayingAudioTotalTime$1($completion);
            }

            @Nullable
            public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                return ((UnityBridgeActivity$audioPlayerGetPlayingAudioTotalTime$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
            }
        }
        public final void audioPlayerIsPlaying () {
            if (this.bound && this.musicService != null) {
                if (this.musicService != null) {
                    this.musicService.audioPlayerIsPlaying();
                } else {

                }
            } else {
                IsPlaying isplayingIn = new IsPlaying(false);
                UnityPlayer.UnitySendMessage("Boot", "audioPlayerIsPlaying", (new Gson()).toJson(isplayingIn));
            }
        }
        public final void audioPlayerPlayAudio ( int targetIndex){
            if (this.bound && this.musicService != null) {
                if (this.musicService != null) {
                    this.musicService.audioPlayerPlayAudio(targetIndex);
                } else {

                }
                UnityPlayer.UnitySendMessage("Boot", "playItemAt", String.valueOf(targetIndex));
            }
        }
        @NotNull public final String getDeleteJson () {
            return this.deleteJson;
        }
        public final void audioPlayerDeleteItems (@NotNull String deleteJson){
            Intrinsics.checkNotNullParameter(deleteJson, "deleteJson");
            if (!this.bound || this.musicService == null)
                return;
            try {
                new JSONObject(deleteJson);
            } catch (JSONException e) {
                return;
            }
            try {
                MusicService musicService = this.musicService;
                if (musicService != null) {
                    musicService.audioPlayerDeleteItems(deleteJson);
                } else {

                }
                UnityPlayer.UnitySendMessage("Boot", "audioPlayerDeleteItemsWithJson", deleteJson);
            } catch (Exception exception) {
            }
        }
        public final void audioPlayerGetPlayingAudioInfo () {
            if (!this.bound || this.musicService == null)
                return;
            BuildersKt.launch$default((CoroutineScope) LifecycleOwnerKt.getLifecycleScope((LifecycleOwner) this), null, null, new UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1(null), 3, null);
        }
        @DebugMetadata(f = "UnityBridgeActivity.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1")
        @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
        static final class UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
            int label;

            UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1(Continuation $completion) {
                super(2, $completion);
            }

            @Nullable
            public final Object invokeSuspend(@NotNull Object $result) {
                IntrinsicsKt.getCOROUTINE_SUSPENDED();
                switch (this.label) {
                    case 0:
                        ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                        try {
                            UnityBridgeActivity.this.musicService;
                            MusicInfo currentMusicInfo = (UnityBridgeActivity.this.musicService != null) ? UnityBridgeActivity.this.musicService.getCurrentPlayingMusicInfo() : null;
                            UnityBridgeActivity.this.musicService;
                            int currentIndex = (UnityBridgeActivity.this.musicService != null) ? UnityBridgeActivity.this.musicService.getCurrentPlayingIndex() : -1;
                            UnityBridgeActivity.this.musicService;
                            double totalDuration = (UnityBridgeActivity.this.musicService != null) ? UnityBridgeActivity.this.musicService.audioPlayerGetPlayingAudioTotalTime() : 0.0D;
                            UnityBridgeActivity.this.musicService;
                            double currentTime = (UnityBridgeActivity.this.musicService != null) ? UnityBridgeActivity.this.musicService.audioPlayerGetPlayingAudioCurrentTime() : 0.0D;
                            JSONObject jSONObject1 = new JSONObject(), $this$invokeSuspend_u24lambda_u240 = jSONObject1;
                            int $i$a$ -apply - UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1$musicInfo$1 = 0;
                            if (currentMusicInfo == null || currentMusicInfo.getUrl() == null)
                                currentMusicInfo.getUrl();
                            "url".put(currentMusicInfo.getUrl(), "");
                            if (currentMusicInfo == null || currentMusicInfo.getTitle() == null)
                                currentMusicInfo.getTitle();
                            "title".put(currentMusicInfo.getTitle(), "");
                            if (currentMusicInfo == null || currentMusicInfo.getArtist() == null)
                                currentMusicInfo.getArtist();
                            "artist".put(currentMusicInfo.getArtist(), "");
                            if (currentMusicInfo == null || currentMusicInfo.getCover() == null)
                                currentMusicInfo.getCover();
                            "cover".put(currentMusicInfo.getCover(), "");
                            $this$invokeSuspend_u24lambda_u240.put("duration", totalDuration);
                            $this$invokeSuspend_u24lambda_u240.put("currentTime", currentTime);
                            $this$invokeSuspend_u24lambda_u240.put("index", currentIndex);
                            JSONObject musicInfo = jSONObject1;
                            Intrinsics.checkNotNullExpressionValue(musicInfo.toString(), "toString(...)");
                            String musicInfoJson = musicInfo.toString();
                            UnityPlayer.UnitySendMessage("Boot", "audioPlayerGetPlayingAudioInfo", musicInfoJson);
                        } catch (Exception exception) {
                            JSONObject jSONObject1 = new JSONObject(), $this$invokeSuspend_u24lambda_u241 = jSONObject1;
                            int $i$a$ -apply - UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1$emptyInfo$1 = 0;
                            $this$invokeSuspend_u24lambda_u241.put("url", "");
                            $this$invokeSuspend_u24lambda_u241.put("title", "");
                            $this$invokeSuspend_u24lambda_u241.put("artist", "");
                            $this$invokeSuspend_u24lambda_u241.put("cover", "");
                            $this$invokeSuspend_u24lambda_u241.put("duration", 0.0D);
                            $this$invokeSuspend_u24lambda_u241.put("currentTime", 0.0D);
                            $this$invokeSuspend_u24lambda_u241.put("index", -1);
                            JSONObject emptyInfo = jSONObject1;
                            UnityPlayer.UnitySendMessage("Boot", "audioPlayerGetPlayingAudioInfo", emptyInfo.toString());
                        } return Unit.INSTANCE;
                } throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }

            @NotNull
            public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1> $completion) {
                return (Continuation<Unit>) new UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1($completion);
            }

            @Nullable
            public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                return ((UnityBridgeActivity$audioPlayerGetPlayingAudioInfo$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
            }
        }
        public final void audioPlayerAddItemsToPlayList (@NotNull String addJson){
            Intrinsics.checkNotNullParameter(addJson, "addJson");
            if (!this.bound || this.musicService == null)
                return;
            BuildersKt.launch$default((CoroutineScope) LifecycleOwnerKt.getLifecycleScope((LifecycleOwner) this), null, null, new UnityBridgeActivity$audioPlayerAddItemsToPlayList$1(addJson, null), 3, null);
        }
        @DebugMetadata(f = "UnityBridgeActivity.kt", l = {726}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$audioPlayerAddItemsToPlayList$1")
        @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
        static final class UnityBridgeActivity$audioPlayerAddItemsToPlayList$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
            int label;

            UnityBridgeActivity$audioPlayerAddItemsToPlayList$1(String $addJson, Continuation $completion) {
                super(2, $completion);
            }

            @Nullable
            public final Object invokeSuspend(@NotNull Object $result) { // Byte code:
                //   0: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
                //   3: astore_3
                //   4: aload_0
                //   5: getfield label : I
                //   8: tableswitch default -> 135, 0 -> 32, 1 -> 77
                //   32: aload_1
                //   33: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                //   36: nop
                //   37: invokestatic getIO : ()Lkotlinx/coroutines/CoroutineDispatcher;
                //   40: checkcast kotlin/coroutines/CoroutineContext
                //   43: new com/etouch/activity/UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1
                //   46: dup
                //   47: aload_0
                //   48: getfield $addJson : Ljava/lang/String;
                //   51: aconst_null
                //   52: invokespecial <init> : (Ljava/lang/String;Lkotlin/coroutines/Continuation;)V
                //   55: checkcast kotlin/jvm/functions/Function2
                //   58: aload_0
                //   59: checkcast kotlin/coroutines/Continuation
                //   62: aload_0
                //   63: iconst_1
                //   64: putfield label : I
                //   67: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
                //   70: dup
                //   71: aload_3
                //   72: if_acmpne -> 83
                //   75: aload_3
                //   76: areturn
                //   77: nop
                //   78: aload_1
                //   79: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                //   82: aload_1
                //   83: checkcast java/util/List
                //   86: astore_2
                //   87: aload_2
                //   88: invokeinterface isEmpty : ()Z
                //   93: ifeq -> 100
                //   96: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                //   99: areturn
                //   100: aload_0
                //   101: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                //   104: invokestatic access$getMusicService$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/service/MusicService;
                //   107: dup
                //   108: ifnull -> 122
                //   111: aload_2
                //   112: invokestatic checkNotNull : (Ljava/lang/Object;)V
                //   115: aload_2
                //   116: invokevirtual audioPlayerAddItemsToPlayList : (Ljava/util/List;)V
                //   119: goto -> 131
                //   122: pop
                //   123: goto -> 131
                //   126: astore_2
                //   127: goto -> 131
                //   130: astore_2
                //   131: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                //   134: areturn
                //   135: new java/lang/IllegalStateException
                //   138: dup
                //   139: ldc 'call to 'resume' before 'invoke' with coroutine'
                //   141: invokespecial <init> : (Ljava/lang/String;)V
                //   144: athrow
                // Line number table:
                //   Java source line number -> byte code offset
                //   #723	-> 3
                //   #724	-> 36
                //   #726	-> 37
                //   #723	-> 75
                //   #733	-> 87
                //   #735	-> 96
                //   #739	-> 100
                //   #745	-> 126
                //   #747	-> 130
                //   #750	-> 131
                //   #723	-> 135
                // Local variable table:
                //   start	length	slot	name	descriptor
                //   87	9	2	newMusicList	Ljava/util/List;
                //   100	22	2	newMusicList	Ljava/util/List;
                //   36	99	0	this	Lcom/etouch/activity/UnityBridgeActivity$audioPlayerAddItemsToPlayList$1;
                //   36	99	1	$result	Ljava/lang/Object;
                // Exception table:
                //   from	to	target	type
                //   36	70	126	org/json/JSONException
                //   36	70	130	java/lang/Exception
                //   77	123	126	org/json/JSONException
                //   77	123	130	java/lang/Exception }
                @NotNull public final Continuation<Unit> create (@Nullable Object value, @NotNull Continuation < ? super
                UnityBridgeActivity$audioPlayerAddItemsToPlayList$1 > $completion){
                    return (Continuation<Unit>) new UnityBridgeActivity$audioPlayerAddItemsToPlayList$1(this.$addJson, $completion);
                }
                @Nullable public final Object invoke (@NotNull CoroutineScope p1, @Nullable Continuation < ? > p2){
                    return ((UnityBridgeActivity$audioPlayerAddItemsToPlayList$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
                }
                @DebugMetadata(f = "UnityBridgeActivity.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1")
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\020\n\000\n\002\020 \n\002\030\002\n\000\n\002\030\002\020\000\032\026\022\004\022\0020\002 \003*\n\022\004\022\0020\002\030\0010\0010\001*\0020\004H@"}, d2 = {"<anonymous>", "", "Lcom/etouch/service/MusicInfo;", "kotlin.jvm.PlatformType", "Lkotlinx/coroutines/CoroutineScope;"})
                static final class UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super List<? extends MusicInfo>>, Object> {
                    int label;

                    UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1(String $addJson, Continuation $completion) {
                        super(2, $completion);
                    }

                    @Nullable
                    public final Object invokeSuspend(@NotNull Object $result) {
                        Type type;
                        IntrinsicsKt.getCOROUTINE_SUSPENDED();
                        switch (this.label) {
                            case 0:
                                ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                                type = (new UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1$type$1()).getType();
                                return (new Gson()).fromJson(this.$addJson, type);
                        }
                        throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                    }

                    @NotNull
                    public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1> $completion) {
                        return (Continuation<Unit>) new UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1(this.$addJson, $completion);
                    }

                    @Nullable
                    public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                        return ((UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
                    }

                    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\023\n\000\n\002\030\002\n\002\020 \n\002\030\002\n\000*\001\000\b\n\030\0002\016\022\n\022\b\022\004\022\0020\0030\0020\001¨\006\004"}, d2 = {"com/etouch/activity/UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1$type$1", "Lcom/google/gson/reflect/TypeToken;", "", "Lcom/etouch/service/MusicInfo;", "sdk_android_unity_bridge_v1_debug"})
                    public static final class UnityBridgeActivity$audioPlayerAddItemsToPlayList$1$newMusicList$1$type$1 extends TypeToken<List<? extends MusicInfo>> {
                    }
                }
            }

            private final void startMusicService() {
                Intent intent = new Intent((Context) this, MusicService.class);
                ContextCompat.startForegroundService((Context) this, intent);
            }

            public final void audioPlayerStopService() {
                Intent intent = new Intent((Context) this, MusicService.class);
                stopService(intent);
            }

            protected void onCreate(@Nullable Bundle savedInstanceState) {
                super.onCreate(savedInstanceState);
                Intent intent = new Intent((Context) this, MusicService.class);
                if (Build.VERSION.SDK_INT >= 26) {
                    startForegroundService(intent);
                } else {
                    startService(intent);
                }
                bindService(intent, this.connection, 1);
                this.unityPlayer = new UnityPlayer((Context) this);
                setContentView((View) this.unityPlayer);
                if (this.unityPlayer != null) {
                    this.unityPlayer.requestFocus();
                } else {

                }
                setBluetoothManager(BluetoothManager.Companion.getInstance((Context) this));
                initBluetoothCallBack();
            }

            protected void onStart() {
                super.onStart();
                Intent intent = new Intent((Context) this, MusicService.class);
                bindService(intent, this.connection, 1);
            }

            protected void onStop() {
                super.onStop();
            }

            public final void showToast() {
            }

            public final void openBluetooth() { // Byte code:
                //   0: getstatic android/os/Build$VERSION.SDK_INT : I
                //   3: bipush #31
                //   5: if_icmplt -> 29
                //   8: iconst_2
                //   9: anewarray java/lang/String
                //   12: astore_2
                //   13: aload_2
                //   14: iconst_0
                //   15: ldc_w 'android.permission.BLUETOOTH_SCAN'
                //   18: aastore
                //   19: aload_2
                //   20: iconst_1
                //   21: ldc_w 'android.permission.BLUETOOTH_CONNECT'
                //   24: aastore
                //   25: aload_2
                //   26: goto -> 53
                //   29: iconst_3
                //   30: anewarray java/lang/String
                //   33: astore_2
                //   34: aload_2
                //   35: iconst_0
                //   36: ldc_w 'android.permission.BLUETOOTH'
                //   39: aastore
                //   40: aload_2
                //   41: iconst_1
                //   42: ldc_w 'android.permission.BLUETOOTH_ADMIN'
                //   45: aastore
                //   46: aload_2
                //   47: iconst_2
                //   48: ldc_w 'android.permission.ACCESS_FINE_LOCATION'
                //   51: aastore
                //   52: aload_2
                //   53: astore_1
                //   54: getstatic android/os/Build$VERSION.SDK_INT : I
                //   57: bipush #31
                //   59: if_icmplt -> 96
                //   62: aload_0
                //   63: checkcast android/content/Context
                //   66: ldc_w 'android.permission.BLUETOOTH_SCAN'
                //   69: invokestatic checkSelfPermission : (Landroid/content/Context;Ljava/lang/String;)I
                //   72: ifne -> 92
                //   75: aload_0
                //   76: checkcast android/content/Context
                //   79: ldc_w 'android.permission.BLUETOOTH_CONNECT'
                //   82: invokestatic checkSelfPermission : (Landroid/content/Context;Ljava/lang/String;)I
                //   85: ifne -> 92
                //   88: iconst_1
                //   89: goto -> 140
                //   92: iconst_0
                //   93: goto -> 140
                //   96: aload_0
                //   97: checkcast android/content/Context
                //   100: ldc_w 'android.permission.BLUETOOTH'
                //   103: invokestatic checkSelfPermission : (Landroid/content/Context;Ljava/lang/String;)I
                //   106: ifne -> 139
                //   109: aload_0
                //   110: checkcast android/content/Context
                //   113: ldc_w 'android.permission.BLUETOOTH_ADMIN'
                //   116: invokestatic checkSelfPermission : (Landroid/content/Context;Ljava/lang/String;)I
                //   119: ifne -> 139
                //   122: aload_0
                //   123: checkcast android/content/Context
                //   126: ldc_w 'android.permission.ACCESS_FINE_LOCATION'
                //   129: invokestatic checkSelfPermission : (Landroid/content/Context;Ljava/lang/String;)I
                //   132: ifne -> 139
                //   135: iconst_1
                //   136: goto -> 140
                //   139: iconst_0
                //   140: istore_2
                //   141: iload_2
                //   142: ifeq -> 152
                //   145: aload_0
                //   146: invokevirtual checkBluetoothEnabled : ()V
                //   149: goto -> 161
                //   152: aload_0
                //   153: aload_1
                //   154: aload_0
                //   155: getfield REQUEST_CODE_BLUETOOTH_PERMISSIONS : I
                //   158: invokevirtual requestPermissions : ([Ljava/lang/String;I)V
                //   161: return
                // Line number table:
                //   Java source line number -> byte code offset
                //   #1069	-> 0
                //   #1071	-> 8
                //   #1072	-> 21
                //   #1071	-> 25
                //   #1076	-> 29
                //   #1077	-> 42
                //   #1076	-> 46
                //   #1078	-> 48
                //   #1076	-> 52
                //   #1069	-> 53
                //   #1082	-> 54
                //   #1085	-> 62
                //   #1086	-> 66
                //   #1084	-> 69
                //   #1089	-> 75
                //   #1090	-> 79
                //   #1088	-> 82
                //   #1095	-> 96
                //   #1096	-> 100
                //   #1094	-> 103
                //   #1099	-> 109
                //   #1100	-> 113
                //   #1098	-> 116
                //   #1103	-> 122
                //   #1104	-> 126
                //   #1102	-> 129
                //   #1082	-> 140
                //   #1108	-> 141
                //   #1110	-> 145
                //   #1113	-> 152
                //   #1115	-> 161
                // Local variable table:
                //   start	length	slot	name	descriptor
                //   54	108	1	bluetoothPermissions	[Ljava/lang/String;
                //   141	21	2	hasPermissions	Z
                //   0	162	0	this	Lcom/etouch/activity/UnityBridgeActivity; }
                public final void checkBluetoothEnabled () {
                    BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
                    if (bluetoothAdapter == null) {
                        UnityPlayer.UnitySendMessage("Boot", "checkBluetoothEnabled", "设备不支持蓝牙");
                        return;
                    }
                    if (!bluetoothAdapter.isEnabled()) {
                        Intent enableBtIntent = new Intent("android.bluetooth.adapter.action.REQUEST_ENABLE");
                        startActivityForResult(enableBtIntent, this.REQUEST_CODE_ENABLE_BLUETOOTH);
                    } else {
                        this.isScanning = true;
                        getBluetoothManager().startScanning();
                    }
                }
                public void onRequestPermissionsResult ( int requestCode, @NotNull String[] permissions,
                @NotNull int[] grantResults){
                    Intrinsics.checkNotNullParameter(permissions, "permissions");
                    Intrinsics.checkNotNullParameter(grantResults, "grantResults");
                    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
                    if (requestCode == this.REQUEST_CODE_BLUETOOTH_PERMISSIONS) {
                        boolean allGranted = true;
                        byte b;
                        int i;
                        for (b = 0, i = grantResults.length; b < i; ) {
                            int grantResult = grantResults[b];
                            if (grantResult != 0) {
                                allGranted = false;
                                break;
                            }
                            b++;
                        }
                        if (allGranted)
                            checkBluetoothEnabled();
                    } else if (requestCode == this.REQUEST_CODE_CAMERA) {
                        if ((!((grantResults.length == 0) ? 1 : 0)) && grantResults[0] == 0) {
                            Intent intent = new Intent((Context) this, QRScanActivity.class);
                            startActivityForResult(intent, 49374);
                        }
                    }
                }
                protected void onActivityResult ( int requestCode, int resultCode, @Nullable Intent data){
                    super.onActivityResult(requestCode, resultCode, data);
                    int i = requestCode;
                    if (i == this.REQUEST_CODE_ENABLE_BLUETOOTH) {
                        if (resultCode == -1) {
                            this.isScanning = true;
                            getBluetoothManager().startScanning();
                            this.pendingStartScan = true;
                        }
                    } else if (i == 49374) {
                        String scanResult = QRScanner.Companion.handleScanResult(requestCode, resultCode, data);
                        if (scanResult != null) {
                            ScanResultInfo scanResultInfo = new ScanResultInfo(null, 1, null);
                            scanResultInfo.setScanResult(scanResult);
                            UnityPlayer.UnitySendMessage("Boot", "startQRCodeScan", (new Gson()).toJson(scanResultInfo));
                        }
                    }
                }
                private final void updateDeviceList (List < BluetoothManager.BluetoothDeviceInfo > newDeviceList) {
                    this.discoveredDevicesList = newDeviceList;
                    if (this.scanResultAdapter == null)
                        Intrinsics.throwUninitializedPropertyAccessException("scanResultAdapter");
                    null.submitList(newDeviceList);
                }
                public final void initBluetoothCallBack () {
                    getBluetoothManager().setOnScanResult(new UnityBridgeActivity$initBluetoothCallBack$1());
                    getBluetoothManager().setOnTargetDeviceFound(new UnityBridgeActivity$initBluetoothCallBack$2());
                    getBluetoothManager().setOnConnectionStateChanged(new UnityBridgeActivity$initBluetoothCallBack$3());
                    getBluetoothManager().setOnBatteryLevelUpdated(new UnityBridgeActivity$initBluetoothCallBack$4());
                    getBluetoothManager().setOnCurrentGearUpdated(new UnityBridgeActivity$initBluetoothCallBack$5());
                    getBluetoothManager().setOnVibrationTypeUpdated(new UnityBridgeActivity$initBluetoothCallBack$6());
                    getBluetoothManager().setOnControlSourceUpdated(new UnityBridgeActivity$initBluetoothCallBack$7());
                }
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "device", "Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;", "invoke"})
                static final class UnityBridgeActivity$initBluetoothCallBack$1 extends Lambda implements Function1<BluetoothManager.BluetoothDeviceInfo, Unit> {
                    public final void invoke(@NotNull BluetoothManager.BluetoothDeviceInfo device) {
                        Intrinsics.checkNotNullParameter(device, "device");
                        UnityBridgeActivity.this.setDiscoveredDevicesList(CollectionsKt.toList(UnityBridgeActivity.this.getBluetoothManager().getDiscoveredDevices()));
                        UnityPlayer.UnitySendMessage("Boot", "discoveredDevicesList", (new Gson()).toJson(UnityBridgeActivity.this.getDiscoveredDevicesList()));
                    }

                    UnityBridgeActivity$initBluetoothCallBack$1() {
                        super(1);
                    }
                }
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "device", "Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;", "invoke"})
                static final class UnityBridgeActivity$initBluetoothCallBack$2 extends Lambda implements Function1<BluetoothManager.BluetoothDeviceInfo, Unit> {
                    public final void invoke(@NotNull BluetoothManager.BluetoothDeviceInfo device) {
                        Intrinsics.checkNotNullParameter(device, "device");
                        UnityBridgeActivity.this.setDiscoveredDevicesList(CollectionsKt.toList(UnityBridgeActivity.this.getBluetoothManager().getDiscoveredDevices()));
                    }

                    UnityBridgeActivity$initBluetoothCallBack$2() {
                        super(1);
                    }
                }
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\013\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "connected", "", "invoke"})
                @SourceDebugExtension({"SMAP\nUnityBridgeActivity.kt\nKotlin\n*S Kotlin\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$initBluetoothCallBack$3\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,3505:1\n1747#2,3:3506\n*S KotlinDebug\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$initBluetoothCallBack$3\n*L\n1271#1:3506,3\n*E\n"})
                static final class UnityBridgeActivity$initBluetoothCallBack$3 extends Lambda implements Function1<Boolean, Unit> {
                    public final void invoke(boolean connected) { // Byte code:
                        //   0: iload_1
                        //   1: ifeq -> 237
                        //   4: aload_0
                        //   5: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        //   8: invokevirtual getBluetoothManager : ()Lcom/etouch/bt/BluetoothManager;
                        //   11: invokevirtual getTargetDevice : ()Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
                        //   14: dup
                        //   15: ifnull -> 211
                        //   18: astore_2
                        //   19: aload_0
                        //   20: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        //   23: astore_3
                        //   24: aload_2
                        //   25: astore #4
                        //   27: iconst_0
                        //   28: istore #5
                        //   30: aload_3
                        //   31: aload #4
                        //   33: invokevirtual getName : ()Ljava/lang/String;
                        //   36: invokestatic valueOf : (Ljava/lang/Object;)Ljava/lang/String;
                        //   39: invokevirtual setConnectedDeviceName : (Ljava/lang/String;)V
                        //   42: aload_3
                        //   43: aload #4
                        //   45: invokevirtual getAddress : ()Ljava/lang/String;
                        //   48: invokestatic valueOf : (Ljava/lang/Object;)Ljava/lang/String;
                        //   51: invokevirtual setConnectedDeviceAddress : (Ljava/lang/String;)V
                        //   54: aload_3
                        //   55: invokevirtual getConnectedDevicesList : ()Ljava/util/List;
                        //   58: checkcast java/lang/Iterable
                        //   61: astore #6
                        //   63: iconst_0
                        //   64: istore #7
                        //   66: aload #6
                        //   68: instanceof java/util/Collection
                        //   71: ifeq -> 91
                        //   74: aload #6
                        //   76: checkcast java/util/Collection
                        //   79: invokeinterface isEmpty : ()Z
                        //   84: ifeq -> 91
                        //   87: iconst_0
                        //   88: goto -> 150
                        //   91: aload #6
                        //   93: invokeinterface iterator : ()Ljava/util/Iterator;
                        //   98: astore #8
                        //   100: aload #8
                        //   102: invokeinterface hasNext : ()Z
                        //   107: ifeq -> 149
                        //   110: aload #8
                        //   112: invokeinterface next : ()Ljava/lang/Object;
                        //   117: astore #9
                        //   119: aload #9
                        //   121: checkcast com/etouch/bt/BluetoothManager$BluetoothDeviceInfo
                        //   124: astore #10
                        //   126: iconst_0
                        //   127: istore #11
                        //   129: aload #4
                        //   131: invokevirtual getAddress : ()Ljava/lang/String;
                        //   134: aload #10
                        //   136: invokevirtual getAddress : ()Ljava/lang/String;
                        //   139: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
                        //   142: ifeq -> 100
                        //   145: iconst_1
                        //   146: goto -> 150
                        //   149: iconst_0
                        //   150: istore #12
                        //   152: iload #12
                        //   154: ifne -> 207
                        //   157: aload_3
                        //   158: invokevirtual getConnectedDevicesList : ()Ljava/util/List;
                        //   161: aload #4
                        //   163: invokeinterface add : (Ljava/lang/Object;)Z
                        //   168: pop
                        //   169: new com/google/gson/Gson
                        //   172: dup
                        //   173: invokespecial <init> : ()V
                        //   176: astore #6
                        //   178: aload #6
                        //   180: aload_3
                        //   181: invokevirtual getConnectedDevicesList : ()Ljava/util/List;
                        //   184: invokevirtual toJson : (Ljava/lang/Object;)Ljava/lang/String;
                        //   187: astore #7
                        //   189: getstatic com/etouch/SPUtils.INSTANCE : Lcom/etouch/SPUtils;
                        //   192: aload_3
                        //   193: checkcast android/content/Context
                        //   196: ldc 'connectedDevicesList'
                        //   198: aload #7
                        //   200: aconst_null
                        //   201: bipush #8
                        //   203: aconst_null
                        //   204: invokestatic putString$default : (Lcom/etouch/SPUtils;Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/Object;)V
                        //   207: nop
                        //   208: goto -> 213
                        //   211: pop
                        //   212: nop
                        //   213: ldc 'Boot'
                        //   215: ldc 'connectedDeviceAddress'
                        //   217: aload_0
                        //   218: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        //   221: invokevirtual getConnectedDeviceAddress : ()Ljava/lang/String;
                        //   224: invokestatic UnitySendMessage : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
                        //   227: aload_0
                        //   228: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        //   231: invokevirtual sendHistoryConnectedList : ()V
                        //   234: goto -> 246
                        //   237: ldc 'Boot'
                        //   239: ldc 'connectedDeviceError'
                        //   241: ldc '设备已断开'
                        //   243: invokestatic UnitySendMessage : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
                        //   246: return
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #1262	-> 0
                        //   #1263	-> 4
                        //   #1264	-> 30
                        //   #1265	-> 42
                        //   #1271	-> 54
                        //   #3506	-> 66
                        //   #3507	-> 91
                        //   #1272	-> 129
                        //   #3507	-> 142
                        //   #3508	-> 149
                        //   #1271	-> 150
                        //   #1276	-> 152
                        //   #1277	-> 157
                        //   #1280	-> 169
                        //   #1281	-> 178
                        //   #1282	-> 189
                        //   #1284	-> 207
                        //   #1263	-> 208
                        //   #1263	-> 211
                        //   #1287	-> 213
                        //   #1286	-> 224
                        //   #1289	-> 227
                        //   #1292	-> 237
                        //   #1291	-> 243
                        //   #1296	-> 246
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   129	13	11	$i$a$-any-UnityBridgeActivity$initBluetoothCallBack$3$1$isDeviceExisted$1	I
                        //   126	16	10	info	Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
                        //   119	30	9	element$iv	Ljava/lang/Object;
                        //   66	84	7	$i$f$any	I
                        //   63	87	6	$this$any$iv	Ljava/lang/Iterable;
                        //   178	29	6	gson	Lcom/google/gson/Gson;
                        //   189	18	7	deviceListJson	Ljava/lang/String;
                        //   30	178	5	$i$a$-let-UnityBridgeActivity$initBluetoothCallBack$3$1	I
                        //   152	56	12	isDeviceExisted	Z
                        //   27	181	4	device	Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
                        //   0	247	0	this	Lcom/etouch/activity/UnityBridgeActivity$initBluetoothCallBack$3;
                        //   0	247	1	connected	Z }
                        UnityBridgeActivity$initBluetoothCallBack$3() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\b\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "level", "", "invoke"})
                    static final class UnityBridgeActivity$initBluetoothCallBack$4 extends Lambda implements Function1<Integer, Unit> {
                        public final void invoke(int level) {
                            UnityBridgeActivity.this.setDeviceBatteryLevel(level);
                            UnityPlayer.UnitySendMessage("Boot", "deviceBatteryLevel", String.valueOf(UnityBridgeActivity.this.getDeviceBatteryLevel()));
                        }

                        UnityBridgeActivity$initBluetoothCallBack$4() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\022\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "gear", "", "invoke"})
                    static final class UnityBridgeActivity$initBluetoothCallBack$5 extends Lambda implements Function1<byte[], Unit> {
                        public final void invoke(@NotNull byte[] gear) {
                            Intrinsics.checkNotNullParameter(gear, "gear");
                            UnityBridgeActivity.this.setCurrentGear(gear);
                            UnityPlayer.UnitySendMessage("Boot", "currentGear", gear.toString());
                        }

                        UnityBridgeActivity$initBluetoothCallBack$5() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\b\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "type", "", "invoke"})
                    static final class UnityBridgeActivity$initBluetoothCallBack$6 extends Lambda implements Function1<Integer, Unit> {
                        public final void invoke(int type) {
                            UnityBridgeActivity.this.setVibrationType(type);
                            UnityPlayer.UnitySendMessage("Boot", "vibrationType", String.valueOf(type));
                        }

                        UnityBridgeActivity$initBluetoothCallBack$6() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\b\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "source", "", "invoke"})
                    static final class UnityBridgeActivity$initBluetoothCallBack$7 extends Lambda implements Function1<Integer, Unit> {
                        public final void invoke(int source) {
                            UnityBridgeActivity.this.setControlSource(source);
                            UnityPlayer.UnitySendMessage("Boot", "controlSource", String.valueOf(source));
                        }

                        UnityBridgeActivity$initBluetoothCallBack$7() {
                            super(1);
                        }
                    }

                    public final void getDeviceInfo() {
                        DeviceInfo deviceInfo = new DeviceInfo(null, null, null, null, null, null, null, 127, null);
                        deviceInfo.setDeviceBatteryLevel(Integer.valueOf(this.deviceBatteryLevel));
                        deviceInfo.setDeviceName(this.connectedDeviceName);
                        if (this.currentGear != null) {
                            Intrinsics.checkNotNull(this.currentGear);
                            deviceInfo.setCurrentGear(new String(this.currentGear, Charsets.UTF_8));
                        }
                        deviceInfo.setVibrationType(Integer.valueOf(this.vibrationType));
                        deviceInfo.setControlSource(Integer.valueOf(this.controlSource));
                        UnityPlayer.UnitySendMessage("Boot", "deviceInfo", (new Gson()).toJson(deviceInfo));
                    }

                    public final void getDevicesConnectState(@NotNull String uuidListJson) {
                        Intrinsics.checkNotNullParameter(uuidListJson, "uuidListJson");
                        Type type = (new UnityBridgeActivity$getDevicesConnectState$type$1()).getType();
                        Intrinsics.checkNotNullExpressionValue((new Gson()).fromJson(uuidListJson, type), "fromJson(...)");
                        List uuidList = (List) (new Gson()).fromJson(uuidListJson, type);
                        getBluetoothManager().getConnectedGatt().getDevice();
                        String connectedAddress = (getBluetoothManager().getConnectedGatt() != null && getBluetoothManager().getConnectedGatt().getDevice() != null) ? getBluetoothManager().getConnectedGatt().getDevice().getAddress() : null;
                        Iterable $this$map$iv = uuidList;
                        int $i$f$map = 0;
                        Iterable iterable1 = $this$map$iv;
                        Collection destination$iv$iv = new ArrayList(CollectionsKt.collectionSizeOrDefault($this$map$iv, 10));
                        int $i$f$mapTo = 0;
                        for (Object item$iv$iv : iterable1) {
                            DevicesUUidInfo devicesUUidInfo = (DevicesUUidInfo) item$iv$iv;
                            Collection collection = destination$iv$iv;
                            int $i$a$ -map - UnityBridgeActivity$getDevicesConnectState$result$1 = 0;
                            String deviceUuid = devicesUUidInfo.getUuid();
                        } List result = CollectionsKt.toMutableList(destination$iv$iv);
                        UnityPlayer.UnitySendMessage("Boot", "devicesConnectState", (new Gson()).toJson(result));
                    }

                    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\023\n\000\n\002\030\002\n\002\020!\n\002\030\002\n\000*\001\000\b\n\030\0002\016\022\n\022\b\022\004\022\0020\0030\0020\001¨\006\004"}, d2 = {"com/etouch/activity/UnityBridgeActivity$getDevicesConnectState$type$1", "Lcom/google/gson/reflect/TypeToken;", "", "Lcom/etouch/DevicesUUidInfo;", "sdk_android_unity_bridge_v1_debug"})
                    public static final class UnityBridgeActivity$getDevicesConnectState$type$1 extends TypeToken<List<DevicesUUidInfo>> {
                    }

                    public final void connectBluetooth(@NotNull String deviceJson) {
                        BluetoothDevice bluetoothDevice1;
                        Intrinsics.checkNotNullParameter(deviceJson, "deviceJson");
                        Intrinsics.checkNotNullExpressionValue((new Gson()).fromJson(deviceJson, BluetoothManager.BluetoothDeviceInfo.class), "fromJson(...)");
                        BluetoothManager.BluetoothDeviceInfo deviceInfo = (BluetoothManager.BluetoothDeviceInfo) (new Gson()).fromJson(deviceJson, BluetoothManager.BluetoothDeviceInfo.class);
                        String deviceAddress = deviceInfo.getAddress();
                        if (deviceAddress != null && ((deviceAddress.length() == 0))) return;
                        BluetoothAdapter bluetoothAdapter1 = BluetoothAdapter.getDefaultAdapter();
                        if (bluetoothAdapter1 == null) {
                            UnityBridgeActivity $this$connectBluetooth_u24lambda_u2418 = this;
                            int $i$a$ -run - UnityBridgeActivity$connectBluetooth$bluetoothAdapter$1 = 0;
                            return;
                        } BluetoothAdapter bluetoothAdapter = bluetoothAdapter1;
                        try {
                            bluetoothDevice1 = bluetoothAdapter.getRemoteDevice(deviceAddress);
                            Intrinsics.checkNotNull(bluetoothDevice1);
                            bluetoothDevice1 = bluetoothDevice1;
                        } catch (IllegalArgumentException e) {
                            return;
                        }
                        BluetoothDevice validBluetoothDevice = bluetoothDevice1;
                        BluetoothManager.BluetoothDeviceInfo device = new BluetoothManager.BluetoothDeviceInfo(null, null, null, null, null, null, null, null, 255, null);
                        device.setDevice(validBluetoothDevice);
                        device.setName(deviceInfo.getName());
                        device.setAddress(deviceInfo.getAddress());
                        device.setRssi(deviceInfo.getRssi());
                        device.setPaired(deviceInfo.isPaired());
                        device.setConnected(deviceInfo.isConnected());
                        device.setTargetDevice(deviceInfo.isTargetDevice());
                        getBluetoothManager().stopScanning();
                        this.isScanning = false;
                        getBluetoothManager().connect(device);
                    }

                    public final void stopBluetoothScanning() {
                        getBluetoothManager().stopScanning();
                        this.isScanning = false;
                    }

                    public final void getHistoryConnectedList() {
                        String deviceListJson = SPUtils.getString$default(SPUtils.INSTANCE, (Context) this, "connectedDevicesList", null, null, 12, null);
                        String str1 = deviceListJson;
                        if (!((str1 == null || str1.length() == 0) ? 1 : 0))
                            UnityPlayer.UnitySendMessage("Boot", "connectedDevicesList", deviceListJson);
                    }

                    public final void sendHistoryConnectedList() {
                        String deviceListJson = SPUtils.getString$default(SPUtils.INSTANCE, (Context) this, "connectedDevicesList", null, null, 12, null);
                        String str1 = deviceListJson;
                        if (!((str1 == null || str1.length() == 0) ? 1 : 0))
                            UnityPlayer.UnitySendMessage("Boot", "connectedDevicesList", deviceListJson);
                    }

                    public final void disconnectBluetooth() {
                        getBluetoothManager().disconnect();
                    }

                    public final void cleanUpBluetooth() {
                        getBluetoothManager().cleanup();
                    }

                    @NotNull
                    public final String setConnectedDeviceName() {
                        return this.connectedDeviceName;
                    }

                    @Nullable
                    public final String getMVersionCode() {
                        return this.mVersionCode;
                    }

                    public final void setMVersionCode(@Nullable String<set-?>) {
                        this.mVersionCode = < set - ? >;
                    }

                    @Nullable
                    public final String getMVersionName() {
                        return this.mVersionName;
                    }

                    public final void setMVersionName(@Nullable String<set-?>) {
                        this.mVersionName = < set - ? >;
                    }

                    @Nullable
                    public final String getMModelType() {
                        return this.mModelType;
                    }

                    public final void setMModelType(@Nullable String<set-?>) {
                        this.mModelType = < set - ? >;
                    }

                    public final void getSystemDeviceInfo() {
                        UnityBridgeImpl.INSTANCE.getSystemDeviceInfo(new UnityBridgeActivity$getSystemDeviceInfo$1(), new UnityBridgeActivity$getSystemDeviceInfo$2(), new UnityBridgeActivity$getSystemDeviceInfo$3(), (Context) this);
                        SystemDeviceInfo systemDeviceInfo = new SystemDeviceInfo(null, null, null, 7, null);
                        systemDeviceInfo.setVersionCode(this.mVersionCode);
                        systemDeviceInfo.setVersionName(this.mVersionName);
                        systemDeviceInfo.setModelType(this.mModelType);
                        UnityPlayer.UnitySendMessage("Boot", "systemDeviceInfo", (new Gson()).toJson(systemDeviceInfo));
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\016\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "versionCode", "", "invoke"})
                    static final class UnityBridgeActivity$getSystemDeviceInfo$1 extends Lambda implements Function1<String, Unit> {
                        public final void invoke(@NotNull String versionCode) {
                            Intrinsics.checkNotNullParameter(versionCode, "versionCode");
                            UnityBridgeActivity.this.setMVersionCode(versionCode);
                        }

                        UnityBridgeActivity$getSystemDeviceInfo$1() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\016\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "versionName", "", "invoke"})
                    static final class UnityBridgeActivity$getSystemDeviceInfo$2 extends Lambda implements Function1<String, Unit> {
                        public final void invoke(@NotNull String versionName) {
                            Intrinsics.checkNotNullParameter(versionName, "versionName");
                            UnityBridgeActivity.this.setMVersionName(versionName);
                        }

                        UnityBridgeActivity$getSystemDeviceInfo$2() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\016\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "modelType", "", "invoke"})
                    static final class UnityBridgeActivity$getSystemDeviceInfo$3 extends Lambda implements Function1<String, Unit> {
                        public final void invoke(@NotNull String modelType) {
                            Intrinsics.checkNotNullParameter(modelType, "modelType");
                            UnityBridgeActivity.this.setMModelType(modelType);
                        }

                        UnityBridgeActivity$getSystemDeviceInfo$3() {
                            super(1);
                        }
                    }

                    public final void showMediaPicker(int type) {
                        String[] arrayOfString;
                        this.fileType = type;
                        switch (type) {
                            case 0:
                                arrayOfString = new String[1];
                                arrayOfString[0] = "audio/*";
                                this.pickFileLauncher.launch(arrayOfString);
                                break;
                            case 1:
                                arrayOfString = new String[1];
                                arrayOfString[0] = "video/*";
                                this.pickFileLauncher.launch(arrayOfString);
                                break;
                            case 2:
                                arrayOfString = new String[2];
                                arrayOfString[0] = "audio/*";
                                arrayOfString[1] = "video/*";
                                this.pickFileLauncher.launch(arrayOfString);
                                break;
                            case 3:
                            case 4:
                                arrayOfString = new String[1];
                                arrayOfString[0] = "*/*";
                                this.pickFileLauncher.launch(arrayOfString);
                                break;
                            case 5:
                                arrayOfString = new String[1];
                                arrayOfString[0] = "*/*";
                                this.pickFileLauncher.launch(arrayOfString);
                                break;
                            case 6:
                                arrayOfString = new String[1];
                                arrayOfString[0] = "application/pdf";
                                this.pickFileLauncher.launch(arrayOfString);
                                break;
                        }
                    }

                    public final void multipleSelectFiles() {
                        String[] arrayOfString = new String[1];
                        arrayOfString[0] = "*/*";
                        this.pickMultipleFilesLauncher.launch(arrayOfString);
                    }

                    public final void multipleSelectMusicOrVideoFiles(int type) {
                        this.multiFileType = type;
                        String[] arrayOfString = new String[1];
                        arrayOfString[0] = "*/*";
                        this.pickMultipleFilesLauncher2.launch(arrayOfString);
                    }

                    private final CoroutineScope getActivityMultiCoroutineScope() {
                        Lazy lazy = this.activityMultiCoroutineScope$delegate;
                        return (CoroutineScope) lazy.getValue();
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\b\n\000\n\002\030\002\n\000\020\000\032\0020\001H\n¢\006\002\b\002"}, d2 = {"<anonymous>", "Lkotlinx/coroutines/CoroutineScope;", "invoke"})
                    static final class UnityBridgeActivity$activityMultiCoroutineScope$2 extends Lambda implements Function0<CoroutineScope> {
                        public static final UnityBridgeActivity$activityMultiCoroutineScope$2 INSTANCE = new UnityBridgeActivity$activityMultiCoroutineScope$2();

                        @NotNull
                        public final CoroutineScope invoke() {
                            return CoroutineScopeKt.CoroutineScope(JobKt.Job$default(null, 1, null).plus((CoroutineContext) Dispatchers.getIO()));
                        }

                        UnityBridgeActivity$activityMultiCoroutineScope$2() {
                            super(0);
                        }
                    }

                    @NotNull
                    public final List<AudioFile> getMMultiNewFiles() {
                        return this.mMultiNewFiles;
                    }

                    public final void setMMultiNewFiles(@NotNull List<AudioFile> <set-?>) {
                        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
                        this.mMultiNewFiles = < set - ? >;
                    }

                    @NotNull
                    public final List<AudioFile> getMMultiTypeNewFiles() {
                        return this.mMultiTypeNewFiles;
                    }

                    public final void setMMultiTypeNewFiles(@NotNull List<AudioFile> <set-?>) {
                        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
                        this.mMultiTypeNewFiles = < set - ? >;
                    }

                    private final void handleMultiUris(List uris) {
                        Iterable $this$filter$iv = uris;
                        int $i$f$filter = 0;
                        Iterable iterable1 = $this$filter$iv;
                        Collection<Object> destination$iv$iv = new ArrayList();
                        int $i$f$filterTo = 0;
                        for (Object element$iv$iv : iterable1) {
                            Uri it = (Uri) element$iv$iv;
                            int $i$a$ -filter - UnityBridgeActivity$handleMultiUris$validUris$1 = 0;
                            if ((it != null)) destination$iv$iv.add(element$iv$iv);
                        }
                        List validUris = (List) destination$iv$iv;
                        if (validUris.isEmpty()) {
                            UnityPlayer.UnitySendMessage("Boot", "OnImportError", "请选择有效的文件");
                            return;
                        }
                        UnityBridgeImpl.INSTANCE.importMultiFile(getActivityMultiCoroutineScope(), validUris, UnityBridgeActivity$handleMultiUris$1.INSTANCE, new UnityBridgeActivity$handleMultiUris$2(), (Context) this);
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "error", "Lcom/etouch/ParsingErrorType;", "invoke"})
                    static final class UnityBridgeActivity$handleMultiUris$1 extends Lambda implements Function1<ParsingErrorType, Unit> {
                        public static final UnityBridgeActivity$handleMultiUris$1 INSTANCE = new UnityBridgeActivity$handleMultiUris$1();

                        public final void invoke(@NotNull ParsingErrorType error) {
                            Intrinsics.checkNotNullParameter(error, "error");
                            UnityPlayer.UnitySendMessage("Boot", "OnImportError", error.name());
                        }

                        UnityBridgeActivity$handleMultiUris$1() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\022\n\000\n\002\020\002\n\000\n\002\020!\n\002\030\002\n\000\020\000\032\0020\0012\f\020\002\032\b\022\004\022\0020\0040\003H\n¢\006\002\b\005"}, d2 = {"<anonymous>", "", "newFiles", "", "Lcom/etouch/AudioFile;", "invoke"})
                    @SourceDebugExtension({"SMAP\nUnityBridgeActivity.kt\nKotlin\n*S Kotlin\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$handleMultiUris$2\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n+ 3 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,3505:1\n1855#2:3506\n1856#2:3508\n1#3:3507\n*S KotlinDebug\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$handleMultiUris$2\n*L\n1587#1:3506\n1587#1:3508\n*E\n"})
                    static final class UnityBridgeActivity$handleMultiUris$2 extends Lambda implements Function1<List<AudioFile>, Unit> {
                        public final void invoke(@NotNull List<AudioFile> newFiles) {
                            Iterator<AudioFile> iterator;
                            Intrinsics.checkNotNullParameter(newFiles, "newFiles");
                            UnityBridgeActivity.this.setMMultiNewFiles(newFiles);
                            List multiFileInfoList = new ArrayList();
                            if (!UnityBridgeActivity.this.getMMultiNewFiles().isEmpty()) {
                                List<AudioFile> list = UnityBridgeActivity.this.getMMultiNewFiles();
                                UnityBridgeActivity unityBridgeActivity = UnityBridgeActivity.this;
                                int $i$f$forEach = 0;
                                iterator = list.iterator();
                            } else {
                                return;
                            }
                            if (iterator.hasNext()) {
                                Object element$iv = iterator.next();
                                AudioFile file = (AudioFile) element$iv;
                                int $i$a$ -forEach - UnityBridgeActivity$handleMultiUris$2$1 = 0;
                                MultiFileInfo multiFileInfo = new MultiFileInfo(null, null, null, null, 15, null);
                                multiFileInfo.setType("");
                            } String multiFileInfoListJson = (new Gson()).toJson(multiFileInfoList);
                            UnityPlayer.UnitySendMessage("Boot", "selectionMultipleFiles", multiFileInfoListJson);
                        }

                        UnityBridgeActivity$handleMultiUris$2() {
                            super(1);
                        }
                    }

                    @Nullable
                    public final Object convertVideoToMp3(@NotNull Context context, @NotNull Uri videoUri, @NotNull Continuation $completion) {
                        return BuildersKt.withContext((CoroutineContext) Dispatchers.getIO(), new UnityBridgeActivity$convertVideoToMp3$2(context, videoUri, null), $completion);
                    }

                    @DebugMetadata(f = "UnityBridgeActivity.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$convertVideoToMp3$2")
                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\016\n\002\030\002\020\000\032\004\030\0010\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
                    static final class UnityBridgeActivity$convertVideoToMp3$2 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super String>, Object> {
                        int label;

                        UnityBridgeActivity$convertVideoToMp3$2(Context $context, Uri $videoUri, Continuation $completion) {
                            super(2, $completion);
                        }

                        @Nullable
                        public final Object invokeSuspend(@NotNull Object $result) {
                            CoroutineScope $this$withContext;
                            String originalFileName, mp3FileName;
                            File outputFile, inputFile;
                            Object object;
                            IntrinsicsKt.getCOROUTINE_SUSPENDED();
                            switch (this.label) {
                                case 0:
                                    ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                                    $this$withContext = (CoroutineScope) this.L$0;
                                    if (UnityBridgeActivity.this.getOriginalFileName(this.$context, this.$videoUri) == null)
                                        UnityBridgeActivity.this.getOriginalFileName(this.$context, this.$videoUri);
                                    originalFileName = "video_temp";
                                    Intrinsics.checkNotNullExpressionValue(originalFileName.substring(0, StringsKt.lastIndexOf$default(originalFileName, ".", 0, false, 6, null)), "substring(...)");
                                    mp3FileName = StringsKt.contains$default(originalFileName, ".", false, 2, null) ? (originalFileName.substring(0, StringsKt.lastIndexOf$default(originalFileName, ".", 0, false, 6, null)) + ".mp3") : (originalFileName + ".mp3");
                                    outputFile = new File(this.$context.getCacheDir(), mp3FileName);
                                    inputFile = new File(this.$context.getCacheDir(), "temp_input_" + System.currentTimeMillis());
                                    try {
                                        if (this.$context.getContentResolver().openInputStream(this.$videoUri) != null) {
                                            InputStream inputStream = this.$context.getContentResolver().openInputStream(this.$videoUri);
                                            Throwable throwable = null;
                                            try {
                                                InputStream input = inputStream;
                                                int $i$a$ -use - UnityBridgeActivity$convertVideoToMp3$2$1 = 0;
                                                FileOutputStream fileOutputStream = new FileOutputStream(inputFile);
                                                Throwable throwable1 = null;
                                                try {
                                                    FileOutputStream output = fileOutputStream;
                                                    int $i$a$ -use - UnityBridgeActivity$convertVideoToMp3$2$1$1 = 0;
                                                    long l1 = ByteStreamsKt.copyTo$default(input, output, 0, 2, null);
                                                } catch (Throwable throwable2) {
                                                    throwable1 = throwable2 = null;
                                                    throw throwable2;
                                                } finally {
                                                    CloseableKt.closeFinally(fileOutputStream, throwable1);
                                                } long l = l1;
                                            } catch (Throwable throwable1) {
                                                throwable = throwable1 = null;
                                                throw throwable1;
                                            } finally {
                                                CloseableKt.closeFinally(inputStream, throwable);
                                            }
                                        } else {
                                            int $i$a$ -run - UnityBridgeActivity$convertVideoToMp3$2$2 = 0;
                                            return null;
                                        } UnityBridgeActivity.this.getOriginalFileName(this.$context, this.$videoUri);
                                        object = "-i " + inputFile.getAbsolutePath() + " -vn -acodec libmp3lame -ab 128k -ar 44100 -ac 2 -y " + outputFile.getAbsolutePath();
                                        FFmpegSession session = FFmpegKit.execute((String) object);
                                        if (outputFile.exists()) outputFile.delete();
                                        return ReturnCode.isSuccess(session.getReturnCode()) ? outputFile.getAbsolutePath() : null;
                                    } catch (Exception exception) {
                                        if (outputFile.exists()) outputFile.delete();
                                        object = null;
                                    } finally {
                                        if (inputFile.exists()) inputFile.delete();
                                    } return object;
                            } throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                        }

                        @NotNull
                        public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$convertVideoToMp3$2> $completion) {
                            UnityBridgeActivity$convertVideoToMp3$2 unityBridgeActivity$convertVideoToMp3$2 = new UnityBridgeActivity$convertVideoToMp3$2(this.$context, this.$videoUri, $completion);
                            unityBridgeActivity$convertVideoToMp3$2.L$0 = value;
                            return (Continuation<Unit>) unityBridgeActivity$convertVideoToMp3$2;
                        }

                        @Nullable
                        public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                            return ((UnityBridgeActivity$convertVideoToMp3$2) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
                        }
                    }

                    private final String getOriginalFileName(Context context, Uri uri) {
                        String str;
                        try {
                            str = uri.getScheme();
                            if (str != null) {
                                switch (str.hashCode()) {
                                    case 3143036:
                                        if (str.equals("file")) {
                                            if (uri.getPath() == null) uri.getPath();
                                            super("");
                                        }
                                    case 951530617:
                                        if (str.equals("content")) {
                                            Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);
                                            if (cursor != null) {
                                                Cursor it = cursor;
                                                int $i$a$ -let - UnityBridgeActivity$getOriginalFileName$1 = 0;
                                                int nameIndex = it.getColumnIndex("_display_name");
                                                String fileName = (nameIndex != -1) ? it.getString(nameIndex) : null;
                                                cursor.close();
                                                cursor.close();
                                            } it.moveToFirst() ? fileName : null;
                                        }
                                    default:
                                        break;
                                } str = null;
                            } else {
                            }
                        } catch (Exception e) {
                            str = null;
                        } return str;
                    }

                    private final String getSoftwareDecoderName(String mime) {
                        return StringsKt.contains(mime, "aac", true) ? "OMX.google.aac.decoder" : (StringsKt.contains(mime, "mp3", true) ? "OMX.google.mp3.decoder" : (StringsKt.contains(mime, "ac3", true) ? "OMX.google.ac3.decoder" : (StringsKt.contains(mime, "pcm", true) ? "OMX.google.pcm.decoder" : (StringsKt.contains(mime, "mpeg", true) ? "OMX.google.mpeg4.aac.decoder" : null))));
                    }

                    private final void handleMultiUris2(List uris) {
                        Iterable $this$filter$iv = uris;
                        int $i$f$filter = 0;
                        Iterable iterable1 = $this$filter$iv;
                        Collection destination$iv$iv = new ArrayList();
                        int $i$f$filterTo = 0;
                        for (Object element$iv$iv : iterable1) {
                            Uri uri = (Uri) element$iv$iv;
                            int $i$a$ -filter - UnityBridgeActivity$handleMultiUris2$validUris$1 = 0;
                            continue;
                            Intrinsics.checkNotNullExpressionValue(getFileName((Uri) SYNTHETIC_LOCAL_VARIABLE_10).toLowerCase(Locale.ROOT), "toLowerCase(...)");
                            fileName = getFileName((Uri) SYNTHETIC_LOCAL_VARIABLE_10).toLowerCase(Locale.ROOT);
                        }
                        List validUris = (List) destination$iv$iv;
                        if (validUris.isEmpty()) return;
                        UnityBridgeImpl.INSTANCE.importMultiFile(getActivityMultiCoroutineScope(), validUris, UnityBridgeActivity$handleMultiUris2$1.INSTANCE, new UnityBridgeActivity$handleMultiUris2$2(), (Context) this);
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "error", "Lcom/etouch/ParsingErrorType;", "invoke"})
                    static final class UnityBridgeActivity$handleMultiUris2$1 extends Lambda implements Function1<ParsingErrorType, Unit> {
                        public static final UnityBridgeActivity$handleMultiUris2$1 INSTANCE = new UnityBridgeActivity$handleMultiUris2$1();

                        public final void invoke(@NotNull ParsingErrorType error) {
                            Intrinsics.checkNotNullParameter(error, "error");
                        }

                        UnityBridgeActivity$handleMultiUris2$1() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\022\n\000\n\002\020\002\n\000\n\002\020!\n\002\030\002\n\000\020\000\032\0020\0012\f\020\002\032\b\022\004\022\0020\0040\003H\n¢\006\002\b\005"}, d2 = {"<anonymous>", "", "newFiles", "", "Lcom/etouch/AudioFile;", "invoke"})
                    static final class UnityBridgeActivity$handleMultiUris2$2 extends Lambda implements Function1<List<AudioFile>, Unit> {
                        public final void invoke(@NotNull List<AudioFile> newFiles) {
                            Intrinsics.checkNotNullParameter(newFiles, "newFiles");
                            UnityBridgeActivity.this.setMMultiTypeNewFiles(newFiles);
                            List<MultiFileInfo> multiFileInfoList = new ArrayList();
                            BuildersKt.launch$default(UnityBridgeActivity.this.getActivityMultiCoroutineScope(), null, null, new Function2<CoroutineScope, Continuation<? super Unit>, Object>(multiFileInfoList, UnityBridgeActivity.this, null) {
                                Object L$0;
                                Object L$1;
                                Object L$2;
                                Object L$3;
                                Object L$4;
                                int label;

                                @Nullable
                                public final Object invokeSuspend(@NotNull Object $result) {
                                    List<AudioFile> list;
                                    String json;
                                    UnityBridgeActivity unityBridgeActivity;
                                    List<MultiFileInfo> list1;
                                    int $i$f$forEach;
                                    Iterator<AudioFile> iterator;
                                    int $i$a$ -forEach - UnityBridgeActivity$handleMultiUris2$2$1$1;
                                    String author;
                                    MultiFileInfo multiFileInfo;
                                    String str1;
                                    Object object = IntrinsicsKt.getCOROUTINE_SUSPENDED();
                                    switch (this.label) {
                                        case 0:
                                            ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                                            list = this.$newFiles;
                                            unityBridgeActivity = UnityBridgeActivity.this;
                                            list1 = this.$multiFileInfoList;
                                            $i$f$forEach = 0;
                                            iterator = list.iterator();
                                            if (iterator.hasNext()) {
                                                Object element$iv = iterator.next();
                                                AudioFile file = (AudioFile) element$iv;
                                                int i = 0;
                                                if (file.getUri() == null) {
                                                    file.getUri();
                                                } else {
                                                    Uri uri;
                                                    Intrinsics.checkNotNullExpressionValue(unityBridgeActivity.getFileName(uri).toLowerCase(Locale.ROOT), "toLowerCase(...)");
                                                    unityBridgeActivity.getFileName(uri).toLowerCase(Locale.ROOT);
                                                    if (unityBridgeActivity.getFileSuffixFromUri((Context) unityBridgeActivity, uri) == null)
                                                        unityBridgeActivity.getFileSuffixFromUri((Context) unityBridgeActivity, uri);
                                                    String fileSuffix = "";
                                                    String str2 = file.getAuthor().toString();
                                                    MultiFileInfo multiFileInfo1 = new MultiFileInfo(null, null, null, null, 15, null);
                                                    String[] arrayOfString = new String[4];
                                                    arrayOfString[0] = "mp4";
                                                    arrayOfString[1] = "mkv";
                                                    arrayOfString[2] = "avi";
                                                    arrayOfString[3] = "mov";
                                                    if (SetsKt.setOf((Object[]) arrayOfString).contains(fileSuffix)) {
                                                        this.L$0 = unityBridgeActivity;
                                                        this.L$1 = list1;
                                                        this.L$2 = iterator;
                                                        this.L$3 = str2;
                                                        this.L$4 = multiFileInfo1;
                                                        this.label = 1;
                                                        if (unityBridgeActivity.convertVideoToMp3((Context) unityBridgeActivity, uri, (Continuation<? super String>) this) == object)
                                                            return object;
                                                    } else {
                                                        String[] arrayOfString1 = new String[6];
                                                        arrayOfString1[0] = "mp3";
                                                        arrayOfString1[1] = "wav";
                                                        arrayOfString1[2] = "aac";
                                                        arrayOfString1[3] = "flac";
                                                        arrayOfString1[4] = "m4a";
                                                        arrayOfString1[5] = "ogg";
                                                        if (SetsKt.setOf((Object[]) arrayOfString1).contains(fileSuffix)) {
                                                            if (unityBridgeActivity.uriToFilePathWithSuffix((Context) unityBridgeActivity, uri) == null)
                                                                unityBridgeActivity.uriToFilePathWithSuffix((Context) unityBridgeActivity, uri);
                                                            String filePath = "";
                                                            multiFileInfo1.setType("audio");
                                                            multiFileInfo1.setAuthor(str2);
                                                            multiFileInfo1.setUrl(filePath);
                                                            multiFileInfo1.setUri(uri.toString());
                                                            list1.add(multiFileInfo1);
                                                        } else {
                                                            arrayOfString1 = new String[15];
                                                            arrayOfString1[0] = "jpeg";
                                                            arrayOfString1[1] = "jpg";
                                                            arrayOfString1[2] = "png";
                                                            arrayOfString1[3] = "tiff";
                                                            arrayOfString1[4] = "gif";
                                                            arrayOfString1[5] = "webp";
                                                            arrayOfString1[6] = "bmp";
                                                            arrayOfString1[7] = "heif";
                                                            arrayOfString1[8] = "heic";
                                                            arrayOfString1[9] = "hdr";
                                                            arrayOfString1[10] = "srt";
                                                            arrayOfString1[11] = "vtt";
                                                            arrayOfString1[12] = "lrc";
                                                            arrayOfString1[13] = "sub";
                                                            arrayOfString1[14] = "stl";
                                                            if (SetsKt.setOf((Object[]) arrayOfString1).contains(fileSuffix)) {
                                                                if (unityBridgeActivity.uriToFilePathWithSuffix((Context) unityBridgeActivity, uri) == null)
                                                                    unityBridgeActivity.uriToFilePathWithSuffix((Context) unityBridgeActivity, uri);
                                                                String filePath = "";
                                                                multiFileInfo1.setType(unityBridgeActivity.imageSuffixSet.contains(fileSuffix) ? "image" : "lyric");
                                                                multiFileInfo1.setUrl(filePath);
                                                                multiFileInfo1.setUri(uri.toString());
                                                                list1.add(multiFileInfo1);
                                                            }
                                                        }
                                                    }
                                                    String str3 = unityBridgeActivity.getFileSuffixFromUri((Context) unityBridgeActivity, uri);
                                                }
                                            }
                                            json = (new Gson()).toJson(this.$multiFileInfoList);
                                            UnityPlayer.UnitySendMessage("Boot", "selectionMultipleMusicOrVideoFiles", json);
                                            return Unit.INSTANCE;
                                        case 1:
                                            $i$f$forEach = 0;
                                            $i$a$ - forEach - UnityBridgeActivity$handleMultiUris2$2$1$1 = 0;
                                            multiFileInfo = (MultiFileInfo) this.L$4;
                                            author = (String) this.L$3;
                                            iterator = (Iterator<AudioFile>) this.L$2;
                                            list1 = (List<MultiFileInfo>) this.L$1;
                                            unityBridgeActivity = (UnityBridgeActivity) this.L$0;
                                            ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                                            str1 = (String) SYNTHETIC_LOCAL_VARIABLE_1;
                                    }
                                    throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                                }

                                @NotNull
                                public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super null>$completion) {
                                    return (Continuation) new Function2<>(this.$newFiles, this.$multiFileInfoList, UnityBridgeActivity.this, $completion);
                                }

                                @Nullable
                                public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                                    return ((null) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
                                }
                            }3, null);
                        }

                        UnityBridgeActivity$handleMultiUris2$2() {
                            super(1);
                        }
                    }

                    private final CoroutineScope getActivityCoroutineScope() {
                        Lazy lazy = this.activityCoroutineScope$delegate;
                        return (CoroutineScope) lazy.getValue();
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\b\n\000\n\002\030\002\n\000\020\000\032\0020\001H\n¢\006\002\b\002"}, d2 = {"<anonymous>", "Lkotlinx/coroutines/CoroutineScope;", "invoke"})
                    static final class UnityBridgeActivity$activityCoroutineScope$2 extends Lambda implements Function0<CoroutineScope> {
                        public static final UnityBridgeActivity$activityCoroutineScope$2 INSTANCE = new UnityBridgeActivity$activityCoroutineScope$2();

                        @NotNull
                        public final CoroutineScope invoke() {
                            return CoroutineScopeKt.CoroutineScope(JobKt.Job$default(null, 1, null).plus((CoroutineContext) Dispatchers.getIO()));
                        }

                        UnityBridgeActivity$activityCoroutineScope$2() {
                            super(0);
                        }
                    }

                    @NotNull
                    public final List<AudioFile> getMNewFiles() {
                        return this.mNewFiles;
                    }

                    public final void setMNewFiles(@NotNull List<AudioFile> <set-?>) {
                        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
                        this.mNewFiles = < set - ? >;
                    }

                    private final void handleUris(List uris, int type) {
                        Iterable $this$filter$iv;
                        int $i$f$filter;
                        Iterable iterable1, $this$filterTo$iv$iv;
                        Collection destination$iv$iv;
                        int $i$f$filterTo;
                        switch (type) {
                            case 0:
                                $this$filter$iv = uris;
                                $i$f$filter = 0;
                                iterable1 = $this$filter$iv;
                                destination$iv$iv = new ArrayList();
                                $i$f$filterTo = 0;
                                for (Object element$iv$iv : iterable1) {
                                    Uri uri = (Uri) element$iv$iv;
                                    int $i$a$ -filter - UnityBridgeActivity$handleUris$validUris$1 = 0;
                                    String fileName = getFileName(uri);
                                }
                            case 1:
                                $this$filter$iv = uris;
                                $i$f$filter = 0;
                                $this$filterTo$iv$iv = $this$filter$iv;
                                destination$iv$iv = new ArrayList();
                                $i$f$filterTo = 0;
                                for (Object element$iv$iv : $this$filterTo$iv$iv) {
                                    Uri uri = (Uri) element$iv$iv;
                                    int $i$a$ -filter - UnityBridgeActivity$handleUris$validUris$2 = 0;
                                    String fileName = getFileName(uri);
                                }
                            case 2:
                                $this$filter$iv = uris;
                                $i$f$filter = 0;
                                $this$filterTo$iv$iv = $this$filter$iv;
                                destination$iv$iv = new ArrayList();
                                $i$f$filterTo = 0;
                                for (Object element$iv$iv : $this$filterTo$iv$iv) {
                                    Uri uri = (Uri) element$iv$iv;
                                    int $i$a$ -filter - UnityBridgeActivity$handleUris$validUris$3 = 0;
                                    String fileName = getFileName(uri);
                                }
                            case 3:
                                $this$filter$iv = uris;
                                $i$f$filter = 0;
                                $this$filterTo$iv$iv = $this$filter$iv;
                                destination$iv$iv = new ArrayList();
                                $i$f$filterTo = 0;
                                for (Object element$iv$iv : $this$filterTo$iv$iv) {
                                    Uri uri = (Uri) element$iv$iv;
                                    int $i$a$ -filter - UnityBridgeActivity$handleUris$validUris$4 = 0;
                                    String fileName = getFileName(uri);
                                }
                            case 4:
                                $this$filter$iv = uris;
                                $i$f$filter = 0;
                                $this$filterTo$iv$iv = $this$filter$iv;
                                destination$iv$iv = new ArrayList();
                                $i$f$filterTo = 0;
                                for (Object element$iv$iv : $this$filterTo$iv$iv) {
                                    Uri uri = (Uri) element$iv$iv;
                                    int $i$a$ -filter - UnityBridgeActivity$handleUris$validUris$5 = 0;
                                    String fileName = getFileName(uri);
                                }
                            case 5:
                                $this$filter$iv = uris;
                                $i$f$filter = 0;
                                $this$filterTo$iv$iv = $this$filter$iv;
                                destination$iv$iv = new ArrayList();
                                $i$f$filterTo = 0;
                                for (Object element$iv$iv : $this$filterTo$iv$iv) {
                                    Uri uri = (Uri) element$iv$iv;
                                    int $i$a$ -filter - UnityBridgeActivity$handleUris$validUris$6 = 0;
                                    String fileName = getFileName(uri);
                                }
                            case 6:
                                $this$filter$iv = uris;
                                $i$f$filter = 0;
                                $this$filterTo$iv$iv = $this$filter$iv;
                                destination$iv$iv = new ArrayList();
                                $i$f$filterTo = 0;
                                for (Object element$iv$iv : $this$filterTo$iv$iv) {
                                    Uri uri = (Uri) element$iv$iv;
                                    int $i$a$ -filter - UnityBridgeActivity$handleUris$validUris$7 = 0;
                                    String fileName = getFileName(uri);
                                }
                            default:
                                break;
                        } List validUris = CollectionsKt.emptyList();
                        if (validUris.isEmpty()) {
                            UnityPlayer.UnitySendMessage("Boot", "OnImportError", "请选择有效的文件");
                            return;
                        }
                        UnityBridgeImpl.INSTANCE.importFile(getActivityCoroutineScope(), validUris, UnityBridgeActivity$handleUris$1.INSTANCE, new UnityBridgeActivity$handleUris$2(), (Context) this);
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "error", "Lcom/etouch/ParsingErrorType;", "invoke"})
                    static final class UnityBridgeActivity$handleUris$1 extends Lambda implements Function1<ParsingErrorType, Unit> {
                        public static final UnityBridgeActivity$handleUris$1 INSTANCE = new UnityBridgeActivity$handleUris$1();

                        public final void invoke(@NotNull ParsingErrorType error) {
                            Intrinsics.checkNotNullParameter(error, "error");
                            UnityPlayer.UnitySendMessage("Boot", "OnImportError", error.name());
                        }

                        UnityBridgeActivity$handleUris$1() {
                            super(1);
                        }
                    }

                    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\022\n\000\n\002\020\002\n\000\n\002\020!\n\002\030\002\n\000\020\000\032\0020\0012\f\020\002\032\b\022\004\022\0020\0040\003H\n¢\006\002\b\005"}, d2 = {"<anonymous>", "", "newFiles", "", "Lcom/etouch/AudioFile;", "invoke"})
                    @SourceDebugExtension({"SMAP\nUnityBridgeActivity.kt\nKotlin\n*S Kotlin\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$handleUris$2\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,3505:1\n1#2:3506\n*E\n"})
                    static final class UnityBridgeActivity$handleUris$2 extends Lambda implements Function1<List<AudioFile>, Unit> {
                        public final void invoke(@NotNull List<AudioFile> newFiles) {
                            Intrinsics.checkNotNullParameter(newFiles, "newFiles");
                            UnityBridgeActivity.this.setMNewFiles(newFiles);
                            MultiFileInfo multiFileInfo = new MultiFileInfo(null, null, null, null, 15, null);
                            multiFileInfo.setType(String.valueOf(UnityBridgeActivity.this.fileType));
                            Uri uri1 = ((AudioFile) UnityBridgeActivity.this.getMNewFiles().get(0)).getUri();
                            UnityBridgeActivity unityBridgeActivity = UnityBridgeActivity.this;
                            Uri uri2 = uri1;
                            MultiFileInfo multiFileInfo1 = multiFileInfo;
                            int $i$a$ -let - UnityBridgeActivity$handleUris$2$1 = 0;
                            ((AudioFile) UnityBridgeActivity.this.getMNewFiles().get(0)).getUri();
                            multiFileInfo.setUrl((((AudioFile) UnityBridgeActivity.this.getMNewFiles().get(0)).getUri() != null) ? String.valueOf(unityBridgeActivity.uriToFilePathWithSuffix((Context) unityBridgeActivity, uri2)) : null);
                            multiFileInfo.setUri(String.valueOf(((AudioFile) UnityBridgeActivity.this.getMNewFiles().get(0)).getUri()));
                            multiFileInfo.setAuthor(((AudioFile) UnityBridgeActivity.this.getMNewFiles().get(0)).getAuthor().toString());
                            UnityPlayer.UnitySendMessage("Boot", "MediaCompletion", (new Gson()).toJson(multiFileInfo));
                        }

                        UnityBridgeActivity$handleUris$2() {
                            super(1);
                        }
                    }

                    @Nullable
                    public final String uriToFilePathWithSuffix(@NotNull Context context, @NotNull Uri uri) {
                        Intrinsics.checkNotNullParameter(context, "context");
                        Intrinsics.checkNotNullParameter(uri, "uri");
                        try {
                            String fileSuffix, fileName;
                            if (getFileSuffixFromUri(context, uri) == null) {
                                getFileSuffixFromUri(context, uri);
                                return null;
                            }
                            if (context.getExternalFilesDir(Environment.DIRECTORY_MUSIC) == null)
                                context.getExternalFilesDir(Environment.DIRECTORY_MUSIC);
                            File appPrivateDir = context.getFilesDir();
                            if (!appPrivateDir.exists()) appPrivateDir.mkdirs();
                            if (getFileName(uri) == null) {
                                getFileName(uri);
                                return null;
                            }
                            File targetFile = new File(appPrivateDir, fileName);
                            Intrinsics.checkNotNullExpressionValue(context.getContentResolver(), "getContentResolver(...)");
                            ContentResolver contentResolver = context.getContentResolver();
                            InputStream inputStream = contentResolver.openInputStream(uri);
                            FileOutputStream outputStream = new FileOutputStream(targetFile);
                            if (inputStream != null) {
                                InputStream inputStream1 = inputStream;
                                Throwable throwable = null;
                                try {
                                    InputStream inStream = inputStream1;
                                    int $i$a$ -use - UnityBridgeActivity$uriToFilePathWithSuffix$1 = 0;
                                    FileOutputStream fileOutputStream = outputStream;
                                    Throwable throwable1 = null;
                                    try {
                                        FileOutputStream outStream = fileOutputStream;
                                        int $i$a$ -use - UnityBridgeActivity$uriToFilePathWithSuffix$1$1 = 0;
                                        byte[] buffer = new byte[4096];
                                        int length = 0;
                                        while (true) {
                                            int i = inStream.read(buffer), it = i;
                                            int $i$a$ -also - UnityBridgeActivity$uriToFilePathWithSuffix$1$1$1 = 0;
                                            length = it;
                                            if (i != -1) {
                                                outStream.write(buffer, 0, length);
                                                continue;
                                            }
                                            break;
                                        } Unit unit1 = Unit.INSTANCE;
                                    } catch (Throwable throwable2) {
                                        throwable1 = throwable2 = null;
                                        throw throwable2;
                                    } finally {
                                        CloseableKt.closeFinally(fileOutputStream, throwable1);
                                    } Unit unit = Unit.INSTANCE;
                                } catch (Throwable throwable1) {
                                    throwable = throwable1 = null;
                                    throw throwable1;
                                } finally {
                                    CloseableKt.closeFinally(inputStream1, throwable);
                                }
                            } else {
                            } return targetFile.getAbsolutePath();
                        } catch (Exception e) {
                            e.printStackTrace();
                            return null;
                        }
                    }

                    private final String getFileSuffixFromUri(Context context, Uri uri) { // Byte code:
                        //   0: aload_0
                        //   1: aload_2
                        //   2: invokevirtual getFileName : (Landroid/net/Uri;)Ljava/lang/String;
                        //   5: dup
                        //   6: ifnull -> 25
                        //   9: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
                        //   12: invokevirtual toLowerCase : (Ljava/util/Locale;)Ljava/lang/String;
                        //   15: dup
                        //   16: ldc_w 'toLowerCase(...)'
                        //   19: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
                        //   22: goto -> 27
                        //   25: pop
                        //   26: aconst_null
                        //   27: astore_3
                        //   28: aload_3
                        //   29: ifnull -> 89
                        //   32: aload_3
                        //   33: bipush #46
                        //   35: ldc ''
                        //   37: invokestatic substringAfterLast : (Ljava/lang/String;CLjava/lang/String;)Ljava/lang/String;
                        //   40: astore #5
                        //   42: aload #5
                        //   44: ifnull -> 89
                        //   47: aload #5
                        //   49: astore #6
                        //   51: aload #6
                        //   53: astore #7
                        //   55: iconst_0
                        //   56: istore #8
                        //   58: aload #7
                        //   60: checkcast java/lang/CharSequence
                        //   63: invokeinterface length : ()I
                        //   68: ifle -> 75
                        //   71: iconst_1
                        //   72: goto -> 76
                        //   75: iconst_0
                        //   76: nop
                        //   77: ifeq -> 85
                        //   80: aload #6
                        //   82: goto -> 90
                        //   85: aconst_null
                        //   86: goto -> 90
                        //   89: aconst_null
                        //   90: astore #4
                        //   92: bipush #15
                        //   94: anewarray java/lang/String
                        //   97: astore #5
                        //   99: aload #5
                        //   101: iconst_0
                        //   102: ldc_w 'jpeg'
                        //   105: aastore
                        //   106: aload #5
                        //   108: iconst_1
                        //   109: ldc_w 'jpg'
                        //   112: aastore
                        //   113: aload #5
                        //   115: iconst_2
                        //   116: ldc_w 'png'
                        //   119: aastore
                        //   120: aload #5
                        //   122: iconst_3
                        //   123: ldc_w 'tiff'
                        //   126: aastore
                        //   127: aload #5
                        //   129: iconst_4
                        //   130: ldc_w 'gif'
                        //   133: aastore
                        //   134: aload #5
                        //   136: iconst_5
                        //   137: ldc_w 'webp'
                        //   140: aastore
                        //   141: aload #5
                        //   143: bipush #6
                        //   145: ldc_w 'bmp'
                        //   148: aastore
                        //   149: aload #5
                        //   151: bipush #7
                        //   153: ldc_w 'heif'
                        //   156: aastore
                        //   157: aload #5
                        //   159: bipush #8
                        //   161: ldc_w 'heic'
                        //   164: aastore
                        //   165: aload #5
                        //   167: bipush #9
                        //   169: ldc_w 'hdr'
                        //   172: aastore
                        //   173: aload #5
                        //   175: bipush #10
                        //   177: ldc_w 'srt'
                        //   180: aastore
                        //   181: aload #5
                        //   183: bipush #11
                        //   185: ldc_w 'vtt'
                        //   188: aastore
                        //   189: aload #5
                        //   191: bipush #12
                        //   193: ldc_w 'lrc'
                        //   196: aastore
                        //   197: aload #5
                        //   199: bipush #13
                        //   201: ldc_w 'sub'
                        //   204: aastore
                        //   205: aload #5
                        //   207: bipush #14
                        //   209: ldc_w 'stl'
                        //   212: aastore
                        //   213: aload #5
                        //   215: invokestatic setOf : ([Ljava/lang/Object;)Ljava/util/Set;
                        //   218: checkcast java/lang/Iterable
                        //   221: aload #4
                        //   223: invokestatic contains : (Ljava/lang/Iterable;Ljava/lang/Object;)Z
                        //   226: ifeq -> 232
                        //   229: aload #4
                        //   231: areturn
                        //   232: aload_1
                        //   233: invokevirtual getContentResolver : ()Landroid/content/ContentResolver;
                        //   236: aload_2
                        //   237: invokevirtual getType : (Landroid/net/Uri;)Ljava/lang/String;
                        //   240: dup
                        //   241: ifnonnull -> 248
                        //   244: pop
                        //   245: aload #4
                        //   247: areturn
                        //   248: astore #5
                        //   250: nop
                        //   251: aload #5
                        //   253: ldc_w 'audio/'
                        //   256: iconst_0
                        //   257: iconst_2
                        //   258: aconst_null
                        //   259: invokestatic startsWith$default : (Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z
                        //   262: ifeq -> 487
                        //   265: aload #5
                        //   267: astore #6
                        //   269: aload #6
                        //   271: invokevirtual hashCode : ()I
                        //   274: lookupswitch default -> 474, -586683234 -> 368, 187078282 -> 382, 187090232 -> 396, 187091926 -> 340, 187099443 -> 354, 1504619009 -> 424, 1504831518 -> 410
                        //   340: aload #6
                        //   342: ldc_w 'audio/ogg'
                        //   345: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   348: ifne -> 468
                        //   351: goto -> 474
                        //   354: aload #6
                        //   356: ldc_w 'audio/wav'
                        //   359: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   362: ifne -> 450
                        //   365: goto -> 474
                        //   368: aload #6
                        //   370: ldc_w 'audio/x-wav'
                        //   373: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   376: ifne -> 450
                        //   379: goto -> 474
                        //   382: aload #6
                        //   384: ldc_w 'audio/aac'
                        //   387: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   390: ifne -> 456
                        //   393: goto -> 474
                        //   396: aload #6
                        //   398: ldc_w 'audio/mp4'
                        //   401: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   404: ifne -> 438
                        //   407: goto -> 474
                        //   410: aload #6
                        //   412: ldc_w 'audio/mpeg'
                        //   415: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   418: ifne -> 444
                        //   421: goto -> 474
                        //   424: aload #6
                        //   426: ldc_w 'audio/flac'
                        //   429: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   432: ifne -> 462
                        //   435: goto -> 474
                        //   438: ldc_w 'm4a'
                        //   441: goto -> 726
                        //   444: ldc_w 'mp3'
                        //   447: goto -> 726
                        //   450: ldc_w 'wav'
                        //   453: goto -> 726
                        //   456: ldc_w 'aac'
                        //   459: goto -> 726
                        //   462: ldc_w 'flac'
                        //   465: goto -> 726
                        //   468: ldc_w 'ogg'
                        //   471: goto -> 726
                        //   474: aload #4
                        //   476: dup
                        //   477: ifnonnull -> 726
                        //   480: pop
                        //   481: ldc_w 'audio'
                        //   484: goto -> 726
                        //   487: aload #5
                        //   489: ldc_w 'video/'
                        //   492: iconst_0
                        //   493: iconst_2
                        //   494: aconst_null
                        //   495: invokestatic startsWith$default : (Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z
                        //   498: ifeq -> 663
                        //   501: aload #5
                        //   503: astore #6
                        //   505: aload #6
                        //   507: invokevirtual hashCode : ()I
                        //   510: lookupswitch default -> 650, -107252314 -> 602, 1331836736 -> 560, 1331848029 -> 616, 1331848064 -> 574, 2039520277 -> 588
                        //   560: aload #6
                        //   562: ldc_w 'video/avi'
                        //   565: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   568: ifne -> 638
                        //   571: goto -> 650
                        //   574: aload #6
                        //   576: ldc_w 'video/mov'
                        //   579: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   582: ifne -> 644
                        //   585: goto -> 650
                        //   588: aload #6
                        //   590: ldc_w 'video/x-matroska'
                        //   593: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   596: ifne -> 632
                        //   599: goto -> 650
                        //   602: aload #6
                        //   604: ldc_w 'video/quicktime'
                        //   607: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   610: ifne -> 644
                        //   613: goto -> 650
                        //   616: aload #6
                        //   618: ldc_w 'video/mp4'
                        //   621: invokevirtual equals : (Ljava/lang/Object;)Z
                        //   624: ifeq -> 650
                        //   627: ldc 'mp4'
                        //   629: goto -> 726
                        //   632: ldc_w 'mkv'
                        //   635: goto -> 726
                        //   638: ldc_w 'avi'
                        //   641: goto -> 726
                        //   644: ldc_w 'mov'
                        //   647: goto -> 726
                        //   650: aload #4
                        //   652: dup
                        //   653: ifnonnull -> 726
                        //   656: pop
                        //   657: ldc_w 'video'
                        //   660: goto -> 726
                        //   663: aload #5
                        //   665: ldc_w 'application/subrip'
                        //   668: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
                        //   671: ifne -> 685
                        //   674: aload #5
                        //   676: ldc_w 'application/x-subrip'
                        //   679: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
                        //   682: ifeq -> 691
                        //   685: ldc_w 'srt'
                        //   688: goto -> 726
                        //   691: aload #5
                        //   693: ldc_w 'text/vtt'
                        //   696: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
                        //   699: ifeq -> 708
                        //   702: ldc_w 'vtt'
                        //   705: goto -> 726
                        //   708: aload #5
                        //   710: ldc_w 'application/octet-stream'
                        //   713: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
                        //   716: ifeq -> 724
                        //   719: aload #4
                        //   721: goto -> 726
                        //   724: aload #4
                        //   726: areturn
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #2268	-> 0
                        //   #2268	-> 25
                        //   #2270	-> 28
                        //   #2269	-> 32
                        //   #2270	-> 33
                        //   #2271	-> 42
                        //   #2270	-> 47
                        //   #2271	-> 51
                        //   #3537	-> 55
                        //   #2271	-> 58
                        //   #2271	-> 76
                        //   #2271	-> 77
                        //   #2270	-> 89
                        //   #2269	-> 90
                        //   #2274	-> 92
                        //   #2275	-> 92
                        //   #2276	-> 109
                        //   #2275	-> 113
                        //   #2277	-> 116
                        //   #2275	-> 120
                        //   #2278	-> 123
                        //   #2275	-> 127
                        //   #2279	-> 130
                        //   #2275	-> 134
                        //   #2280	-> 137
                        //   #2275	-> 141
                        //   #2281	-> 145
                        //   #2275	-> 149
                        //   #2282	-> 153
                        //   #2275	-> 157
                        //   #2283	-> 161
                        //   #2275	-> 165
                        //   #2284	-> 169
                        //   #2275	-> 173
                        //   #2284	-> 177
                        //   #2275	-> 181
                        //   #2284	-> 185
                        //   #2275	-> 189
                        //   #2284	-> 193
                        //   #2275	-> 197
                        //   #2284	-> 201
                        //   #2275	-> 205
                        //   #2284	-> 209
                        //   #2275	-> 213
                        //   #2274	-> 215
                        //   #2287	-> 229
                        //   #2291	-> 232
                        //   #2293	-> 250
                        //   #2295	-> 251
                        //   #2296	-> 438
                        //   #2297	-> 444
                        //   #2298	-> 450
                        //   #2299	-> 456
                        //   #2300	-> 462
                        //   #2301	-> 468
                        //   #2302	-> 474
                        //   #2306	-> 487
                        //   #2307	-> 627
                        //   #2308	-> 632
                        //   #2309	-> 638
                        //   #2310	-> 644
                        //   #2311	-> 650
                        //   #2315	-> 663
                        //   #2316	-> 674
                        //   #2319	-> 691
                        //   #2322	-> 708
                        //   #2324	-> 724
                        //   #2293	-> 726
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   58	19	8	$i$a$-takeIf-UnityBridgeActivity$getFileSuffixFromUri$extFromName$1	I
                        //   55	22	7	it	Ljava/lang/String;
                        //   28	699	3	fileName	Ljava/lang/String;
                        //   92	635	4	extFromName	Ljava/lang/String;
                        //   250	477	5	mimeType	Ljava/lang/String;
                        //   0	727	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                        //   0	727	1	context	Landroid/content/Context;
                        //   0	727	2	uri	Landroid/net/Uri; } @NotNull public final String getFileName(@NotNull Uri uri) { Intrinsics.checkNotNullParameter(uri, "uri"); String[] arrayOfString = new String[1]; arrayOfString[0] = "_display_name"; Cursor cursor = getContentResolver().query(uri, arrayOfString, null, null, null); if (cursor != null) { Closeable closeable = (Closeable)cursor; Throwable throwable = null; } else {  }  return "Unknown"; } @NotNull public final String getImportFiles() { Uri it = ((AudioFile)this.mNewFiles.get(0)).getUri(); int $i$a$-let-UnityBridgeActivity$getImportFiles$1 = 0; ((AudioFile)this.mNewFiles.get(0)).getUri(); return String.valueOf((((AudioFile)this.mNewFiles.get(0)).getUri() != null) ? String.valueOf(uriToFilePathWithSuffix((Context)this, it)) : null); } public final void selectZipFile() { String[] arrayOfString = new String[1]; arrayOfString[0] = "application/zip"; this.pickZipLauncher.launch(arrayOfString); } private final boolean zipForcesUtf8(File zipFile) { // Byte code:
                        //   0: nop
                        //   1: new net/lingala/zip4j/ZipFile
                        //   4: dup
                        //   5: aload_1
                        //   6: invokespecial <init> : (Ljava/io/File;)V
                        //   9: astore_2
                        //   10: aload_2
                        //   11: invokevirtual getFileHeaders : ()Ljava/util/List;
                        //   14: dup
                        //   15: ldc_w 'getFileHeaders(...)'
                        //   18: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
                        //   21: checkcast java/lang/Iterable
                        //   24: astore_3
                        //   25: iconst_0
                        //   26: istore #4
                        //   28: aload_3
                        //   29: instanceof java/util/Collection
                        //   32: ifeq -> 51
                        //   35: aload_3
                        //   36: checkcast java/util/Collection
                        //   39: invokeinterface isEmpty : ()Z
                        //   44: ifeq -> 51
                        //   47: iconst_0
                        //   48: goto -> 101
                        //   51: aload_3
                        //   52: invokeinterface iterator : ()Ljava/util/Iterator;
                        //   57: astore #5
                        //   59: aload #5
                        //   61: invokeinterface hasNext : ()Z
                        //   66: ifeq -> 100
                        //   69: aload #5
                        //   71: invokeinterface next : ()Ljava/lang/Object;
                        //   76: astore #6
                        //   78: aload #6
                        //   80: checkcast net/lingala/zip4j/model/FileHeader
                        //   83: astore #7
                        //   85: iconst_0
                        //   86: istore #8
                        //   88: aload #7
                        //   90: invokevirtual isFileNameUTF8Encoded : ()Z
                        //   93: ifeq -> 59
                        //   96: iconst_1
                        //   97: goto -> 101
                        //   100: iconst_0
                        //   101: istore_2
                        //   102: goto -> 108
                        //   105: astore_3
                        //   106: iconst_0
                        //   107: istore_2
                        //   108: iload_2
                        //   109: ireturn
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #2372	-> 0
                        //   #2373	-> 1
                        //   #2374	-> 10
                        //   #3538	-> 28
                        //   #3539	-> 51
                        //   #2374	-> 88
                        //   #3539	-> 93
                        //   #3540	-> 100
                        //   #2375	-> 105
                        //   #2376	-> 106
                        //   #2372	-> 109
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   88	5	8	$i$a$-any-UnityBridgeActivity$zipForcesUtf8$1	I
                        //   85	8	7	it	Lnet/lingala/zip4j/model/FileHeader;
                        //   78	22	6	element$iv	Ljava/lang/Object;
                        //   28	73	4	$i$f$any	I
                        //   25	76	3	$this$any$iv	Ljava/lang/Iterable;
                        //   10	91	2	zip	Lnet/lingala/zip4j/ZipFile;
                        //   106	2	3	e	Ljava/lang/Exception;
                        //   0	110	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                        //   0	110	1	zipFile	Ljava/io/File;
                        // Exception table:
                        //   from	to	target	type
                        //   0	102	105	java/lang/Exception } private final int scoreName(String name) { int score = 0; byte b; int i; for (b = 0, i = name.length(); b < i; ) { char c = name.charAt(b); if (('一' <= c) ? ((c < 'ꀀ')) : false) { score += 3; } else if (('぀' <= c) ? ((c < '㄀')) : false) { score += 3; } else if (Character.isLetterOrDigit(c)) { score++; } else if (c == '_' || c == '.') { score++; } else if (c == '�') { score -= 5; }  b++; }  return score; } private final Charset resolveZipCharset(File zipFile) { if (zipForcesUtf8(zipFile)) return Charsets.UTF_8;  Charset[] arrayOfCharset = new Charset[2]; arrayOfCharset[0] = Charset.forName("GBK"); arrayOfCharset[1] = Charset.forName("Shift_JIS"); List candidates = CollectionsKt.listOf((Object[])arrayOfCharset); Charset best = (Charset)CollectionsKt.first(candidates); int bestScore = Integer.MIN_VALUE; for (Charset cs : candidates) { try { ZipFile zip = new ZipFile(zipFile); zip.setCharset(cs); Intrinsics.checkNotNullExpressionValue(zip.getFileHeaders(), "getFileHeaders(...)"); List list = CollectionsKt.take(zip.getFileHeaders(), 5); int i = 0; for (FileHeader fileHeader1 : list) { FileHeader fileHeader2 = fileHeader1; int j = i, $i$a$-sumOfInt-UnityBridgeActivity$resolveZipCharset$score$1 = 0; Intrinsics.checkNotNullExpressionValue(fileHeader2.getFileName(), "getFileName(...)"); int k = scoreName(fileHeader2.getFileName()); i = j + k; }  int score = i; if (score > bestScore) { bestScore = score; best = cs; }  } catch (Exception exception) {} }  Charset charset1 = best; Intrinsics.checkNotNull(charset1); return charset1; } private final void handleZip(Uri uri) { File zipFile; if (copyZipToCache(uri) == null) { copyZipToCache(uri); UnityBridgeActivity $this$handleZip_u24lambda_u2437 = this; int $i$a$-run-UnityBridgeActivity$handleZip$zipFile$1 = 0; return; }  ZipFile zip = new ZipFile(zipFile); if (zip.isEncrypted()) { showPasswordDialog(new UnityBridgeActivity$handleZip$1(zipFile)); } else { BuildersKt.launch$default((CoroutineScope)GlobalScope.INSTANCE, (CoroutineContext)Dispatchers.getIO(), null, new UnityBridgeActivity$handleZip$2(zipFile, null), 2, null); }  } @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\016\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "pwd", "", "invoke"}) static final class UnityBridgeActivity$handleZip$1 extends Lambda implements Function1<String, Unit> { public final void invoke(@NotNull String pwd) { Intrinsics.checkNotNullParameter(pwd, "pwd"); BuildersKt.launch$default((CoroutineScope)GlobalScope.INSTANCE, (CoroutineContext)Dispatchers.getIO(), null, new Function2<CoroutineScope, Continuation<? super Unit>, Object>(this.$zipFile, pwd, null) { int label; @Nullable public final Object invokeSuspend(@NotNull Object $result) { Object object = IntrinsicsKt.getCOROUTINE_SUSPENDED(); switch (this.label) { case 0: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); this.label = 1; if (UnityBridgeActivity.this.unzip(this.$zipFile, this.$pwd, (Continuation)this) == object) return object;  UnityBridgeActivity.this.unzip(this.$zipFile, this.$pwd, (Continuation)this); return Unit.INSTANCE;case 1: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); return Unit.INSTANCE; }  throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine"); } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super null> $completion) { return (Continuation)new Function2<>(UnityBridgeActivity.this, this.$zipFile, this.$pwd, $completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((null)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } }2, null); } UnityBridgeActivity$handleZip$1(File $zipFile) { super(1); } } @DebugMetadata(f = "UnityBridgeActivity.kt", l = {2446}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$handleZip$2") @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"}) static final class UnityBridgeActivity$handleZip$2 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> { int label; UnityBridgeActivity$handleZip$2(File $zipFile, Continuation $completion) { super(2, $completion); } @Nullable public final Object invokeSuspend(@NotNull Object $result) { Object object = IntrinsicsKt.getCOROUTINE_SUSPENDED(); switch (this.label) { case 0: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); this.label = 1; if (UnityBridgeActivity.this.unzip(this.$zipFile, (String)null, (Continuation)this) == object) return object;  UnityBridgeActivity.this.unzip(this.$zipFile, (String)null, (Continuation)this); return Unit.INSTANCE;case 1: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); return Unit.INSTANCE; }  throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine"); } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$handleZip$2> $completion) { return (Continuation<Unit>)new UnityBridgeActivity$handleZip$2(this.$zipFile, $completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((UnityBridgeActivity$handleZip$2)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } } private final Object unzip(File zipFile, String password, Continuation $completion) { if (BuildersKt.withContext((CoroutineContext)Dispatchers.getIO(), new UnityBridgeActivity$unzip$2(zipFile, password, null), $completion) == IntrinsicsKt.getCOROUTINE_SUSPENDED()) return BuildersKt.withContext((CoroutineContext)Dispatchers.getIO(), new UnityBridgeActivity$unzip$2(zipFile, password, null), $completion);  BuildersKt.withContext((CoroutineContext)Dispatchers.getIO(), new UnityBridgeActivity$unzip$2(zipFile, password, null), $completion); return Unit.INSTANCE; } @DebugMetadata(f = "UnityBridgeActivity.kt", l = {2473, 2476}, i = {1}, s = {"L$0"}, n = {"e"}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$unzip$2") @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"}) @SourceDebugExtension({"SMAP\nUnityBridgeActivity.kt\nKotlin\n*S Kotlin\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$unzip$2\n+ 2 _Arrays.kt\nkotlin/collections/ArraysKt___ArraysKt\n*L\n1#1,3505:1\n13309#2,2:3506\n*S KotlinDebug\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$unzip$2\n*L\n2468#1:3506,2\n*E\n"}) static final class UnityBridgeActivity$unzip$2 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> { Object L$0; int label; UnityBridgeActivity$unzip$2(File $zipFile, String $password, Continuation $completion) { super(2, $completion); } @Nullable public final Object invokeSuspend(@NotNull Object $result) { Object object = IntrinsicsKt.getCOROUTINE_SUSPENDED(); switch (this.label) { case 0: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); try { File[] arrayOfFile; byte b; int i; Charset charset = UnityBridgeActivity.this.resolveZipCharset(this.$zipFile); ZipFile zip = new ZipFile(this.$zipFile); zip.setCharset(charset); if (zip.isEncrypted()) { Intrinsics.checkNotNull(this.$password); Intrinsics.checkNotNullExpressionValue(this.$password.toCharArray(), "toCharArray(...)"); zip.setPassword(this.$password.toCharArray()); }  File outDir = new File(UnityBridgeActivity.this.getExternalFilesDir(null), "unzipped"); FilesKt.deleteRecursively(outDir); outDir.mkdirs(); zip.extractAll(outDir.getAbsolutePath()); if (outDir.listFiles() != null) { arrayOfFile = outDir.listFiles(); int $i$f$forEach = 0; b = 0; i = arrayOfFile.length; } else { outDir.listFiles(); this.label = 1; if (UnityBridgeActivity.this.processUnzippedFiles(outDir, (Context)UnityBridgeActivity.this, (Continuation)this) == object) return object;  }  if (b < i) { Object element$iv = arrayOfFile[b]; int $i$a$-forEach-UnityBridgeActivity$unzip$2$1 = 0; b++; }  } catch (Exception e) { this.L$0 = e; this.label = 2; if (BuildersKt.withContext((CoroutineContext)Dispatchers.getMain(), new Function2<CoroutineScope, Continuation<? super Unit>, Object>(null) { int label; @Nullable public final Object invokeSuspend(@NotNull Object $result) { IntrinsicsKt.getCOROUTINE_SUSPENDED(); switch (this.label) { case 0: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); UnityPlayer.UnitySendMessage("Boot", "onZipError", "解压失败或密码错误"); return Unit.INSTANCE; }  throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine"); } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super null> $completion) { return (Continuation)new Function2<>($completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((null)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } }(Continuation)this) == object) return object;  }  BuildersKt.withContext((CoroutineContext)Dispatchers.getMain(), new Function2<CoroutineScope, Continuation<? super Unit>, Object>(null) { int label; @Nullable public final Object invokeSuspend(@NotNull Object $result) { IntrinsicsKt.getCOROUTINE_SUSPENDED(); switch (this.label) { case 0: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); UnityPlayer.UnitySendMessage("Boot", "onZipError", "解压失败或密码错误"); return Unit.INSTANCE; }  throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine"); } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super null> $completion) { return (Continuation)new Function2<>($completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((null)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } }(Continuation)this); e.printStackTrace(); return Unit.INSTANCE;case 1: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); return Unit.INSTANCE;case 2: e = (Exception)this.L$0; ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); e.printStackTrace(); return Unit.INSTANCE; }  throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine"); } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$unzip$2> $completion) { return (Continuation<Unit>)new UnityBridgeActivity$unzip$2(this.$zipFile, this.$password, $completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((UnityBridgeActivity$unzip$2)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } } private final void returnUnzippedFiles() { File dir = new File(getExternalFilesDir(null), "unzipped"); if (dir.exists()) { List list = SequencesKt.toList(SequencesKt.map(SequencesKt.filter((Sequence)FilesKt.walkTopDown(dir), UnityBridgeActivity$returnUnzippedFiles$list$1.INSTANCE), UnityBridgeActivity$returnUnzippedFiles$list$2.INSTANCE)); UnityPlayer.UnitySendMessage("Boot", "selectZipFile", (new Gson()).toJson(list)); } else { UnityPlayer.UnitySendMessage("Boot", "selectZipFile", ""); }  } @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\020\n\000\n\002\020\013\n\000\n\002\030\002\n\002\b\002\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\004\b\004\020\005"}, d2 = {"<anonymous>", "", "it", "Ljava/io/File;", "invoke", "(Ljava/io/File;)Ljava/lang/Boolean;"}) static final class UnityBridgeActivity$returnUnzippedFiles$list$1 extends Lambda implements Function1<File, Boolean> { public static final UnityBridgeActivity$returnUnzippedFiles$list$1 INSTANCE = new UnityBridgeActivity$returnUnzippedFiles$list$1(); UnityBridgeActivity$returnUnzippedFiles$list$1() { super(1); } @NotNull public final Boolean invoke(@NotNull File it) { Intrinsics.checkNotNullParameter(it, "it"); return Boolean.valueOf(it.isFile()); } } @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\030\002\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "Lcom/etouch/MultiFileInfo;", "file", "Ljava/io/File;", "invoke"}) static final class UnityBridgeActivity$returnUnzippedFiles$list$2 extends Lambda implements Function1<File, MultiFileInfo> { public static final UnityBridgeActivity$returnUnzippedFiles$list$2 INSTANCE = new UnityBridgeActivity$returnUnzippedFiles$list$2(); @NotNull public final MultiFileInfo invoke(@NotNull File file) { Intrinsics.checkNotNullParameter(file, "file"); return new MultiFileInfo(null, file.getAbsolutePath(), null, null, 12, null); } UnityBridgeActivity$returnUnzippedFiles$list$2() { super(1); } } private final Object processUnzippedFiles(File unzipDir, Context context, Continuation $completion) { if (BuildersKt.withContext((CoroutineContext)Dispatchers.getIO(), new UnityBridgeActivity$processUnzippedFiles$2(this, context, null), $completion) == IntrinsicsKt.getCOROUTINE_SUSPENDED()) return BuildersKt.withContext((CoroutineContext)Dispatchers.getIO(), new UnityBridgeActivity$processUnzippedFiles$2(this, context, null), $completion);  BuildersKt.withContext((CoroutineContext)Dispatchers.getIO(), new UnityBridgeActivity$processUnzippedFiles$2(this, context, null), $completion); return Unit.INSTANCE; } @DebugMetadata(f = "UnityBridgeActivity.kt", l = {2570, 2659}, i = {0, 0, 0}, s = {"L$0", "L$4", "L$5"}, n = {"fileList", "multiFileInfo", "artistName"}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$processUnzippedFiles$2") @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"}) @SourceDebugExtension({"SMAP\nUnityBridgeActivity.kt\nKotlin\n*S Kotlin\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$processUnzippedFiles$2\n+ 2 _Sequences.kt\nkotlin/sequences/SequencesKt___SequencesKt\n*L\n1#1,3505:1\n1313#2,2:3506\n*S KotlinDebug\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$processUnzippedFiles$2\n*L\n2531#1:3506,2\n*E\n"}) static final class UnityBridgeActivity$processUnzippedFiles$2 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> { Object L$0; Object L$1; Object L$2; Object L$3; Object L$4; Object L$5; int label; UnityBridgeActivity$processUnzippedFiles$2(UnityBridgeActivity $receiver, Context $context, Continuation $completion) { super(2, $completion); } @Nullable public final Object invokeSuspend(@NotNull Object $result) { // Byte code:
                        //   0: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
                        //   3: astore #18
                        //   5: aload_0
                        //   6: getfield label : I
                        //   9: tableswitch default -> 1025, 0 -> 36, 1 -> 447, 2 -> 1015
                        //   36: aload_1
                        //   37: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   40: aload_0
                        //   41: getfield $unzipDir : Ljava/io/File;
                        //   44: invokevirtual exists : ()Z
                        //   47: ifne -> 63
                        //   50: ldc 'Boot'
                        //   52: ldc 'selectZipFile'
                        //   54: ldc ''
                        //   56: invokestatic UnitySendMessage : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
                        //   59: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                        //   62: areturn
                        //   63: new java/util/ArrayList
                        //   66: dup
                        //   67: invokespecial <init> : ()V
                        //   70: checkcast java/util/List
                        //   73: astore_2
                        //   74: aload_0
                        //   75: getfield $unzipDir : Ljava/io/File;
                        //   78: invokestatic walkTopDown : (Ljava/io/File;)Lkotlin/io/FileTreeWalk;
                        //   81: checkcast kotlin/sequences/Sequence
                        //   84: getstatic com/etouch/activity/UnityBridgeActivity$processUnzippedFiles$2$1.INSTANCE : Lcom/etouch/activity/UnityBridgeActivity$processUnzippedFiles$2$1;
                        //   87: checkcast kotlin/jvm/functions/Function1
                        //   90: invokestatic filter : (Lkotlin/sequences/Sequence;Lkotlin/jvm/functions/Function1;)Lkotlin/sequences/Sequence;
                        //   93: astore_3
                        //   94: aload_0
                        //   95: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        //   98: astore #4
                        //   100: aload_0
                        //   101: getfield $context : Landroid/content/Context;
                        //   104: astore #5
                        //   106: iconst_0
                        //   107: istore #6
                        //   109: aload_3
                        //   110: invokeinterface iterator : ()Ljava/util/Iterator;
                        //   115: astore #7
                        //   117: aload #7
                        //   119: invokeinterface hasNext : ()Z
                        //   124: ifeq -> 933
                        //   127: aload #7
                        //   129: invokeinterface next : ()Ljava/lang/Object;
                        //   134: astore #8
                        //   136: aload #8
                        //   138: checkcast java/io/File
                        //   141: astore #9
                        //   143: iconst_0
                        //   144: istore #10
                        //   146: aload #9
                        //   148: invokevirtual getName : ()Ljava/lang/String;
                        //   151: dup
                        //   152: ldc 'getName(...)'
                        //   154: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
                        //   157: getstatic java/util/Locale.ROOT : Ljava/util/Locale;
                        //   160: invokevirtual toLowerCase : (Ljava/util/Locale;)Ljava/lang/String;
                        //   163: dup
                        //   164: ldc 'toLowerCase(...)'
                        //   166: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
                        //   169: astore #12
                        //   171: aload #12
                        //   173: checkcast java/lang/CharSequence
                        //   176: ldc '.'
                        //   178: checkcast java/lang/CharSequence
                        //   181: iconst_0
                        //   182: iconst_2
                        //   183: aconst_null
                        //   184: invokestatic contains$default : (Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZILjava/lang/Object;)Z
                        //   187: ifeq -> 203
                        //   190: aload #12
                        //   192: ldc '.'
                        //   194: aconst_null
                        //   195: iconst_2
                        //   196: aconst_null
                        //   197: invokestatic substringAfterLast$default : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/Object;)Ljava/lang/String;
                        //   200: goto -> 205
                        //   203: ldc ''
                        //   205: astore #11
                        //   207: new com/etouch/MultiFileInfo
                        //   210: dup
                        //   211: aconst_null
                        //   212: aconst_null
                        //   213: aconst_null
                        //   214: aconst_null
                        //   215: bipush #15
                        //   217: aconst_null
                        //   218: invokespecial <init> : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
                        //   221: astore #13
                        //   223: nop
                        //   224: aload #4
                        //   226: invokestatic access$getVideoSuffixSet$p : (Lcom/etouch/activity/UnityBridgeActivity;)Ljava/util/Set;
                        //   229: aload #11
                        //   231: invokeinterface contains : (Ljava/lang/Object;)Z
                        //   236: ifeq -> 574
                        //   239: new android/media/MediaMetadataRetriever
                        //   242: dup
                        //   243: invokespecial <init> : ()V
                        //   246: astore #14
                        //   248: aconst_null
                        //   249: astore #15
                        //   251: nop
                        //   252: nop
                        //   253: aload #14
                        //   255: aload #9
                        //   257: invokevirtual getAbsolutePath : ()Ljava/lang/String;
                        //   260: invokevirtual setDataSource : (Ljava/lang/String;)V
                        //   263: aload #14
                        //   265: iconst_2
                        //   266: invokevirtual extractMetadata : (I)Ljava/lang/String;
                        //   269: dup
                        //   270: ifnonnull -> 292
                        //   273: pop
                        //   274: aload #14
                        //   276: bipush #13
                        //   278: invokevirtual extractMetadata : (I)Ljava/lang/String;
                        //   281: dup
                        //   282: ifnonnull -> 292
                        //   285: pop
                        //   286: aload #14
                        //   288: iconst_3
                        //   289: invokevirtual extractMetadata : (I)Ljava/lang/String;
                        //   292: astore #15
                        //   294: aload #14
                        //   296: bipush #9
                        //   298: invokevirtual extractMetadata : (I)Ljava/lang/String;
                        //   301: astore #16
                        //   303: aload #16
                        //   305: ifnull -> 328
                        //   308: aload #16
                        //   310: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
                        //   313: astore #17
                        //   315: aload #17
                        //   317: ifnull -> 328
                        //   320: aload #17
                        //   322: invokevirtual longValue : ()J
                        //   325: goto -> 329
                        //   328: lconst_0
                        //   329: pop2
                        //   330: nop
                        //   331: aload #14
                        //   333: invokevirtual release : ()V
                        //   336: goto -> 341
                        //   339: astore #16
                        //   341: goto -> 376
                        //   344: astore #16
                        //   346: nop
                        //   347: aload #14
                        //   349: invokevirtual release : ()V
                        //   352: goto -> 357
                        //   355: astore #16
                        //   357: goto -> 376
                        //   360: astore #16
                        //   362: nop
                        //   363: aload #14
                        //   365: invokevirtual release : ()V
                        //   368: goto -> 373
                        //   371: astore #17
                        //   373: aload #16
                        //   375: athrow
                        //   376: aload #9
                        //   378: invokestatic fromFile : (Ljava/io/File;)Landroid/net/Uri;
                        //   381: astore #16
                        //   383: aload #4
                        //   385: aload #5
                        //   387: aload #16
                        //   389: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        //   392: aload #16
                        //   394: aload_0
                        //   395: aload_0
                        //   396: aload_2
                        //   397: putfield L$0 : Ljava/lang/Object;
                        //   400: aload_0
                        //   401: aload #4
                        //   403: putfield L$1 : Ljava/lang/Object;
                        //   406: aload_0
                        //   407: aload #5
                        //   409: putfield L$2 : Ljava/lang/Object;
                        //   412: aload_0
                        //   413: aload #7
                        //   415: putfield L$3 : Ljava/lang/Object;
                        //   418: aload_0
                        //   419: aload #13
                        //   421: putfield L$4 : Ljava/lang/Object;
                        //   424: aload_0
                        //   425: aload #15
                        //   427: putfield L$5 : Ljava/lang/Object;
                        //   430: aload_0
                        //   431: iconst_1
                        //   432: putfield label : I
                        //   435: invokevirtual convertVideoToMp3 : (Landroid/content/Context;Landroid/net/Uri;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
                        //   438: dup
                        //   439: aload #18
                        //   441: if_acmpne -> 511
                        //   444: aload #18
                        //   446: areturn
                        //   447: iconst_0
                        //   448: istore #6
                        //   450: iconst_0
                        //   451: istore #10
                        //   453: aload_0
                        //   454: getfield L$5 : Ljava/lang/Object;
                        //   457: checkcast java/lang/String
                        //   460: astore #15
                        //   462: aload_0
                        //   463: getfield L$4 : Ljava/lang/Object;
                        //   466: checkcast com/etouch/MultiFileInfo
                        //   469: astore #13
                        //   471: aload_0
                        //   472: getfield L$3 : Ljava/lang/Object;
                        //   475: checkcast java/util/Iterator
                        //   478: astore #7
                        //   480: aload_0
                        //   481: getfield L$2 : Ljava/lang/Object;
                        //   484: checkcast android/content/Context
                        //   487: astore #5
                        //   489: aload_0
                        //   490: getfield L$1 : Ljava/lang/Object;
                        //   493: checkcast com/etouch/activity/UnityBridgeActivity
                        //   496: astore #4
                        //   498: aload_0
                        //   499: getfield L$0 : Ljava/lang/Object;
                        //   502: checkcast java/util/List
                        //   505: astore_2
                        //   506: aload_1
                        //   507: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   510: aload_1
                        //   511: checkcast java/lang/String
                        //   514: astore #17
                        //   516: aload #17
                        //   518: ifnull -> 929
                        //   521: aload #13
                        //   523: ldc 'audio'
                        //   525: invokevirtual setType : (Ljava/lang/String;)V
                        //   528: aload #13
                        //   530: aload #17
                        //   532: invokevirtual setUrl : (Ljava/lang/String;)V
                        //   535: aload #13
                        //   537: new java/io/File
                        //   540: dup
                        //   541: aload #17
                        //   543: invokespecial <init> : (Ljava/lang/String;)V
                        //   546: invokestatic fromFile : (Ljava/io/File;)Landroid/net/Uri;
                        //   549: invokevirtual toString : ()Ljava/lang/String;
                        //   552: invokevirtual setUri : (Ljava/lang/String;)V
                        //   555: aload #13
                        //   557: aload #15
                        //   559: invokevirtual setAuthor : (Ljava/lang/String;)V
                        //   562: aload_2
                        //   563: aload #13
                        //   565: invokeinterface add : (Ljava/lang/Object;)Z
                        //   570: pop
                        //   571: goto -> 929
                        //   574: aload #4
                        //   576: invokestatic access$getAudioSuffixSet$p : (Lcom/etouch/activity/UnityBridgeActivity;)Ljava/util/Set;
                        //   579: aload #11
                        //   581: invokeinterface contains : (Ljava/lang/Object;)Z
                        //   586: ifeq -> 775
                        //   589: new android/media/MediaMetadataRetriever
                        //   592: dup
                        //   593: invokespecial <init> : ()V
                        //   596: astore #14
                        //   598: aconst_null
                        //   599: astore #15
                        //   601: nop
                        //   602: nop
                        //   603: aload #14
                        //   605: aload #9
                        //   607: invokevirtual getAbsolutePath : ()Ljava/lang/String;
                        //   610: invokevirtual setDataSource : (Ljava/lang/String;)V
                        //   613: aload #14
                        //   615: iconst_2
                        //   616: invokevirtual extractMetadata : (I)Ljava/lang/String;
                        //   619: dup
                        //   620: ifnonnull -> 642
                        //   623: pop
                        //   624: aload #14
                        //   626: bipush #13
                        //   628: invokevirtual extractMetadata : (I)Ljava/lang/String;
                        //   631: dup
                        //   632: ifnonnull -> 642
                        //   635: pop
                        //   636: aload #14
                        //   638: iconst_3
                        //   639: invokevirtual extractMetadata : (I)Ljava/lang/String;
                        //   642: astore #15
                        //   644: aload #14
                        //   646: bipush #9
                        //   648: invokevirtual extractMetadata : (I)Ljava/lang/String;
                        //   651: astore #16
                        //   653: aload #16
                        //   655: ifnull -> 678
                        //   658: aload #16
                        //   660: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
                        //   663: astore #17
                        //   665: aload #17
                        //   667: ifnull -> 678
                        //   670: aload #17
                        //   672: invokevirtual longValue : ()J
                        //   675: goto -> 679
                        //   678: lconst_0
                        //   679: pop2
                        //   680: nop
                        //   681: aload #14
                        //   683: invokevirtual release : ()V
                        //   686: goto -> 691
                        //   689: astore #16
                        //   691: goto -> 726
                        //   694: astore #16
                        //   696: nop
                        //   697: aload #14
                        //   699: invokevirtual release : ()V
                        //   702: goto -> 707
                        //   705: astore #16
                        //   707: goto -> 726
                        //   710: astore #16
                        //   712: nop
                        //   713: aload #14
                        //   715: invokevirtual release : ()V
                        //   718: goto -> 723
                        //   721: astore #17
                        //   723: aload #16
                        //   725: athrow
                        //   726: aload #13
                        //   728: ldc 'audio'
                        //   730: invokevirtual setType : (Ljava/lang/String;)V
                        //   733: aload #13
                        //   735: aload #9
                        //   737: invokevirtual getAbsolutePath : ()Ljava/lang/String;
                        //   740: invokevirtual setUrl : (Ljava/lang/String;)V
                        //   743: aload #13
                        //   745: aload #9
                        //   747: invokestatic fromFile : (Ljava/io/File;)Landroid/net/Uri;
                        //   750: invokevirtual toString : ()Ljava/lang/String;
                        //   753: invokevirtual setUri : (Ljava/lang/String;)V
                        //   756: aload #13
                        //   758: aload #15
                        //   760: invokevirtual setAuthor : (Ljava/lang/String;)V
                        //   763: aload_2
                        //   764: aload #13
                        //   766: invokeinterface add : (Ljava/lang/Object;)Z
                        //   771: pop
                        //   772: goto -> 929
                        //   775: aload #4
                        //   777: invokestatic access$getImageSuffixSet$p : (Lcom/etouch/activity/UnityBridgeActivity;)Ljava/util/Set;
                        //   780: aload #11
                        //   782: invokeinterface contains : (Ljava/lang/Object;)Z
                        //   787: ifeq -> 833
                        //   790: aload #13
                        //   792: ldc_w 'image'
                        //   795: invokevirtual setType : (Ljava/lang/String;)V
                        //   798: aload #13
                        //   800: aload #9
                        //   802: invokevirtual getAbsolutePath : ()Ljava/lang/String;
                        //   805: invokevirtual setUrl : (Ljava/lang/String;)V
                        //   808: aload #13
                        //   810: aload #9
                        //   812: invokestatic fromFile : (Ljava/io/File;)Landroid/net/Uri;
                        //   815: invokevirtual toString : ()Ljava/lang/String;
                        //   818: invokevirtual setUri : (Ljava/lang/String;)V
                        //   821: aload_2
                        //   822: aload #13
                        //   824: invokeinterface add : (Ljava/lang/Object;)Z
                        //   829: pop
                        //   830: goto -> 929
                        //   833: aload #4
                        //   835: invokestatic access$getLyricSuffixSet$p : (Lcom/etouch/activity/UnityBridgeActivity;)Ljava/util/Set;
                        //   838: aload #11
                        //   840: invokeinterface contains : (Ljava/lang/Object;)Z
                        //   845: ifeq -> 891
                        //   848: aload #13
                        //   850: ldc_w 'lyric'
                        //   853: invokevirtual setType : (Ljava/lang/String;)V
                        //   856: aload #13
                        //   858: aload #9
                        //   860: invokevirtual getAbsolutePath : ()Ljava/lang/String;
                        //   863: invokevirtual setUrl : (Ljava/lang/String;)V
                        //   866: aload #13
                        //   868: aload #9
                        //   870: invokestatic fromFile : (Ljava/io/File;)Landroid/net/Uri;
                        //   873: invokevirtual toString : ()Ljava/lang/String;
                        //   876: invokevirtual setUri : (Ljava/lang/String;)V
                        //   879: aload_2
                        //   880: aload #13
                        //   882: invokeinterface add : (Ljava/lang/Object;)Z
                        //   887: pop
                        //   888: goto -> 929
                        //   891: aload #13
                        //   893: aconst_null
                        //   894: invokevirtual setType : (Ljava/lang/String;)V
                        //   897: aload #13
                        //   899: aload #9
                        //   901: invokevirtual getAbsolutePath : ()Ljava/lang/String;
                        //   904: invokevirtual setUrl : (Ljava/lang/String;)V
                        //   907: aload #13
                        //   909: aload #9
                        //   911: invokestatic fromFile : (Ljava/io/File;)Landroid/net/Uri;
                        //   914: invokevirtual toString : ()Ljava/lang/String;
                        //   917: invokevirtual setUri : (Ljava/lang/String;)V
                        //   920: aload_2
                        //   921: aload #13
                        //   923: invokeinterface add : (Ljava/lang/Object;)Z
                        //   928: pop
                        //   929: nop
                        //   930: goto -> 117
                        //   933: nop
                        //   934: new com/google/gson/Gson
                        //   937: dup
                        //   938: invokespecial <init> : ()V
                        //   941: aload_2
                        //   942: invokevirtual toJson : (Ljava/lang/Object;)Ljava/lang/String;
                        //   945: astore_3
                        //   946: invokestatic getMain : ()Lkotlinx/coroutines/MainCoroutineDispatcher;
                        //   949: checkcast kotlin/coroutines/CoroutineContext
                        //   952: new com/etouch/activity/UnityBridgeActivity$processUnzippedFiles$2$3
                        //   955: dup
                        //   956: aload_3
                        //   957: aconst_null
                        //   958: invokespecial <init> : (Ljava/lang/String;Lkotlin/coroutines/Continuation;)V
                        //   961: checkcast kotlin/jvm/functions/Function2
                        //   964: aload_0
                        //   965: checkcast kotlin/coroutines/Continuation
                        //   968: aload_0
                        //   969: aconst_null
                        //   970: putfield L$0 : Ljava/lang/Object;
                        //   973: aload_0
                        //   974: aconst_null
                        //   975: putfield L$1 : Ljava/lang/Object;
                        //   978: aload_0
                        //   979: aconst_null
                        //   980: putfield L$2 : Ljava/lang/Object;
                        //   983: aload_0
                        //   984: aconst_null
                        //   985: putfield L$3 : Ljava/lang/Object;
                        //   988: aload_0
                        //   989: aconst_null
                        //   990: putfield L$4 : Ljava/lang/Object;
                        //   993: aload_0
                        //   994: aconst_null
                        //   995: putfield L$5 : Ljava/lang/Object;
                        //   998: aload_0
                        //   999: iconst_2
                        //   1000: putfield label : I
                        //   1003: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
                        //   1006: dup
                        //   1007: aload #18
                        //   1009: if_acmpne -> 1020
                        //   1012: aload #18
                        //   1014: areturn
                        //   1015: aload_1
                        //   1016: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   1019: aload_1
                        //   1020: pop
                        //   1021: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                        //   1024: areturn
                        //   1025: new java/lang/IllegalStateException
                        //   1028: dup
                        //   1029: ldc_w 'call to 'resume' before 'invoke' with coroutine'
                        //   1032: invokespecial <init> : (Ljava/lang/String;)V
                        //   1035: athrow
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #2521	-> 3
                        //   #2523	-> 40
                        //   #2525	-> 50
                        //   #2526	-> 59
                        //   #2529	-> 63
                        //   #2529	-> 73
                        //   #2531	-> 74
                        //   #3506	-> 109
                        //   #2533	-> 146
                        //   #2533	-> 169
                        //   #2534	-> 171
                        //   #2535	-> 207
                        //   #2537	-> 223
                        //   #2542	-> 224
                        //   #2544	-> 239
                        //   #2545	-> 248
                        //   #2546	-> 251
                        //   #2548	-> 252
                        //   #2549	-> 253
                        //   #2552	-> 263
                        //   #2553	-> 273
                        //   #2552	-> 281
                        //   #2554	-> 286
                        //   #2551	-> 292
                        //   #2557	-> 294
                        //   #2558	-> 303
                        //   #2557	-> 308
                        //   #2558	-> 310
                        //   #2557	-> 313
                        //   #2558	-> 328
                        //   #2556	-> 329
                        //   #2563	-> 330
                        //   #2564	-> 331
                        //   #2565	-> 339
                        //   #2567	-> 341
                        //   #2560	-> 344
                        //   #2563	-> 346
                        //   #2564	-> 347
                        //   #2565	-> 355
                        //   #2567	-> 357
                        //   #2563	-> 360
                        //   #2564	-> 363
                        //   #2565	-> 371
                        //   #2569	-> 376
                        //   #2570	-> 383
                        //   #2521	-> 444
                        //   #2572	-> 516
                        //   #2573	-> 521
                        //   #2574	-> 528
                        //   #2575	-> 535
                        //   #2577	-> 555
                        //   #2579	-> 562
                        //   #2588	-> 574
                        //   #2590	-> 589
                        //   #2591	-> 598
                        //   #2592	-> 601
                        //   #2594	-> 602
                        //   #2595	-> 603
                        //   #2598	-> 613
                        //   #2599	-> 623
                        //   #2598	-> 631
                        //   #2600	-> 636
                        //   #2597	-> 642
                        //   #2603	-> 644
                        //   #2604	-> 653
                        //   #2603	-> 658
                        //   #2604	-> 660
                        //   #2603	-> 663
                        //   #2604	-> 678
                        //   #2602	-> 679
                        //   #2609	-> 680
                        //   #2610	-> 681
                        //   #2611	-> 689
                        //   #2613	-> 691
                        //   #2606	-> 694
                        //   #2609	-> 696
                        //   #2610	-> 697
                        //   #2611	-> 705
                        //   #2613	-> 707
                        //   #2609	-> 710
                        //   #2610	-> 713
                        //   #2611	-> 721
                        //   #2615	-> 726
                        //   #2616	-> 733
                        //   #2617	-> 743
                        //   #2618	-> 756
                        //   #2620	-> 763
                        //   #2626	-> 775
                        //   #2627	-> 790
                        //   #2628	-> 798
                        //   #2629	-> 808
                        //   #2630	-> 821
                        //   #2636	-> 833
                        //   #2637	-> 848
                        //   #2638	-> 856
                        //   #2639	-> 866
                        //   #2640	-> 879
                        //   #2647	-> 891
                        //   #2648	-> 897
                        //   #2649	-> 907
                        //   #2650	-> 920
                        //   #2653	-> 929
                        //   #3506	-> 930
                        //   #3507	-> 933
                        //   #2655	-> 934
                        //   #2659	-> 946
                        //   #2521	-> 1012
                        //   #2666	-> 1020
                        //   #2521	-> 1025
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   74	286	2	fileList	Ljava/util/List;
                        //   376	71	2	fileList	Ljava/util/List;
                        //   506	204	2	fileList	Ljava/util/List;
                        //   726	204	2	fileList	Ljava/util/List;
                        //   930	4	2	fileList	Ljava/util/List;
                        //   934	12	2	fileList	Ljava/util/List;
                        //   106	11	3	$this$forEach$iv	Lkotlin/sequences/Sequence;
                        //   946	60	3	json	Ljava/lang/String;
                        //   136	7	8	element$iv	Ljava/lang/Object;
                        //   143	217	9	file	Ljava/io/File;
                        //   376	7	9	file	Ljava/io/File;
                        //   574	136	9	file	Ljava/io/File;
                        //   726	30	9	file	Ljava/io/File;
                        //   775	46	9	file	Ljava/io/File;
                        //   833	46	9	file	Ljava/io/File;
                        //   891	29	9	file	Ljava/io/File;
                        //   207	32	11	suffix	Ljava/lang/String;
                        //   574	15	11	suffix	Ljava/lang/String;
                        //   775	15	11	suffix	Ljava/lang/String;
                        //   833	15	11	suffix	Ljava/lang/String;
                        //   171	32	12	fileName	Ljava/lang/String;
                        //   223	137	13	multiFileInfo	Lcom/etouch/MultiFileInfo;
                        //   376	71	13	multiFileInfo	Lcom/etouch/MultiFileInfo;
                        //   471	100	13	multiFileInfo	Lcom/etouch/MultiFileInfo;
                        //   574	136	13	multiFileInfo	Lcom/etouch/MultiFileInfo;
                        //   726	46	13	multiFileInfo	Lcom/etouch/MultiFileInfo;
                        //   775	58	13	multiFileInfo	Lcom/etouch/MultiFileInfo;
                        //   833	58	13	multiFileInfo	Lcom/etouch/MultiFileInfo;
                        //   891	38	13	multiFileInfo	Lcom/etouch/MultiFileInfo;
                        //   248	88	14	retriever	Landroid/media/MediaMetadataRetriever;
                        //   344	8	14	retriever	Landroid/media/MediaMetadataRetriever;
                        //   360	8	14	retriever	Landroid/media/MediaMetadataRetriever;
                        //   598	88	14	retriever	Landroid/media/MediaMetadataRetriever;
                        //   694	8	14	retriever	Landroid/media/MediaMetadataRetriever;
                        //   710	8	14	retriever	Landroid/media/MediaMetadataRetriever;
                        //   251	43	15	artistName	Ljava/lang/String;
                        //   294	66	15	artistName	Ljava/lang/String;
                        //   376	71	15	artistName	Ljava/lang/String;
                        //   462	109	15	artistName	Ljava/lang/String;
                        //   601	43	15	artistName	Ljava/lang/String;
                        //   644	66	15	artistName	Ljava/lang/String;
                        //   726	46	15	artistName	Ljava/lang/String;
                        //   383	55	16	videoUri	Landroid/net/Uri;
                        //   516	55	17	mp3Path	Ljava/lang/String;
                        //   146	301	10	$i$a$-forEach-UnityBridgeActivity$processUnzippedFiles$2$2	I
                        //   109	338	6	$i$f$forEach	I
                        //   40	985	0	this	Lcom/etouch/activity/UnityBridgeActivity$processUnzippedFiles$2;
                        //   40	985	1	$result	Ljava/lang/Object;
                        //   453	477	10	$i$a$-forEach-UnityBridgeActivity$processUnzippedFiles$2$2	I
                        //   450	484	6	$i$f$forEach	I
                        // Exception table:
                        //   from	to	target	type
                        //   252	330	344	java/lang/Exception
                        //   252	330	360	finally
                        //   330	336	339	java/lang/Exception
                        //   344	346	360	finally
                        //   346	352	355	java/lang/Exception
                        //   360	362	360	finally
                        //   362	368	371	java/lang/Exception
                        //   602	680	694	java/lang/Exception
                        //   602	680	710	finally
                        //   680	686	689	java/lang/Exception
                        //   694	696	710	finally
                        //   696	702	705	java/lang/Exception
                        //   710	712	710	finally
                        //   712	718	721	java/lang/Exception } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$processUnzippedFiles$2> $completion) { return (Continuation<Unit>)new UnityBridgeActivity$processUnzippedFiles$2(UnityBridgeActivity.this, this.$context, $completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((UnityBridgeActivity$processUnzippedFiles$2)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } } private final File copyZipToCache(Uri uri) { File file = new File(getCacheDir(), "temp.zip"); Intrinsics.checkNotNull(getContentResolver().openInputStream(uri)); InputStream inputStream = getContentResolver().openInputStream(uri); Throwable throwable = null; try { InputStream input = inputStream; int $i$a$-use-UnityBridgeActivity$copyZipToCache$1 = 0; FileOutputStream fileOutputStream = new FileOutputStream(file); Throwable throwable1 = null; try { FileOutputStream output = fileOutputStream; int $i$a$-use-UnityBridgeActivity$copyZipToCache$1$1 = 0; Intrinsics.checkNotNull(input); long l1 = ByteStreamsKt.copyTo$default(input, output, 0, 2, null); } catch (Throwable throwable2) { throwable1 = throwable2 = null; throw throwable2; } finally { CloseableKt.closeFinally(fileOutputStream, throwable1); }  long l = l1; } catch (Throwable throwable1) { throwable = throwable1 = null; throw throwable1; } finally { CloseableKt.closeFinally(inputStream, throwable); }  return file; } private final void clearDir(File dir) { if (dir.exists()) FilesKt.deleteRecursively(dir);  dir.mkdirs(); } private final void showPasswordDialog(Function1 onOk) { // Byte code:
                        //   0: new android/widget/EditText
                        //   3: dup
                        //   4: aload_0
                        //   5: checkcast android/content/Context
                        //   8: invokespecial <init> : (Landroid/content/Context;)V
                        //   11: astore_3
                        //   12: aload_3
                        //   13: astore #4
                        //   15: iconst_0
                        //   16: istore #5
                        //   18: aload #4
                        //   20: sipush #129
                        //   23: invokevirtual setInputType : (I)V
                        //   26: nop
                        //   27: aload_3
                        //   28: astore_2
                        //   29: new androidx/appcompat/app/AlertDialog$Builder
                        //   32: dup
                        //   33: aload_0
                        //   34: checkcast android/content/Context
                        //   37: invokespecial <init> : (Landroid/content/Context;)V
                        //   40: ldc_w '输入 ZIP 密码'
                        //   43: checkcast java/lang/CharSequence
                        //   46: invokevirtual setTitle : (Ljava/lang/CharSequence;)Landroidx/appcompat/app/AlertDialog$Builder;
                        //   49: aload_2
                        //   50: checkcast android/view/View
                        //   53: invokevirtual setView : (Landroid/view/View;)Landroidx/appcompat/app/AlertDialog$Builder;
                        //   56: iconst_0
                        //   57: invokevirtual setCancelable : (Z)Landroidx/appcompat/app/AlertDialog$Builder;
                        //   60: ldc_w '解压'
                        //   63: checkcast java/lang/CharSequence
                        //   66: aload_1
                        //   67: aload_2
                        //   68: <illegal opcode> onClick : (Lkotlin/jvm/functions/Function1;Landroid/widget/EditText;)Landroid/content/DialogInterface$OnClickListener;
                        //   73: invokevirtual setPositiveButton : (Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroidx/appcompat/app/AlertDialog$Builder;
                        //   76: ldc_w '取消'
                        //   79: checkcast java/lang/CharSequence
                        //   82: aconst_null
                        //   83: invokevirtual setNegativeButton : (Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroidx/appcompat/app/AlertDialog$Builder;
                        //   86: invokevirtual show : ()Landroidx/appcompat/app/AlertDialog;
                        //   89: pop
                        //   90: return
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #2689	-> 0
                        //   #2690	-> 18
                        //   #2691	-> 20
                        //   #2690	-> 23
                        //   #2692	-> 26
                        //   #2689	-> 27
                        //   #2689	-> 28
                        //   #2694	-> 29
                        //   #2695	-> 40
                        //   #2696	-> 49
                        //   #2697	-> 56
                        //   #2698	-> 60
                        //   #2701	-> 76
                        //   #2702	-> 86
                        //   #2703	-> 90
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   18	9	5	$i$a$-apply-UnityBridgeActivity$showPasswordDialog$input$1	I
                        //   15	12	4	$this$showPasswordDialog_u24lambda_u2440	Landroid/widget/EditText;
                        //   29	62	2	input	Landroid/widget/EditText;
                        //   0	91	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                        //   0	91	1	onOk	Lkotlin/jvm/functions/Function1; } private static final void showPasswordDialog$lambda$41(Function1 $onOk, EditText $input, DialogInterface paramDialogInterface, int paramInt) { Intrinsics.checkNotNullParameter($onOk, "$onOk"); Intrinsics.checkNotNullParameter($input, "$input"); $onOk.invoke($input.getText().toString()); } private static final void selectFolderLauncher$lambda$42(UnityBridgeActivity this$0, Uri folderUri) { Intrinsics.checkNotNullParameter(this$0, "this$0"); Ref.ObjectRef<ExPortFileResult> exPortFileResult = new Ref.ObjectRef(); exPortFileResult.element = new ExPortFileResult(null, null, 3, null); if (folderUri != null) { BuildersKt.launch$default((CoroutineScope)LifecycleOwnerKt.getLifecycleScope((LifecycleOwner)this$0), null, null, new UnityBridgeActivity$selectFolderLauncher$1$1(folderUri, exPortFileResult, null), 3, null); } else { ((ExPortFileResult)exPortFileResult.element).setSuccess(Boolean.valueOf(false)); ((ExPortFileResult)exPortFileResult.element).setErrorMsg("未选择文件夹"); UnityPlayer.UnitySendMessage("Boot", "exportFile", (new Gson()).toJson(exPortFileResult.element)); }  } @DebugMetadata(f = "UnityBridgeActivity.kt", l = {2720}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$selectFolderLauncher$1$1") @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"}) static final class UnityBridgeActivity$selectFolderLauncher$1$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> { int label; UnityBridgeActivity$selectFolderLauncher$1$1(Uri $folderUri, Ref.ObjectRef<ExPortFileResult> $exPortFileResult, Continuation $completion) { super(2, $completion); } @Nullable public final Object invokeSuspend(@NotNull Object $result) { // Byte code:
                        //   0: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
                        //   3: astore_3
                        //   4: aload_0
                        //   5: getfield label : I
                        //   8: tableswitch default -> 166, 0 -> 32, 1 -> 70
                        //   32: aload_1
                        //   33: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   36: aload_0
                        //   37: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        //   40: aload_0
                        //   41: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        //   44: invokestatic access$getSourceLocalPath$p : (Lcom/etouch/activity/UnityBridgeActivity;)Ljava/lang/String;
                        //   47: aload_0
                        //   48: getfield $folderUri : Landroid/net/Uri;
                        //   51: aload_0
                        //   52: checkcast kotlin/coroutines/Continuation
                        //   55: aload_0
                        //   56: iconst_1
                        //   57: putfield label : I
                        //   60: invokevirtual saveMediaToSelectedDirAsync : (Ljava/lang/String;Landroid/net/Uri;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
                        //   63: dup
                        //   64: aload_3
                        //   65: if_acmpne -> 75
                        //   68: aload_3
                        //   69: areturn
                        //   70: aload_1
                        //   71: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   74: aload_1
                        //   75: checkcast java/lang/Boolean
                        //   78: invokevirtual booleanValue : ()Z
                        //   81: istore_2
                        //   82: iload_2
                        //   83: ifeq -> 106
                        //   86: aload_0
                        //   87: getfield $exPortFileResult : Lkotlin/jvm/internal/Ref$ObjectRef;
                        //   90: getfield element : Ljava/lang/Object;
                        //   93: checkcast com/etouch/ExPortFileResult
                        //   96: iconst_1
                        //   97: invokestatic boxBoolean : (Z)Ljava/lang/Boolean;
                        //   100: invokevirtual setSuccess : (Ljava/lang/Boolean;)V
                        //   103: goto -> 138
                        //   106: aload_0
                        //   107: getfield $exPortFileResult : Lkotlin/jvm/internal/Ref$ObjectRef;
                        //   110: getfield element : Ljava/lang/Object;
                        //   113: checkcast com/etouch/ExPortFileResult
                        //   116: iconst_0
                        //   117: invokestatic boxBoolean : (Z)Ljava/lang/Boolean;
                        //   120: invokevirtual setSuccess : (Ljava/lang/Boolean;)V
                        //   123: aload_0
                        //   124: getfield $exPortFileResult : Lkotlin/jvm/internal/Ref$ObjectRef;
                        //   127: getfield element : Ljava/lang/Object;
                        //   130: checkcast com/etouch/ExPortFileResult
                        //   133: ldc '源文件无效或保存失败（请检查权限和目录可写性）'
                        //   135: invokevirtual setErrorMsg : (Ljava/lang/String;)V
                        //   138: ldc 'Boot'
                        //   140: ldc 'exportFile'
                        //   142: new com/google/gson/Gson
                        //   145: dup
                        //   146: invokespecial <init> : ()V
                        //   149: aload_0
                        //   150: getfield $exPortFileResult : Lkotlin/jvm/internal/Ref$ObjectRef;
                        //   153: getfield element : Ljava/lang/Object;
                        //   156: invokevirtual toJson : (Ljava/lang/Object;)Ljava/lang/String;
                        //   159: invokestatic UnitySendMessage : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
                        //   162: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                        //   165: areturn
                        //   166: new java/lang/IllegalStateException
                        //   169: dup
                        //   170: ldc 'call to 'resume' before 'invoke' with coroutine'
                        //   172: invokespecial <init> : (Ljava/lang/String;)V
                        //   175: athrow
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #2719	-> 3
                        //   #2720	-> 36
                        //   #2719	-> 68
                        //   #2720	-> 75
                        //   #2721	-> 82
                        //   #2722	-> 86
                        //   #2724	-> 106
                        //   #2725	-> 123
                        //   #2729	-> 138
                        //   #2728	-> 159
                        //   #2731	-> 162
                        //   #2719	-> 166
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   82	4	2	isSaveSuccess	Z
                        //   36	130	0	this	Lcom/etouch/activity/UnityBridgeActivity$selectFolderLauncher$1$1;
                        //   36	130	1	$result	Ljava/lang/Object; } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$selectFolderLauncher$1$1> $completion) { return (Continuation<Unit>)new UnityBridgeActivity$selectFolderLauncher$1$1(this.$folderUri, this.$exPortFileResult, $completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((UnityBridgeActivity$selectFolderLauncher$1$1)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } } private final void exportFileToSystem(String localPath) { this.sourceLocalPath = localPath; if (Build.VERSION.SDK_INT <= 28) { String[] arrayOfString = new String[2]; arrayOfString[0] = "android.permission.READ_EXTERNAL_STORAGE"; arrayOfString[1] = "android.permission.WRITE_EXTERNAL_STORAGE"; this.requestStoragePermissionLauncher.launch(arrayOfString); }  this.selectFolderLauncher.launch(null); } @Nullable public final Object saveMediaToSelectedDirAsync(@NotNull String sourceLocalPath, @NotNull Uri currentFolderUri, @NotNull Continuation<? super Boolean> paramContinuation) { // Byte code:
                        //   0: aload_3
                        //   1: instanceof com/etouch/activity/UnityBridgeActivity$saveMediaToSelectedDirAsync$1
                        //   4: ifeq -> 41
                        //   7: aload_3
                        //   8: checkcast com/etouch/activity/UnityBridgeActivity$saveMediaToSelectedDirAsync$1
                        //   11: astore #6
                        //   13: aload #6
                        //   15: getfield label : I
                        //   18: ldc_w -2147483648
                        //   21: iand
                        //   22: ifeq -> 41
                        //   25: aload #6
                        //   27: dup
                        //   28: getfield label : I
                        //   31: ldc_w -2147483648
                        //   34: isub
                        //   35: putfield label : I
                        //   38: goto -> 52
                        //   41: new com/etouch/activity/UnityBridgeActivity$saveMediaToSelectedDirAsync$1
                        //   44: dup
                        //   45: aload_0
                        //   46: aload_3
                        //   47: invokespecial <init> : (Lcom/etouch/activity/UnityBridgeActivity;Lkotlin/coroutines/Continuation;)V
                        //   50: astore #6
                        //   52: aload #6
                        //   54: getfield result : Ljava/lang/Object;
                        //   57: astore #5
                        //   59: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
                        //   62: astore #7
                        //   64: aload #6
                        //   66: getfield label : I
                        //   69: tableswitch default -> 172, 0 -> 92, 1 -> 151
                        //   92: aload #5
                        //   94: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   97: aload_0
                        //   98: checkcast androidx/lifecycle/LifecycleOwner
                        //   101: invokestatic getLifecycleScope : (Landroidx/lifecycle/LifecycleOwner;)Landroidx/lifecycle/LifecycleCoroutineScope;
                        //   104: invokevirtual getCoroutineContext : ()Lkotlin/coroutines/CoroutineContext;
                        //   107: pop
                        //   108: iconst_0
                        //   109: istore #4
                        //   111: invokestatic getIO : ()Lkotlinx/coroutines/CoroutineDispatcher;
                        //   114: checkcast kotlin/coroutines/CoroutineContext
                        //   117: new com/etouch/activity/UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1
                        //   120: dup
                        //   121: aload_1
                        //   122: aload_0
                        //   123: aload_2
                        //   124: aconst_null
                        //   125: invokespecial <init> : (Ljava/lang/String;Lcom/etouch/activity/UnityBridgeActivity;Landroid/net/Uri;Lkotlin/coroutines/Continuation;)V
                        //   128: checkcast kotlin/jvm/functions/Function2
                        //   131: aload #6
                        //   133: aload #6
                        //   135: iconst_1
                        //   136: putfield label : I
                        //   139: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
                        //   142: dup
                        //   143: aload #7
                        //   145: if_acmpne -> 161
                        //   148: aload #7
                        //   150: areturn
                        //   151: iconst_0
                        //   152: istore #4
                        //   154: aload #5
                        //   156: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   159: aload #5
                        //   161: checkcast java/lang/Boolean
                        //   164: invokevirtual booleanValue : ()Z
                        //   167: invokestatic boxBoolean : (Z)Ljava/lang/Boolean;
                        //   170: nop
                        //   171: areturn
                        //   172: new java/lang/IllegalStateException
                        //   175: dup
                        //   176: ldc_w 'call to 'resume' before 'invoke' with coroutine'
                        //   179: invokespecial <init> : (Ljava/lang/String;)V
                        //   182: athrow
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #2763	-> 62
                        //   #2767	-> 97
                        //   #2768	-> 111
                        //   #2763	-> 148
                        //   #2768	-> 161
                        //   #2767	-> 170
                        //   #2834	-> 171
                        //   #2763	-> 172
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   97	45	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                        //   97	45	1	sourceLocalPath	Ljava/lang/String;
                        //   97	45	2	currentFolderUri	Landroid/net/Uri;
                        //   111	40	4	$i$a$-run-UnityBridgeActivity$saveMediaToSelectedDirAsync$2	I
                        //   52	120	6	$continuation	Lkotlin/coroutines/Continuation;
                        //   59	113	5	$result	Ljava/lang/Object;
                        //   154	13	4	$i$a$-run-UnityBridgeActivity$saveMediaToSelectedDirAsync$2	I } @DebugMetadata(f = "UnityBridgeActivity.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1") @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\013\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"}) @SourceDebugExtension({"SMAP\nUnityBridgeActivity.kt\nKotlin\n*S Kotlin\n*F\n+ 1 UnityBridgeActivity.kt\ncom/etouch/activity/UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,3505:1\n1#2:3506\n*E\n"}) static final class UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Boolean>, Object> { int label; UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1(UnityBridgeActivity $receiver, Uri $currentFolderUri, Continuation $completion) { super(2, $completion); } @Nullable public final Object invokeSuspend(@NotNull Object $result) { FileInputStream fileInputStream; OutputStream outputStream; boolean bool; IntrinsicsKt.getCOROUTINE_SUSPENDED(); switch (this.label) { case 0: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); fileInputStream = null; outputStream = null; try { File sourceFile = new File(this.$sourceLocalPath); if (!sourceFile.exists() || !sourceFile.isFile()) { System.out.println("源文件无效：" + this.$sourceLocalPath); return Boxing.boxBoolean(false); }  DocumentFile currentFolderDoc = DocumentFile.fromTreeUri((Context)UnityBridgeActivity.this, this.$currentFolderUri); if (currentFolderDoc == null || !currentFolderDoc.exists() || !currentFolderDoc.isDirectory()) { System.out.println("本次选择的目录无效"); return Boxing.boxBoolean(false); }  String targetFileName = sourceFile.getName(); DocumentFile existingFile = currentFolderDoc.findFile(targetFileName); if (existingFile != null && existingFile.exists()) { existingFile.delete(); System.out.println("已删除目录下同名文件：" + targetFileName); }  Intrinsics.checkNotNull(targetFileName); String mimeType = StringsKt.endsWith$default(targetFileName, ".mp4", false, 2, null) ? "video/mp4" : "audio/mpeg"; DocumentFile targetDocFile = currentFolderDoc.createFile(mimeType, targetFileName); if (targetDocFile == null) { System.out.println("无法在当前选择的目录创建文件：" + targetFileName); return Boxing.boxBoolean(false); }  fileInputStream = new FileInputStream(sourceFile); outputStream = UnityBridgeActivity.this.getContentResolver().openOutputStream(targetDocFile.getUri()); if (outputStream == null) { System.out.println("无法获取输出流"); return Boxing.boxBoolean(false); }  byte[] buffer = new byte[8192]; int bytesRead = 0; while (true) { int i = fileInputStream.read(buffer), it = i; int $i$a$-also-UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1$1 = 0; bytesRead = it; if (i != -1) { outputStream.write(buffer, 0, bytesRead); continue; }  break; }  bool = true; try { fileInputStream.close(); outputStream.close(); } catch (Exception e) { DocumentFile documentFile; documentFile.printStackTrace(); }  } catch (Exception e) { DocumentFile currentFolderDoc; currentFolderDoc.printStackTrace(); bool = false; } finally { try { if (fileInputStream != null) { fileInputStream.close(); } else {  }  if (outputStream != null) { outputStream.close(); } else {  }  } catch (Exception e) { String targetFileName; targetFileName.printStackTrace(); }  }  }  throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine"); } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1> $completion) { return (Continuation<Unit>)new UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1(UnityBridgeActivity.this, this.$currentFolderUri, $completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((UnityBridgeActivity$saveMediaToSelectedDirAsync$2$1)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } } public final void controlPlay(int play) { switch (play) { case 1: case 0: default: break; }  boolean newPlayState = false; this.isPlaying = newPlayState; if (this.isPlaying) { startPlaybackIfNeeded(); } else { stopPlayback(); }  } public final void updatePlaybackCoroutine(int newSelectedWaveform, int newSelectedSwingPreset, int newSelectedVibrationPreset) { this.selectedWaveform = newSelectedWaveform; this.selectedSwingPreset = newSelectedSwingPreset; this.selectedVibrationPreset = newSelectedVibrationPreset; } private final void startPlaybackIfNeeded() { if (((this.currentPlaybackJob != null) ? ((this.currentPlaybackJob.isActive() == true)) : false) || !this.isPlaying) return;  this.isCoroutineActive.set(true); Job job1 = BuildersKt.launch$default(this.playbackScope, null, null, new UnityBridgeActivity$startPlaybackIfNeeded$1(null), 3, null); Job job2 = job1; UnityBridgeActivity unityBridgeActivity = this; int $i$a$-apply-UnityBridgeActivity$startPlaybackIfNeeded$2 = 0; job2.invokeOnCompletion(new UnityBridgeActivity$startPlaybackIfNeeded$2$1()); unityBridgeActivity.currentPlaybackJob = job1; } @DebugMetadata(f = "UnityBridgeActivity.kt", l = {2888}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$startPlaybackIfNeeded$1") @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"}) static final class UnityBridgeActivity$startPlaybackIfNeeded$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> { int label; UnityBridgeActivity$startPlaybackIfNeeded$1(Continuation $completion) { super(2, $completion); } @Nullable public final Object invokeSuspend(@NotNull Object $result) { Object object = IntrinsicsKt.getCOROUTINE_SUSPENDED(); switch (this.label) { case 0: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); this.label = 1; if (UnityBridgeActivity.this.playbackCoreLoop((Continuation)this) == object) return object;  UnityBridgeActivity.this.playbackCoreLoop((Continuation)this); return Unit.INSTANCE;case 1: ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1); return Unit.INSTANCE; }  throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine"); } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$startPlaybackIfNeeded$1> $completion) { return (Continuation<Unit>)new UnityBridgeActivity$startPlaybackIfNeeded$1($completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((UnityBridgeActivity$startPlaybackIfNeeded$1)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } } @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\003\n\000\020\000\032\0020\0012\b\020\002\032\004\030\0010\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "it", "", "invoke"}) static final class UnityBridgeActivity$startPlaybackIfNeeded$2$1 extends Lambda implements Function1<Throwable, Unit> { public final void invoke(@Nullable Throwable it) { UnityBridgeActivity.this.isCoroutineActive.set(false); if (!(it instanceof java.util.concurrent.CancellationException)) UnityBridgeActivity.this.getBluetoothManager().sendVibrationControl(0, 0, 0, 0);  } UnityBridgeActivity$startPlaybackIfNeeded$2$1() { super(1); } } private final void stopPlayback() { if (this.currentPlaybackJob != null) { Job.DefaultImpls.cancel$default(this.currentPlaybackJob, null, 1, null); } else {  }  this.currentPlaybackJob = null; this.isCoroutineActive.set(false); getBluetoothManager().sendVibrationControl(0, 0, 0, 0); } private final Object playbackCoreLoop(Continuation<? super Unit> paramContinuation) { // Byte code:
                        //   0: aload_1
                        //   1: instanceof com/etouch/activity/UnityBridgeActivity$playbackCoreLoop$1
                        //   4: ifeq -> 41
                        //   7: aload_1
                        //   8: checkcast com/etouch/activity/UnityBridgeActivity$playbackCoreLoop$1
                        //   11: astore #8
                        //   13: aload #8
                        //   15: getfield label : I
                        //   18: ldc_w -2147483648
                        //   21: iand
                        //   22: ifeq -> 41
                        //   25: aload #8
                        //   27: dup
                        //   28: getfield label : I
                        //   31: ldc_w -2147483648
                        //   34: isub
                        //   35: putfield label : I
                        //   38: goto -> 52
                        //   41: new com/etouch/activity/UnityBridgeActivity$playbackCoreLoop$1
                        //   44: dup
                        //   45: aload_0
                        //   46: aload_1
                        //   47: invokespecial <init> : (Lcom/etouch/activity/UnityBridgeActivity;Lkotlin/coroutines/Continuation;)V
                        //   50: astore #8
                        //   52: aload #8
                        //   54: getfield result : Ljava/lang/Object;
                        //   57: astore #7
                        //   59: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
                        //   62: astore #9
                        //   64: aload #8
                        //   66: getfield label : I
                        //   69: tableswitch default -> 330, 0 -> 92, 1 -> 306
                        //   92: aload #7
                        //   94: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   97: aload_0
                        //   98: getfield isCoroutineActive : Ljava/util/concurrent/atomic/AtomicBoolean;
                        //   101: invokevirtual get : ()Z
                        //   104: ifeq -> 326
                        //   107: aload_0
                        //   108: getfield isPlaying : Z
                        //   111: ifeq -> 326
                        //   114: aload_0
                        //   115: getfield selectedWaveform : I
                        //   118: istore_2
                        //   119: aload_0
                        //   120: aload_0
                        //   121: getfield selectedSwingPreset : I
                        //   124: invokespecial mapPreset : (I)I
                        //   127: istore_3
                        //   128: aload_0
                        //   129: aload_0
                        //   130: getfield selectedVibrationPreset : I
                        //   133: invokespecial mapPreset : (I)I
                        //   136: istore #4
                        //   138: iconst_0
                        //   139: iload_3
                        //   140: if_icmpgt -> 157
                        //   143: iload_3
                        //   144: bipush #10
                        //   146: if_icmpge -> 153
                        //   149: iconst_1
                        //   150: goto -> 158
                        //   153: iconst_0
                        //   154: goto -> 158
                        //   157: iconst_0
                        //   158: ifeq -> 184
                        //   161: aload_0
                        //   162: aload_0
                        //   163: getfield presetIntensities : Ljava/util/List;
                        //   166: iload_3
                        //   167: invokeinterface get : (I)Ljava/lang/Object;
                        //   172: checkcast java/lang/Number
                        //   175: invokevirtual intValue : ()I
                        //   178: invokevirtual applyIntensity : (I)I
                        //   181: goto -> 196
                        //   184: iload_2
                        //   185: ifne -> 195
                        //   188: aload_0
                        //   189: getfield intensity : I
                        //   192: goto -> 196
                        //   195: iconst_0
                        //   196: istore #5
                        //   198: iconst_0
                        //   199: iload #4
                        //   201: if_icmpgt -> 219
                        //   204: iload #4
                        //   206: bipush #10
                        //   208: if_icmpge -> 215
                        //   211: iconst_1
                        //   212: goto -> 220
                        //   215: iconst_0
                        //   216: goto -> 220
                        //   219: iconst_0
                        //   220: ifeq -> 247
                        //   223: aload_0
                        //   224: aload_0
                        //   225: getfield presetIntensities : Ljava/util/List;
                        //   228: iload #4
                        //   230: invokeinterface get : (I)Ljava/lang/Object;
                        //   235: checkcast java/lang/Number
                        //   238: invokevirtual intValue : ()I
                        //   241: invokevirtual applyIntensity : (I)I
                        //   244: goto -> 260
                        //   247: iload_2
                        //   248: iconst_1
                        //   249: if_icmpne -> 259
                        //   252: aload_0
                        //   253: getfield intensity : I
                        //   256: goto -> 260
                        //   259: iconst_0
                        //   260: istore #6
                        //   262: aload_0
                        //   263: invokevirtual getBluetoothManager : ()Lcom/etouch/bt/BluetoothManager;
                        //   266: iload #5
                        //   268: iload #6
                        //   270: sipush #500
                        //   273: iconst_0
                        //   274: invokevirtual sendVibrationControl : (IIII)V
                        //   277: ldc2_w 500
                        //   280: aload #8
                        //   282: aload #8
                        //   284: aload_0
                        //   285: putfield L$0 : Ljava/lang/Object;
                        //   288: aload #8
                        //   290: iconst_1
                        //   291: putfield label : I
                        //   294: invokestatic delay : (JLkotlin/coroutines/Continuation;)Ljava/lang/Object;
                        //   297: dup
                        //   298: aload #9
                        //   300: if_acmpne -> 322
                        //   303: aload #9
                        //   305: areturn
                        //   306: aload #8
                        //   308: getfield L$0 : Ljava/lang/Object;
                        //   311: checkcast com/etouch/activity/UnityBridgeActivity
                        //   314: astore_0
                        //   315: aload #7
                        //   317: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   320: aload #7
                        //   322: pop
                        //   323: goto -> 97
                        //   326: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                        //   329: areturn
                        //   330: new java/lang/IllegalStateException
                        //   333: dup
                        //   334: ldc_w 'call to 'resume' before 'invoke' with coroutine'
                        //   337: invokespecial <init> : (Ljava/lang/String;)V
                        //   340: athrow
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #2908	-> 62
                        //   #2912	-> 97
                        //   #2913	-> 114
                        //   #2914	-> 119
                        //   #2915	-> 128
                        //   #2923	-> 138
                        //   #2924	-> 161
                        //   #2925	-> 184
                        //   #2926	-> 188
                        //   #2928	-> 195
                        //   #2923	-> 196
                        //   #2932	-> 198
                        //   #2933	-> 223
                        //   #2934	-> 247
                        //   #2935	-> 252
                        //   #2937	-> 259
                        //   #2932	-> 260
                        //   #2946	-> 262
                        //   #2947	-> 266
                        //   #2948	-> 268
                        //   #2949	-> 270
                        //   #2950	-> 273
                        //   #2946	-> 274
                        //   #2953	-> 277
                        //   #2908	-> 303
                        //   #2953	-> 322
                        //   #2955	-> 326
                        //   #2908	-> 330
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   97	209	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                        //   315	11	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                        //   119	104	2	currentWaveform	I
                        //   247	5	2	currentWaveform	I
                        //   128	56	3	mappedSwingPreset	I
                        //   138	109	4	mappedVibrationPreset	I
                        //   198	70	5	swingLevel	I
                        //   262	8	6	vibrationLevel	I
                        //   52	278	8	$continuation	Lkotlin/coroutines/Continuation;
                        //   59	271	7	$result	Ljava/lang/Object; } private final int mapPreset(int preset) { switch (preset) { case -1: case 0: case 1: case 2: case 3:  }  return 0; } private final void stopVibrationTimer() { if (this.analyzeRunnable != null) { Runnable it = this.analyzeRunnable; int $i$a$-let-UnityBridgeActivity$stopVibrationTimer$1 = 0; this.mainHandler.removeCallbacks(it); } else {  }  if (this.sendRunnable != null) { Runnable it = this.sendRunnable; int $i$a$-let-UnityBridgeActivity$stopVibrationTimer$2 = 0;
                        this.mainHandler.removeCallbacks(it);
                    }
     else

                    {
                    }

     this.analyzeRunnable =null;
     this.sendRunnable =null;
     this.waveformStep =0;
                }


                public final void setIntensitLevel ( int selectedWaveform, int level){
                    this.intensityLevel = level;
                }

                public final int applyIntensity ( int sn){
                    switch (this.intensityLevel) {
                        case 0:

                        case 1:

                        case 2:

                    }
                    int result = sn;
                    return RangesKt.coerceIn(result, 0, 100);
                }

                private final void cancelCurrentPlaybackJob () {
                    this.isCoroutineActive.set(false);
                    if (this.currentPlaybackJob != null) {
                        Job.DefaultImpls.cancel$default(this.currentPlaybackJob, null, 1, null);
                    } else {

                    }
                    this.currentPlaybackJob = null;
                }

                public final void release () {
                    cancelCurrentPlaybackJob();
                    CoroutineScopeKt.cancel$default(this.playbackScope, null, 1, null);
                }

                public final int getWaveformValue ( int waveformIndex, long timeMs){
                    int t;
                    List sineValues;
                    Integer[] arrayOfInteger;
                    int index;
                    switch (waveformIndex) {
                        case 0:
                            t = (int) (timeMs % 1500L);
                            return (t < 500) ? 0 : ((t < 1000) ? (int) ((t - 500) * 0.2D) : 100);
                        case 1:
                            t = (int) (timeMs % 2000L);
                            return (t < 1000) ? (int) (50 + t * 0.05D) : (int) ('' - (t - 1000) * 0.05D);
                        case 2:
                            t = (int) (timeMs % 2000L);
                            return (t < 500) ? 0 : 80;
                        case 3:
                            t = (int) (timeMs % 400L);
                            return (t < 200) ? 0 : 80;
                        case 4:
                            arrayOfInteger = new Integer[20];
                            arrayOfInteger[0] = Integer.valueOf(50);
                            arrayOfInteger[1] = Integer.valueOf(65);
                            arrayOfInteger[2] = Integer.valueOf(79);
                            arrayOfInteger[3] = Integer.valueOf(90);
                            arrayOfInteger[4] = Integer.valueOf(97);
                            arrayOfInteger[5] = Integer.valueOf(100);
                            arrayOfInteger[6] = Integer.valueOf(97);
                            arrayOfInteger[7] = Integer.valueOf(90);
                            arrayOfInteger[8] = Integer.valueOf(79);
                            arrayOfInteger[9] = Integer.valueOf(65);
                            arrayOfInteger[10] = Integer.valueOf(50);
                            arrayOfInteger[11] = Integer.valueOf(35);
                            arrayOfInteger[12] = Integer.valueOf(21);
                            arrayOfInteger[13] = Integer.valueOf(10);
                            arrayOfInteger[14] = Integer.valueOf(3);
                            arrayOfInteger[15] = Integer.valueOf(0);
                            arrayOfInteger[16] = Integer.valueOf(3);
                            arrayOfInteger[17] = Integer.valueOf(10);
                            arrayOfInteger[18] = Integer.valueOf(21);
                            arrayOfInteger[19] = Integer.valueOf(35);
                            sineValues = CollectionsKt.listOf((Object[]) arrayOfInteger);
                            index = (int) (timeMs % 1000L / 50L);
                    }
                    return this.intensity;
                }

                public final void sendToBluetoothParameter ( int swingLevel, int vibrationLevel, int duration, int delay)
                {
                    if ((this.currentPlaybackJob != null) ? ((this.currentPlaybackJob.isActive() == true)) : false)
                        if (this.currentPlaybackJob != null) {
                            Job.DefaultImpls.cancel$default(this.currentPlaybackJob, null, 1, null);
                        } else {

                        }
                    getBluetoothManager().sendVibrationControl(swingLevel, vibrationLevel, duration, delay);
                }

                public final void setSystemVolume ( float value){
                    UnityBridgeImpl.INSTANCE.setSystemVolume((Context) this, value);
                }

                public final void getSystemVolume () {
                    SystemVolumeInfo systemVolumeInfo = new SystemVolumeInfo(null, 1, null);
                    float currentVolume = UnityBridgeImpl.INSTANCE.getSystemVolume((Context) this);
                    systemVolumeInfo.setSystemVolume(String.valueOf(currentVolume));
                    UnityPlayer.UnitySendMessage("Boot", "SystemVolume", (new Gson()).toJson(systemVolumeInfo));
                }

                public final void setScreenBrightness ( float percent){
                    // Byte code:
                    //   0: getstatic com/unity3d/player/UnityPlayer.currentActivity : Landroid/app/Activity;
                    //   3: dup
                    //   4: ifnonnull -> 17
                    //   7: pop
                    //   8: aload_0
                    //   9: checkcast com/etouch/activity/UnityBridgeActivity
                    //   12: astore_3
                    //   13: iconst_0
                    //   14: istore #4
                    //   16: return
                    //   17: astore_2
                    //   18: aload_2
                    //   19: fload_1
                    //   20: aload_2
                    //   21: <illegal opcode> run : (FLandroid/app/Activity;)Ljava/lang/Runnable;
                    //   26: invokevirtual runOnUiThread : (Ljava/lang/Runnable;)V
                    //   29: return
                    // Line number table:
                    //   Java source line number -> byte code offset
                    //   #3092	-> 0
                    //   #3094	-> 16
                    //   #3092	-> 0
                    //   #3092	-> 0
                    //   #3098	-> 18
                    //   #3109	-> 29
                    // Local variable table:
                    //   start	length	slot	name	descriptor
                    //   16	1	4	$i$a$-run-UnityBridgeActivity$setScreenBrightness$activity$1	I
                    //   13	4	3	$this$setScreenBrightness_u24lambda_u2445	Lcom/etouch/activity/UnityBridgeActivity;
                    //   18	12	2	activity	Landroid/app/Activity;
                    //   0	30	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                    //   0	30	1	percent	F
                }

                private static final void setScreenBrightness$lambda$46 ( float $percent, Activity $activity){
                    Intrinsics.checkNotNullParameter($activity, "$activity");
                    float clamped = RangesKt.coerceIn($percent, 0.0F, 1.0F);
                    WindowManager.LayoutParams lp = $activity.getWindow().getAttributes();
                    lp.screenBrightness = clamped;
                    $activity.getWindow().setAttributes(lp);
                }

                public final void getScreenBrightness () {
                    ScreenBrightness screenBrightness = new ScreenBrightness(null, 1, null);
                    float currentScreenBrightness = UnityBridgeImpl.INSTANCE.getScreenBrightness((Context) this);
                    screenBrightness.setScreenBrightness(String.valueOf(currentScreenBrightness));
                    UnityPlayer.UnitySendMessage("Boot", "ScreenBrightness", (new Gson()).toJson(screenBrightness));
                }

                public final void qrCodeScan () {
                    if (ContextCompat.checkSelfPermission((Context) this, "android.permission.CAMERA") != 0) {
                        String[] arrayOfString = new String[1];
                        arrayOfString[0] = "android.permission.CAMERA";
                        ActivityCompat.requestPermissions((Activity) this, arrayOfString, this.REQUEST_CODE_CAMERA);
                    } else {
                        Intent intent = new Intent((Context) this, QRScanActivity.class);
                        startActivityForResult(intent, 49374);
                    }
                }

                public final void updatePlayCoroutine ( int newSelectedWaveform, int newSelectedSwingPreset,
                int newSelectedVibrationPreset){
                    this.selectedWaveform = newSelectedWaveform;
                    this.selectedSwingPreset = newSelectedSwingPreset;
                    this.selectedVibrationPreset = newSelectedVibrationPreset;
                }

                private final void startPlay ( int swingLevel, int vibrationLevel, int duration, int delay){
                    if ((this.currentPlaybackJob != null) ? ((this.currentPlaybackJob.isActive() == true)) : false)
                        return;
                    this.isCoroutineActive.set(true);
                    Job job1 = BuildersKt.launch$default(this.playbackScope, null, null, new UnityBridgeActivity$startPlay$1(swingLevel, vibrationLevel, duration, delay, null), 3, null);
                    Job job2 = job1;
                    UnityBridgeActivity unityBridgeActivity = this;
                    int $i$a$ -apply - UnityBridgeActivity$startPlay$2 = 0;
                    job2.invokeOnCompletion(new UnityBridgeActivity$startPlay$2$1());
                    unityBridgeActivity.currentPlaybackJob = job1;
                }

                @DebugMetadata(f = "UnityBridgeActivity.kt", l = {3160}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.activity.UnityBridgeActivity$startPlay$1")
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
                static final class UnityBridgeActivity$startPlay$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
                    int label;

                    UnityBridgeActivity$startPlay$1(int $swingLevel, int $vibrationLevel, int $duration, int $delay, Continuation $completion) {
                        super(2, $completion);
                    }

                    @Nullable
                    public final Object invokeSuspend(@NotNull Object $result) {
                        Object object = IntrinsicsKt.getCOROUTINE_SUSPENDED();
                        switch (this.label) {
                            case 0:
                                ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                                this.label = 1;
                                if (UnityBridgeActivity.this.playCoreLoop(this.$swingLevel, this.$vibrationLevel, this.$duration, this.$delay, (Continuation) this) == object)
                                    return object;
                                UnityBridgeActivity.this.playCoreLoop(this.$swingLevel, this.$vibrationLevel, this.$duration, this.$delay, (Continuation) this);
                                return Unit.INSTANCE;
                            case 1:
                                ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                                return Unit.INSTANCE;
                        }
                        throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                    }

                    @NotNull
                    public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeActivity$startPlay$1> $completion) {
                        return (Continuation<Unit>) new UnityBridgeActivity$startPlay$1(this.$swingLevel, this.$vibrationLevel, this.$duration, this.$delay, $completion);
                    }

                    @Nullable
                    public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                        return ((UnityBridgeActivity$startPlay$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
                    }
                }

                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\002\n\000\n\002\020\003\n\000\020\000\032\0020\0012\b\020\002\032\004\030\0010\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "it", "", "invoke"})
                static final class UnityBridgeActivity$startPlay$2$1 extends Lambda implements Function1<Throwable, Unit> {
                    public final void invoke(@Nullable Throwable it) {
                        UnityBridgeActivity.this.isCoroutineActive.set(false);
                        if (!(it instanceof java.util.concurrent.CancellationException))
                            UnityBridgeActivity.this.getBluetoothManager().sendVibrationControl(0, 0, 0, 0);
                    }

                    UnityBridgeActivity$startPlay$2$1() {
                        super(1);
                    }
                }

                private final Object playCoreLoop ( int swingLevel, int vibrationLevel, int duration,
                int delay, Continuation<?super Unit > paramContinuation){
                    // Byte code:
                    //   0: aload #5
                    //   2: instanceof com/etouch/activity/UnityBridgeActivity$playCoreLoop$1
                    //   5: ifeq -> 43
                    //   8: aload #5
                    //   10: checkcast com/etouch/activity/UnityBridgeActivity$playCoreLoop$1
                    //   13: astore #7
                    //   15: aload #7
                    //   17: getfield label : I
                    //   20: ldc_w -2147483648
                    //   23: iand
                    //   24: ifeq -> 43
                    //   27: aload #7
                    //   29: dup
                    //   30: getfield label : I
                    //   33: ldc_w -2147483648
                    //   36: isub
                    //   37: putfield label : I
                    //   40: goto -> 55
                    //   43: new com/etouch/activity/UnityBridgeActivity$playCoreLoop$1
                    //   46: dup
                    //   47: aload_0
                    //   48: aload #5
                    //   50: invokespecial <init> : (Lcom/etouch/activity/UnityBridgeActivity;Lkotlin/coroutines/Continuation;)V
                    //   53: astore #7
                    //   55: aload #7
                    //   57: getfield result : Ljava/lang/Object;
                    //   60: astore #6
                    //   62: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
                    //   65: astore #8
                    //   67: aload #7
                    //   69: getfield label : I
                    //   72: tableswitch default -> 226, 0 -> 96, 1 -> 177
                    //   96: aload #6
                    //   98: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                    //   101: aload_0
                    //   102: getfield isCoroutineActive : Ljava/util/concurrent/atomic/AtomicBoolean;
                    //   105: invokevirtual get : ()Z
                    //   108: ifeq -> 222
                    //   111: aload_0
                    //   112: invokevirtual getBluetoothManager : ()Lcom/etouch/bt/BluetoothManager;
                    //   115: iload_1
                    //   116: iload_2
                    //   117: iload_3
                    //   118: iload #4
                    //   120: invokevirtual sendVibrationControl : (IIII)V
                    //   123: ldc2_w 500
                    //   126: aload #7
                    //   128: aload #7
                    //   130: aload_0
                    //   131: putfield L$0 : Ljava/lang/Object;
                    /*      */     //   134: aload #7
                    /*      */     //   136: iload_1
                    /*      */     //   137: putfield I$0 : I
                    /*      */     //   140: aload #7
                    /*      */     //   142: iload_2
                    /*      */     //   143: putfield I$1 : I
                    /*      */     //   146: aload #7
                    /*      */     //   148: iload_3
                    /*      */     //   149: putfield I$2 : I
                    /*      */     //   152: aload #7
                    /*      */     //   154: iload #4
                    /*      */     //   156: putfield I$3 : I
                    /*      */     //   159: aload #7
                    /*      */     //   161: iconst_1
                    /*      */     //   162: putfield label : I
                    /*      */     //   165: invokestatic delay : (JLkotlin/coroutines/Continuation;)Ljava/lang/Object;
                    /*      */     //   168: dup
                    /*      */     //   169: aload #8
                    /*      */     //   171: if_acmpne -> 218
                    /*      */     //   174: aload #8
                    /*      */     //   176: areturn
                    /*      */     //   177: aload #7
                    /*      */     //   179: getfield I$3 : I
                    /*      */     //   182: istore #4
                    /*      */     //   184: aload #7
                    /*      */     //   186: getfield I$2 : I
                    /*      */     //   189: istore_3
                    /*      */     //   190: aload #7
                    /*      */     //   192: getfield I$1 : I
                    /*      */     //   195: istore_2
                    /*      */     //   196: aload #7
                    /*      */     //   198: getfield I$0 : I
                    /*      */     //   201: istore_1
                    /*      */     //   202: aload #7
                    /*      */     //   204: getfield L$0 : Ljava/lang/Object;
                    /*      */     //   207: checkcast com/etouch/activity/UnityBridgeActivity
                    /*      */     //   210: astore_0
                    /*      */     //   211: aload #6
                    /*      */     //   213: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                    /*      */     //   216: aload #6
                    /*      */     //   218: pop
                    /*      */     //   219: goto -> 101
                    /*      */     //   222: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                    /*      */     //   225: areturn
                    /*      */     //   226: new java/lang/IllegalStateException
                    /*      */     //   229: dup
                    /*      */     //   230: ldc_w 'call to 'resume' before 'invoke' with coroutine'
                    /*      */     //   233: invokespecial <init> : (Ljava/lang/String;)V
                    /*      */     //   236: athrow
                    /*      */     // Line number table:
                    /*      */     //   Java source line number -> byte code offset
                    /*      */     //   #3172	-> 65
                    /*      */     //   #3180	-> 101
                    /*      */     //   #3182	-> 111
                    /*      */     //   #3183	-> 115
                    /*      */     //   #3184	-> 116
                    /*      */     //   #3185	-> 117
                    /*      */     //   #3186	-> 118
                    /*      */     //   #3182	-> 120
                    /*      */     //   #3189	-> 123
                    /*      */     //   #3172	-> 174
                    /*      */     //   #3189	-> 218
                    /*      */     //   #3191	-> 222
                    /*      */     //   #3172	-> 226
                    /*      */     // Local variable table:
                    /*      */     //   start	length	slot	name	descriptor
                    /*      */     //   101	76	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                    /*      */     //   211	15	0	this	Lcom/etouch/activity/UnityBridgeActivity;
                    /*      */     //   101	76	1	swingLevel	I
                    /*      */     //   202	24	1	swingLevel	I
                    /*      */     //   101	76	2	vibrationLevel	I
                    /*      */     //   196	30	2	vibrationLevel	I
                    /*      */     //   101	76	3	duration	I
                    /*      */     //   190	36	3	duration	I
                    /*      */     //   101	76	4	delay	I
                    /*      */     //   184	42	4	delay	I
                    /*      */     //   55	171	7	$continuation	Lkotlin/coroutines/Continuation;
                    /*      */     //   62	164	6	$result	Ljava/lang/Object;
                    /*      */
                }
                /*      */
                /*      */
                protected void onResume () {
                    /*      */
                    super.onResume();
                    /*      */
                    if (this.unityPlayer != null) {
                        /*      */
                        this.unityPlayer.resume();
                        /*      */
                    } else {
                        /*      */
                        /*      */
                    }
                    /*      */
                    if (this.pendingStartScan) {
                        /*      */
                        this.pendingStartScan = false;
                        /*      */
                        BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
                        /*      */
                        if (adapter != null && adapter.isEnabled()) {
                            /*      */
                            this.isScanning = true;
                            /*      */
                            getBluetoothManager().startScanning();
                            /*      */
                        }
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                protected void onPause () {
                    /*      */
                    super.onPause();
                    /*      */
                    if (this.unityPlayer != null) {
                        /*      */
                        this.unityPlayer.pause();
                        /*      */
                    } else {
                        /*      */
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                private final void stopForegroundService () {
                    /*      */
                    try {
                        /*      */
                        Intent intent = new Intent((Context) this, MusicService.class);
                        /*      */
                        stopService(intent);
                        /*      */
                        if (this.musicService != null) {
                            /*      */
                            Intrinsics.checkNotNull(this.musicService);
                            /*      */
                            this.musicService.stopForeground(1);
                            /*      */
                            Intrinsics.checkNotNull(this.musicService);
                            /*      */
                            this.musicService.stopSelf();
                            /*      */
                        }
                        /*      */
                    } catch (Exception exception) {
                    }
                    /*      */
                }
                /*      */
                /*      */
                protected void onDestroy () {
                    /*      */
                    super.onDestroy();
                    /*      */
                    getBluetoothManager().disconnect();
                    /*      */
                    getBluetoothManager().cleanup();
                    /*      */
                    CoroutineScopeKt.cancel$default(getActivityCoroutineScope(), null, 1, null);
                    /*      */
                    if (this.bound) {
                        /*      */
                        unbindService(this.connection);
                        /*      */
                        this.bound = false;
                        /*      */
                    }
                    /*      */
                    this.pendingPlayTask = null;
                    /*      */
                    this.pendingSetPlaylistTask = null;
                    /*      */
                    stopForegroundService();
                    /*      */
                    if (this.bound) {
                        /*      */
                        unbindService(this.connection);
                        /*      */
                        this.bound = false;
                        /*      */
                    }
                    /*      */
                    if (this.unityPlayer != null) {
                        /*      */
                        this.unityPlayer.quit();
                        /*      */
                    } else {
                        /*      */
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                public void onConfigurationChanged (@NotNull Configuration newConfig){
                    /*      */
                    Intrinsics.checkNotNullParameter(newConfig, "newConfig");
                    /*      */
                    super.onConfigurationChanged(newConfig);
                    /*      */
                    if (this.unityPlayer != null) {
                        /*      */
                        this.unityPlayer.configurationChanged(newConfig);
                        /*      */
                    } else {
                        /*      */
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                public void onWindowFocusChanged ( boolean hasFocus){
                    /*      */
                    super.onWindowFocusChanged(hasFocus);
                    /*      */
                    if (this.unityPlayer != null) {
                        /*      */
                        this.unityPlayer.windowFocusChanged(hasFocus);
                        /*      */
                    } else {
                        /*      */
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                public final void updateAudioEnergy ( int value){
                    /*      */
                    int v = applyIntensity(value);
                    /*      */
                    getBluetoothManager().sendVibrationControl(v, v, 50, 0);
                    /*      */
                }
                /*      */
                /*      */
                public final void audioPlayerReciveEquipmentControlData (@NotNull String json){
                    /*      */
                    Intrinsics.checkNotNullParameter(json, "json");
                    /*      */
                    try {
                        /*      */
                        ReciveEquipmentControlData equipmentControlData = (ReciveEquipmentControlData) (new Gson()).fromJson(json, ReciveEquipmentControlData.class);
                        /*      */
                        this.cachedEquipmentData = equipmentControlData;
                        /*      */
                        if (this.audioEnergyStream == null)
                            /*      */ this.audioEnergyStream = new AudioEnergyStream(44100);
                        /*      */
                        equipmentControlData.getSwingIntensity();
                        /*      */
                        int swingIntensity = (equipmentControlData.getSwingIntensity() != null) ? equipmentControlData.getSwingIntensity().intValue() : 0;
                        /*      */
                        equipmentControlData.getVibrationIntensity();
                        /*      */
                        int vibrationIntensity = (equipmentControlData.getVibrationIntensity() != null) ? equipmentControlData.getVibrationIntensity().intValue() : 0;
                        /*      */
                        if (swingIntensity == 0 && vibrationIntensity == 0) {
                            /*      */
                            this.stopRequested = true;
                            /*      */
                            return;
                            /*      */
                        }
                        /*      */
                        this.stopRequested = false;
                        /*      */
                        this.deviceStopped = false;
                        /*      */
                        this.waveformStep = 0;
                        /*      */
                        if (this.controlRunnable != null)
                            /*      */ return;
                        /*      */
                        this.lastSendTime = System.currentTimeMillis();
                        /*      */
                        this.controlRunnable = new UnityBridgeActivity$audioPlayerReciveEquipmentControlData$1();
                        /*      */
                        Intrinsics.checkNotNull(this.controlRunnable);
                        /*      */
                        this.mainHandler.post(this.controlRunnable);
                        /*      */
                    } catch (Exception exception) {
                    }
                    /*      */
                }
                /*      */
                /*      */
                @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\021\n\000\n\002\030\002\n\000\n\002\020\002\n\000*\001\000\b\n\030\0002\0020\001J\b\020\002\032\0020\003H\026¨\006\004"}, d2 = {"com/etouch/activity/UnityBridgeActivity$audioPlayerReciveEquipmentControlData$1", "Ljava/lang/Runnable;", "run", "", "sdk_android_unity_bridge_v1_debug"})
                /*      */ public static final class UnityBridgeActivity$audioPlayerReciveEquipmentControlData$1 implements Runnable {
                    /*      */
                    public void run() {
                        /*      */       // Byte code:
                        /*      */       //   0: aload_0
                        /*      */       //   1: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   4: invokestatic access$getBound$p : (Lcom/etouch/activity/UnityBridgeActivity;)Z
                        /*      */       //   7: ifeq -> 30
                        /*      */       //   10: aload_0
                        /*      */       //   11: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   14: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   17: ifnull -> 30
                        /*      */       //   20: aload_0
                        /*      */       //   21: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   24: invokestatic access$getAudioEnergyStream$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/AudioEnergyStream;
                        /*      */       //   27: ifnonnull -> 38
                        /*      */       //   30: aload_0
                        /*      */       //   31: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   34: invokestatic access$stopControlLoop : (Lcom/etouch/activity/UnityBridgeActivity;)V
                        /*      */       //   37: return
                        /*      */       //   38: nop
                        /*      */       //   39: aload_0
                        /*      */       //   40: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   43: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   46: dup
                        /*      */       //   47: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   50: invokevirtual getTimes : ()Ljava/lang/Integer;
                        /*      */       //   53: iconst_m1
                        /*      */       //   54: istore_1
                        /*      */       //   55: dup
                        /*      */       //   56: ifnonnull -> 63
                        /*      */       //   59: pop
                        /*      */       //   60: goto -> 360
                        /*      */       //   63: invokevirtual intValue : ()I
                        /*      */       //   66: iload_1
                        /*      */       //   67: if_icmpne -> 360
                        /*      */       //   70: aload_0
                        /*      */       //   71: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   74: invokestatic access$getMusicService$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/service/MusicService;
                        /*      */       //   77: dup
                        /*      */       //   78: ifnull -> 87
                        /*      */       //   81: invokevirtual getPCMData : ()Ljava/lang/String;
                        /*      */       //   84: goto -> 89
                        /*      */       //   87: pop
                        /*      */       //   88: aconst_null
                        /*      */       //   89: astore_1
                        /*      */       //   90: aload_1
                        /*      */       //   91: checkcast java/lang/CharSequence
                        /*      */       //   94: astore_2
                        /*      */       //   95: aload_2
                        /*      */       //   96: ifnull -> 108
                        /*      */       //   99: aload_2
                        /*      */       //   100: invokeinterface length : ()I
                        /*      */       //   105: ifne -> 112
                        /*      */       //   108: iconst_1
                        /*      */       //   109: goto -> 113
                        /*      */       //   112: iconst_0
                        /*      */       //   113: ifne -> 565
                        /*      */       //   116: new com/google/gson/Gson
                        /*      */       //   119: dup
                        /*      */       //   120: invokespecial <init> : ()V
                        /*      */       //   123: aload_1
                        /*      */       //   124: ldc com/etouch/PCMData
                        /*      */       //   126: invokevirtual fromJson : (Ljava/lang/String;Ljava/lang/Class;)Ljava/lang/Object;
                        /*      */       //   129: checkcast com/etouch/PCMData
                        /*      */       //   132: astore_2
                        /*      */       //   133: aload_2
                        /*      */       //   134: invokevirtual getPcmData : ()[F
                        /*      */       //   137: ifnull -> 565
                        /*      */       //   140: aload_2
                        /*      */       //   141: invokevirtual getSize : ()Ljava/lang/Integer;
                        /*      */       //   144: ifnull -> 565
                        /*      */       //   147: aload_2
                        /*      */       //   148: invokevirtual getSize : ()Ljava/lang/Integer;
                        /*      */       //   151: dup
                        /*      */       //   152: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   155: invokevirtual intValue : ()I
                        /*      */       //   158: ifle -> 565
                        /*      */       //   161: aload_0
                        /*      */       //   162: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   165: invokestatic access$getAudioEnergyStream$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/AudioEnergyStream;
                        /*      */       //   168: dup
                        /*      */       //   169: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   172: aload_2
                        /*      */       //   173: invokevirtual getPcmData : ()[F
                        /*      */       //   176: aload_2
                        /*      */       //   177: invokevirtual getSize : ()Ljava/lang/Integer;
                        /*      */       //   180: dup
                        /*      */       //   181: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   184: invokevirtual intValue : ()I
                        /*      */       //   187: aload_0
                        /*      */       //   188: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   191: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   194: dup
                        /*      */       //   195: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   198: invokevirtual getSwingWaveformIndex : ()Ljava/lang/Integer;
                        /*      */       //   201: dup
                        /*      */       //   202: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   205: invokevirtual intValue : ()I
                        /*      */       //   208: aload_0
                        /*      */       //   209: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   212: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   215: dup
                        /*      */       //   216: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   219: invokevirtual getVibrationWaveformIndex : ()Ljava/lang/Integer;
                        /*      */       //   222: dup
                        /*      */       //   223: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   226: invokevirtual intValue : ()I
                        /*      */       //   229: aload_0
                        /*      */       //   230: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   233: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   236: dup
                        /*      */       //   237: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   240: invokevirtual getSwingIntensity : ()Ljava/lang/Integer;
                        /*      */       //   243: dup
                        /*      */       //   244: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   247: invokevirtual intValue : ()I
                        /*      */       //   250: aload_0
                        /*      */       //   251: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   254: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   257: dup
                        /*      */       //   258: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   261: invokevirtual getVibrationIntensity : ()Ljava/lang/Integer;
                        /*      */       //   264: dup
                        /*      */       //   265: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   268: invokevirtual intValue : ()I
                        /*      */       //   271: aload_0
                        /*      */       //   272: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   275: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   278: dup
                        /*      */       //   279: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   282: invokevirtual getSwingWaveformArray : ()[I
                        /*      */       //   285: aload_0
                        /*      */       //   286: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   289: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   292: dup
                        /*      */       //   293: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   296: invokevirtual getVibrationWaveformArray : ()[I
                        /*      */       //   299: invokevirtual processInterleaved : ([FIIIII[I[I)Lcom/etouch/AudioEnergyResult;
                        /*      */       //   302: astore_3
                        /*      */       //   303: aload_3
                        /*      */       //   304: dup
                        /*      */       //   305: ifnull -> 355
                        /*      */       //   308: astore #4
                        /*      */       //   310: aload_0
                        /*      */       //   311: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   314: astore #5
                        /*      */       //   316: aload #4
                        /*      */       //   318: astore #6
                        /*      */       //   320: iconst_0
                        /*      */       //   321: istore #7
                        /*      */       //   323: aload #5
                        /*      */       //   325: aload #6
                        /*      */       //   327: getfield swingLevel : I
                        /*      */       //   330: invokestatic access$setLatestSwing$p : (Lcom/etouch/activity/UnityBridgeActivity;I)V
                        /*      */       //   333: aload #5
                        /*      */       //   335: aload #6
                        /*      */       //   337: getfield vibrationLevel : I
                        /*      */       //   340: invokestatic access$setLatestVibration$p : (Lcom/etouch/activity/UnityBridgeActivity;I)V
                        /*      */       //   343: aload #5
                        /*      */       //   345: sipush #500
                        /*      */       //   348: invokestatic access$setLatestDuration$p : (Lcom/etouch/activity/UnityBridgeActivity;I)V
                        /*      */       //   351: nop
                        /*      */       //   352: goto -> 565
                        /*      */       //   355: pop
                        /*      */       //   356: nop
                        /*      */       //   357: goto -> 565
                        /*      */       //   360: aload_0
                        /*      */       //   361: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   364: invokestatic access$getAudioEnergyStream$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/AudioEnergyStream;
                        /*      */       //   367: dup
                        /*      */       //   368: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   371: aload_0
                        /*      */       //   372: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   375: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   378: dup
                        /*      */       //   379: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   382: invokevirtual getSwingWaveformIndex : ()Ljava/lang/Integer;
                        /*      */       //   385: dup
                        /*      */       //   386: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   389: invokevirtual intValue : ()I
                        /*      */       //   392: aload_0
                        /*      */       //   393: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   396: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   399: dup
                        /*      */       //   400: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   403: invokevirtual getVibrationWaveformIndex : ()Ljava/lang/Integer;
                        /*      */       //   406: dup
                        /*      */       //   407: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   410: invokevirtual intValue : ()I
                        /*      */       //   413: aload_0
                        /*      */       //   414: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   417: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   420: dup
                        /*      */       //   421: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   424: invokevirtual getSwingIntensity : ()Ljava/lang/Integer;
                        /*      */       //   427: dup
                        /*      */       //   428: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   431: invokevirtual intValue : ()I
                        /*      */       //   434: aload_0
                        /*      */       //   435: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   438: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   441: dup
                        /*      */       //   442: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   445: invokevirtual getVibrationIntensity : ()Ljava/lang/Integer;
                        /*      */       //   448: dup
                        /*      */       //   449: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   452: invokevirtual intValue : ()I
                        /*      */       //   455: aload_0
                        /*      */       //   456: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   459: invokestatic access$getWaveformStep$p : (Lcom/etouch/activity/UnityBridgeActivity;)I
                        /*      */       //   462: aload_0
                        /*      */       //   463: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   466: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   469: dup
                        /*      */       //   470: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   473: invokevirtual getSwingWaveformArray : ()[I
                        /*      */       //   476: aload_0
                        /*      */       //   477: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   480: invokestatic access$getCachedEquipmentData$p : (Lcom/etouch/activity/UnityBridgeActivity;)Lcom/etouch/ReciveEquipmentControlData;
                        /*      */       //   483: dup
                        /*      */       //   484: invokestatic checkNotNull : (Ljava/lang/Object;)V
                        /*      */       //   487: invokevirtual getVibrationWaveformArray : ()[I
                        /*      */       //   490: invokevirtual computeWaveformStep : (IIIII[I[I)Lcom/etouch/WaveformComputeResult;
                        /*      */       //   493: astore_1
                        /*      */       //   494: aload_0
                        /*      */       //   495: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   498: astore_2
                        /*      */       //   499: aload_2
                        /*      */       //   500: invokestatic access$getWaveformStep$p : (Lcom/etouch/activity/UnityBridgeActivity;)I
                        /*      */       //   503: istore_3
                        /*      */       //   504: aload_2
                        /*      */       //   505: iload_3
                        /*      */       //   506: iconst_1
                        /*      */       //   507: iadd
                        /*      */       //   508: invokestatic access$setWaveformStep$p : (Lcom/etouch/activity/UnityBridgeActivity;I)V
                        /*      */       //   511: aload_1
                        /*      */       //   512: dup
                        /*      */       //   513: ifnull -> 559
                        /*      */       //   516: astore_2
                        /*      */       //   517: aload_0
                        /*      */       //   518: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   521: astore_3
                        /*      */       //   522: aload_2
                        /*      */       //   523: astore #4
                        /*      */       //   525: iconst_0
                        /*      */       //   526: istore #5
                        /*      */       //   528: aload_3
                        /*      */       //   529: aload #4
                        /*      */       //   531: getfield swing : I
                        /*      */       //   534: invokestatic access$setLatestSwing$p : (Lcom/etouch/activity/UnityBridgeActivity;I)V
                        /*      */       //   537: aload_3
                        /*      */       //   538: aload #4
                        /*      */       //   540: getfield vibration : I
                        /*      */       //   543: invokestatic access$setLatestVibration$p : (Lcom/etouch/activity/UnityBridgeActivity;I)V
                        /*      */       //   546: aload_3
                        /*      */       //   547: aload #4
                        /*      */       //   549: getfield duration : I
                        /*      */       //   552: invokestatic access$setLatestDuration$p : (Lcom/etouch/activity/UnityBridgeActivity;I)V
                        /*      */       //   555: nop
                        /*      */       //   556: goto -> 565
                        /*      */       //   559: pop
                        /*      */       //   560: nop
                        /*      */       //   561: goto -> 565
                        /*      */       //   564: astore_1
                        /*      */       //   565: invokestatic currentTimeMillis : ()J
                        /*      */       //   568: lstore_1
                        /*      */       //   569: lload_1
                        /*      */       //   570: aload_0
                        /*      */       //   571: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   574: invokestatic access$getLastSendTime$p : (Lcom/etouch/activity/UnityBridgeActivity;)J
                        /*      */       //   577: lsub
                        /*      */       //   578: aload_0
                        /*      */       //   579: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   582: invokestatic access$getIntervalMs$p : (Lcom/etouch/activity/UnityBridgeActivity;)J
                        /*      */       //   585: lcmp
                        /*      */       //   586: iflt -> 684
                        /*      */       //   589: aload_0
                        /*      */       //   590: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   593: lload_1
                        /*      */       //   594: invokestatic access$setLastSendTime$p : (Lcom/etouch/activity/UnityBridgeActivity;J)V
                        /*      */       //   597: aload_0
                        /*      */       //   598: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   601: invokestatic access$getStopRequested$p : (Lcom/etouch/activity/UnityBridgeActivity;)Z
                        /*      */       //   604: ifeq -> 645
                        /*      */       //   607: aload_0
                        /*      */       //   608: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   611: invokevirtual getBluetoothManager : ()Lcom/etouch/bt/BluetoothManager;
                        /*      */       //   614: iconst_0
                        /*      */       //   615: iconst_0
                        /*      */       //   616: iconst_0
                        /*      */       //   617: iconst_0
                        /*      */       //   618: invokevirtual sendVibrationControl : (IIII)V
                        /*      */       //   621: aload_0
                        /*      */       //   622: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   625: iconst_0
                        /*      */       //   626: invokestatic access$setStopRequested$p : (Lcom/etouch/activity/UnityBridgeActivity;Z)V
                        /*      */       //   629: aload_0
                        /*      */       //   630: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   633: iconst_1
                        /*      */       //   634: invokestatic access$setDeviceStopped$p : (Lcom/etouch/activity/UnityBridgeActivity;Z)V
                        /*      */       //   637: aload_0
                        /*      */       //   638: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   641: invokestatic access$stopControlLoop : (Lcom/etouch/activity/UnityBridgeActivity;)V
                        /*      */       //   644: return
                        /*      */       //   645: aload_0
                        /*      */       //   646: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   649: invokevirtual getBluetoothManager : ()Lcom/etouch/bt/BluetoothManager;
                        /*      */       //   652: aload_0
                        /*      */       //   653: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   656: invokestatic access$getLatestSwing$p : (Lcom/etouch/activity/UnityBridgeActivity;)I
                        /*      */       //   659: aload_0
                        /*      */       //   660: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   663: invokestatic access$getLatestVibration$p : (Lcom/etouch/activity/UnityBridgeActivity;)I
                        /*      */       //   666: aload_0
                        /*      */       //   667: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   670: invokestatic access$getLatestDuration$p : (Lcom/etouch/activity/UnityBridgeActivity;)I
                        /*      */       //   673: aload_0
                        /*      */       //   674: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   677: invokestatic access$getIntervalMs$p : (Lcom/etouch/activity/UnityBridgeActivity;)J
                        /*      */       //   680: l2i
                        /*      */       //   681: invokevirtual sendVibrationControl : (IIII)V
                        /*      */       //   684: aload_0
                        /*      */       //   685: getfield this$0 : Lcom/etouch/activity/UnityBridgeActivity;
                        /*      */       //   688: invokestatic access$getMainHandler$p : (Lcom/etouch/activity/UnityBridgeActivity;)Landroid/os/Handler;
                        /*      */       //   691: aload_0
                        /*      */       //   692: checkcast java/lang/Runnable
                        /*      */       //   695: ldc2_w 20
                        /*      */       //   698: invokevirtual postDelayed : (Ljava/lang/Runnable;J)Z
                        /*      */       //   701: pop
                        /*      */       //   702: return
                        /*      */       // Line number table:
                        /*      */       //   Java source line number -> byte code offset
                        /*      */       //   #3349	-> 0
                        /*      */       //   #3350	-> 30
                        /*      */       //   #3351	-> 37
                        /*      */       //   #3354	-> 38
                        /*      */       //   #3359	-> 39
                        /*      */       //   #3361	-> 70
                        /*      */       //   #3363	-> 90
                        /*      */       //   #3363	-> 113
                        /*      */       //   #3366	-> 116
                        /*      */       //   #3365	-> 132
                        /*      */       //   #3368	-> 133
                        /*      */       //   #3369	-> 140
                        /*      */       //   #3370	-> 147
                        /*      */       //   #3374	-> 161
                        /*      */       //   #3375	-> 172
                        /*      */       //   #3376	-> 176
                        /*      */       //   #3377	-> 187
                        /*      */       //   #3378	-> 208
                        /*      */       //   #3379	-> 229
                        /*      */       //   #3380	-> 250
                        /*      */       //   #3381	-> 271
                        /*      */       //   #3382	-> 285
                        /*      */       //   #3374	-> 299
                        /*      */       //   #3373	-> 302
                        /*      */       //   #3385	-> 303
                        /*      */       //   #3386	-> 323
                        /*      */       //   #3387	-> 333
                        /*      */       //   #3388	-> 343
                        /*      */       //   #3389	-> 351
                        /*      */       //   #3385	-> 352
                        /*      */       //   #3385	-> 355
                        /*      */       //   #3396	-> 360
                        /*      */       //   #3397	-> 371
                        /*      */       //   #3398	-> 392
                        /*      */       //   #3399	-> 413
                        /*      */       //   #3400	-> 434
                        /*      */       //   #3401	-> 455
                        /*      */       //   #3402	-> 462
                        /*      */       //   #3403	-> 476
                        /*      */       //   #3396	-> 490
                        /*      */       //   #3395	-> 493
                        /*      */       //   #3406	-> 494
                        /*      */       //   #3408	-> 511
                        /*      */       //   #3409	-> 528
                        /*      */       //   #3410	-> 537
                        /*      */       //   #3411	-> 546
                        /*      */       //   #3412	-> 555
                        /*      */       //   #3408	-> 556
                        /*      */       //   #3408	-> 559
                        /*      */       //   #3415	-> 564
                        /*      */       //   #3422	-> 565
                        /*      */       //   #3424	-> 569
                        /*      */       //   #3426	-> 589
                        /*      */       //   #3428	-> 597
                        /*      */       //   #3430	-> 607
                        /*      */       //   #3433	-> 621
                        /*      */       //   #3434	-> 629
                        /*      */       //   #3435	-> 637
                        /*      */       //   #3436	-> 644
                        /*      */       //   #3439	-> 645
                        /*      */       //   #3440	-> 652
                        /*      */       //   #3441	-> 659
                        /*      */       //   #3442	-> 666
                        /*      */       //   #3443	-> 673
                        /*      */       //   #3439	-> 681
                        /*      */       //   #3447	-> 684
                        /*      */       //   #3448	-> 702
                        /*      */       // Local variable table:
                        /*      */       //   start	length	slot	name	descriptor
                        /*      */       //   323	29	7	$i$a$-let-UnityBridgeActivity$audioPlayerReciveEquipmentControlData$1$run$1	I
                        /*      */       //   320	32	6	it	Lcom/etouch/AudioEnergyResult;
                        /*      */       //   303	54	3	result	Lcom/etouch/AudioEnergyResult;
                        /*      */       //   133	224	2	pcmData	Lcom/etouch/PCMData;
                        /*      */       //   90	267	1	pcmJson	Ljava/lang/String;
                        /*      */       //   528	28	5	$i$a$-let-UnityBridgeActivity$audioPlayerReciveEquipmentControlData$1$run$2	I
                        /*      */       //   525	31	4	it	Lcom/etouch/WaveformComputeResult;
                        /*      */       //   494	67	1	result	Lcom/etouch/WaveformComputeResult;
                        /*      */       //   569	134	1	now	J
                        /*      */       //   0	703	0	this	Lcom/etouch/activity/UnityBridgeActivity$audioPlayerReciveEquipmentControlData$1;
                        /*      */       // Exception table:
                        /*      */       //   from	to	target	type
                        /*      */       //   38	561	564	java/lang/Exception
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                private final void stopControlLoop () {
                    /*      */
                    Runnable it = this.controlRunnable;
                    /*      */
                    int $i$a$ -let - UnityBridgeActivity$stopControlLoop$1 = 0;
                    /*      */
                    this.mainHandler.removeCallbacks(it);
                    /*      */
                    this.controlRunnable = null;
                    /*      */
                }
                /*      */
                /*      */
                private final void postNextRunnable () {
                    /*      */
                    if (this.vibrationRunnable != null) {
                        /*      */
                        Runnable it = this.vibrationRunnable;
                        /*      */
                        int $i$a$ -let - UnityBridgeActivity$postNextRunnable$1 = 0;
                        /*      */
                        this.mainHandler.postDelayed(it, 250L);
                        /*      */
                    } else {
                        /*      */
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                public final void openAppSet () {
                    /*      */
                    Intent bluetoothIntent = new Intent("android.settings.BLUETOOTH_SETTINGS");
                    /*      */
                    if (bluetoothIntent.resolveActivity(getPackageManager()) != null) {
                        /*      */
                        startActivity(bluetoothIntent);
                        /*      */
                    } else {
                        /*      */
                        Intent fallbackIntent = new Intent("android.settings.SETTINGS");
                        /*      */
                        startActivity(fallbackIntent);
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                @DebugMetadata(f = "UnityBridgeActivity.kt", l = {3189}, i = {0, 0, 0, 0, 0}, s = {"L$0", "I$0", "I$1", "I$2", "I$3"}, n = {"this", "swingLevel", "vibrationLevel", "duration", "delay"}, m = "playCoreLoop", c = "com.etouch.activity.UnityBridgeActivity")
                /*      */
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48)
                /*      */ static final class UnityBridgeActivity$playCoreLoop$1 extends ContinuationImpl {
                    /*      */ Object L$0;
                    /*      */ int I$0;
                    /*      */ int I$1;
                    /*      */ int I$2;
                    /*      */ int I$3;
                    /*      */ int label;

                    /*      */
                    /*      */     UnityBridgeActivity$playCoreLoop$1(Continuation $completion) {
                        /*      */
                        super($completion);
                        /*      */
                    }

                    /*      */
                    /*      */
                    @Nullable
                    /*      */ public final Object invokeSuspend(@NotNull Object $result) {
                        /*      */
                        this.result = $result;
                        /*      */
                        this.label |= Integer.MIN_VALUE;
                        /*      */
                        return UnityBridgeActivity.this.playCoreLoop(0, 0, 0, 0, (Continuation) this);
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                @DebugMetadata(f = "UnityBridgeActivity.kt", l = {2953}, i = {0}, s = {"L$0"}, n = {"this"}, m = "playbackCoreLoop", c = "com.etouch.activity.UnityBridgeActivity")
                /*      */
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48)
                /*      */ static final class UnityBridgeActivity$playbackCoreLoop$1 extends ContinuationImpl {
                    /*      */ Object L$0;
                    /*      */ int label;

                    /*      */
                    /*      */     UnityBridgeActivity$playbackCoreLoop$1(Continuation $completion) {
                        /*      */
                        super($completion);
                        /*      */
                    }

                    /*      */
                    /*      */
                    @Nullable
                    /*      */ public final Object invokeSuspend(@NotNull Object $result) {
                        /*      */
                        this.result = $result;
                        /*      */
                        this.label |= Integer.MIN_VALUE;
                        /*      */
                        return UnityBridgeActivity.this.playbackCoreLoop((Continuation) this);
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /*      */
                @DebugMetadata(f = "UnityBridgeActivity.kt", l = {2768}, i = {}, s = {}, n = {}, m = "saveMediaToSelectedDirAsync", c = "com.etouch.activity.UnityBridgeActivity")
                /*      */
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48)
                /*      */ static final class UnityBridgeActivity$saveMediaToSelectedDirAsync$1 extends ContinuationImpl {
                    /*      */ int label;

                    /*      */
                    /*      */     UnityBridgeActivity$saveMediaToSelectedDirAsync$1(Continuation $completion) {
                        /*      */
                        super($completion);
                        /*      */
                    }

                    /*      */
                    /*      */
                    @Nullable
                    /*      */ public final Object invokeSuspend(@NotNull Object $result) {
                        /*      */
                        this.result = $result;
                        /*      */
                        this.label |= Integer.MIN_VALUE;
                        /*      */
                        return UnityBridgeActivity.this.saveMediaToSelectedDirAsync((String) null, (Uri) null, (Continuation<? super Boolean>) this);
                        /*      */
                    }
                    /*      */
                }
                /*      */
            }

