package com.etouch;


class WaveformStep {
    public final int value;
    public final int durationMs;
    public final int delayMs;

    public WaveformStep(int value, int durationMs, int delayMs) {
        this.value = value;
        this.durationMs = durationMs;
        this.delayMs = delayMs;
    }
}


