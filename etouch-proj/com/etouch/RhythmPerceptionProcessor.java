package com.etouch;


class RhythmPerceptionProcessor {
    private final BandEnergy band;

    public RhythmPerceptionProcessor(int sampleRate) {
        this.band = new BandEnergy(100.0F, 6000.0F, sampleRate);
    }

    public void reset() {
        this.band.reset();
    }

    public float compute(float[] monoSamples) {
        return this.band.computeRms(monoSamples);
    }
}


