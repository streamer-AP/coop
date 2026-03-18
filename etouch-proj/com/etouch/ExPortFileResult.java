package com.etouch;

import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class ExPortFileResult {
    @Nullable
    private Boolean success;
    @Nullable
    private String errorMsg;

    public ExPortFileResult(@Nullable Boolean success, @Nullable String errorMsg) {
        this.success = success;
        this.errorMsg = errorMsg;
    }

    @Nullable
    public final Boolean getSuccess() {
        return this.success;
    }

    public final void setSuccess(@Nullable Boolean<set-?>) {
        this.success = < set - ? >;
    }

    @Nullable
    public final String getErrorMsg() {
        return this.errorMsg;
    }

    public final void setErrorMsg(@Nullable String<set-?>) {
        this.errorMsg = < set - ? >;
    }


    @Nullable
    public final Boolean component1() {
        return this.success;
    }

    @Nullable
    public final String component2() {
        return this.errorMsg;
    }

    @NotNull
    public final ExPortFileResult copy(@Nullable Boolean success, @Nullable String errorMsg) {
        return new ExPortFileResult(success, errorMsg);
    }

    @NotNull
    public String toString() {
        return "ExPortFileResult(success=" + this.success + ", errorMsg=" + this.errorMsg + ")";
    }

    public int hashCode() {
        result = (this.success == null) ? 0 : this.success.hashCode();
        return result * 31 + ((this.errorMsg == null) ? 0 : this.errorMsg.hashCode());
    }

    public boolean equals(@Nullable Object other) {
        if (this == other)
            return true;
        if (!(other instanceof ExPortFileResult))
            return false;
        ExPortFileResult exPortFileResult = (ExPortFileResult) other;
        return !Intrinsics.areEqual(this.success, exPortFileResult.success) ? false : (!!Intrinsics.areEqual(this.errorMsg, exPortFileResult.errorMsg));
    }

    public ExPortFileResult() {
        this(null, null, 3, null);
    }
}


