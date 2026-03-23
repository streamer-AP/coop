package com.etouch;

import android.media.MediaCodec;
import android.media.MediaExtractor;
import android.media.MediaFormat;

import java.util.List;

import kotlin.jvm.internal.Intrinsics;



public final class AudioPcmExtractor {
    @NotNull
    public static final AudioPcmExtractor INSTANCE = new AudioPcmExtractor();
    @NotNull
    private static final String TAG = "AudioPcmExtractor";


    public final void extractPcmAndChannel(@NotNull String audioFilePath, @NotNull Function3 onSuccess, @NotNull Function1 onError) {
        // Byte code:
        //   0: aload_1
        //   1: ldc 'audioFilePath'
        //   3: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
        //   6: aload_2
        //   7: ldc 'onSuccess'
        //   9: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
        //   12: aload_3
        //   13: ldc 'onError'
        //   15: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
        //   18: new java/lang/Thread
        //   21: dup
        //   22: aload_1
        //   23: aload_3
        //   24: aload_2
        //   25: <illegal opcode> run : (Ljava/lang/String;Lkotlin/jvm/functions/Function1;Lkotlin/jvm/functions/Function3;)Ljava/lang/Runnable;
        //   30: invokespecial <init> : (Ljava/lang/Runnable;)V
        //   33: invokevirtual start : ()V
        //   36: return
        // Line number table:
        //   Java source line number -> byte code offset
        //   #25	-> 18
        //   #165	-> 22
        //   #25	-> 30
        //   #165	-> 33
        //   #166	-> 36
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   0	37	0	this	Lcom/etouch/AudioPcmExtractor;
        //   0	37	1	audioFilePath	Ljava/lang/String;
        //   0	37	2	onSuccess	Lkotlin/jvm/functions/Function3;
        //   0	37	3	onError	Lkotlin/jvm/functions/Function1;
    }


    private static final void extractPcmAndChannel$lambda$5(String $audioFilePath, Function1 $onError, Function3 $onSuccess) {
        Intrinsics.checkNotNullParameter($audioFilePath, "$audioFilePath");
        Intrinsics.checkNotNullParameter($onError, "$onError");
        Intrinsics.checkNotNullParameter($onSuccess, "$onSuccess");
        File audioFile = new File($audioFilePath);
        if (!audioFile.exists()) {
            $onError.invoke("音频文件不存在：" + $audioFilePath);

            return;
        }
        MediaExtractor extractor = null;
        MediaCodec codec = null;
        List<byte[]> pcmDataList = new ArrayList();
        int channelCount = 0;
        int sampleRate = 0;
        int selectedTrackIndex = 0;
        selectedTrackIndex = -1;

        try {
            String mimeType;
            MediaExtractor mediaExtractor1 = new MediaExtractor(), $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u240 = mediaExtractor1;
            int $i$a$ -apply - AudioPcmExtractor$extractPcmAndChannel$1$1 = 0;
            $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u240.setDataSource(audioFile.getAbsolutePath());

            for (int i = 0, j = $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u240.getTrackCount(); i < j; i++) {
                Intrinsics.checkNotNullExpressionValue($this$extractPcmAndChannel_u24lambda_u245_u24lambda_u240.getTrackFormat(i), "getTrackFormat(...)");
                MediaFormat mediaFormat = $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u240.getTrackFormat(i);
                String str = mediaFormat.getString("mime");
                if ((str != null) ? ((StringsKt.startsWith$default(str, "audio/", false, 2, null) == true)) : false) {
                    $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u240.selectTrack(i);
                    selectedTrackIndex = i;

                    channelCount = mediaFormat.getInteger("channel-count");
                    sampleRate = mediaFormat.getInteger("sample-rate");
                    Log.d(TAG, "选中音频轨道索引：" + i + "，声道数=" + channelCount + "，采样率=" + sampleRate + " Hz");

                    break;
                }
            }

            extractor = mediaExtractor1;
            if (selectedTrackIndex == -1) {
                return;
            }

            if (channelCount == 0 || sampleRate == 0) {
                return;
            }


            Intrinsics.checkNotNullExpressionValue(extractor.getTrackFormat(selectedTrackIndex), "getTrackFormat(...)");
            MediaFormat trackFormat = extractor.getTrackFormat(selectedTrackIndex);
            if (trackFormat.getString("mime") == null) {
                trackFormat.getString("mime");
                AudioPcmExtractor $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u241 = INSTANCE;

                return;
            }

            MediaCodec mediaCodec1 = MediaCodec.createDecoderByType(mimeType), $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u242 = mediaCodec1;
            int $i$a$ -apply - AudioPcmExtractor$extractPcmAndChannel$1$2 = 0;
            $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u242.configure(trackFormat, null, null, 0);
            $this$extractPcmAndChannel_u24lambda_u245_u24lambda_u242.start();

            codec = mediaCodec1;

            MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
            boolean isEOS = false;

            while (!isEOS) {

                Intrinsics.checkNotNull(codec);
                int inputBufferIndex = codec.dequeueInputBuffer(10000L);
                if (inputBufferIndex >= 0) {
                    Object object;
                    if (((Build.VERSION.SDK_INT >= 21) ?
                            codec.getInputBuffer(inputBufferIndex) :


                            codec.getInputBuffers()[inputBufferIndex]) == null) {
                        (Build.VERSION.SDK_INT >= 21) ? codec.getInputBuffer(inputBufferIndex) : codec.getInputBuffers()[inputBufferIndex];
                        continue;
                    }

                    object.clear();
                    int sampleSize = extractor.readSampleData((ByteBuffer) object, 0);
                    if (sampleSize < 0) {

                        codec.queueInputBuffer(inputBufferIndex, 0, 0, 0L, 4);
                        isEOS = true;
                    } else {
                        codec.queueInputBuffer(inputBufferIndex, 0, sampleSize, extractor.getSampleTime(), 0);
                        extractor.advance();
                    }
                }


                int outputBufferIndex = codec.dequeueOutputBuffer(bufferInfo, 10000L);
                switch (outputBufferIndex) {
                    case -2:
                    case -1:
                        continue;
                }


                if (outputBufferIndex >= 0) {
                    Object object;
                    if (((Build.VERSION.SDK_INT >= 21) ?
                            codec.getOutputBuffer(outputBufferIndex) :


                            codec.getOutputBuffers()[outputBufferIndex]) == null) {
                        (Build.VERSION.SDK_INT >= 21) ? codec.getOutputBuffer(outputBufferIndex) : codec.getOutputBuffers()[outputBufferIndex];

                        continue;
                    }

                    byte[] pcmChunk = new byte[bufferInfo.size];
                    object.position(bufferInfo.offset);
                    object.limit(bufferInfo.offset + bufferInfo.size);
                    object.get(pcmChunk);
                    pcmDataList.add(pcmChunk);


                    codec.releaseOutputBuffer(outputBufferIndex, false);


                    if ((bufferInfo.flags & 0x4) != 0) {
                        isEOS = true;
                    }
                }
            }


            List<byte[]> list = pcmDataList;
            int k = 0;
            for (byte b : list) {
                byte[] arrayOfByte = (byte[]) b;


                int m = k, $i$a$ -sumOfInt - AudioPcmExtractor$extractPcmAndChannel$1$totalSize$1 = 0;
                int n = arrayOfByte.length;
                k = m + n;
            }
            int totalSize = k;
            byte[] fullPcmData = new byte[totalSize];
            int offset = 0;
            Iterable<byte[]> $this$forEach$iv = (Iterable<byte[]>) pcmDataList;
            int $i$f$forEach = 0;
            Iterator<byte> iterator = $this$forEach$iv.iterator();
            if (iterator.hasNext()) {
                Object element$iv = iterator.next();
                byte[] chunk = (byte[]) element$iv;
                int $i$a$ -forEach - AudioPcmExtractor$extractPcmAndChannel$1$3 = 0;
                System.arraycopy(chunk, 0, fullPcmData, offset, chunk.length);
                offset += chunk.length;
            }

            $onSuccess.invoke(fullPcmData, Integer.valueOf(channelCount), Integer.valueOf(sampleRate));
        } catch (Exception e) {
            MediaFormat trackFormat;
            if (trackFormat.getMessage() == null)
                trackFormat.getMessage();
            trackFormat.getMessage().invoke("解析失败：" + "未知错误");
            Log.e(TAG, "音频解析异常", (Throwable) trackFormat);
        } finally {
            if (codec != null) {
                codec.stop();
            } else {

            }
            if (codec != null) {
                codec.release();
            } else {

            }
            if (extractor != null) {
                extractor.release();
            } else {

            }
        }
    }
}


