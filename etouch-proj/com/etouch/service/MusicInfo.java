package com.etouch.service;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class MusicInfo {
    @NotNull
    private final String uri;
    @NotNull
    private final String url;
    @NotNull
    private final String title;
    @NotNull
    private final String artist;
    @Nullable
    private final String cover;
    @Nullable
    private final String duration;
    @Nullable
    private final Double currentTime;
    @Nullable
    private final Integer index;
    @Nullable
    private final String path;

    public MusicInfo(@NotNull String uri, @NotNull String url, @NotNull String title, @NotNull String artist, @Nullable String cover, @Nullable String duration, @Nullable Double currentTime, @Nullable Integer index, @Nullable String path) {
        this.uri = uri;
        this.url = url;
        this.title = title;
        this.artist = artist;
        this.cover = cover;
        this.duration = duration;
        this.currentTime = currentTime;
        this.index = index;
        this.path = path;
    }

    @Nullable
    public final String getPath() {
        return this.path;
    }


    @NotNull
    public final String getUri() {
        return this.uri;
    }

    @NotNull
    public final String getUrl() {
        return this.url;
    }

    @NotNull
    public final String getTitle() {
        return this.title;
    }

    @NotNull
    public final String getArtist() {
        return this.artist;
    }

    @Nullable
    public final String getCover() {
        return this.cover;
    }

    @Nullable
    public final String getDuration() {
        return this.duration;
    }

    @Nullable
    public final Double getCurrentTime() {
        return this.currentTime;
    }

    @Nullable
    public final Integer getIndex() {
        return this.index;
    }

    @NotNull
    public final String component1() {
        return this.uri;
    }

    @NotNull
    public final String component2() {
        return this.url;
    }

    @NotNull
    public final String component3() {
        return this.title;
    }

    @NotNull
    public final String component4() {
        return this.artist;
    }

    @Nullable
    public final String component5() {
        return this.cover;
    }

    @Nullable
    public final String component6() {
        return this.duration;
    }

    @Nullable
    public final Double component7() {
        return this.currentTime;
    }

    @Nullable
    public final Integer component8() {
        return this.index;
    }

    @Nullable
    public final String component9() {
        return this.path;
    }

    @NotNull
    public final MusicInfo copy(@NotNull String uri, @NotNull String url, @NotNull String title, @NotNull String artist, @Nullable String cover, @Nullable String duration, @Nullable Double currentTime, @Nullable Integer index, @Nullable String path) {
        Intrinsics.checkNotNullParameter(uri, "uri");
        Intrinsics.checkNotNullParameter(url, "url");
        Intrinsics.checkNotNullParameter(title, "title");
        Intrinsics.checkNotNullParameter(artist, "artist");
        return new MusicInfo(uri, url, title, artist, cover, duration, currentTime, index, path);
    }

    @NotNull
    public String toString() {
        return "MusicInfo(uri=" + this.uri + ", url=" + this.url + ", title=" + this.title + ", artist=" + this.artist + ", cover=" + this.cover + ", duration=" + this.duration + ", currentTime=" + this.currentTime + ", index=" + this.index + ", path=" + this.path + ")";
    }

    public int hashCode() {
        result = this.uri.hashCode();
        result = result * 31 + this.url.hashCode();
        result = result * 31 + this.title.hashCode();
        result = result * 31 + this.artist.hashCode();
        result = result * 31 + ((this.cover == null) ? 0 : this.cover.hashCode());
        result = result * 31 + ((this.duration == null) ? 0 : this.duration.hashCode());
        result = result * 31 + ((this.currentTime == null) ? 0 : this.currentTime.hashCode());
        result = result * 31 + ((this.index == null) ? 0 : this.index.hashCode());
        return result * 31 + ((this.path == null) ? 0 : this.path.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof MusicInfo))
            return false;
        MusicInfo musicInfo = (MusicInfo) other;
        return !Intrinsics.areEqual(this.uri, musicInfo.uri) ? false : (!Intrinsics.areEqual(this.url, musicInfo.url) ? false : (!Intrinsics.areEqual(this.title, musicInfo.title) ? false : (!Intrinsics.areEqual(this.artist, musicInfo.artist) ? false : (!Intrinsics.areEqual(this.cover, musicInfo.cover) ? false : (!Intrinsics.areEqual(this.duration, musicInfo.duration) ? false : (!Intrinsics.areEqual(this.currentTime, musicInfo.currentTime) ? false : (!Intrinsics.areEqual(this.index, musicInfo.index) ? false : (!!Intrinsics.areEqual(this.path, musicInfo.path)))))))));
    }
}


