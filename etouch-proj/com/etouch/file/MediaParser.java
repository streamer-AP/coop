package com.etouch.file;

import android.database.Cursor;
import android.media.MediaMetadataRetriever;
import com.etouch.MediaType;

import java.util.Set;

import kotlin.Metadata;
import kotlin.collections.SetsKt;
import kotlin.coroutines.Continuation;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Ref;
import kotlin.text.StringsKt;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;


public final class MediaParser {
    public MediaParser(@NotNull Context context) {
        this.context = context;
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000&\n\002\030\002\n\002\020\000\n\002\b\002\n\002\020\t\n\002\b\002\n\002\020\b\n\000\n\002\020\"\n\002\020\016\n\002\b\006\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002R\016\020\003\032\0020\004XT¢\006\002\n\000R\016\020\005\032\0020\004XT¢\006\002\n\000R\016\020\006\032\0020\007XT¢\006\002\n\000R\024\020\b\032\b\022\004\022\0020\n0\tX\004¢\006\002\n\000R\024\020\013\032\b\022\004\022\0020\n0\tX\004¢\006\002\n\000R\024\020\f\032\b\022\004\022\0020\n0\tX\004¢\006\002\n\000R\024\020\r\032\b\022\004\022\0020\n0\tX\004¢\006\002\n\000R\024\020\016\032\b\022\004\022\0020\n0\tX\004¢\006\002\n\000R\016\020\017\032\0020\nXT¢\006\002\n\000¨\006\020"}, d2 = {"Lcom/etouch/file/MediaParser$Companion;", "", "()V", "MAX_DURATION_MS", "", "MAX_FILE_SIZE", "MAX_ITEM_NAME_BYTES", "", "SUPPORTED_AUDIO_FORMATS", "", "", "SUPPORTED_IMAGE_FORMATS", "SUPPORTED_PDF_FORMATS", "SUPPORTED_SUBTITLE_FORMATS", "SUPPORTED_VIDEO_FORMATS", "TAG", "sdk_android_unity_bridge_v1_debug"})
    public static final class Companion {
        private Companion() {
        }
    }

    @NotNull
    public static final Companion Companion = new Companion(null);
    @NotNull
    private final Context context;
    @NotNull
    private static final String TAG = "MediaParser";
    @NotNull
    private static final Set<String> SUPPORTED_AUDIO_FORMATS;
    @NotNull
    private static final Set<String> SUPPORTED_VIDEO_FORMATS;
    @NotNull
    private static final Set<String> SUPPORTED_SUBTITLE_FORMATS;
    @NotNull
    private static final Set<String> SUPPORTED_IMAGE_FORMATS;

    static {
        String[] arrayOfString = new String[6];
        arrayOfString[0] = "mp3";
        arrayOfString[1] = "wav";
        arrayOfString[2] = "aac";
        arrayOfString[3] = "flac";
        arrayOfString[4] = "m4a";
        arrayOfString[5] = "ogg";
        SUPPORTED_AUDIO_FORMATS = SetsKt.setOf((Object[]) arrayOfString);


        arrayOfString = new String[4];
        arrayOfString[0] = "mp4";
        arrayOfString[1] = "mov";
        arrayOfString[2] = "mkv";
        arrayOfString[3] = "avi";
        SUPPORTED_VIDEO_FORMATS = SetsKt.setOf((Object[]) arrayOfString);


        arrayOfString = new String[5];
        arrayOfString[0] = "srt";
        arrayOfString[1] = "vtt";
        arrayOfString[2] = "lrc";
        arrayOfString[3] = "sub";
        arrayOfString[4] = "stl";
        SUPPORTED_SUBTITLE_FORMATS = SetsKt.setOf((Object[]) arrayOfString);


        arrayOfString = new String[15];
        arrayOfString[0] = "jpeg";
        arrayOfString[1] =
                "jpg";
        arrayOfString[2] = "png";
        arrayOfString[3] = "tiff";
        arrayOfString[4] = "gif";
        arrayOfString[5] = "webp";
        arrayOfString[6] = "bmp";
        arrayOfString[7] = "heif";
        arrayOfString[8] = "heic";
        arrayOfString[9] = "hdr";
        arrayOfString[10] = "srt";
        arrayOfString[11] = "vtt";
        arrayOfString[12] = "lrc";
        arrayOfString[13] = "sub";
        arrayOfString[14] = "stl";
        SUPPORTED_IMAGE_FORMATS = SetsKt.setOf((Object[]) arrayOfString);
    }

    @NotNull
    private static final Set<String> SUPPORTED_PDF_FORMATS = SetsKt.setOf("pdf");
    private static final long MAX_DURATION_MS = 18000000L;
    private static final long MAX_FILE_SIZE = 1099511627776L;
    private static final int MAX_ITEM_NAME_BYTES = 40;

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\026\n\002\030\002\n\002\020\000\n\002\b\003\n\002\030\002\n\002\030\002\n\000\b6\030\0002\0020\001:\002\003\004B\007\b\004¢\006\002\020\002\001\002\005\006¨\006\007"}, d2 = {"Lcom/etouch/file/MediaParser$ValidationResult;", "", "()V", "Error", "Success", "Lcom/etouch/file/MediaParser$ValidationResult$Error;", "Lcom/etouch/file/MediaParser$ValidationResult$Success;", "sdk_android_unity_bridge_v1_debug"})
    public static abstract class ValidationResult {
        private ValidationResult() {
        }

        @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\0004\n\002\030\002\n\002\030\002\n\000\n\002\020\016\n\002\b\002\n\002\020\t\n\000\n\002\030\002\n\002\b\016\n\002\020\013\n\000\n\002\020\000\n\000\n\002\020\b\n\002\b\002\b\b\030\0002\0020\001B%\022\006\020\002\032\0020\003\022\006\020\004\032\0020\003\022\006\020\005\032\0020\006\022\006\020\007\032\0020\b¢\006\002\020\tJ\t\020\021\032\0020\003HÆ\003J\t\020\022\032\0020\003HÆ\003J\t\020\023\032\0020\006HÆ\003J\t\020\024\032\0020\bHÆ\003J1\020\025\032\0020\0002\b\b\002\020\002\032\0020\0032\b\b\002\020\004\032\0020\0032\b\b\002\020\005\032\0020\0062\b\b\002\020\007\032\0020\bHÆ\001J\023\020\026\032\0020\0272\b\020\030\032\004\030\0010\031HÖ\003J\t\020\032\032\0020\033HÖ\001J\t\020\034\032\0020\003HÖ\001R\021\020\005\032\0020\006¢\006\b\n\000\032\004\b\n\020\013R\021\020\004\032\0020\003¢\006\b\n\000\032\004\b\f\020\rR\021\020\002\032\0020\003¢\006\b\n\000\032\004\b\016\020\rR\021\020\007\032\0020\b¢\006\b\n\000\032\004\b\017\020\020¨\006\035"}, d2 = {"Lcom/etouch/file/MediaParser$ValidationResult$Success;", "Lcom/etouch/file/MediaParser$ValidationResult;", "fileName", "", "fileExtension", "duration", "", "mediaType", "Lcom/etouch/MediaType;", "(Ljava/lang/String;Ljava/lang/String;JLcom/etouch/MediaType;)V", "getDuration", "()J", "getFileExtension", "()Ljava/lang/String;", "getFileName", "getMediaType", "()Lcom/etouch/MediaType;", "component1", "component2", "component3", "component4", "copy", "equals", "", "other", "", "hashCode", "", "toString", "sdk_android_unity_bridge_v1_debug"})
        public static final class Success extends ValidationResult {
            @NotNull
            private final String fileName;
            @NotNull
            private final String fileExtension;
            private final long duration;
            @NotNull
            private final MediaType mediaType;

            @NotNull
            public final String getFileName() {
                return this.fileName;
            }

            @NotNull
            public final String getFileExtension() {
                return this.fileExtension;
            }

            public final long getDuration() {
                return this.duration;
            }

            @NotNull
            public final MediaType getMediaType() {
                return this.mediaType;
            }

            @NotNull
            public final String component1() {
                return this.fileName;
            }

            @NotNull
            public final String component2() {
                return this.fileExtension;
            }

            public final long component3() {
                return this.duration;
            }

            @NotNull
            public final MediaType component4() {
                return this.mediaType;
            }

            @NotNull
            public final Success copy(@NotNull String fileName, @NotNull String fileExtension, long duration, @NotNull MediaType mediaType) {
                Intrinsics.checkNotNullParameter(fileName, "fileName");
                Intrinsics.checkNotNullParameter(fileExtension, "fileExtension");
                Intrinsics.checkNotNullParameter(mediaType, "mediaType");
                return new Success(fileName, fileExtension, duration, mediaType);
            }

            @NotNull
            public String toString() {
                return "Success(fileName=" + this.fileName + ", fileExtension=" + this.fileExtension + ", duration=" + this.duration + ", mediaType=" + this.mediaType + ")";
            }

            public Success(@NotNull String fileName, @NotNull String fileExtension, long duration, @NotNull MediaType mediaType) {
                super(null);
                this.fileName = fileName;
                this.fileExtension = fileExtension;
                this.duration = duration;
                this.mediaType = mediaType;
            }

            public int hashCode() {
                result = this.fileName.hashCode();
                result = result * 31 + this.fileExtension.hashCode();
                result = result * 31 + Long.hashCode(this.duration);
                return result * 31 + this.mediaType.hashCode();
            }

            public boolean equals(@Nullable Object other) {
                if (this == other) return true;
                if (!(other instanceof Success)) return false;
                Success success = (Success) other;
                return !Intrinsics.areEqual(this.fileName, success.fileName) ? false : (!Intrinsics.areEqual(this.fileExtension, success.fileExtension) ? false : ((this.duration != success.duration) ? false : (!(this.mediaType != success.mediaType))));
            }
        }

        @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\036\n\002\030\002\n\002\030\002\n\002\b\005\n\002\030\002\n\002\030\002\n\002\030\002\n\002\030\002\n\000\b6\030\0002\0020\001:\004\003\004\005\006B\007\b\004¢\006\002\020\002\001\004\007\b\t\n¨\006\013"}, d2 = {"Lcom/etouch/file/MediaParser$ValidationResult$Error;", "Lcom/etouch/file/MediaParser$ValidationResult;", "()V", "DurationTooLong", "FileTooLarge", "UnknownError", "UnsupportedFileType", "Lcom/etouch/file/MediaParser$ValidationResult$Error$DurationTooLong;", "Lcom/etouch/file/MediaParser$ValidationResult$Error$FileTooLarge;", "Lcom/etouch/file/MediaParser$ValidationResult$Error$UnknownError;", "Lcom/etouch/file/MediaParser$ValidationResult$Error$UnsupportedFileType;", "sdk_android_unity_bridge_v1_debug"})
        public static abstract class Error extends ValidationResult {
            private Error() {
                super(null);
            }

            @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\f\n\002\030\002\n\002\030\002\n\002\b\002\bÆ\002\030\0002\0020\001B\007\b\002¢\006\002\020\002¨\006\003"}, d2 = {"Lcom/etouch/file/MediaParser$ValidationResult$Error$UnsupportedFileType;", "Lcom/etouch/file/MediaParser$ValidationResult$Error;", "()V", "sdk_android_unity_bridge_v1_debug"})
            public static final class UnsupportedFileType extends Error {
                @NotNull
                public static final UnsupportedFileType INSTANCE = new UnsupportedFileType();

                private UnsupportedFileType() {
                    super(null);
                }
            }

            @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\f\n\002\030\002\n\002\030\002\n\002\b\002\bÆ\002\030\0002\0020\001B\007\b\002¢\006\002\020\002¨\006\003"}, d2 = {"Lcom/etouch/file/MediaParser$ValidationResult$Error$DurationTooLong;", "Lcom/etouch/file/MediaParser$ValidationResult$Error;", "()V", "sdk_android_unity_bridge_v1_debug"})
            public static final class DurationTooLong extends Error {
                @NotNull
                public static final DurationTooLong INSTANCE = new DurationTooLong();

                private DurationTooLong() {
                    super(null);
                }
            }

            @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\f\n\002\030\002\n\002\030\002\n\002\b\002\bÆ\002\030\0002\0020\001B\007\b\002¢\006\002\020\002¨\006\003"}, d2 = {"Lcom/etouch/file/MediaParser$ValidationResult$Error$FileTooLarge;", "Lcom/etouch/file/MediaParser$ValidationResult$Error;", "()V", "sdk_android_unity_bridge_v1_debug"})
            public static final class FileTooLarge extends Error {
                @NotNull
                public static final FileTooLarge INSTANCE = new FileTooLarge();

                private FileTooLarge() {
                    super(null);
                }
            }

            @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000&\n\002\030\002\n\002\030\002\n\000\n\002\020\016\n\002\b\006\n\002\020\013\n\000\n\002\020\000\n\000\n\002\020\b\n\002\b\002\b\b\030\0002\0020\001B\r\022\006\020\002\032\0020\003¢\006\002\020\004J\t\020\007\032\0020\003HÆ\003J\023\020\b\032\0020\0002\b\b\002\020\002\032\0020\003HÆ\001J\023\020\t\032\0020\n2\b\020\013\032\004\030\0010\fHÖ\003J\t\020\r\032\0020\016HÖ\001J\t\020\017\032\0020\003HÖ\001R\021\020\002\032\0020\003¢\006\b\n\000\032\004\b\005\020\006¨\006\020"}, d2 = {"Lcom/etouch/file/MediaParser$ValidationResult$Error$UnknownError;", "Lcom/etouch/file/MediaParser$ValidationResult$Error;", "message", "", "(Ljava/lang/String;)V", "getMessage", "()Ljava/lang/String;", "component1", "copy", "equals", "", "other", "", "hashCode", "", "toString", "sdk_android_unity_bridge_v1_debug"})
            public static final class UnknownError extends Error {
                @NotNull
                private final String message;

                public UnknownError(@NotNull String message) {
                    super(null);
                    this.message = message;
                }

                @NotNull
                public final String getMessage() {
                    return this.message;
                }

                @NotNull
                public final String component1() {
                    return this.message;
                }

                @NotNull
                public final UnknownError copy(@NotNull String message) {
                    Intrinsics.checkNotNullParameter(message, "message");
                    return new UnknownError(message);
                }

                @NotNull
                public String toString() {
                    return "UnknownError(message=" + this.message + ")";
                }

                public int hashCode() {
                    return this.message.hashCode();
                }

                public boolean equals(@Nullable Object other) {
                    if (this == other)
                        return true;
                    if (!(other instanceof UnknownError))
                        return false;
                    UnknownError unknownError = (UnknownError) other;
                    return !!Intrinsics.areEqual(this.message, unknownError.message);
                }
            }
        }
    }

    @Nullable
    public final Object validateMediaFile(@NotNull Uri uri, @NotNull Continuation $completion) {
        return BuildersKt.withContext((CoroutineContext) Dispatchers.getIO(), new MediaParser$validateMediaFile$2(uri, null), $completion);
    }

    @DebugMetadata(f = "MediaParser.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.file.MediaParser$validateMediaFile$2")
    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\030\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "Lcom/etouch/file/MediaParser$ValidationResult;", "Lkotlinx/coroutines/CoroutineScope;"})
    static final class MediaParser$validateMediaFile$2 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super ValidationResult>, Object> {
        int label;

        MediaParser$validateMediaFile$2(Uri $uri, Continuation $completion) {
            super(2, $completion);
        }

        @Nullable
        public final Object invokeSuspend(@NotNull Object $result) {
            MediaParser.ValidationResult.Error.UnknownError unknownError;
            IntrinsicsKt.getCOROUTINE_SUSPENDED();
            switch (this.label) {
                case 0:
                    ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);


                    try {
                        String[] arrayOfString = new String[2];
                        arrayOfString[0] = "_display_name";
                        arrayOfString[1] = "_size";
                        Cursor cursor = MediaParser.this.context.getContentResolver().query(this.$uri, arrayOfString,
                                null, null, null);


                        Ref.ObjectRef fileName = new Ref.ObjectRef();
                        fileName.element = "Unknown";
                        Ref.ObjectRef fileExtension = new Ref.ObjectRef();
                        fileExtension.element = "";
                        Ref.LongRef fileSize = new Ref.LongRef();

                        if (cursor != null) {
                            Closeable closeable = (Closeable) cursor;
                            Throwable throwable = null;
                            try {
                                Cursor it = (Cursor) closeable;
                                int $i$a$ -use - MediaParser$validateMediaFile$2$1 = 0;
                                if (it.moveToFirst()) {
                                    int nameIndex = it.getColumnIndex("_display_name");
                                    int sizeIndex = it.getColumnIndex("_size");

                                    if (nameIndex >= 0) {
                                        String str1 = it.getString(nameIndex);
                                        Intrinsics.checkNotNull(str1);
                                        String fullName = (str1 == null) ? "Unknown" : str1;
                                        Intrinsics.checkNotNullExpressionValue(StringsKt.substringAfterLast(fullName, ".", "").toLowerCase(Locale.ROOT), "toLowerCase(...)");
                                        fileExtension.element = StringsKt.substringAfterLast(fullName, ".", "").toLowerCase(Locale.ROOT);
                                        fileName.element = StringsKt.substringBeforeLast$default(fullName, ".", null, 2, null);
                                    }

                                    if (sizeIndex >= 0) {
                                        fileSize.element = it.getLong(sizeIndex);
                                    }
                                }
                                Unit unit = Unit.INSTANCE;
                            } catch (Throwable throwable1) {
                                throwable = throwable1 = null;
                                throw throwable1;
                            } finally {
                                CloseableKt.closeFinally(closeable, throwable);
                            }
                        } else {
                        }
                        if (MediaParser.SUPPORTED_PDF_FORMATS.contains(fileExtension.element)) {
                        } else {
                            return MediaParser.ValidationResult.Error.UnsupportedFileType.INSTANCE;
                        }


                        MediaType mediaType = MediaParser.SUPPORTED_AUDIO_FORMATS.contains(fileExtension.element) ? MediaType.AUDIO : (MediaParser.SUPPORTED_VIDEO_FORMATS.contains(fileExtension.element) ? MediaType.VIDEO : (MediaParser.SUPPORTED_SUBTITLE_FORMATS.contains(fileExtension.element) ? MediaType.SUBTITLE : (MediaParser.SUPPORTED_IMAGE_FORMATS.contains(fileExtension.element) ? MediaType.IMAGE : (MediaType) "JD-Core does not support Kotlin")));
                        if (fileSize.element > 1099511627776L) {
                            return MediaParser.ValidationResult.Error.FileTooLarge.INSTANCE;
                        }


                        long duration = 0L;
                        if (mediaType == MediaType.AUDIO || mediaType == MediaType.VIDEO) {
                            try {
                                MediaMetadataRetriever retriever = new MediaMetadataRetriever();
                                retriever.setDataSource(MediaParser.this.context, this.$uri);

                                String durationStr =
                                        retriever.extractMetadata(9);
                                StringsKt.toLongOrNull(durationStr);
                                duration = (durationStr != null && StringsKt.toLongOrNull(durationStr) != null) ? StringsKt.toLongOrNull(durationStr).longValue() : 0L;

                                retriever.release();

                                if (duration > 18000000L) {
                                    return MediaParser.ValidationResult.Error.DurationTooLong.INSTANCE;
                                }
                            } catch (Exception exception) {
                            }
                        }


                        MediaParser.ValidationResult.Success success = new MediaParser.ValidationResult.Success(
                                (String) fileName.element,
                                (String) fileExtension.element,
                                duration,
                                mediaType);
                    } catch (Exception e) {
                        Ref.ObjectRef fileName;
                        if (fileName.getMessage() == null) fileName.getMessage();
                        super("未知错误");
                    } return unknownError;
            }

            throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
        }

        @NotNull
        public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super MediaParser$validateMediaFile$2> $completion) {
            return (Continuation<Unit>) new MediaParser$validateMediaFile$2(this.$uri, $completion);
        }

        @Nullable
        public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
            return ((MediaParser$validateMediaFile$2) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
        }
    }

    @NotNull
    public final String generateUniqueItemName(@NotNull String baseName, @NotNull List existingNames) {
        Intrinsics.checkNotNullParameter(baseName, "baseName");
        Intrinsics.checkNotNullParameter(existingNames, "existingNames");
        String truncatedName = truncateToBytes(baseName, 40);


        if (!existingNames.contains(truncatedName)) {
            return truncatedName;
        }


        int suffix = 1;
        String uniqueName = null;
        do {
            uniqueName = truncatedName + " (" + truncatedName + ")";
            suffix++;
        } while (existingNames.contains(uniqueName));

        return uniqueName;
    }


    private final String truncateToBytes(String str, int maxBytes) {
        Intrinsics.checkNotNullExpressionValue(str.getBytes(Charsets.UTF_8), "getBytes(...)");
        byte[] bytes = str.getBytes(Charsets.UTF_8);
        if (bytes.length <= maxBytes) {
            return str;
        }


        String result = "";
        byte b = 0;
        int i = str.length();
        char char =str.charAt(b);
        String temp = result + result;
        Intrinsics.checkNotNullExpressionValue(temp.getBytes(Charsets.UTF_8), "getBytes(...)");
        for (; b < i && (temp.getBytes(Charsets.UTF_8)).length <= maxBytes; b++) {

            result = temp;
        }

        return result;
    }
}


