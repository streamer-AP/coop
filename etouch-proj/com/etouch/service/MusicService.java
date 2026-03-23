package com.etouch.service;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Handler;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import androidx.core.app.NotificationCompat;
import androidx.media.app.NotificationCompat;
import com.etouch.PCMData;
import com.etouch.PcmCaptureProcessor;
import com.google.android.exoplayer2.DefaultRenderersFactory;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.audio.AudioAttributes;
import com.google.android.exoplayer2.audio.AudioProcessor;
import com.google.android.exoplayer2.audio.AudioSink;
import com.google.android.exoplayer2.audio.DefaultAudioSink;
import com.google.gson.Gson;
import com.unity3d.player.UnityPlayer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import kotlin.Lazy;
import kotlin.LazyKt;
import kotlin.Metadata;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.CoroutineContext;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Lambda;
import kotlinx.coroutines.CoroutineScope;
import kotlinx.coroutines.Dispatchers;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONArray;
import org.json.JSONObject;



public final class MusicService extends Service {
    @NotNull
    public static final Companion Companion = new Companion(null);
    @NotNull
    private final CoroutineScope serviceScope = CoroutineScopeKt.CoroutineScope(Dispatchers.getMain().plus((CoroutineContext) SupervisorKt.SupervisorJob$default(null, 1, null)));
    @NotNull
    private final Lazy mainHandler$delegate = LazyKt.lazy(MusicService$mainHandler$2.INSTANCE);

    private final Handler getMainHandler() {
        Lazy lazy = this.mainHandler$delegate;
        return (Handler) lazy.getValue();
    }

    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\b\n\000\n\002\030\002\n\000\020\000\032\0020\001H\n¢\006\002\b\002"}, d2 = {"<anonymous>", "Landroid/os/Handler;", "invoke"})
    static final class MusicService$mainHandler$2 extends Lambda implements Function0<Handler> {
        public static final MusicService$mainHandler$2 INSTANCE = new MusicService$mainHandler$2();

        MusicService$mainHandler$2() {
            super(0);
        }

        @NotNull
        public final Handler invoke() {
            return new Handler(Looper.getMainLooper());
        }
    }

    @NotNull
    private final Lazy gson$delegate = LazyKt.lazy(MusicService$gson$2.INSTANCE);

    private final Gson getGson() {
        Lazy lazy = this.gson$delegate;
        return (Gson) lazy.getValue();
    }

    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\b\n\000\n\002\030\002\n\000\020\000\032\0020\001H\n¢\006\002\b\002"}, d2 = {"<anonymous>", "Lcom/google/gson/Gson;", "invoke"})
    static final class MusicService$gson$2 extends Lambda implements Function0<Gson> {
        public static final MusicService$gson$2 INSTANCE = new MusicService$gson$2();

        MusicService$gson$2() {
            super(0);
        }

        @NotNull
        public final Gson invoke() {
            return new Gson();
        }
    }

    @NotNull
    private final Lazy notificationManager$delegate = LazyKt.lazy(new MusicService$notificationManager$2());
    private boolean isNotificationManuallyHidden;

    private final NotificationManager getNotificationManager() {
        Lazy lazy = this.notificationManager$delegate;
        return (NotificationManager) lazy.getValue();
    }

    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\b\n\000\n\002\030\002\n\000\020\000\032\0020\001H\n¢\006\002\b\002"}, d2 = {"<anonymous>", "Landroid/app/NotificationManager;", "invoke"})
    static final class MusicService$notificationManager$2 extends Lambda implements Function0<NotificationManager> {
        @NotNull
        public final NotificationManager invoke() {
            Intrinsics.checkNotNull(MusicService.this.getSystemService("notification"), "null cannot be cast to non-null type android.app.NotificationManager");
            return (NotificationManager) MusicService.this.getSystemService("notification");
        }

        MusicService$notificationManager$2() {
            super(0);
        }
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000(\n\002\030\002\n\002\020\000\n\002\b\002\n\002\020\016\n\000\n\002\020\t\n\000\n\002\020\b\n\002\b\004\n\002\030\002\n\002\b\007\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002J\016\020\022\032\0020\0042\006\020\023\032\0020\006R\016\020\003\032\0020\004XT¢\006\002\n\000R\016\020\005\032\0020\006XT¢\006\002\n\000R\016\020\007\032\0020\bXT¢\006\002\n\000R\016\020\t\032\0020\bXT¢\006\002\n\000R\016\020\n\032\0020\bXT¢\006\002\n\000R\016\020\013\032\0020\bXT¢\006\002\n\000R\034\020\f\032\004\030\0010\rX\016¢\006\016\n\000\032\004\b\016\020\017\"\004\b\020\020\021¨\006\024"}, d2 = {"Lcom/etouch/service/MusicService$Companion;", "", "()V", "CHANNEL_ID", "", "DURATION_UNSET", "", "NOTIFY_ID", "", "PLAY_MODE_LOOP", "PLAY_MODE_RANDOM", "PLAY_MODE_SINGLE", "instance", "Lcom/etouch/service/MusicService;", "getInstance", "()Lcom/etouch/service/MusicService;", "setInstance", "(Lcom/etouch/service/MusicService;)V", "formatTime", "milliseconds", "sdk_android_unity_bridge_v1_debug"})
    public static final class Companion {
        private Companion() {
        }

        @Nullable
        public final MusicService getInstance() {
            return MusicService.instance;
        }

        public final void setInstance(@Nullable MusicService<set-?>) {
            MusicService.instance = < set - ? >;
        }


        @NotNull
        public final String formatTime(long milliseconds) {
            if (milliseconds < 0L || milliseconds == -9223372036854775807L) return "00:00";
            int seconds = (int) (milliseconds / 1000L);
            String str = "%02d:%02d";
            Object[] arrayOfObject = new Object[2];
            arrayOfObject[0] = Integer.valueOf(seconds / 60);
            arrayOfObject[1] = Integer.valueOf(seconds % 60);
            arrayOfObject = arrayOfObject;
            Intrinsics.checkNotNullExpressionValue(String.format(str, Arrays.copyOf(arrayOfObject, arrayOfObject.length)), "format(...)");
            return String.format(str, Arrays.copyOf(arrayOfObject, arrayOfObject.length));
        }
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\022\n\002\030\002\n\002\030\002\n\002\b\002\n\002\030\002\n\000\b\004\030\0002\0020\001B\005¢\006\002\020\002J\006\020\003\032\0020\004¨\006\005"}, d2 = {"Lcom/etouch/service/MusicService$MusicBinder;", "Landroid/os/Binder;", "(Lcom/etouch/service/MusicService;)V", "getService", "Lcom/etouch/service/MusicService;", "sdk_android_unity_bridge_v1_debug"})
    public final class MusicBinder extends Binder {
        @NotNull
        public final MusicService getService() {
            return MusicService.this;
        }
    }

    @NotNull
    private final MusicBinder binder = new MusicBinder();
    private ExoPlayer exoPlayer;
    private MediaSessionCompat mediaSession;
    private int playMode;

    @NotNull
    public IBinder onBind(@Nullable Intent intent) {
        return (IBinder) this.binder;
    }


    @NotNull
    private final List<MusicInfo> musicInfoCache = new ArrayList<>();

    private long lastKnownPosition;

    private long lastKnownDuration;

    private Handler handler;
    @NotNull
    private final MusicService$updateRunnable$1 updateRunnable = new MusicService$updateRunnable$1();

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\025\n\000\n\002\030\002\n\002\030\002\n\000\n\002\020\002\n\000*\001\000\b\n\030\0002\0060\001j\002`\002J\b\020\003\032\0020\004H\026¨\006\005"}, d2 = {"com/etouch/service/MusicService$updateRunnable$1", "Ljava/lang/Runnable;", "Lkotlinx/coroutines/Runnable;", "run", "", "sdk_android_unity_bridge_v1_debug"})
    public static final class MusicService$updateRunnable$1 implements Runnable {
        public void run() {
            if (!MusicService.this.isNotificationManuallyHidden) {
                MusicService.this.updateNotification();
            }
            if (MusicService.this.handler == null) {
                MusicService.this.handler;
                Intrinsics.throwUninitializedPropertyAccessException("handler");
            }
            null.postDelayed(this, 1000L);
        }
    }


    @NotNull
    public final float[] pcm16ToFloat(@NotNull byte[] pcm, int channelCount) {
        // Byte code:
        //   0: aload_1
        //   1: ldc 'pcm'
        //   3: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
        //   6: aload_1
        //   7: arraylength
        //   8: iconst_2
        //   9: idiv
        //   10: istore_3
        //   11: iload_3
        //   12: newarray float
        //   14: astore #4
        //   16: iconst_0
        //   17: istore #5
        //   19: iconst_0
        //   20: istore #6
        //   22: iload #5
        //   24: aload_1
        //   25: arraylength
        //   26: if_icmpge -> 83
        //   29: aload_1
        //   30: iload #5
        //   32: baload
        //   33: sipush #255
        //   36: iand
        //   37: istore #7
        //   39: aload_1
        //   40: iload #5
        //   42: iconst_1
        //   43: iadd
        //   44: baload
        //   45: istore #8
        //   47: iload #8
        //   49: bipush #8
        //   51: ishl
        //   52: iload #7
        //   54: ior
        //   55: istore #9
        //   57: iload #9
        //   59: i2s
        //   60: istore #10
        //   62: aload #4
        //   64: iload #6
        //   66: iload #10
        //   68: i2f
        //   69: ldc 32768.0
        //   71: fdiv
        //   72: fastore
        //   73: iinc #5, 2
        //   76: nop
        //   77: iinc #6, 1
        //   80: goto -> 22
        //   83: aload #4
        //   85: areturn
        // Line number table:
        //   Java source line number -> byte code offset
        //   #119	-> 6
        //   #120	-> 11
        //   #122	-> 16
        //   #123	-> 19
        //   #125	-> 22
        //   #127	-> 29
        //   #128	-> 39
        //   #130	-> 47
        //   #131	-> 57
        //   #133	-> 62
        //   #135	-> 76
        //   #136	-> 77
        //   #139	-> 83
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   39	41	7	low	I
        //   47	33	8	high	I
        //   57	23	9	sample	I
        //   62	18	10	shortSample	S
        //   11	75	3	shortCount	I
        //   16	70	4	floatArray	[F
        //   19	67	5	i	I
        //   22	64	6	j	I
        //   0	86	0	this	Lcom/etouch/service/MusicService;
        //   0	86	1	pcm	[B
        //   0	86	2	channelCount	I
    }


    private final DefaultRenderersFactory createRenderersFactory() {
        PcmCaptureProcessor pcmProcessor = new PcmCaptureProcessor(new MusicService$createRenderersFactory$pcmProcessor$1());


        return new MusicService$createRenderersFactory$1(this, pcmProcessor);
    }

    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\026\n\000\n\002\020\002\n\000\n\002\020\022\n\000\n\002\020\b\n\002\b\003\020\000\032\0020\0012\006\020\002\032\0020\0032\006\020\004\032\0020\0052\006\020\006\032\0020\0052\006\020\007\032\0020\005H\n¢\006\002\b\b"}, d2 = {"<anonymous>", "", "pcm", "", "sampleRate", "", "channelCount", "encoding", "invoke"})
    static final class MusicService$createRenderersFactory$pcmProcessor$1 extends Lambda implements Function4<byte[], Integer, Integer, Integer, Unit> {
        public final void invoke(@NotNull byte[] pcm, int sampleRate, int channelCount, int encoding) {
            Intrinsics.checkNotNullParameter(pcm, "pcm");
            MusicService.this.setPCMData(MusicService.this.pcm16ToFloat(pcm, channelCount), channelCount);
        }

        MusicService$createRenderersFactory$pcmProcessor$1() {
            super(4);
        }
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\037\n\000\n\002\030\002\n\000\n\002\030\002\n\000\n\002\030\002\n\000\n\002\020\013\n\002\b\003*\001\000\b\n\030\0002\0020\001J(\020\002\032\0020\0032\006\020\004\032\0020\0052\006\020\006\032\0020\0072\006\020\b\032\0020\0072\006\020\t\032\0020\007H\024¨\006\n"}, d2 = {"com/etouch/service/MusicService$createRenderersFactory$1", "Lcom/google/android/exoplayer2/DefaultRenderersFactory;", "buildAudioSink", "Lcom/google/android/exoplayer2/audio/AudioSink;", "context", "Landroid/content/Context;", "enableFloatOutput", "", "enableAudioTrackPlaybackParams", "enableOffload", "sdk_android_unity_bridge_v1_debug"})
    public static final class MusicService$createRenderersFactory$1 extends DefaultRenderersFactory {
        MusicService$createRenderersFactory$1(MusicService $receiver, PcmCaptureProcessor $pcmProcessor) {
            super((Context) $receiver);
        }


        @NotNull
        protected AudioSink buildAudioSink(@NotNull Context context, boolean enableFloatOutput, boolean enableAudioTrackPlaybackParams, boolean enableOffload) {
            Intrinsics.checkNotNullParameter(context, "context");
            PcmCaptureProcessor[] arrayOfPcmCaptureProcessor = new PcmCaptureProcessor[1];
            arrayOfPcmCaptureProcessor[0] = this.$pcmProcessor;


            Intrinsics.checkNotNullExpressionValue((new DefaultAudioSink.Builder()).setAudioProcessors((AudioProcessor[]) arrayOfPcmCaptureProcessor).setEnableFloatOutput(enableFloatOutput).setEnableAudioTrackPlaybackParams(enableAudioTrackPlaybackParams).build(), "build(...)");
            return (AudioSink) (new DefaultAudioSink.Builder()).setAudioProcessors((AudioProcessor[]) arrayOfPcmCaptureProcessor).setEnableFloatOutput(enableFloatOutput).setEnableAudioTrackPlaybackParams(enableAudioTrackPlaybackParams).build();
        }
    }


    private final void sendCurrentMusicInfoToUnity() {
        MusicInfo currentInfo, musicInfo1 = getCurrentPlayingMusicInfo();
        if (musicInfo1 == null)
            return;
        try {
            UnityPlayer.UnitySendMessage(
                    "Boot",
                    "audioPlayerGetCurrentPlayingAudioData",
                    getGson().toJson(currentInfo));


        } catch (Exception exception) {
        }
    }


    public void onCreate() {
        super.onCreate();


        if (instance != null) {

            stopSelf();

            return;
        }
        instance = this;
        this.handler = new Handler(Looper.getMainLooper());
        createChannel();


        try {
            DefaultRenderersFactory renderersFactory = createRenderersFactory();


            Intrinsics.checkNotNullExpressionValue((new ExoPlayer.Builder((Context) this, (RenderersFactory) renderersFactory)).build(), "build(...)");
            ExoPlayer exoPlayer1 = (new ExoPlayer.Builder((Context) this, (RenderersFactory) renderersFactory)).build();
            ExoPlayer exoPlayer2 = exoPlayer1;
            MusicService musicService = this;
            int $i$a$ -apply - MusicService$onCreate$1 = 0;


            Intrinsics.checkNotNullExpressionValue((new AudioAttributes.Builder()).setUsage(1).setContentType(2).build(), "build(...)");
            AudioAttributes audioAttributes = (new AudioAttributes.Builder()).setUsage(1).setContentType(2).build();
            exoPlayer2.setAudioAttributes(audioAttributes, false);
            exoPlayer2.addListener(new MusicService$onCreate$1$1());


            musicService.exoPlayer = exoPlayer1;
        } catch (Exception exception) {
        }


        try {
            MediaSessionCompat mediaSessionCompat1 = new MediaSessionCompat((Context) this, "MusicService"), mediaSessionCompat2 = mediaSessionCompat1;
            MusicService musicService = this;
            int $i$a$ -apply - MusicService$onCreate$2 = 0;
            mediaSessionCompat2.setActive(true);
            mediaSessionCompat2.setMediaButtonReceiver(
                    PendingIntent.getBroadcast(
                            (Context) this,
                            0,
                            new Intent((Context) this, MediaButtonReceiver.class),
                            201326592));


            mediaSessionCompat2.setCallback(new MusicService$onCreate$2$1());


            PlaybackStateCompat playbackState = (new PlaybackStateCompat.Builder())
                    .setState(2, 0L, 1.0F)
                    .setActions(
                            310L)


                    .build();
            mediaSessionCompat2.setPlaybackState(playbackState);
            musicService.mediaSession = mediaSessionCompat1;
        } catch (Exception exception) {
        }


        startForeground(1, buildEmptyNotification());


        if (this.handler == null) Intrinsics.throwUninitializedPropertyAccessException("handler");
        null.post(this.updateRunnable);
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000'\n\000\n\002\030\002\n\000\n\002\020\002\n\000\n\002\020\013\n\002\b\002\n\002\020\b\n\002\b\002\n\002\030\002\n\000*\001\000\b\n\030\0002\0020\001J\020\020\002\032\0020\0032\006\020\004\032\0020\005H\026J\020\020\006\032\0020\0032\006\020\007\032\0020\bH\026J\020\020\t\032\0020\0032\006\020\n\032\0020\013H\026¨\006\f"}, d2 = {"com/etouch/service/MusicService$onCreate$1$1", "Lcom/google/android/exoplayer2/Player$Listener;", "onIsPlayingChanged", "", "isPlaying", "", "onPlaybackStateChanged", "state", "", "onPlayerError", "error", "Lcom/google/android/exoplayer2/PlaybackException;", "sdk_android_unity_bridge_v1_debug"})
    public static final class MusicService$onCreate$1$1 implements Player.Listener {
        public void onPlaybackStateChanged(int state) {
            switch (state) {
                case 3:
                    if (MusicService.this.exoPlayer == null) {
                        MusicService.this.exoPlayer;
                        Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                    }
                    ((MusicService) MusicService.this.exoPlayer).lastKnownPosition = null.getCurrentPosition();
                    if (MusicService.this.exoPlayer == null) {
                        MusicService.this.exoPlayer;
                        Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                    }
                    ((MusicService) MusicService.this.exoPlayer).lastKnownDuration = null.getDuration();
                    MusicService.this.updateMetadata();
                    MusicService.this.updateNotification();
                    break;
                case 4:
                    MusicService.this.updatePlaybackState();
                    break;
            }
        }

        public void onIsPlayingChanged(boolean isPlaying) {
            if (MusicService.this.exoPlayer != null) {
                if (MusicService.this.exoPlayer == null) {
                    MusicService.this.exoPlayer;
                    Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                }
                ((MusicService) MusicService.this.exoPlayer).lastKnownPosition = null.getCurrentPosition();
                if (MusicService.this.exoPlayer == null) {
                    MusicService.this.exoPlayer;
                    Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                }
                ((MusicService) MusicService.this.exoPlayer).lastKnownDuration = null.getDuration();
            }
            MusicService.this.updatePlaybackState();
            MusicService.this.updateNotification();
            if (isPlaying) MusicService.this.sendCurrentMusicInfoToUnity();
        }

        public void onPlayerError(@NotNull PlaybackException error) {
            Intrinsics.checkNotNullParameter(error, "error");
        }
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\033\n\000\n\002\030\002\n\000\n\002\020\002\n\002\b\003\n\002\020\t\n\002\b\003*\001\000\b\n\030\0002\0020\001J\b\020\002\032\0020\003H\026J\b\020\004\032\0020\003H\026J\020\020\005\032\0020\0032\006\020\006\032\0020\007H\026J\b\020\b\032\0020\003H\026J\b\020\t\032\0020\003H\026¨\006\n"}, d2 = {"com/etouch/service/MusicService$onCreate$2$1", "Landroid/support/v4/media/session/MediaSessionCompat$Callback;", "onPause", "", "onPlay", "onSeekTo", "pos", "", "onSkipToNext", "onSkipToPrevious", "sdk_android_unity_bridge_v1_debug"})
    public static final class MusicService$onCreate$2$1 extends MediaSessionCompat.Callback {
        public void onPlay() {
            MusicService.this.play();
        }

        public void onPause() {
            MusicService.this.pause();
        }

        public void onSkipToNext() {
            MusicService.this.playNext();
        }

        public void onSkipToPrevious() {
            MusicService.this.playPrev();
        }

        public void onSeekTo(long pos) {
            MusicService.this.audioPlayerSeekTo(pos);
        }
    }

    public void onDestroy() {
        CoroutineScopeKt.cancel$default(this.serviceScope, null, 1, null);
        if (this.handler == null) Intrinsics.throwUninitializedPropertyAccessException("handler");
        null.removeCallbacks(this.updateRunnable);
        if (this.exoPlayer != null) {
            if (this.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
            null.release();
        }
        if (this.mediaSession != null) {
            if (this.mediaSession == null) Intrinsics.throwUninitializedPropertyAccessException("mediaSession");
            null.release();
        }
        stopForeground(1);
        instance = null;


        if (this.mediaSession == null) Intrinsics.throwUninitializedPropertyAccessException("mediaSession");
        null;
        if (this.mediaSession == null) Intrinsics.throwUninitializedPropertyAccessException("mediaSession");
        null.setActive(false);
        if (this.mediaSession == null) Intrinsics.throwUninitializedPropertyAccessException("mediaSession");
        null.release();


        if (this.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
        null;
        if (this.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
        null.release();


        this.isNotificationManuallyHidden = false;
        hideNotification(false);
        super.onDestroy();
    }

    public final void audioPlayerPlayItem(@NotNull String json, @NotNull PlayItemCallback callback) { // Byte code:
        //   0: aload_1
        //   1: ldc_w 'json'
        //   4: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
        //   7: aload_2
        //   8: ldc_w 'callback'
        //   11: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
        //   14: aload_0
        //   15: invokespecial getMainHandler : ()Landroid/os/Handler;
        //   18: aload_1
        //   19: aload_0
        //   20: aload_2
        //   21: <illegal opcode> run : (Ljava/lang/String;Lcom/etouch/service/MusicService;Lcom/etouch/service/MusicService$PlayItemCallback;)Ljava/lang/Runnable;
        //   26: invokevirtual post : (Ljava/lang/Runnable;)Z
        //   29: pop
        //   30: return
        // Line number table:
        //   Java source line number -> byte code offset
        //   #367	-> 14
        //   #404	-> 30
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   0	31	0	this	Lcom/etouch/service/MusicService;
        //   0	31	1	json	Ljava/lang/String;
        //   0	31	2	callback	Lcom/etouch/service/MusicService$PlayItemCallback; }
        private static final void audioPlayerPlayItem$lambda$3 (String $json, MusicService this$0, PlayItemCallback
        $callback){
            Intrinsics.checkNotNullParameter($json, "$json");
            Intrinsics.checkNotNullParameter(this$0, "this$0");
            Intrinsics.checkNotNullParameter($callback, "$callback");
            try {
                JSONObject obj = new JSONObject($json);
                String uri = obj.optString("uri");
                String title = obj.optString("title", "Unknown");
                String artist = obj.optString("artist", "Unknown");
                String coverUrl = obj.optString("cover", null);
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                null.clearMediaItems();
                this$0.musicInfoCache.clear();
                Intrinsics.checkNotNullExpressionValue(MediaItem.fromUri(uri), "fromUri(...)");
                MediaItem mediaItem = MediaItem.fromUri(uri);
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                null.addMediaItem(mediaItem);
                Intrinsics.checkNotNull(uri);
                Intrinsics.checkNotNull(title);
                Intrinsics.checkNotNull(artist);
                this$0.musicInfoCache.add(new MusicInfo(uri, "", title, artist, coverUrl, null, null, null, null, 480, null));
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                null.prepare();
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                null.play();
                this$0.updateMetadata();
                this$0.updateNotification();
                $callback.onSuccess();
            } catch (Exception e) {
                if (e.getMessage() == null) e.getMessage();
                e.getMessage().onError("播放参数解析失败");
            }
        }
        public final void audioPlayerSetPlaylist (@NotNull String json,int idx, @NotNull PlaylistCallback callback)
        { // Byte code:
            //   0: aload_1
            //   1: ldc_w 'json'
            //   4: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
            //   7: aload_3
            //   8: ldc_w 'callback'
            //   11: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
            //   14: aload_0
            //   15: invokespecial getMainHandler : ()Landroid/os/Handler;
            //   18: aload_1
            //   19: aload_0
            //   20: aload_3
            //   21: iload_2
            //   22: <illegal opcode> run : (Ljava/lang/String;Lcom/etouch/service/MusicService;Lcom/etouch/service/MusicService$PlaylistCallback;I)Ljava/lang/Runnable;
            //   27: invokevirtual post : (Ljava/lang/Runnable;)Z
            //   30: pop
            //   31: return
            // Line number table:
            //   Java source line number -> byte code offset
            //   #408	-> 14
            //   #497	-> 31
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   0	32	0	this	Lcom/etouch/service/MusicService;
            //   0	32	1	json	Ljava/lang/String;
            //   0	32	2	idx	I
            //   0	32	3	callback	Lcom/etouch/service/MusicService$PlaylistCallback; }
            private static final void audioPlayerSetPlaylist$lambda$4 (String $json, MusicService
            this$0, PlaylistCallback $callback,int $idx){
            Intrinsics.checkNotNullParameter($json, "$json");
            Intrinsics.checkNotNullParameter(this$0, "this$0");
            Intrinsics.checkNotNullParameter($callback, "$callback");
            try {
                JSONArray array = new JSONArray($json);
                List<MediaItem> mediaItems = new ArrayList();
                List<MusicInfo> newCache = new ArrayList();
                for (int i = 0, j = array.length(); i < j; i++) {
                    JSONObject obj = array.getJSONObject(i);
                    String uri = obj.optString("uri");
                    String url = obj.optString("url");
                    String title = obj.optString("title", "Unknown");
                    String artist = obj.optString("artist", "Unknown");
                    String coverUrl = obj.optString("cover", null);
                    Intrinsics.checkNotNullExpressionValue(MediaItem.fromUri(uri), "fromUri(...)");
                    mediaItems.add(MediaItem.fromUri(uri));
                    Intrinsics.checkNotNull(uri);
                    Intrinsics.checkNotNull(url);
                    Intrinsics.checkNotNull(title);
                    Intrinsics.checkNotNull(artist);
                    newCache.add(new MusicInfo(uri, url, title, artist, coverUrl, null, null, null, null, 480, null));
                }
                if (mediaItems.isEmpty()) {
                    if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                    null.clearMediaItems();
                    this$0.musicInfoCache.clear();
                    if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                    null.stop();
                    this$0.updateNotification();
                    this$0.updatePlaybackState();
                    $callback.onSuccess();
                    return;
                }
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                int oldIndex = null.getCurrentMediaItemIndex();
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                boolean wasPlaying = null.isPlaying();
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                boolean hasOldItem = (0 <= oldIndex) ? ((this$0.exoPlayer < null.getMediaItemCount())) : false;
                if ($idx == -1 && hasOldItem) {
                    this$0.musicInfoCache.clear();
                    this$0.musicInfoCache.addAll(newCache);
                    $callback.onSuccess();
                    return;
                }
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                null.setMediaItems(mediaItems, false);
                this$0.musicInfoCache.clear();
                this$0.musicInfoCache.addAll(newCache);
                int targetIndex = ($idx >= 0) ? RangesKt.coerceIn($idx, 0, mediaItems.size() - 1) : (((0 <= oldIndex) ? ((oldIndex < mediaItems.size())) : false) ? oldIndex : 0);
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                null.seekToDefaultPosition(targetIndex);
                if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                null.prepare();
                if ($idx >= 0 || wasPlaying) {
                    if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                    null.play();
                }
                this$0.updateMetadata();
                this$0.updateNotification();
                $callback.onSuccess();
            } catch (Exception e) {
                if (e.getMessage() == null) e.getMessage();
                e.getMessage().onError("播放列表解析失败");
            }
        }
            public final void audioPlayerUpdateMarkAudio ( int index, @NotNull String json){ // Byte code:
            //   0: aload_2
            //   1: ldc_w 'json'
            //   4: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
            //   7: aload_0
            //   8: invokespecial getMainHandler : ()Landroid/os/Handler;
            //   11: iload_1
            //   12: aload_0
            //   13: aload_2
            //   14: <illegal opcode> run : (ILcom/etouch/service/MusicService;Ljava/lang/String;)Ljava/lang/Runnable;
            //   19: invokevirtual post : (Ljava/lang/Runnable;)Z
            //   22: pop
            //   23: return
            // Line number table:
            //   Java source line number -> byte code offset
            //   #500	-> 7
            //   #557	-> 23
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   0	24	0	this	Lcom/etouch/service/MusicService;
            //   0	24	1	index	I
            //   0	24	2	json	Ljava/lang/String; } private static final void audioPlayerUpdateMarkAudio$lambda$5(int $index, MusicService this$0, String $json) { // Byte code:
            //   0: aload_1
            //   1: ldc_w 'this$0'
            //   4: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
            //   7: aload_2
            //   8: ldc_w '$json'
            //   11: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
            //   14: nop
            //   15: iconst_0
            //   16: iload_0
            //   17: if_icmpgt -> 41
            //   20: iload_0
            //   21: aload_1
            //   22: getfield musicInfoCache : Ljava/util/List;
            //   25: invokeinterface size : ()I
            //   30: if_icmpge -> 37
            //   33: iconst_1
            //   34: goto -> 42
            //   37: iconst_0
            //   38: goto -> 42
            //   41: iconst_0
            //   42: ifne -> 46
            //   45: return
            //   46: aload_1
            //   47: invokespecial getGson : ()Lcom/google/gson/Gson;
            //   50: aload_2
            //   51: ldc com/etouch/service/MusicInfo
            //   53: invokevirtual fromJson : (Ljava/lang/String;Ljava/lang/Class;)Ljava/lang/Object;
            //   56: checkcast com/etouch/service/MusicInfo
            //   59: astore_3
            //   60: aload_1
            //   61: getfield musicInfoCache : Ljava/util/List;
            //   64: iload_0
            //   65: invokeinterface get : (I)Ljava/lang/Object;
            //   70: checkcast com/etouch/service/MusicInfo
            //   73: astore #4
            //   75: aload_1
            //   76: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   79: ifnull -> 163
            //   82: iload_0
            //   83: aload_1
            //   84: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   87: dup
            //   88: ifnonnull -> 99
            //   91: pop
            //   92: ldc_w 'exoPlayer'
            //   95: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   98: aconst_null
            //   99: invokeinterface getCurrentMediaItemIndex : ()I
            //   104: if_icmpne -> 163
            //   107: aload_1
            //   108: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   111: dup
            //   112: ifnonnull -> 123
            //   115: pop
            //   116: ldc_w 'exoPlayer'
            //   119: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   122: aconst_null
            //   123: invokeinterface getDuration : ()J
            //   128: lconst_0
            //   129: lcmp
            //   130: ifle -> 163
            //   133: getstatic com/etouch/service/MusicService.Companion : Lcom/etouch/service/MusicService$Companion;
            //   136: aload_1
            //   137: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   140: dup
            //   141: ifnonnull -> 152
            //   144: pop
            //   145: ldc_w 'exoPlayer'
            //   148: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   151: aconst_null
            //   152: invokeinterface getDuration : ()J
            //   157: invokevirtual formatTime : (J)Ljava/lang/String;
            //   160: goto -> 168
            //   163: aload #4
            //   165: invokevirtual getDuration : ()Ljava/lang/String;
            //   168: astore #5
            //   170: aload_1
            //   171: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   174: ifnull -> 234
            //   177: iload_0
            //   178: aload_1
            //   179: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   182: dup
            //   183: ifnonnull -> 194
            //   186: pop
            //   187: ldc_w 'exoPlayer'
            //   190: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   193: aconst_null
            //   194: invokeinterface getCurrentMediaItemIndex : ()I
            //   199: if_icmpne -> 234
            //   202: aload_1
            //   203: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   206: dup
            //   207: ifnonnull -> 218
            //   210: pop
            //   211: ldc_w 'exoPlayer'
            //   214: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   217: aconst_null
            //   218: invokeinterface getCurrentPosition : ()J
            //   223: l2d
            //   224: ldc2_w 1000.0
            //   227: ddiv
            //   228: invokestatic valueOf : (D)Ljava/lang/Double;
            //   231: goto -> 239
            //   234: aload #4
            //   236: invokevirtual getCurrentTime : ()Ljava/lang/Double;
            //   239: astore #6
            //   241: aload_3
            //   242: invokevirtual getTitle : ()Ljava/lang/String;
            //   245: checkcast java/lang/CharSequence
            //   248: invokeinterface length : ()I
            //   253: ifle -> 260
            //   256: iconst_1
            //   257: goto -> 261
            //   260: iconst_0
            //   261: ifeq -> 271
            //   264: aload_3
            //   265: invokevirtual getTitle : ()Ljava/lang/String;
            //   268: goto -> 276
            //   271: aload #4
            //   273: invokevirtual getTitle : ()Ljava/lang/String;
            //   276: astore #8
            //   278: aload_3
            //   279: invokevirtual getArtist : ()Ljava/lang/String;
            //   282: checkcast java/lang/CharSequence
            //   285: invokeinterface length : ()I
            //   290: ifle -> 297
            //   293: iconst_1
            //   294: goto -> 298
            //   297: iconst_0
            //   298: ifeq -> 308
            //   301: aload_3
            //   302: invokevirtual getArtist : ()Ljava/lang/String;
            //   305: goto -> 313
            //   308: aload #4
            //   310: invokevirtual getArtist : ()Ljava/lang/String;
            //   313: astore #9
            //   315: aload_3
            //   316: invokevirtual getCover : ()Ljava/lang/String;
            //   319: dup
            //   320: ifnonnull -> 329
            //   323: pop
            //   324: aload #4
            //   326: invokevirtual getCover : ()Ljava/lang/String;
            //   329: astore #10
            //   331: aload_3
            //   332: invokevirtual getUrl : ()Ljava/lang/String;
            //   335: checkcast java/lang/CharSequence
            //   338: invokeinterface length : ()I
            //   343: ifle -> 350
            //   346: iconst_1
            //   347: goto -> 351
            //   350: iconst_0
            //   351: ifeq -> 361
            //   354: aload_3
            //   355: invokevirtual getUrl : ()Ljava/lang/String;
            //   358: goto -> 366
            //   361: aload #4
            //   363: invokevirtual getUrl : ()Ljava/lang/String;
            //   366: astore #11
            //   368: aload_3
            //   369: invokevirtual getPath : ()Ljava/lang/String;
            //   372: dup
            //   373: ifnonnull -> 382
            //   376: pop
            //   377: aload #4
            //   379: invokevirtual getPath : ()Ljava/lang/String;
            //   382: astore #12
            //   384: aload #4
            //   386: aconst_null
            //   387: aload #11
            //   389: aload #8
            //   391: aload #9
            //   393: aload #10
            //   395: aload #5
            //   397: aload #6
            //   399: iload_0
            //   400: invokestatic valueOf : (I)Ljava/lang/Integer;
            //   403: aload #12
            //   405: iconst_1
            //   406: aconst_null
            //   407: invokestatic copy$default : (Lcom/etouch/service/MusicInfo;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Double;Ljava/lang/Integer;Ljava/lang/String;ILjava/lang/Object;)Lcom/etouch/service/MusicInfo;
            //   410: astore #7
            //   412: aload_1
            //   413: getfield musicInfoCache : Ljava/util/List;
            //   416: iload_0
            //   417: aload #7
            //   419: invokeinterface set : (ILjava/lang/Object;)Ljava/lang/Object;
            //   424: pop
            //   425: aload_1
            //   426: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   429: ifnull -> 473
            //   432: iload_0
            //   433: aload_1
            //   434: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   437: dup
            //   438: ifnonnull -> 449
            //   441: pop
            //   442: ldc_w 'exoPlayer'
            //   445: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   448: aconst_null
            //   449: invokeinterface getCurrentMediaItemIndex : ()I
            //   454: if_icmpne -> 473
            //   457: aload_1
            //   458: invokespecial updateMetadata : ()V
            //   461: aload_1
            //   462: invokespecial updateNotification : ()V
            //   465: aload_1
            //   466: invokespecial sendCurrentMusicInfoToUnity : ()V
            //   469: goto -> 473
            //   472: astore_3
            //   473: return
            // Line number table:
            //   Java source line number -> byte code offset
            //   #501	-> 14
            //   #502	-> 15
            //   #504	-> 45
            //   #507	-> 46
            //   #508	-> 60
            //   #511	-> 75
            //   #512	-> 75
            //   #513	-> 82
            //   #514	-> 107
            //   #516	-> 133
            //   #518	-> 163
            //   #511	-> 168
            //   #521	-> 170
            //   #522	-> 170
            //   #523	-> 177
            //   #525	-> 202
            //   #527	-> 234
            //   #521	-> 239
            //   #531	-> 241
            //   #531	-> 261
            //   #532	-> 278
            //   #532	-> 298
            //   #533	-> 315
            //   #534	-> 331
            //   #534	-> 351
            //   #535	-> 368
            //   #530	-> 384
            //   #534	-> 387
            //   #531	-> 389
            //   #532	-> 391
            //   #533	-> 393
            //   #536	-> 395
            //   #537	-> 397
            //   #538	-> 399
            //   #535	-> 403
            //   #530	-> 405
            //   #541	-> 412
            //   #545	-> 425
            //   #546	-> 432
            //   #548	-> 457
            //   #549	-> 461
            //   #550	-> 465
            //   #553	-> 472
            //   #556	-> 473
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   60	409	3	newMusic	Lcom/etouch/service/MusicInfo;
            //   75	394	4	oldMusic	Lcom/etouch/service/MusicInfo;
            //   170	299	5	realDuration	Ljava/lang/String;
            //   241	228	6	realCurrentTime	Ljava/lang/Double;
            //   412	57	7	updatedMusic	Lcom/etouch/service/MusicInfo;
            //   0	474	0	$index	I
            //   0	474	1	this$0	Lcom/etouch/service/MusicService;
            //   0	474	2	$json	Ljava/lang/String;
            // Exception table:
            //   from	to	target	type
            //   14	469	472	java/lang/Exception } @NotNull private PCMData pcmData = new PCMData(null, null, 3, null); @Nullable private static MusicService instance; @NotNull public static final String CHANNEL_ID = "music_channel"; public static final int NOTIFY_ID = 1; public static final int PLAY_MODE_LOOP = 0; public static final int PLAY_MODE_RANDOM = 1; public static final int PLAY_MODE_SINGLE = 2; private static final long DURATION_UNSET = -9223372036854775807L; @NotNull public final PCMData getPcmData() { return this.pcmData; } public final void setPcmData(@NotNull PCMData <set-?>) { Intrinsics.checkNotNullParameter(<set-?>, "<set-?>"); this.pcmData = <set-?>; } @Nullable public final String getPCMData() { return (new Gson()).toJson(this.pcmData); } public final void setPCMData(@NotNull float[] pcmArray, int channelCount) { Intrinsics.checkNotNullParameter(pcmArray, "pcmArray"); this.pcmData.setPcmData(pcmArray); this.pcmData.setSize(Integer.valueOf(channelCount)); } public final void audioPlayerSetPlayMode(int mode) { // Byte code:
            //   0: aload_0
            //   1: invokespecial getMainHandler : ()Landroid/os/Handler;
            //   4: aload_0
            //   5: iload_1
            //   6: <illegal opcode> run : (Lcom/etouch/service/MusicService;I)Ljava/lang/Runnable;
            //   11: invokevirtual post : (Ljava/lang/Runnable;)Z
            //   14: pop
            //   15: return
            // Line number table:
            //   Java source line number -> byte code offset
            //   #571	-> 0
            //   #584	-> 15
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   0	16	0	this	Lcom/etouch/service/MusicService;
            //   0	16	1	mode	I } private static final void audioPlayerSetPlayMode$lambda$6(MusicService this$0, int $mode) { Intrinsics.checkNotNullParameter(this$0, "this$0"); this$0.playMode = $mode; if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  switch ($mode) { case 2: case 0: case 1: default: break; }  null.setRepeatMode(2); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.setShuffleModeEnabled(($mode == 1)); } public int onStartCommand(@Nullable Intent intent, int flags, int startId) { if (this.mediaSession != null)
            if (intent != null) {
                Intent it = intent;


                int $i$a$ -let - MusicService$onStartCommand$1 = 0;
                if (this.mediaSession == null) Intrinsics.throwUninitializedPropertyAccessException("mediaSession");
                MediaButtonReceiver.handleIntent(null, it);
            } else {
            } if (!this.isNotificationManuallyHidden) updateNotification();
            return 1;
        }
            public final int audioPlayerGetPlayMode () {
            return this.playMode;
        }
            public final void audioPlayerSeekTo ( double time){ // Byte code:
            //   0: aload_0
            //   1: invokespecial getMainHandler : ()Landroid/os/Handler;
            //   4: aload_0
            //   5: dload_1
            //   6: <illegal opcode> run : (Lcom/etouch/service/MusicService;D)Ljava/lang/Runnable;
            //   11: invokevirtual post : (Ljava/lang/Runnable;)Z
            //   14: pop
            //   15: return
            // Line number table:
            //   Java source line number -> byte code offset
            //   #590	-> 0
            //   #593	-> 15
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   0	16	0	this	Lcom/etouch/service/MusicService;
            //   0	16	1	time	D } private static final void audioPlayerSeekTo$lambda$7(MusicService this$0, double $time) { Intrinsics.checkNotNullParameter(this$0, "this$0"); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.seekTo((long)$time); } public final double audioPlayerGetPlayingAudioCurrentTime() { if (this.exoPlayer == null) return 0.0D;  if (this.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (this.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  long position = (null.getPlaybackState() == 3) ? null.getCurrentPosition() : this.lastKnownPosition; return position / 1000.0D; } public final double audioPlayerGetPlayingAudioTotalTime() { if (this.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  return (this.exoPlayer != null) ? (null.getDuration() / 'Ϩ') : 0.0D; } public final void audioPlayerIsPlaying() { getMainHandler().post(this::audioPlayerIsPlaying$lambda$8); } private static final void audioPlayerIsPlaying$lambda$8(MusicService this$0) { Intrinsics.checkNotNullParameter(this$0, "this$0"); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  boolean isPlaying = (this$0.exoPlayer != null) ? null.isPlaying() : false; UnityPlayer.UnitySendMessage("Boot", "audioPlayerIsPlaying", this$0.getGson().toJson(new IsPlaying(isPlaying))); } public final void play() { getMainHandler().post(this::play$lambda$9); } private static final void play$lambda$9(MusicService this$0) { Intrinsics.checkNotNullParameter(this$0, "this$0"); if (this$0.exoPlayer == null) return;  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getMediaItemCount() == 0) return;  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  switch (null.getPlaybackState()) { case 4: if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.seekToDefaultPosition(); break;case 1: if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.prepare(); break; }  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.play(); this$0.updatePlaybackState(); } public final void pause() { getMainHandler().post(this::pause$lambda$10); } private static final void pause$lambda$10(MusicService this$0) { Intrinsics.checkNotNullParameter(this$0, "this$0"); if (this$0.exoPlayer == null) return;  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.pause(); this$0.updatePlaybackState(); } public final void playNext() { getMainHandler().post(this::playNext$lambda$11); } private static final void playNext$lambda$11(MusicService this$0) { Intrinsics.checkNotNullParameter(this$0, "this$0"); if (this$0.exoPlayer != null) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getMediaItemCount() != 0) { try { if (this$0.playMode == 1) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  int currentIndex = null.getCurrentMediaItemIndex(); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  int newIndex = this$0.exoPlayer.nextInt(null.getMediaItemCount()); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getMediaItemCount() > 1 && newIndex == currentIndex) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  newIndex = this$0.exoPlayer % null.getMediaItemCount(); }  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.seekToDefaultPosition(newIndex); } else { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.seekToNextMediaItem(); }  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getPlaybackState() != 3) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.prepare(); }  ExoPlayer exoPlayer = this$0.exoPlayer; if (exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.play(); this$0.updateMetadata(); this$0.updateNotification(); } catch (Exception exception) {} return; }  }  } public final void playPrev() { getMainHandler().post(this::playPrev$lambda$12); } private static final void playPrev$lambda$12(MusicService this$0) { Intrinsics.checkNotNullParameter(this$0, "this$0"); if (this$0.exoPlayer != null) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getMediaItemCount() != 0) { try { if (this$0.playMode == 1) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  int currentIndex = null.getCurrentMediaItemIndex(); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  int newIndex = this$0.exoPlayer.nextInt(null.getMediaItemCount()); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getMediaItemCount() > 1 && newIndex == currentIndex) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  newIndex = this$0.exoPlayer % null.getMediaItemCount(); }  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.seekToDefaultPosition(newIndex); } else { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.seekToPreviousMediaItem(); }  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getPlaybackState() != 3) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.prepare(); }  ExoPlayer exoPlayer = this$0.exoPlayer; if (exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.play(); this$0.updateMetadata(); this$0.updateNotification(); } catch (Exception exception) {} return; }  }  } public final void next() { playNext(); } public final void prev() { playPrev(); } public final void audioPlayerPlayAudio(int targetIndex) { // Byte code:
            //   0: aload_0
            //   1: invokespecial getMainHandler : ()Landroid/os/Handler;
            //   4: aload_0
            //   5: iload_1
            //   6: <illegal opcode> run : (Lcom/etouch/service/MusicService;I)Ljava/lang/Runnable;
            //   11: invokevirtual post : (Ljava/lang/Runnable;)Z
            //   14: pop
            //   15: return
            // Line number table:
            //   Java source line number -> byte code offset
            //   #741	-> 0
            //   #749	-> 15
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   0	16	0	this	Lcom/etouch/service/MusicService;
            //   0	16	1	targetIndex	I } private static final void audioPlayerPlayAudio$lambda$13(MusicService this$0, int $targetIndex) { Intrinsics.checkNotNullParameter(this$0, "this$0"); if (this$0.exoPlayer != null) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getMediaItemCount() != 0) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  int validIndex = RangesKt.coerceIn(0, this$0.exoPlayer, null.getMediaItemCount() - 1); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.seekToDefaultPosition(validIndex); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.play(); this$0.updateMetadata(); this$0.updateNotification(); return; }  }  } public final void audioPlayerDeleteItems(@NotNull String deleteJson) { // Byte code:
            //   0: aload_1
            //   1: ldc_w 'deleteJson'
            //   4: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
            //   7: aload_0
            //   8: invokespecial getMainHandler : ()Landroid/os/Handler;
            //   11: aload_1
            //   12: aload_0
            //   13: <illegal opcode> run : (Ljava/lang/String;Lcom/etouch/service/MusicService;)Ljava/lang/Runnable;
            //   18: invokevirtual post : (Ljava/lang/Runnable;)Z
            //   21: pop
            //   22: return
            // Line number table:
            //   Java source line number -> byte code offset
            //   #753	-> 7
            //   #823	-> 22
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   0	23	0	this	Lcom/etouch/service/MusicService;
            //   0	23	1	deleteJson	Ljava/lang/String; } private static final void audioPlayerDeleteItems$lambda$15(String $deleteJson, MusicService this$0) { Intrinsics.checkNotNullParameter($deleteJson, "$deleteJson"); Intrinsics.checkNotNullParameter(this$0, "this$0"); try { JSONObject jsonObj = new JSONObject($deleteJson); if (!jsonObj.has("deleteIndexArr")) return;  JSONArray deleteIndexJsonArr = jsonObj.getJSONArray("deleteIndexArr"); Set<Integer> deleteIndexes = new LinkedHashSet(); for (int i = 0, j = deleteIndexJsonArr.length(); i < j; i++) { int idx = deleteIndexJsonArr.getInt(i); if (idx >= 0) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (this$0.exoPlayer < null.getMediaItemCount()) deleteIndexes.add(Integer.valueOf(idx));  }  }  if (deleteIndexes.isEmpty()) return;  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  int currentIndex = null.getCurrentMediaItemIndex(); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  boolean wasPlaying = null.isPlaying(); List sortedIndexes = CollectionsKt.sortedDescending(deleteIndexes); boolean deletingCurrent = false; Iterable $this$forEach$iv = sortedIndexes; int $i$f$forEach = 0; Iterator iterator = $this$forEach$iv.iterator(); if (iterator.hasNext()) { Object element$iv = iterator.next(); int idx = ((Number)element$iv).intValue(), $i$a$-forEach-MusicService$audioPlayerDeleteItems$1$1 = 0; if (idx == currentIndex) deletingCurrent = true;  }  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (null.getMediaItemCount() == 0) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.stop(); this$0.updateNotification(); this$0.updatePlaybackState(); return; }  if (deletingCurrent) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  int newIndex = (this$0.exoPlayer >= null.getMediaItemCount()) ? (null.getMediaItemCount() - 1) : currentIndex; if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.seekToDefaultPosition(newIndex); if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.prepare(); if (wasPlaying) { if (this$0.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  null.play(); }  }  this$0.updateMetadata(); this$0.updateNotification(); } catch (Exception exception) {} } @Nullable public final MusicInfo getCurrentPlayingMusicInfo() { // Byte code:
            //   0: aload_0
            //   1: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   4: ifnonnull -> 9
            //   7: aconst_null
            //   8: areturn
            //   9: aload_0
            //   10: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   13: dup
            //   14: ifnonnull -> 25
            //   17: pop
            //   18: ldc_w 'exoPlayer'
            //   21: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   24: aconst_null
            //   25: invokeinterface getMediaItemCount : ()I
            //   30: ifne -> 35
            //   33: aconst_null
            //   34: areturn
            //   35: aload_0
            //   36: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   39: dup
            //   40: ifnonnull -> 51
            //   43: pop
            //   44: ldc_w 'exoPlayer'
            //   47: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   50: aconst_null
            //   51: invokeinterface getCurrentMediaItemIndex : ()I
            //   56: istore_1
            //   57: iconst_0
            //   58: iload_1
            //   59: if_icmpgt -> 83
            //   62: iload_1
            //   63: aload_0
            //   64: getfield musicInfoCache : Ljava/util/List;
            //   67: invokeinterface size : ()I
            //   72: if_icmpge -> 79
            //   75: iconst_1
            //   76: goto -> 84
            //   79: iconst_0
            //   80: goto -> 84
            //   83: iconst_0
            //   84: ifne -> 89
            //   87: aconst_null
            //   88: areturn
            //   89: aload_0
            //   90: getfield musicInfoCache : Ljava/util/List;
            //   93: iload_1
            //   94: invokeinterface get : (I)Ljava/lang/Object;
            //   99: checkcast com/etouch/service/MusicInfo
            //   102: astore_2
            //   103: aload_0
            //   104: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   107: dup
            //   108: ifnonnull -> 119
            //   111: pop
            //   112: ldc_w 'exoPlayer'
            //   115: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   118: aconst_null
            //   119: invokeinterface getPlaybackState : ()I
            //   124: iconst_3
            //   125: if_icmpne -> 178
            //   128: aload_0
            //   129: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   132: dup
            //   133: ifnonnull -> 144
            //   136: pop
            //   137: ldc_w 'exoPlayer'
            //   140: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   143: aconst_null
            //   144: invokeinterface getDuration : ()J
            //   149: lconst_0
            //   150: lcmp
            //   151: ifle -> 178
            //   154: aload_0
            //   155: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   158: dup
            //   159: ifnonnull -> 170
            //   162: pop
            //   163: ldc_w 'exoPlayer'
            //   166: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   169: aconst_null
            //   170: invokeinterface getDuration : ()J
            //   175: goto -> 182
            //   178: aload_0
            //   179: getfield lastKnownDuration : J
            //   182: lstore_3
            //   183: aload_0
            //   184: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   187: dup
            //   188: ifnonnull -> 199
            //   191: pop
            //   192: ldc_w 'exoPlayer'
            //   195: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   198: aconst_null
            //   199: invokeinterface getPlaybackState : ()I
            //   204: iconst_3
            //   205: if_icmpne -> 232
            //   208: aload_0
            //   209: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
            //   212: dup
            //   213: ifnonnull -> 224
            //   216: pop
            //   217: ldc_w 'exoPlayer'
            //   220: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
            //   223: aconst_null
            //   224: invokeinterface getCurrentPosition : ()J
            //   229: goto -> 236
            //   232: aload_0
            //   233: getfield lastKnownPosition : J
            //   236: lstore #5
            //   238: aload_2
            //   239: aconst_null
            //   240: aconst_null
            //   241: aconst_null
            //   242: aconst_null
            //   243: aconst_null
            //   244: getstatic com/etouch/service/MusicService.Companion : Lcom/etouch/service/MusicService$Companion;
            //   247: lload_3
            //   248: invokevirtual formatTime : (J)Ljava/lang/String;
            //   251: lload #5
            //   253: l2d
            //   254: ldc2_w 1000.0
            //   257: ddiv
            //   258: invokestatic valueOf : (D)Ljava/lang/Double;
            //   261: iload_1
            //   262: invokestatic valueOf : (I)Ljava/lang/Integer;
            //   265: aconst_null
            //   266: sipush #287
            //   269: aconst_null
            //   270: invokestatic copy$default : (Lcom/etouch/service/MusicInfo;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Double;Ljava/lang/Integer;Ljava/lang/String;ILjava/lang/Object;)Lcom/etouch/service/MusicInfo;
            //   273: areturn
            // Line number table:
            //   Java source line number -> byte code offset
            //   #828	-> 0
            //   #829	-> 9
            //   #831	-> 35
            //   #832	-> 57
            //   #834	-> 89
            //   #838	-> 103
            //   #839	-> 154
            //   #841	-> 178
            //   #838	-> 182
            //   #837	-> 182
            //   #844	-> 183
            //   #845	-> 208
            //   #847	-> 232
            //   #844	-> 236
            //   #843	-> 236
            //   #849	-> 238
            //   #850	-> 244
            //   #851	-> 251
            //   #852	-> 261
            //   #849	-> 265
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   57	217	1	currentIndex	I
            //   103	171	2	cacheMusic	Lcom/etouch/service/MusicInfo;
            //   183	91	3	realDurationMs	J
            //   238	36	5	realPositionMs	J
            //   0	274	0	this	Lcom/etouch/service/MusicService; } public final int getCurrentPlayingIndex() { if (this.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  return (this.exoPlayer != null) ? null.getCurrentMediaItemIndex() : -1; } @NotNull public final String getCurrentPlayingPath() { if (this.exoPlayer == null) Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");  int currentIndex = (this.exoPlayer != null) ? null.getCurrentMediaItemIndex() : -1; if (currentIndex >= 0 && currentIndex < this.musicInfoCache.size()) { if (((MusicInfo)this.musicInfoCache.get(currentIndex)).getPath() == null) ((MusicInfo)this.musicInfoCache.get(currentIndex)).getPath();  } else {  }  return ""; }
            public final void audioPlayerAddItemsToPlayList (@NotNull List newMusicList){ // Byte code:
                //   0: aload_1
                //   1: ldc_w 'newMusicList'
                //   4: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
                //   7: aload_0
                //   8: invokespecial getMainHandler : ()Landroid/os/Handler;
                //   11: aload_1
                //   12: aload_0
                //   13: <illegal opcode> run : (Ljava/util/List;Lcom/etouch/service/MusicService;)Ljava/lang/Runnable;
                //   18: invokevirtual post : (Ljava/lang/Runnable;)Z
                //   21: pop
                //   22: return
                // Line number table:
                //   Java source line number -> byte code offset
                //   #883	-> 7
                //   #890	-> 22
                // Local variable table:
                //   start	length	slot	name	descriptor
                //   0	23	0	this	Lcom/etouch/service/MusicService;
                //   0	23	1	newMusicList	Ljava/util/List; }
                private static final void audioPlayerAddItemsToPlayList$lambda$17 (List < ? extends
                MusicInfo > $newMusicList, MusicService this$0){
                    Intrinsics.checkNotNullParameter($newMusicList, "$newMusicList");
                    Intrinsics.checkNotNullParameter(this$0, "this$0");
                    if ($newMusicList.isEmpty()) return;
                    Iterable<? extends MusicInfo> $this$map$iv = $newMusicList;
                    int $i$f$map = 0;
                    Iterable<? extends MusicInfo> iterable1 = $this$map$iv;
                    Collection<MediaItem> destination$iv$iv = new ArrayList(CollectionsKt.collectionSizeOrDefault($this$map$iv, 10));
                    int $i$f$mapTo = 0;
                    for (Object item$iv$iv : iterable1) {
                        MusicInfo musicInfo = (MusicInfo) item$iv$iv;
                        Collection<MediaItem> collection = destination$iv$iv;
                        int $i$a$ -map - MusicService$audioPlayerAddItemsToPlayList$1$mediaItems$1 = 0;
                        collection.add(MediaItem.fromUri(musicInfo.getUri()));
                    } List mediaItems = (List) destination$iv$iv;
                    if (this$0.exoPlayer == null)
                        Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                    null.addMediaItems(mediaItems);
                    this$0.musicInfoCache.addAll($newMusicList);
                }


                private final Notification buildEmptyNotification () {
                    Intrinsics.checkNotNullExpressionValue((new NotificationCompat.Builder((Context) this, "music_channel")).setSmallIcon(17301540).setContentTitle("Music Service").setContentText("Initializing...").build(), "build(...)");
                    return (new NotificationCompat.Builder((Context) this, "music_channel")).setSmallIcon(17301540).setContentTitle("Music Service").setContentText("Initializing...").build();
                }

                private final void loadCoverAndUpdateNotification (MusicInfo currentMusic, NotificationCompat.Builder
                baseBuilder, NotificationCompat.MediaStyle mediaStyle){
                    Bitmap defaultCover = BitmapFactory.decodeResource(getResources(), R.mipmap.icon_default_cover);
                    baseBuilder.setLargeIcon(defaultCover);
                    BuildersKt.launch$default((CoroutineScope) GlobalScope.INSTANCE, (CoroutineContext) Dispatchers.getIO(), null, new MusicService$loadCoverAndUpdateNotification$1(defaultCover, this, baseBuilder, mediaStyle, null), 2, null);
                }

                @DebugMetadata(f = "MusicService.kt", l = {930}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.service.MusicService$loadCoverAndUpdateNotification$1")
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
                @SourceDebugExtension({"SMAP\nMusicService.kt\nKotlin\n*S Kotlin\n*F\n+ 1 MusicService.kt\ncom/etouch/service/MusicService$loadCoverAndUpdateNotification$1\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,1183:1\n1#2:1184\n*E\n"})
                static final class MusicService$loadCoverAndUpdateNotification$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
                    int label;

                    MusicService$loadCoverAndUpdateNotification$1(Bitmap $defaultCover, MusicService $receiver, NotificationCompat.Builder $baseBuilder, NotificationCompat.MediaStyle $mediaStyle, Continuation $completion) {
                        super(2, $completion);
                    }

                    @Nullable
                    public final Object invokeSuspend(@NotNull Object $result) {
                        // Byte code:
                        //   0: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
                        //   3: astore #12
                        //   5: aload_0
                        //   6: getfield label : I
                        //   9: tableswitch default -> 248, 0 -> 32, 1 -> 238
                        //   32: aload_1
                        //   33: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   36: nop
                        //   37: aload_0
                        //   38: getfield $currentMusic : Lcom/etouch/service/MusicInfo;
                        //   41: invokevirtual getCover : ()Ljava/lang/String;
                        //   44: dup
                        //   45: ifnull -> 169
                        //   48: astore #5
                        //   50: aload #5
                        //   52: astore #6
                        //   54: iconst_0
                        //   55: istore #7
                        //   57: aload #6
                        //   59: checkcast java/lang/CharSequence
                        //   62: invokeinterface length : ()I
                        //   67: ifle -> 74
                        //   70: iconst_1
                        //   71: goto -> 75
                        //   74: iconst_0
                        //   75: nop
                        //   76: ifeq -> 84
                        //   79: aload #5
                        //   81: goto -> 85
                        //   84: aconst_null
                        //   85: dup
                        //   86: ifnull -> 169
                        //   89: astore #6
                        //   91: aload_0
                        //   92: getfield this$0 : Lcom/etouch/service/MusicService;
                        //   95: astore #7
                        //   97: aload #6
                        //   99: astore #8
                        //   101: iconst_0
                        //   102: istore #9
                        //   104: aload #7
                        //   106: invokevirtual getResources : ()Landroid/content/res/Resources;
                        //   109: invokevirtual getDisplayMetrics : ()Landroid/util/DisplayMetrics;
                        //   112: getfield density : F
                        //   115: fstore #10
                        //   117: sipush #200
                        //   120: i2f
                        //   121: fload #10
                        //   123: fmul
                        //   124: f2i
                        //   125: istore #11
                        //   127: aload #7
                        //   129: checkcast android/content/Context
                        //   132: invokestatic with : (Landroid/content/Context;)Lcom/bumptech/glide/RequestManager;
                        //   135: invokevirtual asBitmap : ()Lcom/bumptech/glide/RequestBuilder;
                        //   138: aload #8
                        //   140: invokevirtual load : (Ljava/lang/String;)Lcom/bumptech/glide/RequestBuilder;
                        //   143: iload #11
                        //   145: iload #11
                        //   147: invokevirtual submit : (II)Lcom/bumptech/glide/request/FutureTarget;
                        //   150: ldc2_w 10
                        //   153: getstatic java/util/concurrent/TimeUnit.SECONDS : Ljava/util/concurrent/TimeUnit;
                        //   156: invokeinterface get : (JLjava/util/concurrent/TimeUnit;)Ljava/lang/Object;
                        //   161: checkcast android/graphics/Bitmap
                        //   164: nop
                        //   165: dup
                        //   166: ifnonnull -> 174
                        //   169: pop
                        //   170: aload_0
                        //   171: getfield $defaultCover : Landroid/graphics/Bitmap;
                        //   174: astore_3
                        //   175: goto -> 185
                        //   178: astore #4
                        //   180: aload_0
                        //   181: getfield $defaultCover : Landroid/graphics/Bitmap;
                        //   184: astore_3
                        //   185: aload_3
                        //   186: astore_2
                        //   187: invokestatic getMain : ()Lkotlinx/coroutines/MainCoroutineDispatcher;
                        //   190: checkcast kotlin/coroutines/CoroutineContext
                        //   193: new com/etouch/service/MusicService$loadCoverAndUpdateNotification$1$1
                        //   196: dup
                        //   197: aload_0
                        //   198: getfield this$0 : Lcom/etouch/service/MusicService;
                        //   201: aload_0
                        //   202: getfield $baseBuilder : Landroidx/core/app/NotificationCompat$Builder;
                        //   205: aload_2
                        //   206: aload_0
                        //   207: getfield $mediaStyle : Landroidx/media/app/NotificationCompat$MediaStyle;
                        //   210: aconst_null
                        //   211: invokespecial <init> : (Lcom/etouch/service/MusicService;Landroidx/core/app/NotificationCompat$Builder;Landroid/graphics/Bitmap;Landroidx/media/app/NotificationCompat$MediaStyle;Lkotlin/coroutines/Continuation;)V
                        //   214: checkcast kotlin/jvm/functions/Function2
                        //   217: aload_0
                        //   218: checkcast kotlin/coroutines/Continuation
                        //   221: aload_0
                        //   222: iconst_1
                        //   223: putfield label : I
                        //   226: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
                        //   229: dup
                        //   230: aload #12
                        //   232: if_acmpne -> 243
                        //   235: aload #12
                        //   237: areturn
                        //   238: aload_1
                        //   239: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                        //   242: aload_1
                        //   243: pop
                        //   244: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                        //   247: areturn
                        //   248: new java/lang/IllegalStateException
                        //   251: dup
                        //   252: ldc 'call to 'resume' before 'invoke' with coroutine'
                        //   254: invokespecial <init> : (Ljava/lang/String;)V
                        //   257: athrow
                        // Line number table:
                        //   Java source line number -> byte code offset
                        //   #912	-> 3
                        //   #913	-> 36
                        //   #914	-> 37
                        //   #1184	-> 54
                        //   #914	-> 57
                        //   #914	-> 75
                        //   #914	-> 76
                        //   #914	-> 85
                        //   #915	-> 104
                        //   #916	-> 117
                        //   #917	-> 127
                        //   #918	-> 135
                        //   #919	-> 138
                        //   #920	-> 143
                        //   #921	-> 150
                        //   #914	-> 164
                        //   #914	-> 165
                        //   #922	-> 170
                        //   #923	-> 178
                        //   #926	-> 180
                        //   #913	-> 185
                        //   #930	-> 187
                        //   #912	-> 235
                        //   #944	-> 243
                        //   #912	-> 248
                        // Local variable table:
                        //   start	length	slot	name	descriptor
                        //   187	42	2	coverBitmap	Landroid/graphics/Bitmap;
                        //   54	20	6	it	Ljava/lang/String;
                        //   101	63	8	coverUrl	Ljava/lang/String;
                        //   117	47	10	density	F
                        //   127	37	11	coverSize	I
                        //   57	19	7	$i$a$-takeIf-MusicService$loadCoverAndUpdateNotification$1$coverBitmap$1	I
                        //   104	60	9	$i$a$-let-MusicService$loadCoverAndUpdateNotification$1$coverBitmap$2	I
                        //   36	212	0	this	Lcom/etouch/service/MusicService$loadCoverAndUpdateNotification$1;
                        //   36	212	1	$result	Ljava/lang/Object;
                        // Exception table:
                        //   from	to	target	type
                        //   36	175	178	java/lang/Exception
                    }

                    @NotNull
                    public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super MusicService$loadCoverAndUpdateNotification$1> $completion) {
                        return (Continuation<Unit>) new MusicService$loadCoverAndUpdateNotification$1(this.$defaultCover, MusicService.this, this.$baseBuilder, this.$mediaStyle, $completion);
                    }

                    @Nullable
                    public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                        return ((MusicService$loadCoverAndUpdateNotification$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
                    }
                }

                private final Notification buildNotification () {
                    // Byte code:
                    //   0: new androidx/core/app/NotificationCompat$Builder
                    //   3: dup
                    //   4: aload_0
                    //   5: checkcast android/content/Context
                    //   8: ldc_w 'music_channel'
                    //   11: invokespecial <init> : (Landroid/content/Context;Ljava/lang/String;)V
                    //   14: ldc_w 17301540
                    //   17: invokevirtual setSmallIcon : (I)Landroidx/core/app/NotificationCompat$Builder;
                    //   20: iconst_1
                    //   21: invokevirtual setVisibility : (I)Landroidx/core/app/NotificationCompat$Builder;
                    //   24: aload_0
                    //   25: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   28: ifnull -> 59
                    //   31: aload_0
                    //   32: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   35: dup
                    //   36: ifnonnull -> 47
                    //   39: pop
                    //   40: ldc_w 'exoPlayer'
                    //   43: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   46: aconst_null
                    //   47: invokeinterface isPlaying : ()Z
                    //   52: ifeq -> 59
                    //   55: iconst_1
                    //   56: goto -> 60
                    //   59: iconst_0
                    //   60: invokevirtual setOngoing : (Z)Landroidx/core/app/NotificationCompat$Builder;
                    //   63: dup
                    //   64: ldc_w 'setOngoing(...)'
                    //   67: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
                    //   70: astore_1
                    //   71: new androidx/media/app/NotificationCompat$MediaStyle
                    //   74: dup
                    //   75: invokespecial <init> : ()V
                    //   78: astore_2
                    //   79: aload_0
                    //   80: getfield mediaSession : Landroid/support/v4/media/session/MediaSessionCompat;
                    //   83: ifnull -> 110
                    //   86: aload_2
                    //   87: aload_0
                    //   88: getfield mediaSession : Landroid/support/v4/media/session/MediaSessionCompat;
                    //   91: dup
                    //   92: ifnonnull -> 103
                    //   95: pop
                    //   96: ldc_w 'mediaSession'
                    //   99: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   102: aconst_null
                    //   103: invokevirtual getSessionToken : ()Landroid/support/v4/media/session/MediaSessionCompat$Token;
                    //   106: invokevirtual setMediaSession : (Landroid/support/v4/media/session/MediaSessionCompat$Token;)Landroidx/media/app/NotificationCompat$MediaStyle;
                    //   109: pop
                    //   110: aload_0
                    //   111: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   114: ifnull -> 141
                    //   117: aload_0
                    //   118: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   121: dup
                    //   122: ifnonnull -> 133
                    //   125: pop
                    //   126: ldc_w 'exoPlayer'
                    //   129: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   132: aconst_null
                    //   133: invokeinterface getMediaItemCount : ()I
                    //   138: ifne -> 164
                    //   141: aload_1
                    //   142: ldc_w 'No music playing'
                    //   145: checkcast java/lang/CharSequence
                    //   148: invokevirtual setContentTitle : (Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;
                    //   151: ldc_w '00:00/00:00'
                    //   154: checkcast java/lang/CharSequence
                    //   157: invokevirtual setContentText : (Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;
                    //   160: pop
                    //   161: goto -> 580
                    //   164: aload_0
                    //   165: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   168: dup
                    //   169: ifnonnull -> 180
                    //   172: pop
                    //   173: ldc_w 'exoPlayer'
                    //   176: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   179: aconst_null
                    //   180: invokeinterface getCurrentMediaItemIndex : ()I
                    //   185: istore_3
                    //   186: iload_3
                    //   187: iflt -> 219
                    //   190: iload_3
                    //   191: aload_0
                    //   192: getfield musicInfoCache : Ljava/util/List;
                    //   195: invokeinterface size : ()I
                    //   200: if_icmpge -> 219
                    //   203: aload_0
                    //   204: getfield musicInfoCache : Ljava/util/List;
                    //   207: iload_3
                    //   208: invokeinterface get : (I)Ljava/lang/Object;
                    //   213: checkcast com/etouch/service/MusicInfo
                    //   216: goto -> 249
                    //   219: new com/etouch/service/MusicInfo
                    //   222: dup
                    //   223: ldc_w ''
                    //   226: ldc_w ''
                    //   229: ldc_w 'Unknown'
                    //   232: ldc_w 'Unknown'
                    //   235: ldc_w ''
                    //   238: aconst_null
                    //   239: aconst_null
                    //   240: aconst_null
                    //   241: aconst_null
                    //   242: sipush #480
                    //   245: aconst_null
                    //   246: invokespecial <init> : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Double;Ljava/lang/Integer;Ljava/lang/String;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
                    //   249: astore #4
                    //   251: aload_0
                    //   252: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   255: dup
                    //   256: ifnonnull -> 267
                    //   259: pop
                    //   260: ldc_w 'exoPlayer'
                    //   263: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   266: aconst_null
                    //   267: invokeinterface isPlaying : ()Z
                    //   272: istore #5
                    //   274: aload_0
                    //   275: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   278: dup
                    //   279: ifnonnull -> 290
                    //   282: pop
                    //   283: ldc_w 'exoPlayer'
                    //   286: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   289: aconst_null
                    //   290: invokeinterface getCurrentPosition : ()J
                    //   295: lstore #6
                    //   297: aload_0
                    //   298: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   301: dup
                    //   302: ifnonnull -> 313
                    //   305: pop
                    //   306: ldc_w 'exoPlayer'
                    //   309: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   312: aconst_null
                    //   313: invokeinterface getDuration : ()J
                    //   318: lstore #8
                    //   320: getstatic com/etouch/service/MusicService.Companion : Lcom/etouch/service/MusicService$Companion;
                    //   323: lload #6
                    //   325: invokevirtual formatTime : (J)Ljava/lang/String;
                    //   328: astore #10
                    //   330: getstatic com/etouch/service/MusicService.Companion : Lcom/etouch/service/MusicService$Companion;
                    //   333: lload #8
                    //   335: invokevirtual formatTime : (J)Ljava/lang/String;
                    //   338: astore #11
                    //   340: lload #6
                    //   342: l2i
                    //   343: istore #12
                    //   345: lload #8
                    //   347: ldc2_w -9223372036854775807
                    //   350: lcmp
                    //   351: ifeq -> 361
                    //   354: lload #8
                    //   356: lconst_0
                    //   357: lcmp
                    //   358: ifge -> 365
                    //   361: iconst_1
                    //   362: goto -> 368
                    //   365: lload #8
                    //   367: l2i
                    //   368: istore #13
                    //   370: aload_1
                    //   371: aload #4
                    //   373: invokevirtual getTitle : ()Ljava/lang/String;
                    //   376: checkcast java/lang/CharSequence
                    //   379: invokevirtual setContentTitle : (Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;
                    //   382: aload #4
                    //   384: invokevirtual getArtist : ()Ljava/lang/String;
                    //   387: aload #10
                    //   389: aload #11
                    //   391: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
                    //   396: checkcast java/lang/CharSequence
                    //   399: invokevirtual setContentText : (Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;
                    //   402: iload #13
                    //   404: iload #12
                    //   406: iconst_0
                    //   407: invokevirtual setProgress : (IIZ)Landroidx/core/app/NotificationCompat$Builder;
                    //   410: pop
                    //   411: new androidx/core/app/NotificationCompat$Action
                    //   414: dup
                    //   415: ldc_w 17301541
                    //   418: ldc_w 'Prev'
                    //   421: checkcast java/lang/CharSequence
                    //   424: aload_0
                    //   425: checkcast android/content/Context
                    //   428: ldc2_w 16
                    //   431: invokestatic buildMediaButtonPendingIntent : (Landroid/content/Context;J)Landroid/app/PendingIntent;
                    //   434: invokespecial <init> : (ILjava/lang/CharSequence;Landroid/app/PendingIntent;)V
                    //   437: astore #14
                    //   439: new androidx/core/app/NotificationCompat$Action
                    //   442: dup
                    //   443: iload #5
                    //   445: ifeq -> 454
                    //   448: ldc_w 17301539
                    //   451: goto -> 457
                    //   454: ldc_w 17301540
                    //   457: iload #5
                    //   459: ifeq -> 468
                    //   462: ldc_w 'Pause'
                    //   465: goto -> 471
                    //   468: ldc_w 'Play'
                    //   471: checkcast java/lang/CharSequence
                    //   474: aload_0
                    //   475: checkcast android/content/Context
                    //   478: iload #5
                    //   480: ifeq -> 489
                    //   483: ldc2_w 2
                    //   486: goto -> 492
                    //   489: ldc2_w 4
                    //   492: invokestatic buildMediaButtonPendingIntent : (Landroid/content/Context;J)Landroid/app/PendingIntent;
                    //   495: invokespecial <init> : (ILjava/lang/CharSequence;Landroid/app/PendingIntent;)V
                    //   498: astore #15
                    //   500: new androidx/core/app/NotificationCompat$Action
                    //   503: dup
                    //   504: ldc_w 17301538
                    //   507: ldc_w 'Next'
                    //   510: checkcast java/lang/CharSequence
                    //   513: aload_0
                    //   514: checkcast android/content/Context
                    //   517: ldc2_w 32
                    //   520: invokestatic buildMediaButtonPendingIntent : (Landroid/content/Context;J)Landroid/app/PendingIntent;
                    //   523: invokespecial <init> : (ILjava/lang/CharSequence;Landroid/app/PendingIntent;)V
                    //   526: astore #16
                    //   528: aload_1
                    //   529: aload #14
                    //   531: invokevirtual addAction : (Landroidx/core/app/NotificationCompat$Action;)Landroidx/core/app/NotificationCompat$Builder;
                    //   534: aload #15
                    //   536: invokevirtual addAction : (Landroidx/core/app/NotificationCompat$Action;)Landroidx/core/app/NotificationCompat$Builder;
                    //   539: aload #16
                    //   541: invokevirtual addAction : (Landroidx/core/app/NotificationCompat$Action;)Landroidx/core/app/NotificationCompat$Builder;
                    //   544: pop
                    //   545: aload_2
                    //   546: iconst_3
                    //   547: newarray int
                    //   549: astore #17
                    //   551: aload #17
                    //   553: iconst_0
                    //   554: iconst_0
                    //   555: iastore
                    //   556: aload #17
                    //   558: iconst_1
                    //   559: iconst_1
                    //   560: iastore
                    //   561: aload #17
                    //   563: iconst_2
                    //   564: iconst_2
                    //   565: iastore
                    //   566: aload #17
                    //   568: invokevirtual setShowActionsInCompactView : ([I)Landroidx/media/app/NotificationCompat$MediaStyle;
                    //   571: pop
                    //   572: aload_0
                    //   573: aload #4
                    //   575: aload_1
                    //   576: aload_2
                    //   577: invokespecial loadCoverAndUpdateNotification : (Lcom/etouch/service/MusicInfo;Landroidx/core/app/NotificationCompat$Builder;Landroidx/media/app/NotificationCompat$MediaStyle;)V
                    //   580: aload_1
                    //   581: aload_2
                    //   582: checkcast androidx/core/app/NotificationCompat$Style
                    //   585: invokevirtual setStyle : (Landroidx/core/app/NotificationCompat$Style;)Landroidx/core/app/NotificationCompat$Builder;
                    //   588: invokevirtual build : ()Landroid/app/Notification;
                    //   591: dup
                    //   592: ldc 'build(...)'
                    //   594: invokestatic checkNotNullExpressionValue : (Ljava/lang/Object;Ljava/lang/String;)V
                    //   597: areturn
                    // Line number table:
                    //   Java source line number -> byte code offset
                    //   #949	-> 0
                    //   #950	-> 14
                    //   #951	-> 20
                    //   #952	-> 24
                    //   #949	-> 70
                    //   #954	-> 71
                    //   #955	-> 79
                    //   #956	-> 86
                    //   #959	-> 110
                    //   #960	-> 141
                    //   #961	-> 142
                    //   #962	-> 151
                    //   #964	-> 164
                    //   #965	-> 186
                    //   #966	-> 203
                    //   #968	-> 219
                    //   #965	-> 249
                    //   #971	-> 251
                    //   #972	-> 274
                    //   #973	-> 297
                    //   #975	-> 320
                    //   #976	-> 330
                    //   #977	-> 340
                    //   #979	-> 345
                    //   #978	-> 368
                    //   #982	-> 370
                    //   #983	-> 371
                    //   #984	-> 382
                    //   #985	-> 402
                    //   #988	-> 411
                    //   #989	-> 415
                    //   #990	-> 418
                    //   #992	-> 424
                    //   #993	-> 428
                    //   #991	-> 431
                    //   #988	-> 434
                    //   #996	-> 439
                    //   #997	-> 443
                    //   #998	-> 457
                    //   #1000	-> 474
                    //   #1001	-> 478
                    //   #999	-> 492
                    //   #996	-> 495
                    //   #1004	-> 500
                    //   #1005	-> 504
                    //   #1006	-> 507
                    //   #1008	-> 513
                    //   #1009	-> 517
                    //   #1007	-> 520
                    //   #1004	-> 523
                    //   #1013	-> 528
                    //   #1014	-> 529
                    //   #1015	-> 534
                    //   #1016	-> 539
                    //   #1018	-> 545
                    //   #1021	-> 572
                    //   #1024	-> 580
                    // Local variable table:
                    //   start	length	slot	name	descriptor
                    //   186	394	3	currentIndex	I
                    //   251	329	4	currentMusic	Lcom/etouch/service/MusicInfo;
                    //   274	306	5	isPlaying	Z
                    //   297	283	6	currentPos	J
                    //   320	260	8	totalDuration	J
                    //   330	250	10	currentTimeStr	Ljava/lang/String;
                    //   340	240	11	totalTimeStr	Ljava/lang/String;
                    //   345	235	12	progress	I
                    //   370	210	13	total	I
                    //   439	141	14	prevAction	Landroidx/core/app/NotificationCompat$Action;
                    //   500	80	15	playPauseAction	Landroidx/core/app/NotificationCompat$Action;
                    //   528	52	16	nextAction	Landroidx/core/app/NotificationCompat$Action;
                    //   71	527	1	notificationBuilder	Landroidx/core/app/NotificationCompat$Builder;
                    //   79	519	2	mediaStyle	Landroidx/media/app/NotificationCompat$MediaStyle;
                    //   0	598	0	this	Lcom/etouch/service/MusicService;
                }

                private final void updateNotification () {
                    getMainHandler().post(this::updateNotification$lambda$18);
                }

                private static final void updateNotification$lambda$18 (MusicService this$0){
                    Intrinsics.checkNotNullParameter(this$0, "this$0");
                    try {
                        if (this$0.isNotificationManuallyHidden)
                            return;
                        Notification notification = this$0.buildNotification();
                        this$0.getNotificationManager().notify(1, notification);
                    } catch (Exception exception) {
                    }
                }

                public final void showNotification () {
                    getMainHandler().post(this::showNotification$lambda$19);
                }

                private static final void showNotification$lambda$19 (MusicService this$0){
                    Intrinsics.checkNotNullParameter(this$0, "this$0");
                    try {
                        this$0.isNotificationManuallyHidden = false;
                        Notification notification = this$0.buildNotification();
                        this$0.startForeground(1, notification);
                        if (this$0.handler == null)
                            Intrinsics.throwUninitializedPropertyAccessException("handler");
                        null.removeCallbacks(this$0.updateRunnable);
                        if (this$0.handler == null)
                            Intrinsics.throwUninitializedPropertyAccessException("handler");
                        null.post(this$0.updateRunnable);
                    } catch (Exception exception) {
                    }
                }

                public final void hideNotification ( boolean keepServiceAlive){
                    // Byte code:
                    //   0: aload_0
                    //   1: invokespecial getMainHandler : ()Landroid/os/Handler;
                    //   4: aload_0
                    //   5: iload_1
                    //   6: <illegal opcode> run : (Lcom/etouch/service/MusicService;Z)Ljava/lang/Runnable;
                    //   11: invokevirtual post : (Ljava/lang/Runnable;)Z
                    //   14: pop
                    //   15: return
                    // Line number table:
                    //   Java source line number -> byte code offset
                    //   #1085	-> 0
                    //   #1110	-> 15
                    // Local variable table:
                    //   start	length	slot	name	descriptor
                    //   0	16	0	this	Lcom/etouch/service/MusicService;
                    //   0	16	1	keepServiceAlive	Z
                }

                private static final void hideNotification$lambda$20 (MusicService this$0,boolean $keepServiceAlive){
                    Intrinsics.checkNotNullParameter(this$0, "this$0");
                    try {
                        this$0.isNotificationManuallyHidden = true;
                        this$0.stopForeground(1);
                        this$0.getNotificationManager().cancel(1);
                        Handler handler = this$0.handler;
                        if (handler == null)
                            Intrinsics.throwUninitializedPropertyAccessException("handler");
                        null.removeCallbacks(this$0.updateRunnable);
                        if (!$keepServiceAlive)
                            this$0.stopSelf();
                    } catch (Exception exception) {
                    }
                }

                private final void updateMetadata () {
                    if (this.mediaSession != null && this.exoPlayer != null) {
                        if (this.exoPlayer == null)
                            Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                        if (null.getMediaItemCount() != 0) {
                            if (this.exoPlayer == null)
                                Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                            int currentIndex = null.getCurrentMediaItemIndex();
                            if (currentIndex >= 0 && currentIndex < this.musicInfoCache.size()) {

                            } else {
                                return;
                            }
                            ExoPlayer exoPlayer = this.exoPlayer;
                            if (this.exoPlayer == null)
                                Intrinsics.throwUninitializedPropertyAccessException("exoPlayer");
                            MediaMetadataCompat.Builder metadataBuilder = "android.media.metadata.DURATION".putLong((String) this.exoPlayer, null.getDuration()).putString("android.media.metadata.ALBUM_ART_URI", exoPlayer.getCover());
                            if (this.mediaSession == null)
                                Intrinsics.throwUninitializedPropertyAccessException("mediaSession");
                            null.setMetadata(metadataBuilder.build());
                            return;
                        }
                    }
                }

                public final void audioPlayerGetPlayingListInfo () {
                    getMainHandler().post(this::audioPlayerGetPlayingListInfo$lambda$21);
                }

                private static final void audioPlayerGetPlayingListInfo$lambda$21 (MusicService this$0){
                    Intrinsics.checkNotNullParameter(this$0, "this$0");
                    try {
                        UnityPlayer.UnitySendMessage("Boot", "audioPlayerGetPlayingListInfo", this$0.getGson().toJson(this$0.musicInfoCache));
                    } catch (Exception exception) {
                    }
                }

                private final void createChannel () {
                    if (Build.VERSION.SDK_INT >= 26) {
                        NotificationChannel notificationChannel1 = new NotificationChannel("music_channel", "Music Playback", 2);
                        NotificationChannel $this$createChannel_u24lambda_u2422 = notificationChannel1;
                        int $i$a$ -apply - MusicService$createChannel$channel$1 = 0;
                        $this$createChannel_u24lambda_u2422.setLockscreenVisibility(1);
                        $this$createChannel_u24lambda_u2422.setShowBadge(false);
                        NotificationChannel channel = notificationChannel1;
                        if ((NotificationManager) getSystemService(NotificationManager.class) != null) {
                            ((NotificationManager) getSystemService(NotificationManager.class)).createNotificationChannel(channel);
                        } else {
                            (NotificationManager) getSystemService(NotificationManager.class);
                        }
                    }
                }

                private final void updatePlaybackState () {
                    // Byte code:
                    //   0: aload_0
                    //   1: getfield mediaSession : Landroid/support/v4/media/session/MediaSessionCompat;
                    //   4: ifnonnull -> 8
                    //   7: return
                    //   8: aload_0
                    //   9: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   12: ifnull -> 43
                    //   15: aload_0
                    //   16: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   19: dup
                    //   20: ifnonnull -> 31
                    //   23: pop
                    //   24: ldc_w 'exoPlayer'
                    //   27: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   30: aconst_null
                    //   31: invokeinterface isPlaying : ()Z
                    //   36: ifeq -> 43
                    //   39: iconst_3
                    //   40: goto -> 44
                    //   43: iconst_2
                    //   44: istore_1
                    //   45: new android/support/v4/media/session/PlaybackStateCompat$Builder
                    //   48: dup
                    //   49: invokespecial <init> : ()V
                    //   52: ldc2_w 310
                    //   55: invokevirtual setActions : (J)Landroid/support/v4/media/session/PlaybackStateCompat$Builder;
                    //   58: iload_1
                    //   59: aload_0
                    //   60: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   63: ifnull -> 90
                    //   66: aload_0
                    //   67: getfield exoPlayer : Lcom/google/android/exoplayer2/ExoPlayer;
                    //   70: dup
                    //   71: ifnonnull -> 82
                    //   74: pop
                    //   75: ldc_w 'exoPlayer'
                    //   78: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   81: aconst_null
                    //   82: invokeinterface getCurrentPosition : ()J
                    //   87: goto -> 91
                    //   90: lconst_0
                    //   91: fconst_1
                    //   92: invokevirtual setState : (IJF)Landroid/support/v4/media/session/PlaybackStateCompat$Builder;
                    //   95: invokevirtual build : ()Landroid/support/v4/media/session/PlaybackStateCompat;
                    //   98: astore_2
                    //   99: aload_0
                    //   100: getfield mediaSession : Landroid/support/v4/media/session/MediaSessionCompat;
                    //   103: dup
                    //   104: ifnonnull -> 115
                    //   107: pop
                    //   108: ldc_w 'mediaSession'
                    //   111: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                    //   114: aconst_null
                    //   115: aload_2
                    //   116: invokevirtual setPlaybackState : (Landroid/support/v4/media/session/PlaybackStateCompat;)V
                    //   119: return
                    // Line number table:
                    //   Java source line number -> byte code offset
                    //   #1163	-> 0
                    //   #1165	-> 8
                    //   #1166	-> 39
                    //   #1168	-> 43
                    //   #1165	-> 44
                    //   #1171	-> 45
                    //   #1173	-> 52
                    //   #1172	-> 55
                    //   #1179	-> 58
                    //   #1180	-> 95
                    //   #1171	-> 98
                    //   #1181	-> 99
                    //   #1182	-> 119
                    // Local variable table:
                    //   start	length	slot	name	descriptor
                    //   45	75	1	state	I
                    //   99	21	2	playbackState	Landroid/support/v4/media/session/PlaybackStateCompat;
                    //   0	120	0	this	Lcom/etouch/service/MusicService;
                }

                @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\030\n\002\030\002\n\002\020\000\n\000\n\002\020\002\n\000\n\002\020\016\n\002\b\002\bf\030\0002\0020\001J\020\020\002\032\0020\0032\006\020\004\032\0020\005H&J\b\020\006\032\0020\003H&¨\006\007"}, d2 = {"Lcom/etouch/service/MusicService$PlayItemCallback;", "", "onError", "", "message", "", "onSuccess", "sdk_android_unity_bridge_v1_debug"})
                public static interface PlayItemCallback {
                    void onSuccess();

                    void onError(@NotNull String param1String);
                }

                @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\030\n\002\030\002\n\002\020\000\n\000\n\002\020\002\n\000\n\002\020\016\n\002\b\002\bf\030\0002\0020\001J\020\020\002\032\0020\0032\006\020\004\032\0020\005H&J\b\020\006\032\0020\003H&¨\006\007"}, d2 = {"Lcom/etouch/service/MusicService$PlaylistCallback;", "", "onError", "", "message", "", "onSuccess", "sdk_android_unity_bridge_v1_debug"})
                public static interface PlaylistCallback {
                    void onSuccess();

                    void onError(@NotNull String param1String);
                }
            }


