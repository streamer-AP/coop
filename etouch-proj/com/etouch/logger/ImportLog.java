package com.etouch.logger;


public final class ImportLog {
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
    private final long fileSize;
    private final long mediaDuration;
    @NotNull
    private final MediaType mediaType;
    private final long parseTimeMs;
    private final boolean parseSuccess;
    @Nullable
    private final String errorMessage;
    private boolean uploaded;
    @Nullable
    private Long uploadTimestamp;

    public ImportLog(@NotNull String id, @NotNull String userId, long timestamp, @NotNull String deviceModel, @NotNull String devicePlatform, @NotNull String appVersion, @NotNull String operationType, long fileSize, long mediaDuration, @NotNull MediaType mediaType, long parseTimeMs, boolean parseSuccess, @Nullable String errorMessage, boolean uploaded, @Nullable Long uploadTimestamp) {
        this.id = id;
        this.userId = userId;
        this.timestamp = timestamp;
        this.deviceModel = deviceModel;
        this.devicePlatform = devicePlatform;
        this.appVersion = appVersion;
        this.operationType = operationType;


        this.fileSize = fileSize;
        this.mediaDuration = mediaDuration;
        this.mediaType = mediaType;
        this.parseTimeMs = parseTimeMs;
        this.parseSuccess = parseSuccess;
        this.errorMessage = errorMessage;


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

    @Nullable
    public final Long getUploadTimestamp() {
        return this.uploadTimestamp;
    }

    public final long getFileSize() {
        return this.fileSize;
    }

    public final long getMediaDuration() {
        return this.mediaDuration;
    }

    @NotNull
    public final MediaType getMediaType() {
        return this.mediaType;
    }

    public final long getParseTimeMs() {
        return this.parseTimeMs;
    }

    public final boolean getParseSuccess() {
        return this.parseSuccess;
    }

    @Nullable
    public final String getErrorMessage() {
        return this.errorMessage;
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
        return this.fileSize;
    }

    public final long component9() {
        return this.mediaDuration;
    }

    @NotNull
    public final MediaType component10() {
        return this.mediaType;
    }

    public final long component11() {
        return this.parseTimeMs;
    }

    public final boolean component12() {
        return this.parseSuccess;
    }

    @Nullable
    public final String component13() {
        return this.errorMessage;
    }

    public final boolean component14() {
        return this.uploaded;
    }

    @Nullable
    public final Long component15() {
        return this.uploadTimestamp;
    }

    @NotNull
    public final String toJson() {
        if (this.uploadTimestamp == null) ;

        return StringsKt.trimIndent("\n            {\n                \"id\": \"" + this.userId + "\",\n                \"userId\": \"" + this.timestamp + "\",\n                \"timestamp\": " + this.deviceModel + ",\n                \"deviceModel\": \"" + this.devicePlatform + "\",\n                \"devicePlatform\": \"" + this.appVersion + "\",\n                \"appVersion\": \"" + this.operationType + "\",\n                \"operationType\": \"" + this.fileSize + "\",\n                \"fileSize\": " + this.mediaDuration + ",\n                \"mediaDuration\": " + this.mediaType.name() + ",\n                \"mediaType\": \"" + this.parseTimeMs + "\",\n                \"parseTimeMs\": " + this.parseSuccess + ",\n                \"parseSuccess\": " + ((this.errorMessage != null) ? ("\"" + this.errorMessage + "\"") : "null") + ",\n                \"errorMessage\": " + this.uploaded + ",\n                \"uploaded\": " + this.uploadTimestamp + ",\n                \"uploadTimestamp\": " + "null" + "\n            }\n        ");
    }

    @NotNull
    public final ImportLog copy(@NotNull String id, @NotNull String userId, long timestamp, @NotNull String deviceModel, @NotNull String devicePlatform, @NotNull String appVersion, @NotNull String operationType, long fileSize, long mediaDuration, @NotNull MediaType mediaType, long parseTimeMs, boolean parseSuccess, @Nullable String errorMessage, boolean uploaded, @Nullable Long uploadTimestamp) {
        Intrinsics.checkNotNullParameter(id, "id");
        Intrinsics.checkNotNullParameter(userId, "userId");
        Intrinsics.checkNotNullParameter(deviceModel, "deviceModel");
        Intrinsics.checkNotNullParameter(devicePlatform, "devicePlatform");
        Intrinsics.checkNotNullParameter(appVersion, "appVersion");
        Intrinsics.checkNotNullParameter(operationType, "operationType");
        Intrinsics.checkNotNullParameter(mediaType, "mediaType");
        return new ImportLog(id, userId, timestamp, deviceModel, devicePlatform, appVersion, operationType, fileSize, mediaDuration, mediaType, parseTimeMs, parseSuccess, errorMessage, uploaded, uploadTimestamp);
    }

    @NotNull
    public String toString() {
        return "ImportLog(id=" + this.id + ", userId=" + this.userId + ", timestamp=" + this.timestamp + ", deviceModel=" + this.deviceModel + ", devicePlatform=" + this.devicePlatform + ", appVersion=" + this.appVersion + ", operationType=" + this.operationType + ", fileSize=" + this.fileSize + ", mediaDuration=" + this.mediaDuration + ", mediaType=" + this.mediaType + ", parseTimeMs=" + this.parseTimeMs + ", parseSuccess=" + this.parseSuccess + ", errorMessage=" + this.errorMessage + ", uploaded=" + this.uploaded + ", uploadTimestamp=" + this.uploadTimestamp + ")";
    }

    public int hashCode() {
        result = this.id.hashCode();
        result = result * 31 + this.userId.hashCode();
        result = result * 31 + Long.hashCode(this.timestamp);
        result = result * 31 + this.deviceModel.hashCode();
        result = result * 31 + this.devicePlatform.hashCode();
        result = result * 31 + this.appVersion.hashCode();
        result = result * 31 + this.operationType.hashCode();
        result = result * 31 + Long.hashCode(this.fileSize);
        result = result * 31 + Long.hashCode(this.mediaDuration);
        result = result * 31 + this.mediaType.hashCode();
        result = result * 31 + Long.hashCode(this.parseTimeMs);
        result = result * 31 + Boolean.hashCode(this.parseSuccess);
        result = result * 31 + ((this.errorMessage == null) ? 0 : this.errorMessage.hashCode());
        result = result * 31 + Boolean.hashCode(this.uploaded);
        return result * 31 + ((this.uploadTimestamp == null) ? 0 : this.uploadTimestamp.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof ImportLog))
            return false;
        ImportLog importLog = (ImportLog) other;
        return !Intrinsics.areEqual(this.id, importLog.id) ? false : (!Intrinsics.areEqual(this.userId, importLog.userId) ? false : ((this.timestamp != importLog.timestamp) ? false : (!Intrinsics.areEqual(this.deviceModel, importLog.deviceModel) ? false : (!Intrinsics.areEqual(this.devicePlatform, importLog.devicePlatform) ? false : (!Intrinsics.areEqual(this.appVersion, importLog.appVersion) ? false : (!Intrinsics.areEqual(this.operationType, importLog.operationType) ? false : ((this.fileSize != importLog.fileSize) ? false : ((this.mediaDuration != importLog.mediaDuration) ? false : ((this.mediaType != importLog.mediaType) ? false : ((this.parseTimeMs != importLog.parseTimeMs) ? false : ((this.parseSuccess != importLog.parseSuccess) ? false : (!Intrinsics.areEqual(this.errorMessage, importLog.errorMessage) ? false : ((this.uploaded != importLog.uploaded) ? false : (!!Intrinsics.areEqual(this.uploadTimestamp, importLog.uploadTimestamp)))))))))))))));
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\030\n\002\030\002\n\002\020\000\n\002\b\002\n\002\030\002\n\000\n\002\020\016\n\000\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002J\020\020\003\032\004\030\0010\0042\006\020\005\032\0020\006¨\006\007"}, d2 = {"Lcom/etouch/logger/ImportLog$Companion;", "", "()V", "fromJson", "Lcom/etouch/logger/ImportLog;", "json", "", "sdk_android_unity_bridge_v1_debug"})
    @SourceDebugExtension({"SMAP\nImportLog.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ImportLog.kt\ncom/etouch/logger/ImportLog$Companion\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n+ 3 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,99:1\n1179#2,2:100\n1253#2,4:102\n1#3:106\n*S KotlinDebug\n*F\n+ 1 ImportLog.kt\ncom/etouch/logger/ImportLog$Companion\n*L\n67#1:100,2\n67#1:102,4\n*E\n"})
    public static final class Companion {
        @Nullable
        public final ImportLog fromJson(@NotNull String json) {
            ImportLog importLog;
            Intrinsics.checkNotNullParameter(json, "json");


            try {
                String[] arrayOfString = new String[1];
                arrayOfString[0] = ",";
                List list1 = StringsKt.split$default(StringsKt.replace$default(StringsKt.replace$default(StringsKt.replace$default(json, "{", "", false, 4, null), "}", "", false, 4, null), "\"", "", false, 4, null), arrayOfString, false, 0, 6, null);
                int $i$f$associate = 0;


                int capacity$iv = RangesKt.coerceAtLeast(MapsKt.mapCapacity(CollectionsKt.collectionSizeOrDefault(list1, 10)), 16);
                List list2 = list1;
                Map<Object, Object> destination$iv$iv = new LinkedHashMap<>(capacity$iv);
                int $i$f$associateTo = 0;
                for (Object element$iv$iv : list2) {
                    Map<Object, Object> map = destination$iv$iv;
                    String it = (String) element$iv$iv;
                    int $i$a$ -associate - ImportLog$Companion$fromJson$values$1 = 0;
                    String[] arrayOfString1 = new String[1];
                    arrayOfString1[0] = ":";
                    List parts = StringsKt.split$default(StringsKt.trim(it).toString(), arrayOfString1, false, 2, 2, null);
                }
                Map<Object, Object> values = destination$iv$iv;
                if ((String) values.get("id") == null) {
                    (String) values.get("id");
                    return null;
                }
                if ((String) values.get("userId") == null) {
                    (String) values.get("userId");
                    return null;
                }
                if ((String) values.get("timestamp") != null && (String) values.get("timestamp")) {
                    if (((String) values.get("userId")).longValue()) {
                        (String) values.get("userId");
                        return null;
                    }
                } else {
                    (String) values.get("userId");
                    return null;
                }
                if ((String) values.get("devicePlatform") == null) {
                    (String) values.get("devicePlatform");
                    return null;
                }
                if ((String) values.get("appVersion") == null) {
                    (String) values.get("appVersion");
                    return null;
                }
                if ((String) values.get("operationType") == null)
                    (String) values.get("operationType");
                StringsKt.toLongOrNull((String) values.get("fileSize"));
                StringsKt.toLongOrNull((String) values.get("mediaDuration"));
                StringsKt.toLongOrNull((String) values.get("parseTimeMs"));
                (String) values.get("parseSuccess");
                String str1 = (String) values.get("errorMessage"), str2 = str1;
                boolean bool1 = ((String) values.get("parseSuccess") != null) ? Boolean.parseBoolean((String) values.get("parseSuccess")) : false;
                long l3 = ((String) values.get("parseTimeMs") != null && StringsKt.toLongOrNull((String) values.get("parseTimeMs")) != null) ? StringsKt.toLongOrNull((String) values.get("parseTimeMs")).longValue() : 0L;
                MediaType mediaType1 = Intrinsics.areEqual(values.get("mediaType"), "VIDEO") ? MediaType.VIDEO : MediaType.AUDIO;
                long l2 = ((String) values.get("mediaDuration") != null && StringsKt.toLongOrNull((String) values.get("mediaDuration")) != null) ? StringsKt.toLongOrNull((String) values.get("mediaDuration")).longValue() : 0L, l1 = ((String) values.get("fileSize") != null && StringsKt.toLongOrNull((String) values.get("fileSize")) != null) ? StringsKt.toLongOrNull((String) values.get("fileSize")).longValue() : 0L;
                String str9 = "IMPORT_MEDIA", str8 = (String) values.get("operationType"), str7 = (String) values.get("appVersion"), str6 = str7, str5 = (String) values.get("devicePlatform"), str4 = str5, str3 = (String) values.get("userId");
                int $i$a$ -takeIf - ImportLog$Companion$fromJson$1 = 0;
                boolean bool2 = !Intrinsics.areEqual(str2, "null") ? true : false;
                (String) values.get("errorMessage");
                (String) values.get("uploaded");
                (String) values.get("uploadTimestamp");
                Long long_ = ((String) values.get("uploadTimestamp") != null) ? StringsKt.toLongOrNull((String) values.get("uploadTimestamp")) : null;
                boolean bool3 = ((String) values.get("uploaded") != null) ? Boolean.parseBoolean((String) values.get("uploaded")) : false;
                String str10 = ((String) values.get("errorMessage") != null) ? (bool2 ? str1 : null) : null;
                boolean bool4 = ((String) values.get("parseSuccess") != null) ? Boolean.parseBoolean((String) values.get("parseSuccess")) : false;
                long l4 = ((String) values.get("parseTimeMs") != null && StringsKt.toLongOrNull((String) values.get("parseTimeMs")) != null) ? StringsKt.toLongOrNull((String) values.get("parseTimeMs")).longValue() : 0L;
                MediaType mediaType2 = Intrinsics.areEqual(values.get("mediaType"), "VIDEO") ? MediaType.VIDEO : MediaType.AUDIO;
                long l5 = ((String) values.get("mediaDuration") != null && StringsKt.toLongOrNull((String) values.get("mediaDuration")) != null) ? StringsKt.toLongOrNull((String) values.get("mediaDuration")).longValue() : 0L, l6 = ((String) values.get("fileSize") != null && StringsKt.toLongOrNull((String) values.get("fileSize")) != null) ? StringsKt.toLongOrNull((String) values.get("fileSize")).longValue() : 0L;
                String str11 = "IMPORT_MEDIA", str12 = (String) values.get("operationType"), str13 = (String) values.get("appVersion"), str14 = str13, str15 = (String) values.get("devicePlatform"), str16 = str15, str17 = (String) values.get("userId");
                importLog = new ImportLog(str17, str16, str15, str14, str13, str12, str11, l6, l5, mediaType2, l4, bool4, str10, bool3, long_);
            } catch (Exception e) {
                Iterable $this$associate$iv;
                Log.e("ImportLog", "解析日志失败: " + $this$associate$iv.getMessage());
                importLog = null;
            }
            return importLog;
        }


        private Companion() {
        }
    }
}
