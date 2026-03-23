package com.etouch;

import org.jetbrains.annotations.Nullable;


public final class PlayItemInfo {
    @Nullable
    private String url;
    @Nullable
    private String title;
    @Nullable
    private String artist;
    @Nullable
    private String cover;
    @Nullable
    private String duration;
    @Nullable
    private String currentTime;
    @Nullable
    private String index;

    @Nullable
    public final String getUrl() {
        return this.url;
    }

    public final void setUrl(@Nullable String<set-?>) {
        this.url = < set - ? >;
    }

    @Nullable
    public final String getTitle() {
        return this.title;
    }

    public final void setTitle(@Nullable String<set-?>) {
        this.title = < set - ? >;
    }

    @Nullable
    public final String getArtist() {
        return this.artist;
    }

    public final void setArtist(@Nullable String<set-?>) {
        this.artist = < set - ? >;
    }

    @Nullable
    public final String getCover() {
        return this.cover;
    }

    public final void setCover(@Nullable String<set-?>) {
        this.cover = < set - ? >;
    }

    @Nullable
    public final String getDuration() {
        return this.duration;
    }

    public final void setDuration(@Nullable String<set-?>) {
        this.duration = < set - ? >;
    }

    @Nullable
    public final String getCurrentTime() {
        return this.currentTime;
    }

    public final void setCurrentTime(@Nullable String<set-?>) {
        this.currentTime = < set - ? >;
    }

    public PlayItemInfo(@Nullable String url, @Nullable String title, @Nullable String artist, @Nullable String cover, @Nullable String duration, @Nullable String currentTime, @Nullable String index) {
        this.url = url;
        this.title = title;
        this.artist = artist;
        this.cover = cover;
        this.duration = duration;
        this.currentTime = currentTime;
        this.index = index;
    }

    @Nullable
    public final String getIndex() {
        return this.index;
    }

    public final void setIndex(@Nullable String<set-?>) {
        this.index = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.url;
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

    @Nullable
    public final String component5() {
        return this.duration;
    }

    @Nullable
    public final String component6() {
        return this.currentTime;
    }

    @Nullable
    public final String component7() {
        return this.index;
    }

    @NotNull
    public final PlayItemInfo copy(@Nullable String url, @Nullable String title, @Nullable String artist, @Nullable String cover, @Nullable String duration, @Nullable String currentTime, @Nullable String index) {
        return new PlayItemInfo(url, title, artist, cover, duration, currentTime, index);
    }

    @NotNull
    public String toString() {
        return "PlayItemInfo(url=" + this.url + ", title=" + this.title + ", artist=" + this.artist + ", cover=" + this.cover + ", duration=" + this.duration + ", currentTime=" + this.currentTime + ", index=" + this.index + ")";
    }

    public int hashCode() {
        result = (this.url == null) ? 0 : this.url.hashCode();
        result = result * 31 + ((this.title == null) ? 0 : this.title.hashCode());
        result = result * 31 + ((this.artist == null) ? 0 : this.artist.hashCode());
        result = result * 31 + ((this.cover == null) ? 0 : this.cover.hashCode());
        result = result * 31 + ((this.duration == null) ? 0 : this.duration.hashCode());
        result = result * 31 + ((this.currentTime == null) ? 0 : this.currentTime.hashCode());
        return result * 31 + ((this.index == null) ? 0 : this.index.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof PlayItemInfo))
            return false;
        PlayItemInfo playItemInfo = (PlayItemInfo) other;
        return !Intrinsics.areEqual(this.url, playItemInfo.url) ? false : (!Intrinsics.areEqual(this.title, playItemInfo.title) ? false : (!Intrinsics.areEqual(this.artist, playItemInfo.artist) ? false : (!Intrinsics.areEqual(this.cover, playItemInfo.cover) ? false : (!Intrinsics.areEqual(this.duration, playItemInfo.duration) ? false : (!Intrinsics.areEqual(this.currentTime, playItemInfo.currentTime) ? false : (!!Intrinsics.areEqual(this.index, playItemInfo.index)))))));
    }

    public PlayItemInfo() {
        this(null, null, null, null, null, null, null, 127, null);
    }
}


