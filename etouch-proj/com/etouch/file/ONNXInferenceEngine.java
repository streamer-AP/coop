package com.etouch.file;

import ai.onnxruntime.OrtSession;

import java.io.File;
import java.io.FileOutputStream;

import kotlin.Unit;
import kotlin.coroutines.Continuation;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class ONNXInferenceEngine {
    @NotNull
    public static final Companion Companion = new Companion(null);
    @NotNull
    private final Context context;
    @Nullable
    private OrtEnvironment ortEnv;
    @Nullable
    private OrtSession ortSession;
    @Nullable
    private int[][][] presetSignals;
    private volatile boolean isCancelled;
    @NotNull
    private static final String TAG = "ONNXInferenceEngine";
    @NotNull
    private static final String MODEL_FILE_NAME = "sed_model.onnx";
    private static final int SAMPLE_RATE = 32000;
    private static final float CLIP_WINDOW_SECONDS = 10.0F;
    private static final int CHUNK_SIZE = 320000;
    private static final int SEGMENT_NUMBERS = 2;
    private static final int SIGNAL_CHOICES = 3;
    private static final int CLASSES_NUM = 7;
    private static final int SIGNAL_PERIOD = 40;
    private static final int SIGNAL_FREQ_HZ = 20;

    public ONNXInferenceEngine(@NotNull Context context) {
        this.context = context;
    }


    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\"\n\002\030\002\n\002\020\000\n\002\b\002\n\002\020\b\n\002\b\002\n\002\020\007\n\000\n\002\020\016\n\002\b\007\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002R\016\020\003\032\0020\004XT¢\006\002\n\000R\016\020\005\032\0020\004XT¢\006\002\n\000R\016\020\006\032\0020\007XT¢\006\002\n\000R\016\020\b\032\0020\tXT¢\006\002\n\000R\016\020\n\032\0020\004XT¢\006\002\n\000R\016\020\013\032\0020\004XT¢\006\002\n\000R\016\020\f\032\0020\004XT¢\006\002\n\000R\016\020\r\032\0020\004XT¢\006\002\n\000R\016\020\016\032\0020\004XT¢\006\002\n\000R\016\020\017\032\0020\tXT¢\006\002\n\000¨\006\020"}, d2 = {"Lcom/etouch/file/ONNXInferenceEngine$Companion;", "", "()V", "CHUNK_SIZE", "", "CLASSES_NUM", "CLIP_WINDOW_SECONDS", "", "MODEL_FILE_NAME", "", "SAMPLE_RATE", "SEGMENT_NUMBERS", "SIGNAL_CHOICES", "SIGNAL_FREQ_HZ", "SIGNAL_PERIOD", "TAG", "sdk_android_unity_bridge_v1_debug"})
    public static final class Companion {
        private Companion() {
        }
    }


    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000(\n\002\030\002\n\002\020\000\n\000\n\002\020\024\n\000\n\002\020\016\n\002\b\t\n\002\020\013\n\002\b\002\n\002\020\b\n\002\b\002\b\b\030\0002\0020\001B\025\022\006\020\002\032\0020\003\022\006\020\004\032\0020\005¢\006\002\020\006J\t\020\013\032\0020\003HÆ\003J\t\020\f\032\0020\005HÆ\003J\035\020\r\032\0020\0002\b\b\002\020\002\032\0020\0032\b\b\002\020\004\032\0020\005HÆ\001J\023\020\016\032\0020\0172\b\020\020\032\004\030\0010\001HÖ\003J\t\020\021\032\0020\022HÖ\001J\t\020\023\032\0020\005HÖ\001R\021\020\002\032\0020\003¢\006\b\n\000\032\004\b\007\020\bR\021\020\004\032\0020\005¢\006\b\n\000\032\004\b\t\020\n¨\006\024"}, d2 = {"Lcom/etouch/file/ONNXInferenceEngine$ParsingResult;", "", "controlSignals", "", "signalFilePath", "", "([FLjava/lang/String;)V", "getControlSignals", "()[F", "getSignalFilePath", "()Ljava/lang/String;", "component1", "component2", "copy", "equals", "", "other", "hashCode", "", "toString", "sdk_android_unity_bridge_v1_debug"})
    public static final class ParsingResult {
        @NotNull
        private final float[] controlSignals;


        @NotNull
        private final String signalFilePath;


        public ParsingResult(@NotNull float[] controlSignals, @NotNull String signalFilePath) {
            this.controlSignals = controlSignals;
            this.signalFilePath = signalFilePath;
        }

        @NotNull
        public final float[] getControlSignals() {
            return this.controlSignals;
        }

        @NotNull
        public final float[] component1() {
            return this.controlSignals;
        }

        @NotNull
        public final String component2() {
            return this.signalFilePath;
        }

        @NotNull
        public final ParsingResult copy(@NotNull float[] controlSignals, @NotNull String signalFilePath) {
            Intrinsics.checkNotNullParameter(controlSignals, "controlSignals");
            Intrinsics.checkNotNullParameter(signalFilePath, "signalFilePath");
            return new ParsingResult(controlSignals, signalFilePath);
        }

        @NotNull
        public final String getSignalFilePath() {
            return this.signalFilePath;
        }

        @NotNull
        public String toString() {
            return "ParsingResult(controlSignals=" + Arrays.toString(this.controlSignals) + ", signalFilePath=" + this.signalFilePath + ")";
        }

        public int hashCode() {
            result = Arrays.hashCode(this.controlSignals);
            return result * 31 + this.signalFilePath.hashCode();
        }

        public boolean equals(@Nullable Object other) {
            if (this == other)
                return true;
            if (!(other instanceof ParsingResult))
                return false;
            ParsingResult parsingResult = (ParsingResult) other;
            return !Intrinsics.areEqual(this.controlSignals, parsingResult.controlSignals) ? false : (!!Intrinsics.areEqual(this.signalFilePath, parsingResult.signalFilePath));
        }
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000&\n\002\030\002\n\002\020\000\n\000\n\002\020\007\n\002\b\f\n\002\020\013\n\002\b\002\n\002\020\b\n\000\n\002\020\016\n\000\b\b\030\0002\0020\001B\035\022\006\020\002\032\0020\003\022\006\020\004\032\0020\003\022\006\020\005\032\0020\003¢\006\002\020\006J\t\020\013\032\0020\003HÆ\003J\t\020\f\032\0020\003HÆ\003J\t\020\r\032\0020\003HÆ\003J'\020\016\032\0020\0002\b\b\002\020\002\032\0020\0032\b\b\002\020\004\032\0020\0032\b\b\002\020\005\032\0020\003HÆ\001J\023\020\017\032\0020\0202\b\020\021\032\004\030\0010\001HÖ\003J\t\020\022\032\0020\023HÖ\001J\t\020\024\032\0020\025HÖ\001R\021\020\005\032\0020\003¢\006\b\n\000\032\004\b\007\020\bR\021\020\002\032\0020\003¢\006\b\n\000\032\004\b\t\020\bR\021\020\004\032\0020\003¢\006\b\n\000\032\004\b\n\020\b¨\006\026"}, d2 = {"Lcom/etouch/file/ONNXInferenceEngine$AudioFeatures;", "", "rms", "", "rmsDb", "freq", "(FFF)V", "getFreq", "()F", "getRms", "getRmsDb", "component1", "component2", "component3", "copy", "equals", "", "other", "hashCode", "", "toString", "", "sdk_android_unity_bridge_v1_debug"})
    private static final class AudioFeatures {
        private final float rms;
        private final float rmsDb;
        private final float freq;

        public AudioFeatures(float rms, float rmsDb, float freq) {
            this.rms = rms;
            this.rmsDb = rmsDb;
            this.freq = freq;
        }

        public final float getRms() {
            return this.rms;
        }

        public final float getRmsDb() {
            return this.rmsDb;
        }

        public final float getFreq() {
            return this.freq;
        }

        public final float component1() {
            return this.rms;
        }

        public final float component2() {
            return this.rmsDb;
        }

        public final float component3() {
            return this.freq;
        }

        @NotNull
        public final AudioFeatures copy(float rms, float rmsDb, float freq) {
            return new AudioFeatures(rms, rmsDb, freq);
        }

        @NotNull
        public String toString() {
            return "AudioFeatures(rms=" + this.rms + ", rmsDb=" + this.rmsDb + ", freq=" + this.freq + ")";
        }

        public int hashCode() {
            result = Float.hashCode(this.rms);
            result = result * 31 + Float.hashCode(this.rmsDb);
            return result * 31 + Float.hashCode(this.freq);
        }

        public boolean equals(@Nullable Object other) {
            if (this == other) return true;
            if (!(other instanceof AudioFeatures)) return false;
            AudioFeatures audioFeatures = (AudioFeatures) other;
            return (Float.compare(this.rms, audioFeatures.rms) != 0) ? false : ((Float.compare(this.rmsDb, audioFeatures.rmsDb) != 0) ? false : (!(Float.compare(this.freq, audioFeatures.freq) != 0)));
        }
    }

    @Nullable
    public final Object initialize(@NotNull Continuation $completion) {
        return BuildersKt.withContext((CoroutineContext) Dispatchers.getIO(), new ONNXInferenceEngine$initialize$2(null), $completion);
    }

    @DebugMetadata(f = "ONNXInferenceEngine.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.file.ONNXInferenceEngine$initialize$2")
    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\013\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
    static final class ONNXInferenceEngine$initialize$2 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Boolean>, Object> {
        int label;

        ONNXInferenceEngine$initialize$2(Continuation $completion) {
            super(2, $completion);
        }

        @Nullable
        public final Object invokeSuspend(@NotNull Object $result) {
            boolean bool;
            IntrinsicsKt.getCOROUTINE_SUSPENDED();
            switch (this.label) {
                case 0:
                    ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);


                    try {
                        File modelFile = new File(ONNXInferenceEngine.this.context.getFilesDir(), "sed_model.onnx");


                        if (!modelFile.exists()) {

                            try {

                                InputStream inputStream = ONNXInferenceEngine.this.context.getAssets().open("sed_model.onnx");
                                Throwable throwable = null;
                                try {
                                    InputStream input = inputStream;
                                    int $i$a$ -use - ONNXInferenceEngine$initialize$2$1 = 0;
                                    FileOutputStream fileOutputStream = new FileOutputStream(modelFile);
                                    Throwable throwable1 = null;
                                    try {
                                        FileOutputStream output = fileOutputStream;
                                        int $i$a$ -use - ONNXInferenceEngine$initialize$2$1$1 = 0;
                                        Intrinsics.checkNotNull(input);
                                        long l1 = ByteStreamsKt.copyTo$default(input, output, 0, 2, null);
                                    } catch (Throwable throwable2) {
                                        throwable1 = throwable2 = null;
                                        throw throwable2;
                                    } finally {
                                        CloseableKt.closeFinally(fileOutputStream, throwable1);
                                    } long l = l1;
                                } catch (Throwable throwable1) {
                                    throwable = throwable1 = null;
                                    throw throwable1;
                                } finally {
                                    CloseableKt.closeFinally(inputStream, throwable);
                                }

                            } catch (Exception exception) {


                                return Boxing.boxBoolean(false);
                            }
                        }


                        ONNXInferenceEngine.this.ortEnv = OrtEnvironment.getEnvironment();


                        OrtSession.SessionOptions sessionOptions = new OrtSession.SessionOptions();


                        ONNXInferenceEngine.this.ortEnv;
                        ONNXInferenceEngine.this.ortSession = (ONNXInferenceEngine.this.ortEnv != null) ? ONNXInferenceEngine.this.ortEnv.createSession(modelFile.getAbsolutePath(), sessionOptions) : null;


                        ONNXInferenceEngine.this.initPresetSignals();


                        bool = true;
                    } catch (Exception exception) {
                        ONNXInferenceEngine.this.ortSession = null;
                        ONNXInferenceEngine.this.ortEnv = null;
                        bool = false;
                    } return Boxing.boxBoolean(bool);
            }

            throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
        }

        @NotNull
        public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super ONNXInferenceEngine$initialize$2> $completion) {
            return (Continuation<Unit>) new ONNXInferenceEngine$initialize$2($completion);
        }

        @Nullable
        public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
            return ((ONNXInferenceEngine$initialize$2) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
        }
    }

    private final void initPresetSignals() {
        int[][][] arrayOfInt;
        ONNXInferenceEngine oNNXInferenceEngine;
        for (byte b = 0; b < 7; ) {
            byte b1 = b;
            int arrayOfInt1[][], arrayOfInt2[][][];
            byte b3;
            for (byte b2 = 0; b2 < 3; ) {
                byte b4 = b2;
                int arrayOfInt3[], arrayOfInt4[][];
                byte b6;
                for (byte b5 = 0; b5 < 40; ) {
                    byte b7 = b5;
                    arrayOfInt3[b7] = Random.Default.nextInt(0, 101);
                    b5++;
                }
                arrayOfInt4[b6] = arrayOfInt3;
                b2++;
            }

            arrayOfInt2[b3] = arrayOfInt1;
            b++;
        }

        oNNXInferenceEngine.presetSignals = arrayOfInt;
    }


    @Nullable
    public final Object parseMediaFile(@NotNull File file, @NotNull Function1<? super Integer, Unit> onProgress, @NotNull Continuation $completion) {
        return BuildersKt.withContext((CoroutineContext) Dispatchers.getIO(), new ONNXInferenceEngine$parseMediaFile$2(onProgress, file, null), $completion);
    }

    @DebugMetadata(f = "ONNXInferenceEngine.kt", l = {}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.file.ONNXInferenceEngine$parseMediaFile$2")
    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\030\002\n\002\030\002\020\000\032\004\030\0010\001*\0020\002H@"}, d2 = {"<anonymous>", "Lcom/etouch/file/ONNXInferenceEngine$ParsingResult;", "Lkotlinx/coroutines/CoroutineScope;"})
    static final class ONNXInferenceEngine$parseMediaFile$2 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super ParsingResult>, Object> {
        int label;

        ONNXInferenceEngine$parseMediaFile$2(Function1<Integer, Unit> $onProgress, File $file, Continuation $completion) {
            super(2, $completion);
        }

        @Nullable
        public final Object invokeSuspend(@NotNull Object $result) {
            MediaExtractor extractor;
            MediaCodec decoder;
            Object object;
            IntrinsicsKt.getCOROUTINE_SUSPENDED();
            switch (this.label) {
                case 0:
                    ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                    extractor = null;
            }

            throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
        }


        @NotNull
        public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super ONNXInferenceEngine$parseMediaFile$2> $completion) {
            return (Continuation<Unit>) new ONNXInferenceEngine$parseMediaFile$2(this.$onProgress, this.$file, $completion);
        }


        @Nullable
        public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
            return ((ONNXInferenceEngine$parseMediaFile$2) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
        }
    }


    private final float[] processChunk(float[] chunk, OrtSession session, OrtEnvironment env) {
        // Byte code:
        //   0: new java/util/ArrayList
        //   3: dup
        //   4: invokespecial <init> : ()V
        //   7: checkcast java/util/List
        //   10: astore #4
        //   12: nop
        //   13: iconst_2
        //   14: newarray long
        //   16: astore #6
        //   18: aload #6
        //   20: iconst_0
        //   21: lconst_1
        //   22: lastore
        //   23: aload #6
        //   25: iconst_1
        //   26: aload_1
        //   27: arraylength
        //   28: i2l
        //   29: lastore
        //   30: aload #6
        //   32: astore #5
        //   34: aload_3
        //   35: aload_1
        //   36: invokestatic wrap : ([F)Ljava/nio/FloatBuffer;
        //   39: aload #5
        //   41: invokestatic createTensor : (Lai/onnxruntime/OrtEnvironment;Ljava/nio/FloatBuffer;[J)Lai/onnxruntime/OnnxTensor;
        //   44: astore #6
        //   46: ldc 'waveform'
        //   48: aload #6
        //   50: invokestatic to : (Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;
        //   53: invokestatic mapOf : (Lkotlin/Pair;)Ljava/util/Map;
        //   56: astore #7
        //   58: aload_2
        //   59: aload #7
        //   61: invokevirtual run : (Ljava/util/Map;)Lai/onnxruntime/OrtSession$Result;
        //   64: astore #8
        //   66: aload #8
        //   68: iconst_0
        //   69: invokevirtual get : (I)Lai/onnxruntime/OnnxValue;
        //   72: invokeinterface getValue : ()Ljava/lang/Object;
        //   77: astore #9
        //   79: iconst_0
        //   80: istore #10
        //   82: aload #9
        //   84: astore #11
        //   86: aload #11
        //   88: instanceof [J
        //   91: ifeq -> 113
        //   94: aload #9
        //   96: checkcast [J
        //   99: iconst_0
        //   100: laload
        //   101: l2i
        //   102: iconst_0
        //   103: bipush #6
        //   105: invokestatic coerceIn : (III)I
        //   108: istore #10
        //   110: goto -> 998
        //   113: aload #11
        //   115: instanceof [I
        //   118: ifeq -> 139
        //   121: aload #9
        //   123: checkcast [I
        //   126: iconst_0
        //   127: iaload
        //   128: iconst_0
        //   129: bipush #6
        //   131: invokestatic coerceIn : (III)I
        //   134: istore #10
        //   136: goto -> 998
        //   139: aload #11
        //   141: instanceof [F
        //   144: ifeq -> 320
        //   147: aload #9
        //   149: invokestatic checkNotNull : (Ljava/lang/Object;)V
        //   152: aload #9
        //   154: checkcast [F
        //   157: invokestatic getIndices : ([F)Lkotlin/ranges/IntRange;
        //   160: checkcast java/lang/Iterable
        //   163: astore #13
        //   165: iconst_0
        //   166: istore #14
        //   168: aload #13
        //   170: invokeinterface iterator : ()Ljava/util/Iterator;
        //   175: astore #15
        //   177: aload #15
        //   179: invokeinterface hasNext : ()Z
        //   184: ifne -> 191
        //   187: aconst_null
        //   188: goto -> 300
        //   191: aload #15
        //   193: invokeinterface next : ()Ljava/lang/Object;
        //   198: astore #16
        //   200: aload #15
        //   202: invokeinterface hasNext : ()Z
        //   207: ifne -> 215
        //   210: aload #16
        //   212: goto -> 300
        //   215: aload #16
        //   217: checkcast java/lang/Number
        //   220: invokevirtual intValue : ()I
        //   223: istore #17
        //   225: iconst_0
        //   226: istore #18
        //   228: aload #9
        //   230: checkcast [F
        //   233: iload #17
        //   235: faload
        //   236: fstore #17
        //   238: aload #15
        //   240: invokeinterface next : ()Ljava/lang/Object;
        //   245: astore #18
        //   247: aload #18
        //   249: checkcast java/lang/Number
        //   252: invokevirtual intValue : ()I
        //   255: istore #19
        //   257: iconst_0
        //   258: istore #20
        //   260: aload #9
        //   262: checkcast [F
        //   265: iload #19
        //   267: faload
        //   268: fstore #19
        //   270: fload #17
        //   272: fload #19
        //   274: invokestatic compare : (FF)I
        //   277: ifge -> 288
        //   280: aload #18
        //   282: astore #16
        //   284: fload #19
        //   286: fstore #17
        //   288: aload #15
        //   290: invokeinterface hasNext : ()Z
        //   295: ifne -> 238
        //   298: aload #16
        //   300: checkcast java/lang/Integer
        //   303: dup
        //   304: ifnull -> 313
        //   307: invokevirtual intValue : ()I
        //   310: goto -> 315
        //   313: pop
        //   314: iconst_0
        //   315: istore #10
        //   317: goto -> 998
        //   320: aload #11
        //   322: instanceof [Ljava/lang/Object;
        //   325: ifeq -> 913
        //   328: aload #9
        //   330: invokestatic checkNotNull : (Ljava/lang/Object;)V
        //   333: aload #9
        //   335: checkcast [Ljava/lang/Object;
        //   338: invokestatic firstOrNull : ([Ljava/lang/Object;)Ljava/lang/Object;
        //   341: astore #12
        //   343: aload #12
        //   345: astore #13
        //   347: aload #13
        //   349: instanceof [F
        //   352: ifeq -> 527
        //   355: aload #9
        //   357: checkcast [[F
        //   360: astore #14
        //   362: aload #14
        //   364: iconst_0
        //   365: aaload
        //   366: astore #15
        //   368: aload #15
        //   370: invokestatic getIndices : ([F)Lkotlin/ranges/IntRange;
        //   373: checkcast java/lang/Iterable
        //   376: astore #17
        //   378: iconst_0
        //   379: istore #18
        //   381: aload #17
        //   383: invokeinterface iterator : ()Ljava/util/Iterator;
        //   388: astore #19
        //   390: aload #19
        //   392: invokeinterface hasNext : ()Z
        //   397: ifne -> 404
        //   400: aconst_null
        //   401: goto -> 507
        //   404: aload #19
        //   406: invokeinterface next : ()Ljava/lang/Object;
        //   411: astore #20
        //   413: aload #19
        //   415: invokeinterface hasNext : ()Z
        //   420: ifne -> 428
        //   423: aload #20
        //   425: goto -> 507
        //   428: aload #20
        //   430: checkcast java/lang/Number
        //   433: invokevirtual intValue : ()I
        //   436: istore #21
        //   438: iconst_0
        //   439: istore #22
        //   441: aload #15
        //   443: iload #21
        //   445: faload
        //   446: fstore #21
        //   448: aload #19
        //   450: invokeinterface next : ()Ljava/lang/Object;
        //   455: astore #22
        //   457: aload #22
        //   459: checkcast java/lang/Number
        //   462: invokevirtual intValue : ()I
        //   465: istore #23
        //   467: iconst_0
        //   468: istore #24
        //   470: aload #15
        //   472: iload #23
        //   474: faload
        //   475: fstore #23
        //   477: fload #21
        //   479: fload #23
        //   481: invokestatic compare : (FF)I
        //   484: ifge -> 495
        //   487: aload #22
        //   489: astore #20
        //   491: fload #23
        //   493: fstore #21
        //   495: aload #19
        //   497: invokeinterface hasNext : ()Z
        //   502: ifne -> 448
        //   505: aload #20
        //   507: checkcast java/lang/Integer
        //   510: dup
        //   511: ifnull -> 520
        //   514: invokevirtual intValue : ()I
        //   517: goto -> 522
        //   520: pop
        //   521: iconst_0
        //   522: istore #10
        //   524: goto -> 998
        //   527: aload #13
        //   529: instanceof [Ljava/lang/Object;
        //   532: ifeq -> 998
        //   535: aload #9
        //   537: checkcast [[[F
        //   540: astore #14
        //   542: bipush #7
        //   544: newarray int
        //   546: astore #15
        //   548: aload #14
        //   550: iconst_0
        //   551: aaload
        //   552: astore #16
        //   554: iconst_0
        //   555: istore #17
        //   557: aload #16
        //   559: checkcast [Ljava/lang/Object;
        //   562: arraylength
        //   563: istore #18
        //   565: iload #17
        //   567: iload #18
        //   569: if_icmpge -> 757
        //   572: aload #16
        //   574: iload #17
        //   576: aaload
        //   577: astore #19
        //   579: aload #19
        //   581: invokestatic getIndices : ([F)Lkotlin/ranges/IntRange;
        //   584: checkcast java/lang/Iterable
        //   587: astore #22
        //   589: iconst_0
        //   590: istore #23
        //   592: aload #22
        //   594: invokeinterface iterator : ()Ljava/util/Iterator;
        //   599: astore #24
        //   601: aload #24
        //   603: invokeinterface hasNext : ()Z
        //   608: ifne -> 615
        //   611: aconst_null
        //   612: goto -> 718
        //   615: aload #24
        //   617: invokeinterface next : ()Ljava/lang/Object;
        //   622: astore #25
        //   624: aload #24
        //   626: invokeinterface hasNext : ()Z
        //   631: ifne -> 639
        //   634: aload #25
        //   636: goto -> 718
        //   639: aload #25
        //   641: checkcast java/lang/Number
        //   644: invokevirtual intValue : ()I
        //   647: istore #26
        //   649: iconst_0
        //   650: istore #27
        //   652: aload #19
        //   654: iload #26
        //   656: faload
        //   657: fstore #26
        //   659: aload #24
        //   661: invokeinterface next : ()Ljava/lang/Object;
        //   666: astore #27
        //   668: aload #27
        //   670: checkcast java/lang/Number
        //   673: invokevirtual intValue : ()I
        //   676: istore #28
        //   678: iconst_0
        //   679: istore #29
        //   681: aload #19
        //   683: iload #28
        //   685: faload
        //   686: fstore #28
        //   688: fload #26
        //   690: fload #28
        //   692: invokestatic compare : (FF)I
        //   695: ifge -> 706
        //   698: aload #27
        //   700: astore #25
        //   702: fload #28
        //   704: fstore #26
        //   706: aload #24
        //   708: invokeinterface hasNext : ()Z
        //   713: ifne -> 659
        //   716: aload #25
        //   718: checkcast java/lang/Integer
        //   721: dup
        //   722: ifnull -> 731
        //   725: invokevirtual intValue : ()I
        //   728: goto -> 733
        //   731: pop
        //   732: iconst_0
        //   733: istore #20
        //   735: aload #15
        //   737: iload #20
        //   739: iaload
        //   740: istore #21
        //   742: aload #15
        //   744: iload #20
        //   746: iload #21
        //   748: iconst_1
        //   749: iadd
        //   750: iastore
        //   751: iinc #17, 1
        //   754: goto -> 565
        //   757: aload #15
        //   759: invokestatic getIndices : ([I)Lkotlin/ranges/IntRange;
        //   762: checkcast java/lang/Iterable
        //   765: astore #17
        //   767: iconst_0
        //   768: istore #18
        //   770: aload #17
        //   772: invokeinterface iterator : ()Ljava/util/Iterator;
        //   777: astore #19
        //   779: aload #19
        //   781: invokeinterface hasNext : ()Z
        //   786: ifne -> 793
        //   789: aconst_null
        //   790: goto -> 893
        //   793: aload #19
        //   795: invokeinterface next : ()Ljava/lang/Object;
        //   800: astore #20
        //   802: aload #19
        //   804: invokeinterface hasNext : ()Z
        //   809: ifne -> 817
        //   812: aload #20
        //   814: goto -> 893
        //   817: aload #20
        //   819: checkcast java/lang/Number
        //   822: invokevirtual intValue : ()I
        //   825: istore #21
        //   827: iconst_0
        //   828: istore #22
        //   830: aload #15
        //   832: iload #21
        //   834: iaload
        //   835: istore #21
        //   837: aload #19
        //   839: invokeinterface next : ()Ljava/lang/Object;
        //   844: astore #22
        //   846: aload #22
        //   848: checkcast java/lang/Number
        //   851: invokevirtual intValue : ()I
        //   854: istore #23
        //   856: iconst_0
        //   857: istore #24
        //   859: aload #15
        //   861: iload #23
        //   863: iaload
        //   864: istore #23
        //   866: iload #21
        //   868: iload #23
        //   870: if_icmpge -> 881
        //   873: aload #22
        //   875: astore #20
        //   877: iload #23
        //   879: istore #21
        //   881: aload #19
        //   883: invokeinterface hasNext : ()Z
        //   888: ifne -> 837
        //   891: aload #20
        //   893: checkcast java/lang/Integer
        //   896: dup
        //   897: ifnull -> 906
        //   900: invokevirtual intValue : ()I
        //   903: goto -> 908
        //   906: pop
        //   907: iconst_0
        //   908: istore #10
        //   910: goto -> 998
        //   913: aload #11
        //   915: instanceof java/lang/Long
        //   918: ifeq -> 941
        //   921: aload #9
        //   923: checkcast java/lang/Number
        //   926: invokevirtual longValue : ()J
        //   929: l2i
        //   930: iconst_0
        //   931: bipush #6
        //   933: invokestatic coerceIn : (III)I
        //   936: istore #10
        //   938: goto -> 998
        //   941: aload #11
        //   943: instanceof java/lang/Integer
        //   946: ifeq -> 973
        //   949: aload #9
        //   951: invokestatic checkNotNull : (Ljava/lang/Object;)V
        //   954: aload #9
        //   956: checkcast java/lang/Number
        //   959: invokevirtual intValue : ()I
        //   962: iconst_0
        //   963: bipush #6
        //   965: invokestatic coerceIn : (III)I
        //   968: istore #10
        //   970: goto -> 998
        //   973: aload #11
        //   975: instanceof java/lang/Float
        //   978: ifeq -> 998
        //   981: aload #9
        //   983: checkcast java/lang/Number
        //   986: invokevirtual floatValue : ()F
        //   989: f2i
        //   990: iconst_0
        //   991: bipush #6
        //   993: invokestatic coerceIn : (III)I
        //   996: istore #10
        //   998: aload #6
        //   1000: invokevirtual close : ()V
        //   1003: aload #8
        //   1005: invokevirtual close : ()V
        //   1008: aload_1
        //   1009: arraylength
        //   1010: i2f
        //   1011: iconst_2
        //   1012: i2f
        //   1013: fdiv
        //   1014: f2d
        //   1015: invokestatic ceil : (D)D
        //   1018: d2f
        //   1019: f2i
        //   1020: istore #11
        //   1022: aload_0
        //   1023: aload_1
        //   1024: iload #11
        //   1026: invokespecial clipAndPadding : ([FI)Ljava/util/List;
        //   1029: astore #12
        //   1031: aload #12
        //   1033: invokeinterface iterator : ()Ljava/util/Iterator;
        //   1038: astore #13
        //   1040: aload #13
        //   1042: invokeinterface hasNext : ()Z
        //   1047: ifeq -> 1214
        //   1050: aload #13
        //   1052: invokeinterface next : ()Ljava/lang/Object;
        //   1057: checkcast [F
        //   1060: astore #14
        //   1062: aload_0
        //   1063: aload #14
        //   1065: sipush #32000
        //   1068: invokespecial analyzeFeatures : ([FI)Lcom/etouch/file/ONNXInferenceEngine$AudioFeatures;
        //   1071: astore #15
        //   1073: aload_0
        //   1074: aload #15
        //   1076: invokevirtual getFreq : ()F
        //   1079: invokespecial freqSelectFun : (F)I
        //   1082: istore #16
        //   1084: aload_0
        //   1085: getfield presetSignals : [[[I
        //   1088: dup
        //   1089: ifnull -> 1106
        //   1092: iload #10
        //   1094: aaload
        //   1095: dup
        //   1096: ifnull -> 1106
        //   1099: iload #16
        //   1101: aaload
        //   1102: dup
        //   1103: ifnonnull -> 1142
        //   1106: pop
        //   1107: iconst_0
        //   1108: istore #21
        //   1110: bipush #40
        //   1112: newarray int
        //   1114: astore #22
        //   1116: iload #21
        //   1118: bipush #40
        //   1120: if_icmpge -> 1140
        //   1123: iload #21
        //   1125: istore #23
        //   1127: aload #22
        //   1129: iload #23
        //   1131: bipush #50
        //   1133: iastore
        //   1134: iinc #21, 1
        //   1137: goto -> 1116
        //   1140: aload #22
        //   1142: astore #17
        //   1144: aload_0
        //   1145: aload #15
        //   1147: invokevirtual getRmsDb : ()F
        //   1150: invokespecial dbSelectFun : (F)I
        //   1153: istore #18
        //   1155: aload_0
        //   1156: aload #17
        //   1158: iload #18
        //   1160: invokespecial levelTransform : ([II)[I
        //   1163: astore #19
        //   1165: aload #14
        //   1167: arraylength
        //   1168: i2f
        //   1169: sipush #32000
        //   1172: i2f
        //   1173: fdiv
        //   1174: fstore #20
        //   1176: fload #20
        //   1178: bipush #20
        //   1180: i2f
        //   1181: fmul
        //   1182: f2i
        //   1183: istore #21
        //   1185: aload_0
        //   1186: aload #19
        //   1188: iload #21
        //   1190: invokespecial expandSignal : ([II)[F
        //   1193: astore #22
        //   1195: aload #4
        //   1197: aload #22
        //   1199: invokestatic toList : ([F)Ljava/util/List;
        //   1202: checkcast java/util/Collection
        //   1205: invokeinterface addAll : (Ljava/util/Collection;)Z
        //   1210: pop
        //   1211: goto -> 1040
        //   1214: aload_1
        //   1215: arraylength
        //   1216: i2f
        //   1217: sipush #32000
        //   1220: i2f
        //   1221: fdiv
        //   1222: fstore #13
        //   1224: fload #13
        //   1226: bipush #20
        //   1228: i2f
        //   1229: fmul
        //   1230: f2i
        //   1231: istore #14
        //   1233: aload #4
        //   1235: invokeinterface size : ()I
        //   1240: iload #14
        //   1242: if_icmple -> 1264
        //   1245: aload #4
        //   1247: checkcast java/lang/Iterable
        //   1250: iload #14
        //   1252: invokestatic take : (Ljava/lang/Iterable;I)Ljava/util/List;
        //   1255: checkcast java/util/Collection
        //   1258: invokestatic toFloatArray : (Ljava/util/Collection;)[F
        //   1261: goto -> 1272
        //   1264: aload #4
        //   1266: checkcast java/util/Collection
        //   1269: invokestatic toFloatArray : (Ljava/util/Collection;)[F
        //   1272: areturn
        //   1273: astore #5
        //   1275: aload_1
        //   1276: arraylength
        //   1277: i2f
        //   1278: sipush #32000
        //   1281: i2f
        //   1282: fdiv
        //   1283: fstore #6
        //   1285: fload #6
        //   1287: bipush #20
        //   1289: i2f
        //   1290: fmul
        //   1291: f2i
        //   1292: istore #7
        //   1294: iconst_0
        //   1295: istore #8
        //   1297: iload #7
        //   1299: newarray float
        //   1301: astore #9
        //   1303: iload #8
        //   1305: iload #7
        //   1307: if_icmpge -> 1328
        //   1310: iload #8
        //   1312: istore #10
        //   1314: aload #9
        //   1316: iload #10
        //   1318: ldc_w 50.0
        //   1321: fastore
        //   1322: iinc #8, 1
        //   1325: goto -> 1303
        //   1328: aload #9
        //   1330: areturn
        // Line number table:
        //   Java source line number -> byte code offset
        //   #358	-> 0
        //   #358	-> 10
        //   #360	-> 12
        //   #362	-> 13
        //   #363	-> 34
        //   #364	-> 46
        //   #365	-> 58
        //   #368	-> 66
        //   #372	-> 79
        //   #375	-> 82
        //   #377	-> 86
        //   #378	-> 94
        //   #382	-> 113
        //   #383	-> 121
        //   #387	-> 139
        //   #389	-> 147
        //   #651	-> 168
        //   #652	-> 177
        //   #653	-> 191
        //   #654	-> 200
        //   #655	-> 215
        //   #389	-> 228
        //   #655	-> 236
        //   #657	-> 238
        //   #658	-> 247
        //   #389	-> 260
        //   #658	-> 268
        //   #659	-> 270
        //   #660	-> 280
        //   #661	-> 284
        //   #663	-> 288
        //   #664	-> 298
        //   #389	-> 300
        //   #393	-> 320
        //   #394	-> 328
        //   #395	-> 343
        //   #397	-> 347
        //   #399	-> 355
        //   #400	-> 362
        //   #401	-> 368
        //   #665	-> 381
        //   #666	-> 390
        //   #667	-> 404
        //   #668	-> 413
        //   #669	-> 428
        //   #401	-> 441
        //   #669	-> 446
        //   #671	-> 448
        //   #672	-> 457
        //   #401	-> 470
        //   #672	-> 475
        //   #673	-> 477
        //   #674	-> 487
        //   #675	-> 491
        //   #677	-> 495
        //   #678	-> 505
        //   #401	-> 507
        //   #405	-> 527
        //   #407	-> 535
        //   #408	-> 542
        //   #409	-> 548
        //   #411	-> 579
        //   #679	-> 592
        //   #680	-> 601
        //   #681	-> 615
        //   #682	-> 624
        //   #683	-> 639
        //   #411	-> 652
        //   #683	-> 657
        //   #685	-> 659
        //   #686	-> 668
        //   #411	-> 681
        //   #686	-> 686
        //   #687	-> 688
        //   #688	-> 698
        //   #689	-> 702
        //   #691	-> 706
        //   #692	-> 716
        //   #411	-> 718
        //   #410	-> 733
        //   #412	-> 735
        //   #409	-> 751
        //   #414	-> 757
        //   #693	-> 770
        //   #694	-> 779
        //   #695	-> 793
        //   #696	-> 802
        //   #697	-> 817
        //   #414	-> 830
        //   #697	-> 835
        //   #699	-> 837
        //   #700	-> 846
        //   #414	-> 859
        //   #700	-> 864
        //   #701	-> 866
        //   #702	-> 873
        //   #703	-> 877
        //   #705	-> 881
        //   #706	-> 891
        //   #414	-> 893
        //   #424	-> 913
        //   #425	-> 921
        //   #429	-> 941
        //   #430	-> 949
        //   #434	-> 973
        //   #435	-> 981
        //   #444	-> 998
        //   #445	-> 1003
        //   #448	-> 1008
        //   #448	-> 1019
        //   #449	-> 1022
        //   #452	-> 1031
        //   #453	-> 1062
        //   #456	-> 1073
        //   #457	-> 1084
        //   #458	-> 1107
        //   #457	-> 1142
        //   #461	-> 1144
        //   #462	-> 1155
        //   #465	-> 1165
        //   #466	-> 1176
        //   #467	-> 1185
        //   #469	-> 1195
        //   #473	-> 1214
        //   #474	-> 1224
        //   #475	-> 1233
        //   #476	-> 1245
        //   #478	-> 1264
        //   #475	-> 1272
        //   #481	-> 1273
        //   #484	-> 1275
        //   #485	-> 1285
        //   #486	-> 1294
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   228	8	18	$i$a$-maxByOrNull-ONNXInferenceEngine$processChunk$1	I
        //   225	11	17	it	I
        //   260	8	20	$i$a$-maxByOrNull-ONNXInferenceEngine$processChunk$1	I
        //   257	11	19	it	I
        //   247	41	18	e$iv	Ljava/lang/Object;
        //   270	18	19	v$iv	F
        //   168	132	14	$i$f$maxByOrNull	I
        //   177	123	15	iterator$iv	Ljava/util/Iterator;
        //   200	100	16	maxElem$iv	Ljava/lang/Object;
        //   238	62	17	maxValue$iv	F
        //   165	135	13	$this$maxByOrNull$iv	Ljava/lang/Iterable;
        //   441	5	22	$i$a$-maxByOrNull-ONNXInferenceEngine$processChunk$2	I
        //   438	8	21	it	I
        //   470	5	24	$i$a$-maxByOrNull-ONNXInferenceEngine$processChunk$2	I
        //   467	8	23	it	I
        //   457	38	22	e$iv	Ljava/lang/Object;
        //   477	18	23	v$iv	F
        //   381	126	18	$i$f$maxByOrNull	I
        //   390	117	19	iterator$iv	Ljava/util/Iterator;
        //   413	94	20	maxElem$iv	Ljava/lang/Object;
        //   448	59	21	maxValue$iv	F
        //   378	129	17	$this$maxByOrNull$iv	Ljava/lang/Iterable;
        //   362	162	14	output2D	[[F
        //   368	156	15	probs	[F
        //   652	5	27	$i$a$-maxByOrNull-ONNXInferenceEngine$processChunk$maxClassIndex$1	I
        //   649	8	26	it	I
        //   681	5	29	$i$a$-maxByOrNull-ONNXInferenceEngine$processChunk$maxClassIndex$1	I
        //   678	8	28	it	I
        //   668	38	27	e$iv	Ljava/lang/Object;
        //   688	18	28	v$iv	F
        //   592	126	23	$i$f$maxByOrNull	I
        //   601	117	24	iterator$iv	Ljava/util/Iterator;
        //   624	94	25	maxElem$iv	Ljava/lang/Object;
        //   659	59	26	maxValue$iv	F
        //   589	129	22	$this$maxByOrNull$iv	Ljava/lang/Iterable;
        //   735	16	20	maxClassIndex	I
        //   579	172	19	timeFrame	[F
        //   830	5	22	$i$a$-maxByOrNull-ONNXInferenceEngine$processChunk$3	I
        //   827	8	21	it	I
        //   859	5	24	$i$a$-maxByOrNull-ONNXInferenceEngine$processChunk$3	I
        //   856	8	23	it	I
        //   846	35	22	e$iv	Ljava/lang/Object;
        //   866	15	23	v$iv	I
        //   770	123	18	$i$f$maxByOrNull	I
        //   779	114	19	iterator$iv	Ljava/util/Iterator;
        //   802	91	20	maxElem$iv	Ljava/lang/Object;
        //   837	56	21	maxValue$iv	I
        //   767	126	17	$this$maxByOrNull$iv	Ljava/lang/Iterable;
        //   542	368	14	output3D	[[[F
        //   548	362	15	classCounts	[I
        //   343	567	12	firstElement	Ljava/lang/Object;
        //   1073	138	15	features	Lcom/etouch/file/ONNXInferenceEngine$AudioFeatures;
        //   1084	127	16	signalChoice	I
        //   1144	67	17	baseSignal	[I
        //   1155	56	18	level	I
        //   1165	46	19	adjustedSignal	[I
        //   1176	35	20	miniDurationSeconds	F
        //   1185	26	21	signalCount	I
        //   1195	16	22	expandedSignal	[F
        //   1062	149	14	miniClip	[F
        //   34	1239	5	inputShape	[J
        //   46	1227	6	inputTensor	Lai/onnxruntime/OnnxTensor;
        //   58	1215	7	inputs	Ljava/util/Map;
        //   66	1207	8	outputs	Lai/onnxruntime/OrtSession$Result;
        //   79	1194	9	outputValue	Ljava/lang/Object;
        //   82	1191	10	dominantClass	I
        //   1022	251	11	miniSamples	I
        //   1031	242	12	miniClips	Ljava/util/List;
        //   1224	49	13	chunkDurationSeconds	F
        //   1233	40	14	expectedSignalCount	I
        //   1285	46	6	chunkDurationSeconds	F
        //   1294	37	7	signalCount	I
        //   1275	56	5	e	Ljava/lang/Exception;
        //   12	1319	4	signals	Ljava/util/List;
        //   0	1331	0	this	Lcom/etouch/file/ONNXInferenceEngine;
        //   0	1331	1	chunk	[F
        //   0	1331	2	session	Lai/onnxruntime/OrtSession;
        //   0	1331	3	env	Lai/onnxruntime/OrtEnvironment;
        // Exception table:
        //   from	to	target	type
        //   12	1273	1273	java/lang/Exception
    }


    private final List<float[]> clipAndPadding(float[] array, int window) {
        int paddedLength = (int) (float) Math.ceil((array.length / window)) * window;

        Intrinsics.checkNotNullExpressionValue(Arrays.copyOf(array, paddedLength), "copyOf(...)");
        float[] paddedArray = (array.length < paddedLength) ? Arrays.copyOf(array, paddedLength) :

                array;


        List<float[]> clips = new ArrayList();
        int j = paddedArray.length + -1;
        if (window <= 0) throw new IllegalArgumentException("Step must be positive, was: " + window + ".");
        int i = 0, k = ProgressionUtilKt.getProgressionLastElement(0, j, window);
        if (i <= k)
            while (true) {
                int end = Math.min(i + window, paddedArray.length);
                clips.add(ArraysKt.sliceArray(paddedArray, RangesKt.until(i, end)));
                if (i != k) {
                    i += window;
                    continue;
                }
                break;
            }
        return clips;
    }

    private final AudioFeatures analyzeFeatures(float[] audioSegment, int sampleRate) {
        float[] arrayOfFloat;
        double d1;
        byte b;
        int i;
        for (arrayOfFloat = audioSegment, d1 = 0.0D, b = 0, i = arrayOfFloat.length; b < i; ) {
            float f1 = arrayOfFloat[b], f2 = f1;


            double d2 = d1;
            int $i$a$ -sumOfDouble - ONNXInferenceEngine$analyzeFeatures$sumSquares$1 = 0;
            double d3 = (f2 * f2);
            d1 = d2 + d3;
            b++;
        } double sumSquares = d1;
        float rms = (float) Math.sqrt(sumSquares / audioSegment.length);
        float rmsDb = 20 * (float) Math.log10(Math.max(rms, 1.0E-10F));
        float freq = dominantFrequency(audioSegment, sampleRate);
        return new AudioFeatures(rms, rmsDb, freq);
    }

    private final float dominantFrequency(float[] segment, int sampleRate) {
        if (segment.length < 2) return 0.0F;
        int zeroCrossings = 0;
        for (int i = 1, j = segment.length; i < j; i++) {
            if ((segment[i - 1] >= 0.0F && segment[i] < 0.0F) || (segment[i - 1] < 0.0F && segment[i] >= 0.0F))
                zeroCrossings++;
        }
        float durationSeconds = segment.length / sampleRate;
        float estimatedFreq = zeroCrossings / 2.0F / durationSeconds;
        return RangesKt.coerceIn(estimatedFreq, 20.0F, 8000.0F);
    }

    private final int freqSelectFun(float freq) {
        float normalized = (freq - 'ú') / 'ˮ';
        normalized = (freq - 'Ϩ') / 'ྠ';
        return (freq <= 250.0F) ? 0 : (((250.0F <= freq) ? ((freq <= 1000.0F)) : false) ? RangesKt.coerceIn(2 - (int) (normalized * 2), 0, 2) : (((1000.0F <= freq) ? ((freq <= 5000.0F)) : false) ? RangesKt.coerceIn((int) (normalized * 2), 0, 2) : 2));
    }

    private final int dbSelectFun(float db) {
        return (db <= -30.0F) ? 1 : (((-30.0F <= db) ? ((db <= -10.0F)) : false) ? 2 : 3);
    }

    private final int[] levelTransform(int[] signal, int level) {
        int $this$map$iv[] = signal, $i$f$map = 0;
        int[] arrayOfInt1 = $this$map$iv;
        Collection destination$iv$iv = new ArrayList($this$map$iv.length);
        int $i$f$mapTo = 0;
        byte b;
        int i;
        for (b = 0, i = arrayOfInt1.length; b < i; ) {
            int item$iv$iv = arrayOfInt1[b];
            int j = item$iv$iv;
            Collection collection = destination$iv$iv;
            int $i$a$ -map - ONNXInferenceEngine$levelTransform$1 = 0;
            switch (level) {
                case 1:
                case 2:
                case 3:
                default:
                    break;
            }
        } return CollectionsKt.toIntArray(destination$iv$iv);
    }


    private final float[] expandSignal(int[] signal, int targetLength) {
        float[] result = new float[targetLength];
        for (int i = 0; i < targetLength; i++)
            result[i] = signal[i % signal.length];
        return result;
    }

    private final String saveControlSignals(float[] signals) {
        String fileName = "control_signal_" + System.currentTimeMillis() + ".dat";
        File file = new File(this.context.getFilesDir(), fileName);
        FileOutputStream fileOutputStream = new FileOutputStream(file);
        Throwable throwable = null;
        try {
            FileOutputStream output = fileOutputStream;
            int $i$a$ -use - ONNXInferenceEngine$saveControlSignals$1 = 0;
            ByteBuffer buffer = ByteBuffer.allocate(signals.length * 4);
            buffer.order(ByteOrder.LITTLE_ENDIAN);
            byte b;
            int i;
            for (b = 0, i = signals.length; b < i; ) {
                float signal = signals[b];
                buffer.putFloat(signal);
                b++;
            }
            output.write(buffer.array());
            Unit unit = Unit.INSTANCE;
        } catch (Throwable throwable1) {
            throwable = throwable1 = null;
            throw throwable1;
        } finally {
            CloseableKt.closeFinally(fileOutputStream, throwable);
        }
        Intrinsics.checkNotNullExpressionValue(file.getAbsolutePath(), "getAbsolutePath(...)");
        return file.getAbsolutePath();
    }

    public final void cancelParsing() {
        this.isCancelled = true;
    }

    public final void release() {
        if (this.ortSession != null) {
            this.ortSession.close();
        } else {

        }
        this.ortSession = null;
        this.ortEnv = null;
        this.presetSignals = null;
    }
}


