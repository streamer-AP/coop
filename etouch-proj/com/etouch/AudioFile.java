package com.etouch;

import android.net.Uri;
import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;


public final class AudioFile {
    private final int id;
    @NotNull
    private final String name;
    @NotNull
    private final String author;

    public AudioFile(int id, @NotNull String name, @NotNull String author, @Nullable Uri uri, long importTime, @NotNull MediaType mediaType, @Nullable String controlSignalPath) {
        this.id = id;
        this.name = name;
        this.author = author;
        this.uri = uri;
        this.importTime = importTime;
        this.mediaType = mediaType;
        this.controlSignalPath = controlSignalPath;
    }

    @Nullable
    private final Uri uri;
    private final long importTime;
    @NotNull
    private final MediaType mediaType;
    @Nullable
    private final String controlSignalPath;

    @Nullable
    public final String getControlSignalPath() {
        return this.controlSignalPath;
    }


    public final int getId() {
        return this.id;
    }

    @NotNull
    public final String getName() {
        return this.name;
    }

    @NotNull
    public final String getAuthor() {
        return this.author;
    }

    @Nullable
    public final Uri getUri() {
        return this.uri;
    }

    public final long getImportTime() {
        return this.importTime;
    }

    @NotNull
    public final MediaType getMediaType() {
        return this.mediaType;
    }

    public final int component1() {
        return this.id;
    }

    @NotNull
    public final String component2() {
        return this.name;
    }

    @NotNull
    public final String component3() {
        return this.author;
    }

    @Nullable
    public final Uri component4() {
        return this.uri;
    }

    public final long component5() {
        return this.importTime;
    }

    @NotNull
    public final MediaType component6() {
        return this.mediaType;
    }

    @Nullable
    public final String component7() {
        return this.controlSignalPath;
    }

    @NotNull
    public final AudioFile copy(int id, @NotNull String name, @NotNull String author, @Nullable Uri uri, long importTime, @NotNull MediaType mediaType, @Nullable String controlSignalPath) {
        Intrinsics.checkNotNullParameter(name, "name");
        Intrinsics.checkNotNullParameter(author, "author");
        Intrinsics.checkNotNullParameter(mediaType, "mediaType");
        return new AudioFile(id, name, author, uri, importTime, mediaType, controlSignalPath);
    }

    @NotNull
    public String toString() {
        return "AudioFile(id=" + this.id + ", name=" + this.name + ", author=" + this.author + ", uri=" + this.uri + ", importTime=" + this.importTime + ", mediaType=" + this.mediaType + ", controlSignalPath=" + this.controlSignalPath + ")";
    }

    public int hashCode() {
        result = Integer.hashCode(this.id);
        result = result * 31 + this.name.hashCode();
        result = result * 31 + this.author.hashCode();
        result = result * 31 + ((this.uri == null) ? 0 : this.uri.hashCode());
        result = result * 31 + Long.hashCode(this.importTime);
        result = result * 31 + this.mediaType.hashCode();
        return result * 31 + ((this.controlSignalPath == null) ? 0 : this.controlSignalPath.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof AudioFile))
            return false;
        AudioFile audioFile = (AudioFile) other;
        return (this.id != audioFile.id) ? false : (!Intrinsics.areEqual(this.name, audioFile.name) ? false : (!Intrinsics.areEqual(this.author, audioFile.author) ? false : (!Intrinsics.areEqual(this.uri, audioFile.uri) ? false : ((this.importTime != audioFile.importTime) ? false : ((this.mediaType != audioFile.mediaType) ? false : (!!Intrinsics.areEqual(this.controlSignalPath, audioFile.controlSignalPath)))))));
    }
}


