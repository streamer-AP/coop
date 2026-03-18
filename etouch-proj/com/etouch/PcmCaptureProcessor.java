package com.etouch;

import com.google.android.exoplayer2.audio.AudioProcessor;

import java.nio.ByteBuffer;


public final class PcmCaptureProcessor implements AudioProcessor {
    public PcmCaptureProcessor(@NotNull Function4<byte[], Integer, Integer, Integer, Unit> onPcmData) {
        this.onPcmData = onPcmData;


        this.inputBuffer = EMPTY_BUFFER;


        this.encoding = 2;
    }

    @NotNull
    public AudioProcessor.AudioFormat configure(@NotNull AudioProcessor.AudioFormat inputAudioFormat) {
        Intrinsics.checkNotNullParameter(inputAudioFormat, "inputAudioFormat");
        this.sampleRate = inputAudioFormat.sampleRate;
        this.channelCount = inputAudioFormat.channelCount;
        this.encoding = inputAudioFormat.encoding;

        if (this.encoding != 2) {
            throw new AudioProcessor.UnhandledAudioFormatException(inputAudioFormat);
        }

        return inputAudioFormat;
    }

    public boolean isActive() {
        return true;
    }

    public void queueInput(@NotNull ByteBuffer inputBuffer) {
        Intrinsics.checkNotNullParameter(inputBuffer, "inputBuffer");
        if (!inputBuffer.hasRemaining())
            return;
        byte[] data = new byte[inputBuffer.remaining()];
        inputBuffer.get(data);


        this.onPcmData.invoke(
                data,
                Integer.valueOf(this.sampleRate),
                Integer.valueOf(this.channelCount),
                Integer.valueOf(this.encoding));


        Intrinsics.checkNotNullExpressionValue(ByteBuffer.wrap(data), "wrap(...)");
        this.inputBuffer = ByteBuffer.wrap(data);
    }

    public void queueEndOfStream() {
        this.inputEnded = true;
    }

    @NotNull
    public ByteBuffer getOutput() {
        ByteBuffer buffer = this.inputBuffer;
        this.inputBuffer = EMPTY_BUFFER;
        return buffer;
    }

    public boolean isEnded() {
        return (this.inputEnded && this.inputBuffer == EMPTY_BUFFER);
    }

    public void flush() {
        this.inputBuffer = EMPTY_BUFFER;
        this.inputEnded = false;
    }

    public void reset() {
        flush();
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\022\n\002\030\002\n\002\020\000\n\002\b\002\n\002\030\002\n\000\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002R\016\020\003\032\0020\004X\004¢\006\002\n\000¨\006\005"}, d2 = {"Lcom/etouch/PcmCaptureProcessor$Companion;", "", "()V", "EMPTY_BUFFER", "Ljava/nio/ByteBuffer;", "sdk_android_unity_bridge_v1_debug"})
    public static final class Companion {
        private Companion() {
        }
    }

    @NotNull
    public static final Companion Companion = new Companion(null);
    @NotNull
    private final Function4<byte[], Integer, Integer, Integer, Unit> onPcmData;
    @NotNull
    private ByteBuffer inputBuffer;
    private boolean inputEnded;
    @NotNull
    private static final ByteBuffer EMPTY_BUFFER = ByteBuffer.allocateDirect(0).order(ByteOrder.nativeOrder());
    private int sampleRate;
    private int channelCount;
    private int encoding;

    static {
        Intrinsics.checkNotNullExpressionValue(ByteBuffer.allocateDirect(0).order(ByteOrder.nativeOrder()), "order(...)");
    }

}


