package com.etouch.activity;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.View;
import com.unity3d.player.UnityPlayer;
import org.jetbrains.annotations.Nullable;


public final class TestActivity extends Activity {
    @Nullable
    public final UnityPlayer getUnityPlayer() {
        return this.unityPlayer;
    }

    public final void setUnityPlayer(@Nullable UnityPlayer<set-?>) {
        this.unityPlayer = < set - ? >;
    }

    @Nullable
    private UnityPlayer unityPlayer;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.unityPlayer = new UnityPlayer((Context) this);
        setContentView((View) this.unityPlayer);
        if (this.unityPlayer != null) {
            this.unityPlayer.requestFocus();
        } else {
        }
    }

    public final void showToast() {
        Toast.makeText((Context) this, "测试一下这个activity行不行", 0).show();
    }

    protected void onResume() {
        super.onResume();

        if (this.unityPlayer != null) {
            this.unityPlayer.resume();
        } else {
        }

    }

    protected void onPause() {
        super.onPause();

        if (this.unityPlayer != null) {
            this.unityPlayer.pause();
        } else {
        }
    }

    protected void onDestroy() {
        super.onDestroy();

        if (this.unityPlayer != null) {
            this.unityPlayer.quit();
        } else {
        }

    }

    public void onConfigurationChanged(@NotNull Configuration newConfig) {
        Intrinsics.checkNotNullParameter(newConfig, "newConfig");
        super.onConfigurationChanged(newConfig);
        if (this.unityPlayer != null) {
            this.unityPlayer.configurationChanged(newConfig);
        } else {
        }
    }

    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (this.unityPlayer != null) {
            this.unityPlayer.windowFocusChanged(hasFocus);
        } else {
        }

    }
}


