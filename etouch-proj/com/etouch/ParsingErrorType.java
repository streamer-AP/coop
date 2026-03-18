package com.etouch;

import kotlin.Metadata;
import kotlin.enums.EnumEntries;
import kotlin.enums.EnumEntriesKt;
import org.jetbrains.annotations.NotNull;



public enum ParsingErrorType {
    UnsupportedFileType,
    DurationTooLong,
    FileTooLarge,
    UnknownError;

    @NotNull
    public static EnumEntries<ParsingErrorType> getEntries() {
        return $ENTRIES;
    }
}


