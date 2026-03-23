package com.etouch;


class BandEnergy {
    private final OnePoleFilter hp;
    private final OnePoleFilter lp;

    public BandEnergy(float hpHz, float lpHz, int sampleRate) {
        this.hp = new OnePoleFilter(OnePoleFilter.Type.Highpass, hpHz, sampleRate);
        this.lp = new OnePoleFilter(OnePoleFilter.Type.Lowpass, lpHz, sampleRate);
    }

    public void reset() {
        this.hp.reset();
        this.lp.reset();
    }

    public float computeRms(float[] monoSamples) {
        float sumSq = 0.0F;
        for (float s : monoSamples) {
            float y = this.hp.process(s);
            y = this.lp.process(y);
            sumSq += y * y;
        }
        return (float) Math.sqrt((sumSq / Math.max(1, monoSamples.length)));
    }
}


