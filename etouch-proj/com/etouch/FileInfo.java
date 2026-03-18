package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class FileInfo {
    @Nullable
    private Integer mediaType;
    @Nullable
    private String fileName;

    public FileInfo(@Nullable Integer mediaType, @Nullable String fileName) {
        this.mediaType = mediaType;
        this.fileName = fileName;
    }

    @Nullable
    public final Integer getMediaType() {
        return this.mediaType;
    }

    public final void setMediaType(@Nullable Integer<set-?>) {
        this.mediaType = < set - ? >;
    }

    @Nullable
    public final String getFileName() {
        return this.fileName;
    }

    public final void setFileName(@Nullable String<set-?>) {
        this.fileName = < set - ? >;
    }


    @Nullable
    public final Integer component1() {
        return this.mediaType;
    }

    @Nullable
    public final String component2() {
        return this.fileName;
    }

    @NotNull
    public final FileInfo copy(@Nullable Integer mediaType, @Nullable String fileName) {
        return new FileInfo(mediaType, fileName);
    }

    @NotNull
    public String toString() {
        return "FileInfo(mediaType=" + this.mediaType + ", fileName=" + this.fileName + ")";
    }

    public int hashCode() {
        result = (this.mediaType == null) ? 0 : this.mediaType.hashCode();
        return result * 31 + ((this.fileName == null) ? 0 : this.fileName.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof FileInfo))
            return false;
        FileInfo fileInfo = (FileInfo) other;
        return !Intrinsics.areEqual(this.mediaType, fileInfo.mediaType) ? false : (!!Intrinsics.areEqual(this.fileName, fileInfo.fileName));
    }

    public FileInfo() {
        this(null, null, 3, null);
    }
}


