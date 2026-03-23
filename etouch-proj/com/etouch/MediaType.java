package com.etouch;

import kotlin.Metadata;
import kotlin.enums.EnumEntries;
import kotlin.enums.EnumEntriesKt;
import org.jetbrains.annotations.NotNull;


public enum MediaType {
    AUDIO,
    VIDEO,
    SUBTITLE,
    IMAGE,
    PDF;

    @NotNull
    public static EnumEntries<MediaType> getEntries() {
        return $ENTRIES;
    }
}


