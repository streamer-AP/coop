package com.etouch;


public final class MultiFileInfo {
    @Nullable
    private String type;
    @Nullable
    private String url;
    @Nullable
    private String uri;
    @Nullable
    private String author;

    @Nullable
    public final String getType() {
        return this.type;
    }

    public final void setType(@Nullable String<set-?>) {
        this.type = < set - ? >;
    }

    @Nullable
    public final String getUrl() {
        return this.url;
    }

    public final void setUrl(@Nullable String<set-?>) {
        this.url = < set - ? >;
    }

    @Nullable
    public final String getUri() {
        return this.uri;
    }

    public MultiFileInfo(@Nullable String type, @Nullable String url, @Nullable String uri, @Nullable String author) {
        this.type = type;
        this.url = url;
        this.uri = uri;
        this.author = author;
    }

    @Nullable
    public final String getAuthor() {
        return this.author;
    }

    public final void setUri(@Nullable String<set-?>) {
        this.uri = < set - ? >;
    }

    public final void setAuthor(@Nullable String<set-?>) {
        this.author = < set - ? >;
    }


    @Nullable
    public final String component1() {
        return this.type;
    }

    @Nullable
    public final String component2() {
        return this.url;
    }

    @Nullable
    public final String component3() {
        return this.uri;
    }

    @Nullable
    public final String component4() {
        return this.author;
    }

    @NotNull
    public final MultiFileInfo copy(@Nullable String type, @Nullable String url, @Nullable String uri, @Nullable String author) {
        return new MultiFileInfo(type, url, uri, author);
    }

    @NotNull
    public String toString() {
        return "MultiFileInfo(type=" + this.type + ", url=" + this.url + ", uri=" + this.uri + ", author=" + this.author + ")";
    }

    public int hashCode() {
        result = (this.type == null) ? 0 : this.type.hashCode();
        result = result * 31 + ((this.url == null) ? 0 : this.url.hashCode());
        result = result * 31 + ((this.uri == null) ? 0 : this.uri.hashCode());
        return result * 31 + ((this.author == null) ? 0 : this.author.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof MultiFileInfo))
            return false;
        MultiFileInfo multiFileInfo = (MultiFileInfo) other;
        return !Intrinsics.areEqual(this.type, multiFileInfo.type) ? false : (!Intrinsics.areEqual(this.url, multiFileInfo.url) ? false : (!Intrinsics.areEqual(this.uri, multiFileInfo.uri) ? false : (!!Intrinsics.areEqual(this.author, multiFileInfo.author))));
    }

    public MultiFileInfo() {
        this(null, null, null, null, 15, null);
    }
}


