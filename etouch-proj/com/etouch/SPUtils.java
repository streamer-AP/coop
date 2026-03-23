package com.etouch;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.annotation.NonNull;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.SourceDebugExtension;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;




public final class SPUtils {
    @NotNull
    public static final SPUtils INSTANCE = new SPUtils();
    @NotNull
    private static final String DEFAULT_SP_NAME = "DefaultSharedPreferences";

    private final SharedPreferences getSP(@NonNull Context context, String spName) {
        Intrinsics.checkNotNullExpressionValue(context.getApplicationContext().getSharedPreferences(spName, 0), "getSharedPreferences(...)");
        return context.getApplicationContext().getSharedPreferences(spName, 0);
    }


    public final void putBoolean(@NotNull Context context, @NotNull String key, boolean value, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        getSP(context, spName).edit().putBoolean(key, value).apply();
    }


    public final void putInt(@NotNull Context context, @NotNull String key, int value, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        getSP(context, spName).edit().putInt(key, value).apply();
    }


    public final void putLong(@NotNull Context context, @NotNull String key, long value, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        getSP(context, spName).edit().putLong(key, value).apply();
    }


    public final void putFloat(@NotNull Context context, @NotNull String key, float value, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        getSP(context, spName).edit().putFloat(key, value).apply();
    }


    public final void putString(@NotNull Context context, @NotNull String key, @Nullable String value, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        getSP(context, spName).edit().putString(key, value).apply();
    }


    public final void putStringSet(@NotNull Context context, @NotNull String key, @Nullable Set value, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        getSP(context, spName).edit().putStringSet(key, value).apply();
    }


    public final boolean getBoolean(@NotNull Context context, @NotNull String key, boolean defaultValue, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        return getSP(context, spName).getBoolean(key, defaultValue);
    }


    public final int getInt(@NotNull Context context, @NotNull String key, int defaultValue, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        return getSP(context, spName).getInt(key, defaultValue);
    }


    public final long getLong(@NotNull Context context, @NotNull String key, long defaultValue, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        return getSP(context, spName).getLong(key, defaultValue);
    }


    public final float getFloat(@NotNull Context context, @NotNull String key, float defaultValue, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        return getSP(context, spName).getFloat(key, defaultValue);
    }


    @Nullable
    public final String getString(@NotNull Context context, @NotNull String key, @Nullable String defaultValue, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        return getSP(context, spName).getString(key, defaultValue);
    }


    @Nullable
    public final Set<String> getStringSet(@NotNull Context context, @NotNull String key, @Nullable Set defaultValue, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        return getSP(context, spName).getStringSet(key, defaultValue);
    }


    public final void batchPut(@NotNull Context context, @NotNull Map dataMap, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(dataMap, "dataMap");
        Intrinsics.checkNotNullParameter(spName, "spName");
        SharedPreferences.Editor editor = getSP(context, spName).edit();
        for (Map.Entry entry : dataMap.entrySet()) {
            String key = (String) entry.getKey();
            Object value = entry.getValue();
            Object object1 = value;
            if (object1 instanceof Boolean) {
                editor.putBoolean(key, ((Boolean) value).booleanValue());
                continue;
            }
            if (object1 instanceof Integer) {
                editor.putInt(key, ((Number) value).intValue());
                continue;
            }
            if (object1 instanceof Long) {
                editor.putLong(key, ((Number) value).longValue());
                continue;
            }
            if (object1 instanceof Float) {
                editor.putFloat(key, ((Number) value).floatValue());
                continue;
            }
            if (object1 instanceof String) {
                editor.putString(key, (String) value);
                continue;
            }
            if (object1 instanceof Set) {

                Intrinsics.checkNotNull(value, "null cannot be cast to non-null type kotlin.collections.Set<kotlin.String>");
                editor.putStringSet(key, (Set) value);
                continue;
            }
            if (object1 == null) editor.putString(key, null);
        }

        editor.apply();
    }


    public final void remove(@NotNull Context context, @NotNull String key, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        getSP(context, spName).edit().remove(key).apply();
    }


    public final void batchRemove(@NotNull Context context, @NotNull List keys, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(keys, "keys");
        Intrinsics.checkNotNullParameter(spName, "spName");
        SharedPreferences.Editor editor = getSP(context, spName).edit();
        Iterable $this$forEach$iv = keys;
        int $i$f$forEach = 0;


        Iterator iterator = $this$forEach$iv.iterator();
        if (iterator.hasNext()) {
            Object element$iv = iterator.next();
            String key = (String) element$iv;
            int $i$a$ -forEach - SPUtils$batchRemove$1 = 0;
            editor.remove(key);
        }

        editor.apply();
    }

    public final void clear(@NotNull Context context, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(spName, "spName");
        getSP(context, spName).edit().clear().apply();
    }

    public final boolean contains(@NotNull Context context, @NotNull String key, @NotNull String spName) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(spName, "spName");
        return getSP(context, spName).contains(key);
    }
}


