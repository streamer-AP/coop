package com.etouch.logger;


public final class ResonanceExperienceLog {
    @NotNull
    public static final Companion Companion = new Companion(null);
    @NotNull
    private final String id;
    @NotNull
    private final String userId;
    private final long timestamp;
    @NotNull
    private final String deviceModel;
    @NotNull
    private final String devicePlatform;
    @NotNull
    private final String appVersion;
    @NotNull
    private final String operationType;
    private final long playDurationMs;
    @NotNull
    private final MediaType mediaType;
    private final long mediaDurationMs;
    private final long deviceControlDurationMs;
    private final boolean usedSeek;
    private final boolean usedPrevNext;
    private final boolean isDeviceConnected;
    private final boolean isDeviceControlEnabled;
    @NotNull
    private final String mediaName;
    @NotNull
    private final String mediaAuthor;
    private final int mediaId;
    private boolean uploaded;
    @Nullable
    private Long uploadTimestamp;

    public ResonanceExperienceLog(@NotNull String id, @NotNull String userId, long timestamp, @NotNull String deviceModel, @NotNull String devicePlatform, @NotNull String appVersion, @NotNull String operationType, long playDurationMs, @NotNull MediaType mediaType, long mediaDurationMs, long deviceControlDurationMs, boolean usedSeek, boolean usedPrevNext, boolean isDeviceConnected, boolean isDeviceControlEnabled, @NotNull String mediaName, @NotNull String mediaAuthor, int mediaId, boolean uploaded, @Nullable Long uploadTimestamp) {
        this.id = id;
        this.userId = userId;
        this.timestamp = timestamp;
        this.deviceModel = deviceModel;
        this.devicePlatform = devicePlatform;
        this.appVersion = appVersion;
        this.operationType = operationType;


        this.playDurationMs = playDurationMs;
        this.mediaType = mediaType;
        this.mediaDurationMs = mediaDurationMs;
        this.deviceControlDurationMs = deviceControlDurationMs;


        this.usedSeek = usedSeek;
        this.usedPrevNext = usedPrevNext;
        this.isDeviceConnected = isDeviceConnected;
        this.isDeviceControlEnabled = isDeviceControlEnabled;


        this.mediaName = mediaName;
        this.mediaAuthor = mediaAuthor;
        this.mediaId = mediaId;


        this.uploaded = uploaded;
        this.uploadTimestamp = uploadTimestamp;
    }

    @NotNull
    public final String getId() {
        return this.id;
    }

    @NotNull
    public final String getUserId() {
        return this.userId;
    }

    public final long getTimestamp() {
        return this.timestamp;
    }

    @NotNull
    public final String getDeviceModel() {
        return this.deviceModel;
    }

    @NotNull
    public final String getDevicePlatform() {
        return this.devicePlatform;
    }

    @NotNull
    public final String getAppVersion() {
        return this.appVersion;
    }

    @NotNull
    public final String getOperationType() {
        return this.operationType;
    }

    public final long getPlayDurationMs() {
        return this.playDurationMs;
    }

    @NotNull
    public final MediaType getMediaType() {
        return this.mediaType;
    }

    public final long getMediaDurationMs() {
        return this.mediaDurationMs;
    }

    @Nullable
    public final Long getUploadTimestamp() {
        return this.uploadTimestamp;
    }

    public final long getDeviceControlDurationMs() {
        return this.deviceControlDurationMs;
    }

    public final boolean getUsedSeek() {
        return this.usedSeek;
    }

    public final boolean getUsedPrevNext() {
        return this.usedPrevNext;
    }

    public final boolean isDeviceConnected() {
        return this.isDeviceConnected;
    }

    public final boolean isDeviceControlEnabled() {
        return this.isDeviceControlEnabled;
    }

    @NotNull
    public final String getMediaName() {
        return this.mediaName;
    }

    @NotNull
    public final String getMediaAuthor() {
        return this.mediaAuthor;
    }

    public final int getMediaId() {
        return this.mediaId;
    }

    public final boolean getUploaded() {
        return this.uploaded;
    }

    public final void setUploaded(boolean <set-?>) {
        this.uploaded = < set - ? >;
    }

    public final void setUploadTimestamp(@Nullable Long<set-?>) {
        this.uploadTimestamp = < set - ? >;
    }


    @NotNull
    public final String toJson() {
        if (this.uploadTimestamp == null) ;

        return StringsKt.trimIndent("\n            {\n                \"id\": \"" + this.userId + "\",\n                \"userId\": \"" + this.timestamp + "\",\n                \"timestamp\": " + this.deviceModel + ",\n                \"deviceModel\": \"" + this.devicePlatform + "\",\n                \"devicePlatform\": \"" + this.appVersion + "\",\n                \"appVersion\": \"" + this.operationType + "\",\n                \"operationType\": \"" + this.playDurationMs + "\",\n                \"playDurationMs\": " + this.mediaType.name() + ",\n                \"mediaType\": \"" + this.mediaDurationMs + "\",\n                \"mediaDurationMs\": " + this.deviceControlDurationMs + ",\n                \"deviceControlDurationMs\": " + this.usedSeek + ",\n                \"usedSeek\": " + this.usedPrevNext + ",\n                \"usedPrevNext\": " + this.isDeviceConnected + ",\n                \"isDeviceConnected\": " + this.isDeviceControlEnabled + ",\n                \"isDeviceControlEnabled\": " + this.mediaName + ",\n                \"mediaName\": \"" + this.mediaAuthor + "\",\n                \"mediaAuthor\": \"" + this.mediaId + "\",\n                \"mediaId\": " + this.uploaded + ",\n                \"uploaded\": " + this.uploadTimestamp + ",\n                \"uploadTimestamp\": " + "null" + "\n            }\n        ");
    }

    @NotNull
    public final String component1() {
        return this.id;
    }

    @NotNull
    public final String component2() {
        return this.userId;
    }

    public final long component3() {
        return this.timestamp;
    }

    @NotNull
    public final String component4() {
        return this.deviceModel;
    }

    @NotNull
    public final String component5() {
        return this.devicePlatform;
    }

    @NotNull
    public final String component6() {
        return this.appVersion;
    }

    @NotNull
    public final String component7() {
        return this.operationType;
    }

    public final long component8() {
        return this.playDurationMs;
    }

    @NotNull
    public final MediaType component9() {
        return this.mediaType;
    }

    public final long component10() {
        return this.mediaDurationMs;
    }

    public final long component11() {
        return this.deviceControlDurationMs;
    }

    public final boolean component12() {
        return this.usedSeek;
    }

    public final boolean component13() {
        return this.usedPrevNext;
    }

    public final boolean component14() {
        return this.isDeviceConnected;
    }

    public final boolean component15() {
        return this.isDeviceControlEnabled;
    }

    @NotNull
    public final String component16() {
        return this.mediaName;
    }

    @NotNull
    public final String component17() {
        return this.mediaAuthor;
    }

    public final int component18() {
        return this.mediaId;
    }

    public final boolean component19() {
        return this.uploaded;
    }

    @Nullable
    public final Long component20() {
        return this.uploadTimestamp;
    }

    @NotNull
    public final ResonanceExperienceLog copy(@NotNull String id, @NotNull String userId, long timestamp, @NotNull String deviceModel, @NotNull String devicePlatform, @NotNull String appVersion, @NotNull String operationType, long playDurationMs, @NotNull MediaType mediaType, long mediaDurationMs, long deviceControlDurationMs, boolean usedSeek, boolean usedPrevNext, boolean isDeviceConnected, boolean isDeviceControlEnabled, @NotNull String mediaName, @NotNull String mediaAuthor, int mediaId, boolean uploaded, @Nullable Long uploadTimestamp) {
        Intrinsics.checkNotNullParameter(id, "id");
        Intrinsics.checkNotNullParameter(userId, "userId");
        Intrinsics.checkNotNullParameter(deviceModel, "deviceModel");
        Intrinsics.checkNotNullParameter(devicePlatform, "devicePlatform");
        Intrinsics.checkNotNullParameter(appVersion, "appVersion");
        Intrinsics.checkNotNullParameter(operationType, "operationType");
        Intrinsics.checkNotNullParameter(mediaType, "mediaType");
        Intrinsics.checkNotNullParameter(mediaName, "mediaName");
        Intrinsics.checkNotNullParameter(mediaAuthor, "mediaAuthor");
        return new ResonanceExperienceLog(id, userId, timestamp, deviceModel, devicePlatform, appVersion, operationType, playDurationMs, mediaType, mediaDurationMs, deviceControlDurationMs, usedSeek, usedPrevNext, isDeviceConnected, isDeviceControlEnabled, mediaName, mediaAuthor, mediaId, uploaded, uploadTimestamp);
    }

    @NotNull
    public String toString() {
        return "ResonanceExperienceLog(id=" + this.id + ", userId=" + this.userId + ", timestamp=" + this.timestamp + ", deviceModel=" + this.deviceModel + ", devicePlatform=" + this.devicePlatform + ", appVersion=" + this.appVersion + ", operationType=" + this.operationType + ", playDurationMs=" + this.playDurationMs + ", mediaType=" + this.mediaType + ", mediaDurationMs=" + this.mediaDurationMs + ", deviceControlDurationMs=" + this.deviceControlDurationMs + ", usedSeek=" + this.usedSeek + ", usedPrevNext=" + this.usedPrevNext + ", isDeviceConnected=" + this.isDeviceConnected + ", isDeviceControlEnabled=" + this.isDeviceControlEnabled + ", mediaName=" + this.mediaName + ", mediaAuthor=" + this.mediaAuthor + ", mediaId=" + this.mediaId + ", uploaded=" + this.uploaded + ", uploadTimestamp=" + this.uploadTimestamp + ")";
    }

    public int hashCode() {
        result = this.id.hashCode();
        result = result * 31 + this.userId.hashCode();
        result = result * 31 + Long.hashCode(this.timestamp);
        result = result * 31 + this.deviceModel.hashCode();
        result = result * 31 + this.devicePlatform.hashCode();
        result = result * 31 + this.appVersion.hashCode();
        result = result * 31 + this.operationType.hashCode();
        result = result * 31 + Long.hashCode(this.playDurationMs);
        result = result * 31 + this.mediaType.hashCode();
        result = result * 31 + Long.hashCode(this.mediaDurationMs);
        result = result * 31 + Long.hashCode(this.deviceControlDurationMs);
        result = result * 31 + Boolean.hashCode(this.usedSeek);
        result = result * 31 + Boolean.hashCode(this.usedPrevNext);
        result = result * 31 + Boolean.hashCode(this.isDeviceConnected);
        result = result * 31 + Boolean.hashCode(this.isDeviceControlEnabled);
        result = result * 31 + this.mediaName.hashCode();
        result = result * 31 + this.mediaAuthor.hashCode();
        result = result * 31 + Integer.hashCode(this.mediaId);
        result = result * 31 + Boolean.hashCode(this.uploaded);
        return result * 31 + ((this.uploadTimestamp == null) ? 0 : this.uploadTimestamp.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof ResonanceExperienceLog))
            return false;
        ResonanceExperienceLog resonanceExperienceLog = (ResonanceExperienceLog) other;
        return !Intrinsics.areEqual(this.id, resonanceExperienceLog.id) ? false : (!Intrinsics.areEqual(this.userId, resonanceExperienceLog.userId) ? false : ((this.timestamp != resonanceExperienceLog.timestamp) ? false : (!Intrinsics.areEqual(this.deviceModel, resonanceExperienceLog.deviceModel) ? false : (!Intrinsics.areEqual(this.devicePlatform, resonanceExperienceLog.devicePlatform) ? false : (!Intrinsics.areEqual(this.appVersion, resonanceExperienceLog.appVersion) ? false : (!Intrinsics.areEqual(this.operationType, resonanceExperienceLog.operationType) ? false : ((this.playDurationMs != resonanceExperienceLog.playDurationMs) ? false : ((this.mediaType != resonanceExperienceLog.mediaType) ? false : ((this.mediaDurationMs != resonanceExperienceLog.mediaDurationMs) ? false : ((this.deviceControlDurationMs != resonanceExperienceLog.deviceControlDurationMs) ? false : ((this.usedSeek != resonanceExperienceLog.usedSeek) ? false : ((this.usedPrevNext != resonanceExperienceLog.usedPrevNext) ? false : ((this.isDeviceConnected != resonanceExperienceLog.isDeviceConnected) ? false : ((this.isDeviceControlEnabled != resonanceExperienceLog.isDeviceControlEnabled) ? false : (!Intrinsics.areEqual(this.mediaName, resonanceExperienceLog.mediaName) ? false : (!Intrinsics.areEqual(this.mediaAuthor, resonanceExperienceLog.mediaAuthor) ? false : ((this.mediaId != resonanceExperienceLog.mediaId) ? false : ((this.uploaded != resonanceExperienceLog.uploaded) ? false : (!!Intrinsics.areEqual(this.uploadTimestamp, resonanceExperienceLog.uploadTimestamp))))))))))))))))))));
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\030\n\002\030\002\n\002\020\000\n\002\b\002\n\002\030\002\n\000\n\002\020\016\n\000\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002J\020\020\003\032\004\030\0010\0042\006\020\005\032\0020\006¨\006\007"}, d2 = {"Lcom/etouch/logger/ResonanceExperienceLog$Companion;", "", "()V", "fromJson", "Lcom/etouch/logger/ResonanceExperienceLog;", "json", "", "sdk_android_unity_bridge_v1_debug"})
    public static final class Companion {
        private Companion() {
        }

        @Nullable
        public final ResonanceExperienceLog fromJson(@NotNull String json) {
            // Byte code:
            //   0: aload_1
            //   1: ldc 'json'
            //   3: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
            //   6: nop
            //   7: new kotlin/text/Regex
            //   10: dup
            //   11: ldc '"id":\s*"([^"]+)"'
            //   13: invokespecial <init> : (Ljava/lang/String;)V
            //   16: astore_2
            //   17: new kotlin/text/Regex
            //   20: dup
            //   21: ldc '"userId":\s*"([^"]+)"'
            //   23: invokespecial <init> : (Ljava/lang/String;)V
            //   26: astore_3
            //   27: new kotlin/text/Regex
            //   30: dup
            //   31: ldc '"timestamp":\s*(\d+)'
            //   33: invokespecial <init> : (Ljava/lang/String;)V
            //   36: astore #4
            //   38: new kotlin/text/Regex
            //   41: dup
            //   42: ldc '"deviceModel":\s*"([^"]+)"'
            //   44: invokespecial <init> : (Ljava/lang/String;)V
            //   47: astore #5
            //   49: new kotlin/text/Regex
            //   52: dup
            //   53: ldc '"devicePlatform":\s*"([^"]+)"'
            //   55: invokespecial <init> : (Ljava/lang/String;)V
            //   58: astore #6
            //   60: new kotlin/text/Regex
            //   63: dup
            //   64: ldc '"appVersion":\s*"([^"]+)"'
            //   66: invokespecial <init> : (Ljava/lang/String;)V
            //   69: astore #7
            //   71: new kotlin/text/Regex
            //   74: dup
            //   75: ldc '"operationType":\s*"([^"]+)"'
            //   77: invokespecial <init> : (Ljava/lang/String;)V
            //   80: astore #8
            //   82: new kotlin/text/Regex
            //   85: dup
            //   86: ldc '"playDurationMs":\s*(\d+)'
            //   88: invokespecial <init> : (Ljava/lang/String;)V
            //   91: astore #9
            //   93: new kotlin/text/Regex
            //   96: dup
            //   97: ldc '"mediaType":\s*"([^"]+)"'
            //   99: invokespecial <init> : (Ljava/lang/String;)V
            //   102: astore #10
            //   104: new kotlin/text/Regex
            //   107: dup
            //   108: ldc '"mediaDurationMs":\s*(\d+)'
            //   110: invokespecial <init> : (Ljava/lang/String;)V
            //   113: astore #11
            //   115: new kotlin/text/Regex
            //   118: dup
            //   119: ldc '"deviceControlDurationMs":\s*(\d+)'
            //   121: invokespecial <init> : (Ljava/lang/String;)V
            //   124: astore #12
            //   126: new kotlin/text/Regex
            //   129: dup
            //   130: ldc '"usedSeek":\s*(true|false)'
            //   132: invokespecial <init> : (Ljava/lang/String;)V
            //   135: astore #13
            //   137: new kotlin/text/Regex
            //   140: dup
            //   141: ldc '"usedPrevNext":\s*(true|false)'
            //   143: invokespecial <init> : (Ljava/lang/String;)V
            //   146: astore #14
            //   148: new kotlin/text/Regex
            //   151: dup
            //   152: ldc '"isDeviceConnected":\s*(true|false)'
            //   154: invokespecial <init> : (Ljava/lang/String;)V
            //   157: astore #15
            //   159: new kotlin/text/Regex
            //   162: dup
            //   163: ldc '"isDeviceControlEnabled":\s*(true|false)'
            //   165: invokespecial <init> : (Ljava/lang/String;)V
            //   168: astore #16
            //   170: new kotlin/text/Regex
            //   173: dup
            //   174: ldc '"mediaName":\s*"([^"]+)"'
            //   176: invokespecial <init> : (Ljava/lang/String;)V
            //   179: astore #17
            //   181: new kotlin/text/Regex
            //   184: dup
            //   185: ldc '"mediaAuthor":\s*"([^"]+)"'
            //   187: invokespecial <init> : (Ljava/lang/String;)V
            //   190: astore #18
            //   192: new kotlin/text/Regex
            //   195: dup
            //   196: ldc '"mediaId":\s*(\d+)'
            //   198: invokespecial <init> : (Ljava/lang/String;)V
            //   201: astore #19
            //   203: new kotlin/text/Regex
            //   206: dup
            //   207: ldc '"uploaded":\s*(true|false)'
            //   209: invokespecial <init> : (Ljava/lang/String;)V
            //   212: astore #20
            //   214: new kotlin/text/Regex
            //   217: dup
            //   218: ldc '"uploadTimestamp":\s*(\d+|null)'
            //   220: invokespecial <init> : (Ljava/lang/String;)V
            //   223: astore #21
            //   225: aload_2
            //   226: aload_1
            //   227: checkcast java/lang/CharSequence
            //   230: iconst_0
            //   231: iconst_2
            //   232: aconst_null
            //   233: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   236: dup
            //   237: ifnull -> 262
            //   240: invokeinterface getGroupValues : ()Ljava/util/List;
            //   245: dup
            //   246: ifnull -> 262
            //   249: iconst_1
            //   250: invokeinterface get : (I)Ljava/lang/Object;
            //   255: checkcast java/lang/String
            //   258: dup
            //   259: ifnonnull -> 265
            //   262: pop
            //   263: aconst_null
            //   264: areturn
            //   265: aload_3
            //   266: aload_1
            //   267: checkcast java/lang/CharSequence
            //   270: iconst_0
            //   271: iconst_2
            //   272: aconst_null
            //   273: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   276: dup
            //   277: ifnull -> 302
            //   280: invokeinterface getGroupValues : ()Ljava/util/List;
            //   285: dup
            //   286: ifnull -> 302
            //   289: iconst_1
            //   290: invokeinterface get : (I)Ljava/lang/Object;
            //   295: checkcast java/lang/String
            //   298: dup
            //   299: ifnonnull -> 305
            //   302: pop
            //   303: aconst_null
            //   304: areturn
            //   305: aload #4
            //   307: aload_1
            //   308: checkcast java/lang/CharSequence
            //   311: iconst_0
            //   312: iconst_2
            //   313: aconst_null
            //   314: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   317: dup
            //   318: ifnull -> 356
            //   321: invokeinterface getGroupValues : ()Ljava/util/List;
            //   326: dup
            //   327: ifnull -> 356
            //   330: iconst_1
            //   331: invokeinterface get : (I)Ljava/lang/Object;
            //   336: checkcast java/lang/String
            //   339: dup
            //   340: ifnull -> 356
            //   343: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
            //   346: dup
            //   347: ifnull -> 356
            //   350: invokevirtual longValue : ()J
            //   353: goto -> 359
            //   356: pop
            //   357: aconst_null
            //   358: areturn
            //   359: aload #5
            //   361: aload_1
            //   362: checkcast java/lang/CharSequence
            //   365: iconst_0
            //   366: iconst_2
            //   367: aconst_null
            //   368: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   371: dup
            //   372: ifnull -> 397
            //   375: invokeinterface getGroupValues : ()Ljava/util/List;
            //   380: dup
            //   381: ifnull -> 397
            //   384: iconst_1
            //   385: invokeinterface get : (I)Ljava/lang/Object;
            //   390: checkcast java/lang/String
            //   393: dup
            //   394: ifnonnull -> 400
            //   397: pop
            //   398: aconst_null
            //   399: areturn
            //   400: aload #6
            //   402: aload_1
            //   403: checkcast java/lang/CharSequence
            //   406: iconst_0
            //   407: iconst_2
            //   408: aconst_null
            //   409: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   412: dup
            //   413: ifnull -> 438
            //   416: invokeinterface getGroupValues : ()Ljava/util/List;
            //   421: dup
            //   422: ifnull -> 438
            //   425: iconst_1
            //   426: invokeinterface get : (I)Ljava/lang/Object;
            //   431: checkcast java/lang/String
            //   434: dup
            //   435: ifnonnull -> 441
            //   438: pop
            //   439: aconst_null
            //   440: areturn
            //   441: aload #7
            //   443: aload_1
            //   444: checkcast java/lang/CharSequence
            //   447: iconst_0
            //   448: iconst_2
            //   449: aconst_null
            //   450: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   453: dup
            //   454: ifnull -> 479
            //   457: invokeinterface getGroupValues : ()Ljava/util/List;
            //   462: dup
            //   463: ifnull -> 479
            //   466: iconst_1
            //   467: invokeinterface get : (I)Ljava/lang/Object;
            //   472: checkcast java/lang/String
            //   475: dup
            //   476: ifnonnull -> 482
            //   479: pop
            //   480: aconst_null
            //   481: areturn
            //   482: aload #8
            //   484: aload_1
            //   485: checkcast java/lang/CharSequence
            //   488: iconst_0
            //   489: iconst_2
            //   490: aconst_null
            //   491: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   494: dup
            //   495: ifnull -> 520
            //   498: invokeinterface getGroupValues : ()Ljava/util/List;
            //   503: dup
            //   504: ifnull -> 520
            //   507: iconst_1
            //   508: invokeinterface get : (I)Ljava/lang/Object;
            //   513: checkcast java/lang/String
            //   516: dup
            //   517: ifnonnull -> 523
            //   520: pop
            //   521: ldc 'RESONANCE_EXPERIENCE'
            //   523: aload #9
            //   525: aload_1
            //   526: checkcast java/lang/CharSequence
            //   529: iconst_0
            //   530: iconst_2
            //   531: aconst_null
            //   532: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   535: dup
            //   536: ifnull -> 574
            //   539: invokeinterface getGroupValues : ()Ljava/util/List;
            //   544: dup
            //   545: ifnull -> 574
            //   548: iconst_1
            //   549: invokeinterface get : (I)Ljava/lang/Object;
            //   554: checkcast java/lang/String
            //   557: dup
            //   558: ifnull -> 574
            //   561: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
            //   564: dup
            //   565: ifnull -> 574
            //   568: invokevirtual longValue : ()J
            //   571: goto -> 577
            //   574: pop
            //   575: aconst_null
            //   576: areturn
            //   577: aload #10
            //   579: aload_1
            //   580: checkcast java/lang/CharSequence
            //   583: iconst_0
            //   584: iconst_2
            //   585: aconst_null
            //   586: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   589: dup
            //   590: ifnull -> 615
            //   593: invokeinterface getGroupValues : ()Ljava/util/List;
            //   598: dup
            //   599: ifnull -> 615
            //   602: iconst_1
            //   603: invokeinterface get : (I)Ljava/lang/Object;
            //   608: checkcast java/lang/String
            //   611: dup
            //   612: ifnonnull -> 618
            //   615: pop
            //   616: aconst_null
            //   617: areturn
            //   618: invokestatic valueOf : (Ljava/lang/String;)Lcom/etouch/MediaType;
            //   621: aload #11
            //   623: aload_1
            //   624: checkcast java/lang/CharSequence
            //   627: iconst_0
            //   628: iconst_2
            //   629: aconst_null
            //   630: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   633: dup
            //   634: ifnull -> 672
            //   637: invokeinterface getGroupValues : ()Ljava/util/List;
            //   642: dup
            //   643: ifnull -> 672
            //   646: iconst_1
            //   647: invokeinterface get : (I)Ljava/lang/Object;
            //   652: checkcast java/lang/String
            //   655: dup
            //   656: ifnull -> 672
            //   659: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
            //   662: dup
            //   663: ifnull -> 672
            //   666: invokevirtual longValue : ()J
            //   669: goto -> 675
            //   672: pop
            //   673: aconst_null
            //   674: areturn
            //   675: aload #12
            //   677: aload_1
            //   678: checkcast java/lang/CharSequence
            //   681: iconst_0
            //   682: iconst_2
            //   683: aconst_null
            //   684: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   687: dup
            //   688: ifnull -> 726
            //   691: invokeinterface getGroupValues : ()Ljava/util/List;
            //   696: dup
            //   697: ifnull -> 726
            //   700: iconst_1
            //   701: invokeinterface get : (I)Ljava/lang/Object;
            //   706: checkcast java/lang/String
            //   709: dup
            //   710: ifnull -> 726
            //   713: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
            //   716: dup
            //   717: ifnull -> 726
            //   720: invokevirtual longValue : ()J
            //   723: goto -> 729
            //   726: pop
            //   727: aconst_null
            //   728: areturn
            //   729: aload #13
            //   731: aload_1
            //   732: checkcast java/lang/CharSequence
            //   735: iconst_0
            //   736: iconst_2
            //   737: aconst_null
            //   738: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   741: dup
            //   742: ifnull -> 773
            //   745: invokeinterface getGroupValues : ()Ljava/util/List;
            //   750: dup
            //   751: ifnull -> 773
            //   754: iconst_1
            //   755: invokeinterface get : (I)Ljava/lang/Object;
            //   760: checkcast java/lang/String
            //   763: dup
            //   764: ifnull -> 773
            //   767: invokestatic parseBoolean : (Ljava/lang/String;)Z
            //   770: goto -> 775
            //   773: pop
            //   774: iconst_0
            //   775: aload #14
            //   777: aload_1
            //   778: checkcast java/lang/CharSequence
            //   781: iconst_0
            //   782: iconst_2
            //   783: aconst_null
            //   784: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   787: dup
            //   788: ifnull -> 819
            //   791: invokeinterface getGroupValues : ()Ljava/util/List;
            //   796: dup
            //   797: ifnull -> 819
            //   800: iconst_1
            //   801: invokeinterface get : (I)Ljava/lang/Object;
            //   806: checkcast java/lang/String
            //   809: dup
            //   810: ifnull -> 819
            //   813: invokestatic parseBoolean : (Ljava/lang/String;)Z
            //   816: goto -> 821
            //   819: pop
            //   820: iconst_0
            //   821: aload #15
            //   823: aload_1
            //   824: checkcast java/lang/CharSequence
            //   827: iconst_0
            //   828: iconst_2
            //   829: aconst_null
            //   830: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   833: dup
            //   834: ifnull -> 865
            //   837: invokeinterface getGroupValues : ()Ljava/util/List;
            //   842: dup
            //   843: ifnull -> 865
            //   846: iconst_1
            //   847: invokeinterface get : (I)Ljava/lang/Object;
            //   852: checkcast java/lang/String
            //   855: dup
            //   856: ifnull -> 865
            //   859: invokestatic parseBoolean : (Ljava/lang/String;)Z
            //   862: goto -> 867
            //   865: pop
            //   866: iconst_0
            //   867: aload #16
            //   869: aload_1
            //   870: checkcast java/lang/CharSequence
            //   873: iconst_0
            //   874: iconst_2
            //   875: aconst_null
            //   876: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   879: dup
            //   880: ifnull -> 911
            //   883: invokeinterface getGroupValues : ()Ljava/util/List;
            //   888: dup
            //   889: ifnull -> 911
            //   892: iconst_1
            //   893: invokeinterface get : (I)Ljava/lang/Object;
            //   898: checkcast java/lang/String
            //   901: dup
            //   902: ifnull -> 911
            //   905: invokestatic parseBoolean : (Ljava/lang/String;)Z
            //   908: goto -> 913
            //   911: pop
            //   912: iconst_0
            //   913: aload #17
            //   915: aload_1
            //   916: checkcast java/lang/CharSequence
            //   919: iconst_0
            //   920: iconst_2
            //   921: aconst_null
            //   922: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   925: dup
            //   926: ifnull -> 951
            //   929: invokeinterface getGroupValues : ()Ljava/util/List;
            //   934: dup
            //   935: ifnull -> 951
            //   938: iconst_1
            //   939: invokeinterface get : (I)Ljava/lang/Object;
            //   944: checkcast java/lang/String
            //   947: dup
            //   948: ifnonnull -> 954
            //   951: pop
            //   952: ldc ''
            //   954: aload #18
            //   956: aload_1
            //   957: checkcast java/lang/CharSequence
            //   960: iconst_0
            //   961: iconst_2
            //   962: aconst_null
            //   963: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   966: dup
            //   967: ifnull -> 992
            //   970: invokeinterface getGroupValues : ()Ljava/util/List;
            //   975: dup
            //   976: ifnull -> 992
            //   979: iconst_1
            //   980: invokeinterface get : (I)Ljava/lang/Object;
            //   985: checkcast java/lang/String
            //   988: dup
            //   989: ifnonnull -> 995
            //   992: pop
            //   993: ldc ''
            //   995: aload #19
            //   997: aload_1
            //   998: checkcast java/lang/CharSequence
            //   1001: iconst_0
            //   1002: iconst_2
            //   1003: aconst_null
            //   1004: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   1007: dup
            //   1008: ifnull -> 1046
            //   1011: invokeinterface getGroupValues : ()Ljava/util/List;
            //   1016: dup
            //   1017: ifnull -> 1046
            //   1020: iconst_1
            //   1021: invokeinterface get : (I)Ljava/lang/Object;
            //   1026: checkcast java/lang/String
            //   1029: dup
            //   1030: ifnull -> 1046
            //   1033: invokestatic toIntOrNull : (Ljava/lang/String;)Ljava/lang/Integer;
            //   1036: dup
            //   1037: ifnull -> 1046
            //   1040: invokevirtual intValue : ()I
            //   1043: goto -> 1049
            //   1046: pop
            //   1047: aconst_null
            //   1048: areturn
            //   1049: aload #20
            //   1051: aload_1
            //   1052: checkcast java/lang/CharSequence
            //   1055: iconst_0
            //   1056: iconst_2
            //   1057: aconst_null
            //   1058: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   1061: dup
            //   1062: ifnull -> 1093
            //   1065: invokeinterface getGroupValues : ()Ljava/util/List;
            //   1070: dup
            //   1071: ifnull -> 1093
            //   1074: iconst_1
            //   1075: invokeinterface get : (I)Ljava/lang/Object;
            //   1080: checkcast java/lang/String
            //   1083: dup
            //   1084: ifnull -> 1093
            //   1087: invokestatic parseBoolean : (Ljava/lang/String;)Z
            //   1090: goto -> 1095
            //   1093: pop
            //   1094: iconst_0
            //   1095: aload #21
            //   1097: aload_1
            //   1098: checkcast java/lang/CharSequence
            //   1101: iconst_0
            //   1102: iconst_2
            //   1103: aconst_null
            //   1104: invokestatic find$default : (Lkotlin/text/Regex;Ljava/lang/CharSequence;IILjava/lang/Object;)Lkotlin/text/MatchResult;
            //   1107: dup
            //   1108: ifnull -> 1240
            //   1111: invokeinterface getGroupValues : ()Ljava/util/List;
            //   1116: dup
            //   1117: ifnull -> 1240
            //   1120: iconst_1
            //   1121: invokeinterface get : (I)Ljava/lang/Object;
            //   1126: checkcast java/lang/String
            //   1129: dup
            //   1130: ifnull -> 1240
            //   1133: astore #22
            //   1135: istore #46
            //   1137: istore #45
            //   1139: astore #44
            //   1141: astore #43
            //   1143: istore #42
            //   1145: istore #41
            //   1147: istore #40
            //   1149: istore #39
            //   1151: lstore #37
            //   1153: lstore #35
            //   1155: astore #34
            //   1157: lstore #32
            //   1159: astore #31
            //   1161: astore #30
            //   1163: astore #29
            //   1165: astore #28
            //   1167: lstore #26
            //   1169: astore #25
            //   1171: astore #24
            //   1173: iconst_0
            //   1174: istore #23
            //   1176: aload #22
            //   1178: ldc 'null'
            //   1180: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
            //   1183: ifeq -> 1190
            //   1186: aconst_null
            //   1187: goto -> 1195
            //   1190: aload #22
            //   1192: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
            //   1195: astore #47
            //   1197: aload #24
            //   1199: aload #25
            //   1201: lload #26
            //   1203: aload #28
            //   1205: aload #29
            //   1207: aload #30
            //   1209: aload #31
            //   1211: lload #32
            //   1213: aload #34
            //   1215: lload #35
            //   1217: lload #37
            //   1219: iload #39
            //   1221: iload #40
            //   1223: iload #41
            //   1225: iload #42
            //   1227: aload #43
            //   1229: aload #44
            //   1231: iload #45
            //   1233: iload #46
            //   1235: aload #47
            //   1237: goto -> 1242
            //   1240: pop
            //   1241: aconst_null
            //   1242: astore #48
            //   1244: istore #49
            //   1246: istore #50
            //   1248: astore #51
            //   1250: astore #52
            //   1252: istore #53
            //   1254: istore #54
            //   1256: istore #55
            //   1258: istore #56
            //   1260: lstore #57
            //   1262: lstore #59
            //   1264: astore #61
            //   1266: lstore #62
            //   1268: astore #64
            //   1270: astore #65
            //   1272: astore #66
            //   1274: astore #67
            //   1276: lstore #68
            //   1278: astore #70
            //   1280: astore #71
            //   1282: new com/etouch/logger/ResonanceExperienceLog
            //   1285: dup
            //   1286: aload #71
            //   1288: aload #70
            //   1290: lload #68
            //   1292: aload #67
            //   1294: aload #66
            //   1296: aload #65
            //   1298: aload #64
            //   1300: lload #62
            //   1302: aload #61
            //   1304: lload #59
            //   1306: lload #57
            //   1308: iload #56
            //   1310: iload #55
            //   1312: iload #54
            //   1314: iload #53
            //   1316: aload #52
            //   1318: aload #51
            //   1320: iload #50
            //   1322: iload #49
            //   1324: aload #48
            //   1326: invokespecial <init> : (Ljava/lang/String;Ljava/lang/String;JLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;JLcom/etouch/MediaType;JJZZZZLjava/lang/String;Ljava/lang/String;IZLjava/lang/Long;)V
            //   1329: astore_2
            //   1330: goto -> 1348
            //   1333: astore_3
            //   1334: ldc 'ResonanceExperienceLog'
            //   1336: ldc 'Failed to parse JSON'
            //   1338: aload_3
            //   1339: checkcast java/lang/Throwable
            //   1342: invokestatic e : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
            //   1345: pop
            //   1346: aconst_null
            //   1347: astore_2
            //   1348: aload_2
            //   1349: areturn
            // Line number table:
            //   Java source line number -> byte code offset
            //   #74	-> 6
            //   #76	-> 11
            //   #76	-> 16
            //   #77	-> 21
            //   #77	-> 26
            //   #78	-> 31
            //   #78	-> 36
            //   #79	-> 42
            //   #79	-> 47
            //   #80	-> 53
            //   #80	-> 58
            //   #81	-> 64
            //   #81	-> 69
            //   #82	-> 75
            //   #82	-> 80
            //   #84	-> 86
            //   #84	-> 91
            //   #85	-> 97
            //   #85	-> 102
            //   #86	-> 108
            //   #86	-> 113
            //   #87	-> 119
            //   #87	-> 124
            //   #89	-> 130
            //   #89	-> 135
            //   #90	-> 141
            //   #90	-> 146
            //   #91	-> 152
            //   #91	-> 157
            //   #92	-> 163
            //   #92	-> 168
            //   #94	-> 174
            //   #94	-> 179
            //   #95	-> 185
            //   #95	-> 190
            //   #96	-> 196
            //   #96	-> 201
            //   #98	-> 207
            //   #98	-> 212
            //   #99	-> 218
            //   #99	-> 223
            //   #101	-> 225
            //   #102	-> 225
            //   #103	-> 265
            //   #104	-> 305
            //   #105	-> 359
            //   #106	-> 400
            //   #107	-> 441
            //   #108	-> 482
            //   #110	-> 523
            //   #111	-> 577
            //   #112	-> 621
            //   #113	-> 675
            //   #115	-> 729
            //   #115	-> 770
            //   #116	-> 775
            //   #116	-> 816
            //   #117	-> 821
            //   #117	-> 862
            //   #118	-> 867
            //   #118	-> 908
            //   #120	-> 913
            //   #121	-> 954
            //   #122	-> 995
            //   #124	-> 1049
            //   #124	-> 1090
            //   #125	-> 1095
            //   #126	-> 1176
            //   #125	-> 1237
            //   #125	-> 1240
            //   #101	-> 1242
            //   #129	-> 1333
            //   #130	-> 1334
            //   #131	-> 1346
            //   #74	-> 1349
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   1176	19	23	$i$a$-let-ResonanceExperienceLog$Companion$fromJson$1	I
            //   1173	22	22	it	Ljava/lang/String;
            //   17	1312	2	idRegex	Lkotlin/text/Regex;
            //   27	1302	3	userIdRegex	Lkotlin/text/Regex;
            //   38	1291	4	timestampRegex	Lkotlin/text/Regex;
            //   49	1280	5	deviceModelRegex	Lkotlin/text/Regex;
            //   60	1269	6	devicePlatformRegex	Lkotlin/text/Regex;
            //   71	1258	7	appVersionRegex	Lkotlin/text/Regex;
            //   82	1247	8	operationTypeRegex	Lkotlin/text/Regex;
            //   93	1236	9	playDurationRegex	Lkotlin/text/Regex;
            //   104	1225	10	mediaTypeRegex	Lkotlin/text/Regex;
            //   115	1214	11	mediaDurationRegex	Lkotlin/text/Regex;
            //   126	1203	12	deviceControlDurationRegex	Lkotlin/text/Regex;
            //   137	1192	13	usedSeekRegex	Lkotlin/text/Regex;
            //   148	1181	14	usedPrevNextRegex	Lkotlin/text/Regex;
            //   159	1170	15	isDeviceConnectedRegex	Lkotlin/text/Regex;
            //   170	1159	16	isDeviceControlEnabledRegex	Lkotlin/text/Regex;
            //   181	1148	17	mediaNameRegex	Lkotlin/text/Regex;
            //   192	1137	18	mediaAuthorRegex	Lkotlin/text/Regex;
            //   203	1126	19	mediaIdRegex	Lkotlin/text/Regex;
            //   214	1115	20	uploadedRegex	Lkotlin/text/Regex;
            //   225	1104	21	uploadTimestampRegex	Lkotlin/text/Regex;
            //   1334	14	3	e	Ljava/lang/Exception;
            //   0	1350	0	this	Lcom/etouch/logger/ResonanceExperienceLog$Companion;
            //   0	1350	1	json	Ljava/lang/String;
            // Exception table:
            //   from	to	target	type
            //   6	1330	1333	java/lang/Exception
        }
    }
}


