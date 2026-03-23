package com.etouch;


class BeatDetector {
    private final OnePoleFilter low;
    private float mean;
    private float meanSq;
    private float lastBeatTime;
    private final float k;
    private final float muAlpha;
    private final float minInterval;
    private float lastLevel;

    public BeatDetector(int sampleRate) {
        this.low = new OnePoleFilter(OnePoleFilter.Type.Lowpass, 150.0F, sampleRate);
        this.k = 1.5F;
        this.muAlpha = 0.02F;
        this.minInterval = 0.12F;
        this.lastBeatTime = -10.0F;
    }

    public void reset() {
        this.low.reset();
        this.mean = 0.0F;
        this.meanSq = 0.0F;
        this.lastBeatTime = -10.0F;
    }


    public float getLastLevel() {
        return this.lastLevel;
    }

    public boolean processChunk(float[] monoSamples, float timeNow) {
        float sumSq = 0.0F;
        for (float s : monoSamples) {
            float lp = this.low.process(s);
            sumSq += lp * lp;
        }
        float rms = (float) Math.sqrt((sumSq / Math.max(1, monoSamples.length)));
        this.mean = (1.0F - this.muAlpha) * this.mean + this.muAlpha * rms;
        this.meanSq = (1.0F - this.muAlpha) * this.meanSq + this.muAlpha * rms * rms;
        float var = Math.max(0.0F, this.meanSq - this.mean * this.mean);
        float std = (float) Math.sqrt(var);
        float thr = this.mean + this.k * std;
        boolean isBeat = (rms > thr && timeNow - this.lastBeatTime > this.minInterval);
        if (isBeat) this.lastBeatTime = timeNow;
        this.lastLevel = rms;
        return isBeat;
    }
}


