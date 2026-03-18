package com.etouch.logger;

import com.etouch.AudioFile;
import org.jetbrains.annotations.NotNull;


public final class ResonanceSessionTracker {
    @NotNull
    public static final Companion Companion = new Companion(null);
    @NotNull
    private final Context context;
    @Nullable
    private SessionData currentSession;
    @NotNull
    private static final String TAG = "ResonanceSessionTracker";
    private static final long PAUSE_TIMEOUT_MS = 180000L;

    public ResonanceSessionTracker(@NotNull Context context) {
        this.context = context;
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\030\n\002\030\002\n\002\020\000\n\002\b\002\n\002\020\t\n\000\n\002\020\016\n\000\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002R\016\020\003\032\0020\004XT¢\006\002\n\000R\016\020\005\032\0020\006XT¢\006\002\n\000¨\006\007"}, d2 = {"Lcom/etouch/logger/ResonanceSessionTracker$Companion;", "", "()V", "PAUSE_TIMEOUT_MS", "", "TAG", "", "sdk_android_unity_bridge_v1_debug"})
    public static final class Companion {
        private Companion() {
        }
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000.\n\002\030\002\n\002\020\000\n\000\n\002\020\016\n\000\n\002\020\b\n\002\b\003\n\002\030\002\n\000\n\002\020\t\n\002\b\005\n\002\020\013\n\002\b:\b\b\030\0002\0020\001B\001\022\006\020\002\032\0020\003\022\006\020\004\032\0020\005\022\006\020\006\032\0020\003\022\006\020\007\032\0020\003\022\006\020\b\032\0020\t\022\006\020\n\032\0020\013\022\006\020\f\032\0020\013\022\006\020\r\032\0020\013\022\b\b\002\020\016\032\0020\013\022\b\b\002\020\017\032\0020\013\022\b\b\002\020\020\032\0020\021\022\b\b\002\020\022\032\0020\021\022\b\b\002\020\023\032\0020\021\022\b\b\002\020\024\032\0020\021\022\n\b\002\020\025\032\004\030\0010\013¢\006\002\020\026J\t\0206\032\0020\003HÆ\003J\t\0207\032\0020\013HÆ\003J\t\0208\032\0020\021HÆ\003J\t\0209\032\0020\021HÆ\003J\t\020:\032\0020\021HÆ\003J\t\020;\032\0020\021HÆ\003J\020\020<\032\004\030\0010\013HÆ\003¢\006\002\020\"J\t\020=\032\0020\005HÆ\003J\t\020>\032\0020\003HÆ\003J\t\020?\032\0020\003HÆ\003J\t\020@\032\0020\tHÆ\003J\t\020A\032\0020\013HÆ\003J\t\020B\032\0020\013HÆ\003J\t\020C\032\0020\013HÆ\003J\t\020D\032\0020\013HÆ\003J¦\001\020E\032\0020\0002\b\b\002\020\002\032\0020\0032\b\b\002\020\004\032\0020\0052\b\b\002\020\006\032\0020\0032\b\b\002\020\007\032\0020\0032\b\b\002\020\b\032\0020\t2\b\b\002\020\n\032\0020\0132\b\b\002\020\f\032\0020\0132\b\b\002\020\r\032\0020\0132\b\b\002\020\016\032\0020\0132\b\b\002\020\017\032\0020\0132\b\b\002\020\020\032\0020\0212\b\b\002\020\022\032\0020\0212\b\b\002\020\023\032\0020\0212\b\b\002\020\024\032\0020\0212\n\b\002\020\025\032\004\030\0010\013HÆ\001¢\006\002\020FJ\023\020G\032\0020\0212\b\020H\032\004\030\0010\001HÖ\003J\t\020I\032\0020\005HÖ\001J\t\020J\032\0020\003HÖ\001R\032\020\017\032\0020\013X\016¢\006\016\n\000\032\004\b\027\020\030\"\004\b\031\020\032R\032\020\023\032\0020\021X\016¢\006\016\n\000\032\004\b\023\020\033\"\004\b\034\020\035R\032\020\024\032\0020\021X\016¢\006\016\n\000\032\004\b\024\020\033\"\004\b\036\020\035R\032\020\r\032\0020\013X\016¢\006\016\n\000\032\004\b\037\020\030\"\004\b \020\032R\036\020\025\032\004\030\0010\013X\016¢\006\020\n\002\020%\032\004\b!\020\"\"\004\b#\020$R\021\020\007\032\0020\003¢\006\b\n\000\032\004\b&\020'R\021\020\n\032\0020\013¢\006\b\n\000\032\004\b(\020\030R\021\020\004\032\0020\005¢\006\b\n\000\032\004\b)\020*R\021\020\006\032\0020\003¢\006\b\n\000\032\004\b+\020'R\021\020\b\032\0020\t¢\006\b\n\000\032\004\b,\020-R\021\020\002\032\0020\003¢\006\b\n\000\032\004\b.\020'R\021\020\f\032\0020\013¢\006\b\n\000\032\004\b/\020\030R\032\020\016\032\0020\013X\016¢\006\016\n\000\032\004\b0\020\030\"\004\b1\020\032R\032\020\022\032\0020\021X\016¢\006\016\n\000\032\004\b2\020\033\"\004\b3\020\035R\032\020\020\032\0020\021X\016¢\006\016\n\000\032\004\b4\020\033\"\004\b5\020\035¨\006K"}, d2 = {"Lcom/etouch/logger/ResonanceSessionTracker$SessionData;", "", "sessionId", "", "mediaId", "", "mediaName", "mediaAuthor", "mediaType", "Lcom/etouch/MediaType;", "mediaDurationMs", "", "sessionStartTime", "lastActiveTime", "totalPlayTimeMs", "deviceControlTimeMs", "usedSeek", "", "usedPrevNext", "isDeviceConnected", "isDeviceControlEnabled", "lastDeviceControlEnableTime", "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Lcom/etouch/MediaType;JJJJJZZZZLjava/lang/Long;)V", "getDeviceControlTimeMs", "()J", "setDeviceControlTimeMs", "(J)V", "()Z", "setDeviceConnected", "(Z)V", "setDeviceControlEnabled", "getLastActiveTime", "setLastActiveTime", "getLastDeviceControlEnableTime", "()Ljava/lang/Long;", "setLastDeviceControlEnableTime", "(Ljava/lang/Long;)V", "Ljava/lang/Long;", "getMediaAuthor", "()Ljava/lang/String;", "getMediaDurationMs", "getMediaId", "()I", "getMediaName", "getMediaType", "()Lcom/etouch/MediaType;", "getSessionId", "getSessionStartTime", "getTotalPlayTimeMs", "setTotalPlayTimeMs", "getUsedPrevNext", "setUsedPrevNext", "getUsedSeek", "setUsedSeek", "component1", "component10", "component11", "component12", "component13", "component14", "component15", "component2", "component3", "component4", "component5", "component6", "component7", "component8", "component9", "copy", "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Lcom/etouch/MediaType;JJJJJZZZZLjava/lang/Long;)Lcom/etouch/logger/ResonanceSessionTracker$SessionData;", "equals", "other", "hashCode", "toString", "sdk_android_unity_bridge_v1_debug"})
    private static final class SessionData {
        @NotNull
        private final String sessionId;
        private final int mediaId;
        @NotNull
        private final String mediaName;
        @NotNull
        private final String mediaAuthor;
        @NotNull
        private final MediaType mediaType;
        private final long mediaDurationMs;
        private final long sessionStartTime;
        private long lastActiveTime;
        private long totalPlayTimeMs;
        private long deviceControlTimeMs;
        private boolean usedSeek;
        private boolean usedPrevNext;
        private boolean isDeviceConnected;
        private boolean isDeviceControlEnabled;
        @Nullable
        private Long lastDeviceControlEnableTime;

        public SessionData(@NotNull String sessionId, int mediaId, @NotNull String mediaName, @NotNull String mediaAuthor, @NotNull MediaType mediaType, long mediaDurationMs, long sessionStartTime, long lastActiveTime, long totalPlayTimeMs, long deviceControlTimeMs, boolean usedSeek, boolean usedPrevNext, boolean isDeviceConnected, boolean isDeviceControlEnabled, @Nullable Long lastDeviceControlEnableTime) {
            this.sessionId = sessionId;
            this.mediaId = mediaId;
            this.mediaName = mediaName;
            this.mediaAuthor = mediaAuthor;
            this.mediaType = mediaType;
            this.mediaDurationMs = mediaDurationMs;
            this.sessionStartTime = sessionStartTime;
            this.lastActiveTime = lastActiveTime;
            this.totalPlayTimeMs = totalPlayTimeMs;
            this.deviceControlTimeMs = deviceControlTimeMs;
            this.usedSeek = usedSeek;
            this.usedPrevNext = usedPrevNext;
            this.isDeviceConnected = isDeviceConnected;
            this.isDeviceControlEnabled = isDeviceControlEnabled;
            this.lastDeviceControlEnableTime = lastDeviceControlEnableTime;
        }

        @NotNull
        public final String getSessionId() {
            return this.sessionId;
        }

        public final int getMediaId() {
            return this.mediaId;
        }

        @NotNull
        public final String getMediaName() {
            return this.mediaName;
        }

        @NotNull
        public final String getMediaAuthor() {
            return this.mediaAuthor;
        }

        @NotNull
        public final MediaType getMediaType() {
            return this.mediaType;
        }

        public final long getMediaDurationMs() {
            return this.mediaDurationMs;
        }

        public final long getSessionStartTime() {
            return this.sessionStartTime;
        }

        public final long getLastActiveTime() {
            return this.lastActiveTime;
        }

        public final void setLastActiveTime(long <set-?>) {
            this.lastActiveTime = < set - ? >;
        }

        public final long getTotalPlayTimeMs() {
            return this.totalPlayTimeMs;
        }

        public final void setTotalPlayTimeMs(long <set-?>) {
            this.totalPlayTimeMs = < set - ? >;
        }

        public final long getDeviceControlTimeMs() {
            return this.deviceControlTimeMs;
        }

        public final void setDeviceControlTimeMs(long <set-?>) {
            this.deviceControlTimeMs = < set - ? >;
        }

        public final boolean getUsedSeek() {
            return this.usedSeek;
        }

        public final void setUsedSeek(boolean <set-?>) {
            this.usedSeek = < set - ? >;
        }

        public final boolean getUsedPrevNext() {
            return this.usedPrevNext;
        }

        public final void setUsedPrevNext(boolean <set-?>) {
            this.usedPrevNext = < set - ? >;
        }

        public final boolean isDeviceConnected() {
            return this.isDeviceConnected;
        }

        public final void setDeviceConnected(boolean <set-?>) {
            this.isDeviceConnected = < set - ? >;
        }

        public final boolean isDeviceControlEnabled() {
            return this.isDeviceControlEnabled;
        }

        public final void setDeviceControlEnabled(boolean <set-?>) {
            this.isDeviceControlEnabled = < set - ? >;
        }

        @Nullable
        public final Long getLastDeviceControlEnableTime() {
            return this.lastDeviceControlEnableTime;
        }

        @NotNull
        public final String component1() {
            return this.sessionId;
        }

        public final int component2() {
            return this.mediaId;
        }

        @NotNull
        public final String component3() {
            return this.mediaName;
        }

        @NotNull
        public final String component4() {
            return this.mediaAuthor;
        }

        @NotNull
        public final MediaType component5() {
            return this.mediaType;
        }

        public final long component6() {
            return this.mediaDurationMs;
        }

        public final long component7() {
            return this.sessionStartTime;
        }

        public final long component8() {
            return this.lastActiveTime;
        }

        public final long component9() {
            return this.totalPlayTimeMs;
        }

        public final long component10() {
            return this.deviceControlTimeMs;
        }

        public final void setLastDeviceControlEnableTime(@Nullable Long<set-?>) {
            this.lastDeviceControlEnableTime = < set - ? >;
        }

        public final boolean component11() {
            return this.usedSeek;
        }

        public final boolean component12() {
            return this.usedPrevNext;
        }

        public final boolean component13() {
            return this.isDeviceConnected;
        }

        public final boolean component14() {
            return this.isDeviceControlEnabled;
        }

        @Nullable
        public final Long component15() {
            return this.lastDeviceControlEnableTime;
        }

        @NotNull
        public final SessionData copy(@NotNull String sessionId, int mediaId, @NotNull String mediaName, @NotNull String mediaAuthor, @NotNull MediaType mediaType, long mediaDurationMs, long sessionStartTime, long lastActiveTime, long totalPlayTimeMs, long deviceControlTimeMs, boolean usedSeek, boolean usedPrevNext, boolean isDeviceConnected, boolean isDeviceControlEnabled, @Nullable Long lastDeviceControlEnableTime) {
            Intrinsics.checkNotNullParameter(sessionId, "sessionId");
            Intrinsics.checkNotNullParameter(mediaName, "mediaName");
            Intrinsics.checkNotNullParameter(mediaAuthor, "mediaAuthor");
            Intrinsics.checkNotNullParameter(mediaType, "mediaType");
            return new SessionData(sessionId, mediaId, mediaName, mediaAuthor, mediaType, mediaDurationMs, sessionStartTime, lastActiveTime, totalPlayTimeMs, deviceControlTimeMs, usedSeek, usedPrevNext, isDeviceConnected, isDeviceControlEnabled, lastDeviceControlEnableTime);
        }

        @NotNull
        public String toString() {
            return "SessionData(sessionId=" + this.sessionId + ", mediaId=" + this.mediaId + ", mediaName=" + this.mediaName + ", mediaAuthor=" + this.mediaAuthor + ", mediaType=" + this.mediaType + ", mediaDurationMs=" + this.mediaDurationMs + ", sessionStartTime=" + this.sessionStartTime + ", lastActiveTime=" + this.lastActiveTime + ", totalPlayTimeMs=" + this.totalPlayTimeMs + ", deviceControlTimeMs=" + this.deviceControlTimeMs + ", usedSeek=" + this.usedSeek + ", usedPrevNext=" + this.usedPrevNext + ", isDeviceConnected=" + this.isDeviceConnected + ", isDeviceControlEnabled=" + this.isDeviceControlEnabled + ", lastDeviceControlEnableTime=" + this.lastDeviceControlEnableTime + ")";
        }

        public int hashCode() {
            result = this.sessionId.hashCode();
            result = result * 31 + Integer.hashCode(this.mediaId);
            result = result * 31 + this.mediaName.hashCode();
            result = result * 31 + this.mediaAuthor.hashCode();
            result = result * 31 + this.mediaType.hashCode();
            result = result * 31 + Long.hashCode(this.mediaDurationMs);
            result = result * 31 + Long.hashCode(this.sessionStartTime);
            result = result * 31 + Long.hashCode(this.lastActiveTime);
            result = result * 31 + Long.hashCode(this.totalPlayTimeMs);
            result = result * 31 + Long.hashCode(this.deviceControlTimeMs);
            result = result * 31 + Boolean.hashCode(this.usedSeek);
            result = result * 31 + Boolean.hashCode(this.usedPrevNext);
            result = result * 31 + Boolean.hashCode(this.isDeviceConnected);
            result = result * 31 + Boolean.hashCode(this.isDeviceControlEnabled);
            return result * 31 + ((this.lastDeviceControlEnableTime == null) ? 0 : this.lastDeviceControlEnableTime.hashCode());
        }

        public boolean equals(@Nullable Object other) {
            if (this == other) return true;
            if (!(other instanceof SessionData)) return false;
            SessionData sessionData = (SessionData) other;
            return !Intrinsics.areEqual(this.sessionId, sessionData.sessionId) ? false : ((this.mediaId != sessionData.mediaId) ? false : (!Intrinsics.areEqual(this.mediaName, sessionData.mediaName) ? false : (!Intrinsics.areEqual(this.mediaAuthor, sessionData.mediaAuthor) ? false : ((this.mediaType != sessionData.mediaType) ? false : ((this.mediaDurationMs != sessionData.mediaDurationMs) ? false : ((this.sessionStartTime != sessionData.sessionStartTime) ? false : ((this.lastActiveTime != sessionData.lastActiveTime) ? false : ((this.totalPlayTimeMs != sessionData.totalPlayTimeMs) ? false : ((this.deviceControlTimeMs != sessionData.deviceControlTimeMs) ? false : ((this.usedSeek != sessionData.usedSeek) ? false : ((this.usedPrevNext != sessionData.usedPrevNext) ? false : ((this.isDeviceConnected != sessionData.isDeviceConnected) ? false : ((this.isDeviceControlEnabled != sessionData.isDeviceControlEnabled) ? false : (!!Intrinsics.areEqual(this.lastDeviceControlEnableTime, sessionData.lastDeviceControlEnableTime)))))))))))))));
        }
    }

    public final void startSession(@NotNull AudioFile audioFile) {
        Intrinsics.checkNotNullParameter(audioFile, "audioFile");
        long now = System.currentTimeMillis();


        SessionData session = this.currentSession;
        int $i$a$ -let - ResonanceSessionTracker$startSession$1 = 0;
        endSession();


        Log.d("ResonanceSessionTracker", "开始新的播放会话: " + audioFile.getName());


        Intrinsics.checkNotNullExpressionValue(UUID.randomUUID().toString(), "toString(...)");
        this.currentSession = new SessionData(UUID.randomUUID().toString(),
                audioFile.getId(),
                audioFile.getName(),
                audioFile.getAuthor(),
                audioFile.getMediaType(),
                getMediaDuration(audioFile),
                now,
                now, 0L, 0L, false, false, false, false, null, 32512, null);
    }


    public final void updatePlayTime(long deltaMs) {
        SessionData session = this.currentSession;
        int $i$a$ -let - ResonanceSessionTracker$updatePlayTime$1 = 0;
        session.setTotalPlayTimeMs(session.getTotalPlayTimeMs() + deltaMs);
        session.setLastActiveTime(System.currentTimeMillis());
    }


    public final void onPause() {
        SessionData session = this.currentSession;
        int $i$a$ -let - ResonanceSessionTracker$onPause$1 = 0;
        long now = System.currentTimeMillis();
        long pauseDuration = now - session.getLastActiveTime();

        Log.d("ResonanceSessionTracker", "暂停播放，暂停时长: " + pauseDuration + "ms");


        if (pauseDuration > 180000L) {
            Log.d("ResonanceSessionTracker", "暂停超过3分钟，结束会话");
            endSession();
        }
    }


    public final void onResume() {
        SessionData session = this.currentSession;
        int $i$a$ -let - ResonanceSessionTracker$onResume$1 = 0;
        long now = System.currentTimeMillis();
        long pauseDuration = now - session.getLastActiveTime();


        if (pauseDuration > 180000L) {
            Log.d("ResonanceSessionTracker", "暂停超过3分钟，当前会话已失效");
            this.currentSession = null;
        } else {
            session.setLastActiveTime(now);
        }
    }


    public final void onSeek() {
        SessionData session = this.currentSession;
        int $i$a$ -let - ResonanceSessionTracker$onSeek$1 = 0;
        if (!session.getUsedSeek()) {
            Log.d("ResonanceSessionTracker", "记录快进/快退操作");
            session.setUsedSeek(true);
        }
    }


    public final void onPrevNext() {
        SessionData session = this.currentSession;
        int $i$a$ -let - ResonanceSessionTracker$onPrevNext$1 = 0;
        if (!session.getUsedPrevNext()) {
            Log.d("ResonanceSessionTracker", "记录上一首/下一首操作");
            session.setUsedPrevNext(true);
        }
    }


    public final void updateDeviceConnection(boolean isConnected) {
        if (this.currentSession != null) {
            SessionData session = this.currentSession;
            int $i$a$ -let - ResonanceSessionTracker$updateDeviceConnection$1 = 0;
            session.setDeviceConnected(isConnected);
            Log.d("ResonanceSessionTracker", "更新设备连接状态: " + isConnected);
        } else {
        }

    }


    public final void updateDeviceControl(boolean isEnabled) {
        SessionData session = this.currentSession;
        int $i$a$ -let - ResonanceSessionTracker$updateDeviceControl$1 = 0;
        long now = System.currentTimeMillis();


        if (isEnabled && !session.isDeviceControlEnabled()) {

            session.setDeviceControlEnabled(true);
            session.setLastDeviceControlEnableTime(Long.valueOf(now));
            Log.d("ResonanceSessionTracker", "开启设备APP手机控制");
        } else if (!isEnabled && session.isDeviceControlEnabled()) {

            if (session.getLastDeviceControlEnableTime() != null) {
                long startTime = session.getLastDeviceControlEnableTime().longValue();
                int $i$a$ -let - ResonanceSessionTracker$updateDeviceControl$1$1 = 0;
                long controlDuration = now - startTime;
                session.setDeviceControlTimeMs(session.getDeviceControlTimeMs() + controlDuration);
                Log.d("ResonanceSessionTracker", "关闭设备APP手机控制，累加时长: " + controlDuration + "ms");
            } else {
                session.getLastDeviceControlEnableTime();
            }
            session.setDeviceControlEnabled(false);
            session.setLastDeviceControlEnableTime(null);
        }
    }


    public final void onMediaChanged(@NotNull AudioFile newAudioFile) {
        Intrinsics.checkNotNullParameter(newAudioFile, "newAudioFile");
        Log.d("ResonanceSessionTracker", "切换播放内容: " + newAudioFile.getName());


        endSession();


        startSession(newAudioFile);
    }


    public final void onExitResonancePage() {
        Log.d("ResonanceSessionTracker", "退出共鸣页面，结束会话");
        endSession();
    }


    public final void endSession() {
        SessionData session = this.currentSession;
        int $i$a$ -let - ResonanceSessionTracker$endSession$1 = 0;
        long now = System.currentTimeMillis();


        if (session.isDeviceControlEnabled() && session.getLastDeviceControlEnableTime() != null) {
            Intrinsics.checkNotNull(session.getLastDeviceControlEnableTime());
            long controlDuration = now - session.getLastDeviceControlEnableTime().longValue();
            session.setDeviceControlTimeMs(session.getDeviceControlTimeMs() + controlDuration);
        }

        Log.d("ResonanceSessionTracker", "结束播放会话: " + session.getMediaName() + ", 总播放时长: " + session.getTotalPlayTimeMs() + "ms");


        Intrinsics.checkNotNullExpressionValue(Build.MODEL, "MODEL");
        ResonanceExperienceLog log = new ResonanceExperienceLog(session.getSessionId(), LoggerManager.INSTANCE.getUserId(), session.getSessionStartTime(), Build.MODEL, "Android " +
                Build.VERSION.RELEASE,
                getAppVersion(), null,
                session.getTotalPlayTimeMs(),
                session.getMediaType(),
                session.getMediaDurationMs(),
                session.getDeviceControlTimeMs(),
                session.getUsedSeek(),
                session.getUsedPrevNext(),
                session.isDeviceConnected(),
                session.isDeviceControlEnabled(),
                session.getMediaName(),
                session.getMediaAuthor(),
                session.getMediaId(), false, null, 786496, null);


        LoggerManager.INSTANCE.logResonanceExperience(log);


        this.currentSession = null;
    }


    private final long getMediaDuration(AudioFile audioFile) {
        long l;

        try {
            MediaMetadataRetriever retriever = new MediaMetadataRetriever();
            retriever.setDataSource(this.context, audioFile.getUri());
            String durationStr = retriever.extractMetadata(9);
            retriever.release();
            StringsKt.toLongOrNull(durationStr);
            l = (durationStr != null && StringsKt.toLongOrNull(durationStr) != null) ? StringsKt.toLongOrNull(durationStr).longValue() : 0L;
        } catch (Exception e) {
            Log.e("ResonanceSessionTracker", "无法获取媒体时长", e);
            l = 0L;
        }
        return l;
    }


    private final String getAppVersion() {
        String str;

        try {
            PackageInfo packageInfo = this.context.getPackageManager().getPackageInfo(this.context.getPackageName(), 0);
            if (packageInfo.versionName == null) ;
            str = "Unknown";
        } catch (Exception e) {
            str = "Unknown";
        }
        return str;
    }


    public final boolean hasActiveSession() {
        return (this.currentSession != null);
    }


    @Nullable
    public final Integer getCurrentMediaId() {
        return (this.currentSession != null) ? Integer.valueOf(this.currentSession.getMediaId()) : null;
    }
}


