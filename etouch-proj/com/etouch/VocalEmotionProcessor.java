package com.etouch;


class VocalEmotionProcessor {
    private final BandEnergy band;
    private float env;
    private final float alpha;

    public VocalEmotionProcessor(int sampleRate) {
        this.band = new BandEnergy(200.0F, 5000.0F, sampleRate);
        this.alpha = 0.15F;
    }

    public void reset() {
        this.band.reset();
        this.env = 0.0F;
    }

    public float compute(float[] monoSamples) {
        float rms = this.band.computeRms(monoSamples);
        this.env += this.alpha * (rms - this.env);
        return this.env;
    }
}


