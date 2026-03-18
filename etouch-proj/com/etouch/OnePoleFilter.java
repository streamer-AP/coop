package com.etouch;


class OnePoleFilter {
    private final Type type;
    private final float alpha;
    private float y;
    private float xPrev;

    public enum Type {
        Lowpass,
        Highpass;
    }


    public OnePoleFilter(Type type, float cutoffHz, int sampleRate) {
        this.type = type;
        float rc = 1.0F / 6.2831855F * Math.max(0.001F, cutoffHz);
        float dt = 1.0F / Math.max(1, sampleRate);
        if (type == Type.Lowpass) {
            this.alpha = dt / (rc + dt);
        } else {
            this.alpha = rc / (rc + dt);
        }
    }

    public void reset() {
        this.y = 0.0F;
        this.xPrev = 0.0F;
    }

    public float process(float x) {
        if (this.type == Type.Lowpass) {
            this.y += this.alpha * (x - this.y);
            return this.y;
        }
        this.y = this.alpha * (this.y + x - this.xPrev);
        this.xPrev = x;
        return this.y;
    }
}


