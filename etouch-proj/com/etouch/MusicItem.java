package com.etouch;

import android.net.Uri;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class MusicItem {
    @NotNull
    private final Uri uri;
    @Nullable
    private final String title;
    @Nullable
    private final String artist;
    @Nullable
    private final String cover;

    public MusicItem(@NotNull Uri uri, @Nullable String title, @Nullable String artist, @Nullable String cover) {
        this.uri = uri;
        this.title = title;
        this.artist = artist;
        this.cover = cover;
    }

    @Nullable
    public final String getCover() {
        return this.cover;
    }


    @NotNull
    public final Uri getUri() {
        return this.uri;
    }

    @Nullable
    public final String getTitle() {
        return this.title;
    }

    @Nullable
    public final String getArtist() {
        return this.artist;
    }

    @NotNull
    public final Uri component1() {
        return this.uri;
    }

    @Nullable
    public final String component2() {
        return this.title;
    }

    @Nullable
    public final String component3() {
        return this.artist;
    }

    @Nullable
    public final String component4() {
        return this.cover;
    }

    @NotNull
    public final MusicItem copy(@NotNull Uri uri, @Nullable String title, @Nullable String artist, @Nullable String cover) {
        Intrinsics.checkNotNullParameter(uri, "uri");
        return new MusicItem(uri, title, artist, cover);
    }

    @NotNull
    public String toString() {
        return "MusicItem(uri=" + this.uri + ", title=" + this.title + ", artist=" + this.artist + ", cover=" + this.cover + ")";
    }

    public int hashCode() {
        result = this.uri.hashCode();
        result = result * 31 + ((this.title == null) ? 0 : this.title.hashCode());
        result = result * 31 + ((this.artist == null) ? 0 : this.artist.hashCode());
        return result * 31 + ((this.cover == null) ? 0 : this.cover.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof MusicItem))
            return false;
        MusicItem musicItem = (MusicItem) other;
        return !Intrinsics.areEqual(this.uri, musicItem.uri) ? false : (!Intrinsics.areEqual(this.title, musicItem.title) ? false : (!Intrinsics.areEqual(this.artist, musicItem.artist) ? false : (!!Intrinsics.areEqual(this.cover, musicItem.cover))));
    }
}


