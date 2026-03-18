package com.etouch;

import java.util.Arrays;


public class AudioEnergyStream {
    private final int sampleRate;
    private final BeatDetector beat;
    private final RhythmPerceptionProcessor rhythm;
    private final VocalEmotionProcessor vocal;
    private final WaveformPlayer swingWave;
    private final WaveformPlayer vibrationWave;
    private float[] monoBuffer;
    private float rhythmWeight;
    private float vocalWeight;
    private float beatBoost;
    private float smooth;
    private float smoothed;
    private float agcPeak;
    private final float agcDecay;
    private double timeSeconds;
    private int swingWaveformIndex;
    private int vibrationWaveformIndex;

    public AudioEnergyStream(int sampleRate) {
        this.sampleRate = sampleRate;
        this.beat = new BeatDetector(sampleRate);
        this.rhythm = new RhythmPerceptionProcessor(sampleRate);
        this.vocal = new VocalEmotionProcessor(sampleRate);
        this.swingWave = new WaveformPlayer();
        this.vibrationWave = new WaveformPlayer();
        this.smooth = 0.2F;
        this.agcDecay = 0.9975F;
        this.rhythmWeight = 0.5F;
        this.vocalWeight = 0.5F;
        this.beatBoost = 1.2F;
        this.swingWaveformIndex = Integer.MIN_VALUE;
        this.vibrationWaveformIndex = Integer.MIN_VALUE;
        reset();
    }

    public void reset() {
        this.beat.reset();
        this.rhythm.reset();
        this.vocal.reset();
        this.swingWave.reset();
        this.vibrationWave.reset();
        this.smoothed = 0.0F;
        this.agcPeak = 0.1F;
        this.timeSeconds = 0.0D;
    }

    private static int clamp01To100Int(int v) {
        if (v < 0) return 0;
        if (v > 100) return 100;
        return v;
    }

    private static int clampIntensity(int intensity) {
        if (intensity < 0) return 0;
        if (intensity > 100) return 100;
        return intensity;
    }

    private static WaveformStep[] rampSteps(int count, int from, int to, int durationMs) {
        if (count <= 0) return new WaveformStep[0];
        if (count == 1) return new WaveformStep[]{new WaveformStep(to, durationMs, 0)};

        WaveformStep[] steps = new WaveformStep[count];
        for (int i = 0; i < count; i++) {
            float t = i / (count - 1);
            int value = Math.round(from + (to - from) * t);
            steps[i] = new WaveformStep(value, durationMs, 0);
        }
        return steps;
    }

    private static WaveformStep[] buildSequenceOne() {
        WaveformStep[] ramp = rampSteps(5, 0, 100, 500);
        WaveformStep[] steps = new WaveformStep[1 + ramp.length + 1];
        steps[0] = new WaveformStep(0, 500, 0);
        System.arraycopy(ramp, 0, steps, 1, ramp.length);
        steps[steps.length - 1] = new WaveformStep(100, 500, 0);
        return steps;
    }

    private static WaveformStep[] buildSequenceTwo() {
        WaveformStep[] up = rampSteps(5, 50, 100, 1000);
        WaveformStep[] down = rampSteps(5, 100, 50, 1000);
        WaveformStep[] steps = new WaveformStep[up.length + down.length];
        System.arraycopy(up, 0, steps, 0, up.length);
        System.arraycopy(down, 0, steps, up.length, down.length);
        return steps;
    }

    private static final WaveformStep[] SEQUENCE_ONE = buildSequenceOne();
    private static final WaveformStep[] SEQUENCE_TWO = buildSequenceTwo();
    private static final WaveformStep[] SEQUENCE_THREE = new WaveformStep[]{new WaveformStep(0, 500, 0), new WaveformStep(80, 1500, 0)};


    private static final WaveformStep[] SEQUENCE_FOUR = new WaveformStep[]{new WaveformStep(0, 200, 0), new WaveformStep(80, 200, 0)};


    private static WaveformStep[] getSequenceByIndex(int waveformIndex) {
        switch (waveformIndex) {
            case 0:
                return SEQUENCE_ONE;
            case 1:
                return SEQUENCE_TWO;
            case 2:
                return SEQUENCE_THREE;
            case 3:
                return SEQUENCE_FOUR;
        }
        return null;
    }


    private static WaveformStep[] convertIntArrayToSteps(int[] values, int stepDurationMs) {
        if (values == null || values.length == 0) return null;
        WaveformStep[] steps = new WaveformStep[values.length];
        for (int i = 0; i < values.length; i++) {
            steps[i] = new WaveformStep(values[i], stepDurationMs, 0);
        }
        return steps;
    }

    private void updateWaveforms(int swingWaveformIndex, int vibrationWaveformIndex, int[] swingWaveformArray, int[] vibrationWaveformArray) {
        if (swingWaveformIndex != this.swingWaveformIndex) {
            this.swingWaveformIndex = swingWaveformIndex;
            if (swingWaveformIndex > 3 && swingWaveformArray != null) {
                this.swingWave.setSequence(convertIntArrayToSteps(swingWaveformArray, 200));
            } else {
                this.swingWave.setSequence(getSequenceByIndex(swingWaveformIndex));
            }
        }
        if (vibrationWaveformIndex != this.vibrationWaveformIndex) {
            this.vibrationWaveformIndex = vibrationWaveformIndex;
            if (vibrationWaveformIndex > 3 && vibrationWaveformArray != null) {
                this.vibrationWave.setSequence(convertIntArrayToSteps(vibrationWaveformArray, 200));
            } else {
                this.vibrationWave.setSequence(getSequenceByIndex(vibrationWaveformIndex));
            }
        }
    }


    public AudioEnergyResult process(float[] monoSamples, int swingWaveformIndex, int vibrationWaveformIndex, int swingIntensity, int vibrationIntensity, int[] swingWaveformArray, int[] vibrationWaveformArray) {
        this.timeSeconds += monoSamples.length / this.sampleRate;
        boolean isBeat = this.beat.processChunk(monoSamples, (float) this.timeSeconds);

        float rhythm = this.rhythm.compute(monoSamples);
        float vocal = this.vocal.compute(monoSamples);

        float combined = this.beatBoost * (rhythm * this.rhythmWeight + vocal * this.vocalWeight);
        this.smoothed += this.smooth * (combined - this.smoothed);
        this.agcPeak = Math.max(this.smoothed, this.agcPeak * this.agcDecay);
        float normalized = this.smoothed / Math.max(0.001F, this.agcPeak);
        float energy = Math.min(1.0F, Math.max(0.0F, normalized)) * 100.0F;

        float rhythmVal = Math.min(1.0F, Math.max(0.0F, rhythm / Math.max(0.001F, this.agcPeak))) * 100.0F;
        float vibrationVal = energy;

        updateWaveforms(swingWaveformIndex, vibrationWaveformIndex, swingWaveformArray, vibrationWaveformArray);
        double deltaMs = monoSamples.length * 1000.0D / this.sampleRate;
        this.swingWave.advance(deltaMs);
        this.vibrationWave.advance(deltaMs);

        WaveformStep swingStep = this.swingWave.getCurrentStep();
        WaveformStep vibrationStep = this.vibrationWave.getCurrentStep();

        int baseSwing = Math.round(rhythmVal);
        int baseVibration = Math.round(vibrationVal);

        int waveSwing = (this.swingWave.hasSequence() && swingStep != null) ? swingStep.value : 0;
        int waveVibration = (this.vibrationWave.hasSequence() && vibrationStep != null) ? vibrationStep.value : 0;

        int swingIntensityClamped = clampIntensity(swingIntensity);
        float swingScale = swingIntensityClamped / 100.0F;
        int vibrationIntensityClamped = clampIntensity(vibrationIntensity);
        float vibrationScale = vibrationIntensityClamped / 100.0F;

        int swingOut = (swingWaveformIndex == -1) ? 0 : clamp01To100Int(Math.round((baseSwing + waveSwing) * swingScale));
        if (swingOut > 0 && swingOut < 15) swingOut = 15;

        int vibrationOut = (vibrationWaveformIndex == -1) ? 0 : clamp01To100Int(Math.round((baseVibration + waveVibration) * vibrationScale));
        if (vibrationOut > 0 && vibrationOut < 15) vibrationOut = 15;


        int durationOut = (this.vibrationWave.hasSequence() && vibrationStep != null) ? vibrationStep.durationMs : ((this.swingWave.hasSequence() && swingStep != null) ? swingStep.durationMs : 200);

        int delayOut = (this.vibrationWave.hasSequence() && vibrationStep != null) ? vibrationStep.delayMs : ((this.swingWave.hasSequence() && swingStep != null) ? swingStep.delayMs : 0);

        if (durationOut < 0) durationOut = 0;
        if (durationOut > 65535) durationOut = 65535;
        if (delayOut < 0) delayOut = 0;
        if (delayOut > 255) delayOut = 255;

        AudioEnergyResult result = new AudioEnergyResult();
        result.energy = energy;
        result.isBeat = isBeat;
        result.rhythmEnergy = rhythmVal;
        result.vocalEnergy = Math.min(1.0F, Math.max(0.0F, vocal / Math.max(0.001F, this.agcPeak))) * 100.0F;
        result.smoothedEnergy = Math.min(100.0F, Math.max(0.0F, this.smoothed / Math.max(0.001F, this.agcPeak) * 100.0F));
        result.swingLevel = swingOut;
        result.vibrationLevel = vibrationOut;
        result.duration = durationOut;
        result.delay = delayOut;

        return result;
    }

    public AudioEnergyResult process(float[] monoSamples) {
        return process(monoSamples, -1, -1, 100, 100, null, null);
    }


    public AudioEnergyResult processInterleaved(float[] interleaved, int channels, int swingWaveformIndex, int vibrationWaveformIndex, int swingIntensity, int vibrationIntensity, int[] swingWaveformArray, int[] vibrationWaveformArray) {
        if (interleaved == null || interleaved.length == 0 || channels <= 0) {
            return null;
        }
        int frames = interleaved.length / channels;
        if (this.monoBuffer == null || this.monoBuffer.length < frames) {
            this.monoBuffer = new float[frames];
        }
        int di = 0;
        for (int i = 0; i < frames; i++) {
            float sum = 0.0F;
            for (int c = 0; c < channels; c++) {
                sum += interleaved[di + c];
            }
            this.monoBuffer[i] = sum / channels;
            di += channels;
        }

        float[] monoSlice = Arrays.copyOf(this.monoBuffer, frames);
        return process(monoSlice, swingWaveformIndex, vibrationWaveformIndex, swingIntensity, vibrationIntensity, swingWaveformArray, vibrationWaveformArray);
    }

    public AudioEnergyResult processInterleaved(float[] interleaved, int channels) {
        return processInterleaved(interleaved, channels, -1, -1, 100, 100, null, null);
    }


    public WaveformComputeResult computeWaveformStep(int swingWaveformId, int vibrationWaveformId, int swingIntensity, int vibrationIntensity, int times, int[] swingWaveformArray, int[] vibrationWaveformArray) {
        int rawSwing = getWaveformValue(swingWaveformId, swingWaveformArray, times);
        int rawVibration = getWaveformValue(vibrationWaveformId, vibrationWaveformArray, times);

        int swingIntensityClamped = clampIntensity(swingIntensity);
        float swingScale = swingIntensityClamped / 100.0F;
        int vibrationIntensityClamped = clampIntensity(vibrationIntensity);
        float vibrationScale = vibrationIntensityClamped / 100.0F;

        int swingOut = (swingWaveformId == -1) ? 0 : clamp01To100Int(Math.round(rawSwing * swingScale));
        int vibrationOut = (vibrationWaveformId == -1) ? 0 : clamp01To100Int(Math.round(rawVibration * vibrationScale));

        return new WaveformComputeResult(swingOut, vibrationOut, 50);
    }

    private int getWaveformValue(int id, int[] customArray, int t) {
        if (id == -1) return 0;
        if (id >= 0 && id <= 3) {
            WaveformStep[] steps = getSequenceByIndex(id);
            if (steps == null || steps.length == 0) return 0;
            WaveformStep step = steps[t % steps.length];
            return step.value;
        }
        if (id > 3) {
            if (customArray == null || customArray.length == 0) return 0;
            return customArray[t % customArray.length];
        }
        return 0;
    }
}


