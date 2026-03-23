package com.etouch;


class WaveformPlayer {
    private WaveformStep[] steps;
    private int stepIndex;
    private double remainingMs;

    public boolean hasSequence() {
        return (this.steps != null && this.steps.length > 0);
    }

    private static double stepTotalMs(WaveformStep step) {
        return (Math.max(0, step.delayMs) + Math.max(0, step.durationMs));
    }

    public void setSequence(WaveformStep[] steps) {
        this.steps = steps;
        this.stepIndex = 0;
        this.remainingMs = hasSequence() ? stepTotalMs(steps[0]) : 0.0D;
        if (hasSequence() && this.remainingMs <= 0.0D) this.remainingMs = 1.0D;
    }

    public void reset() {
        this.steps = null;
        this.stepIndex = 0;
        this.remainingMs = 0.0D;
    }

    public void advance(double deltaMs) {
        if (!hasSequence())
            return;
        if (deltaMs <= 0.0D)
            return;
        this.remainingMs -= deltaMs;
        while (this.remainingMs <= 0.0D && hasSequence()) {
            this.stepIndex++;
            if (this.stepIndex >= this.steps.length) this.stepIndex = 0;
            this.remainingMs += stepTotalMs(this.steps[this.stepIndex]);
            if (this.remainingMs <= 0.0D) this.remainingMs = 1.0D;
        }
    }

    public WaveformStep getCurrentStep() {
        if (!hasSequence()) return null;
        return this.steps[this.stepIndex];
    }
}

