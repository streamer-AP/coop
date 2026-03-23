package com.etouch;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import com.etouch.file.MediaParser;
import com.unity3d.player.UnityPlayer;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import kotlin.Metadata;
import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.CoroutineContext;
import kotlin.coroutines.intrinsics.IntrinsicsKt;
import kotlin.coroutines.jvm.internal.DebugMetadata;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.io.ByteStreamsKt;
import kotlin.io.CloseableKt;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.SourceDebugExtension;
import kotlin.math.MathKt;
import kotlin.ranges.RangesKt;
import kotlin.text.StringsKt;
import kotlinx.coroutines.BuildersKt;
import kotlinx.coroutines.CoroutineScope;
import kotlinx.coroutines.Dispatchers;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class UnityBridgeImpl
        implements IUnityBridge {
    public void bindBT(@NotNull String deviceId) {
        Intrinsics.checkNotNullParameter(deviceId, "deviceId");
    }

    public void doNativeWork(@NotNull String param) {
        Intrinsics.checkNotNullParameter(param, "param");
        String result = "处理参数：" + param + "，时间：" + System.currentTimeMillis();


        if (isUnityContext())
            UnityPlayer.UnitySendMessage("UnityCallbackObj", "OnNativeResult", result);
    }

    private final boolean isUnityContext() {
        boolean bool;

        try {
            bool = (UnityPlayer.currentActivity != null) ? true : false;
        } catch (Exception e) {
            bool = false;
        }
        return bool;
    }

    @NotNull
    public final File copyUriToCache(@NotNull Context context, @NotNull Uri uri) {
        InputStream input;
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(uri, "uri");
        if (context.getContentResolver().openInputStream(uri) == null) {
            context.getContentResolver().openInputStream(uri);
            throw new IOException("Cannot open input stream");
        }

        File file = new File(
                context.getCacheDir(), "media_" +
                System.currentTimeMillis());


        InputStream inputStream1 = input;
        Throwable throwable = null;
        try {
            InputStream inputStream = inputStream1;
            int $i$a$ -use - UnityBridgeImpl$copyUriToCache$1 = 0;
            FileOutputStream fileOutputStream = new FileOutputStream(file);
            Throwable throwable1 = null;
            try {
                FileOutputStream output = fileOutputStream;
                int $i$a$ -use - UnityBridgeImpl$copyUriToCache$1$1 = 0;
                long l1 =
                        ByteStreamsKt.copyTo$default(inputStream, output, 0, 2, null);
            } catch (Throwable throwable2) {
                throwable1 = throwable2 = null;
                throw throwable2;
            } finally {
                CloseableKt.closeFinally(fileOutputStream, throwable1);
            }
            long l = l1;
        } catch (Throwable throwable1) {
            throwable = throwable1 = null;
            throw throwable1;
        } finally {
            CloseableKt.closeFinally(inputStream1, throwable);
        }
        return file;
    }


    @NotNull
    public static final UnityBridgeImpl INSTANCE = new UnityBridgeImpl();
    @NotNull
    private static final String TAG = "UnityBridgeImpl";
    @NotNull
    private static final List<AudioFile> audioFiles = new ArrayList<>();

    @NotNull
    public final List<AudioFile> getAudioFiles() {
        return audioFiles;
    }

    @NotNull
    private static final List<AudioFile> audioMultiFiles = new ArrayList<>();

    @NotNull
    public final List<AudioFile> getAudioMultiFiles() {
        return audioMultiFiles;
    }


    public void importFile(@NotNull CoroutineScope scope, @NotNull List<? extends Uri> uris, @NotNull Function1<? super ParsingErrorType, Unit> onError, @NotNull Function1<? super List<AudioFile>, Unit> onSuccess, @NotNull Context mContext) {
        Intrinsics.checkNotNullParameter(scope, "scope");
        Intrinsics.checkNotNullParameter(uris, "uris");
        Intrinsics.checkNotNullParameter(onError, "onError");
        Intrinsics.checkNotNullParameter(onSuccess, "onSuccess");
        Intrinsics.checkNotNullParameter(mContext, "mContext");
        Context context = mContext;
        MediaParser mediaParser = new MediaParser(context);

        BuildersKt.launch$default(scope, (CoroutineContext) Dispatchers.getIO(), null, new UnityBridgeImpl$importFile$1(uris, mediaParser, context, onError, onSuccess, null), 2, null);
    }


    @DebugMetadata(f = "UnityBridgeImpl.kt", l = {121, 200, 208, 217}, i = {0, 0, 1, 2}, s = {"L$0", "L$2", "L$0", "L$0"}, n = {"newFiles", "uri", "newFiles", "newFiles"}, m = "invokeSuspend", c = "com.etouch.UnityBridgeImpl$importFile$1")
    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
    @SourceDebugExtension({"SMAP\nUnityBridgeImpl.kt\nKotlin\n*S Kotlin\n*F\n+ 1 UnityBridgeImpl.kt\ncom/etouch/UnityBridgeImpl$importFile$1\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,471:1\n1855#2,2:472\n1549#2:474\n1620#2,3:475\n1549#2:478\n1620#2,3:479\n*S KotlinDebug\n*F\n+ 1 UnityBridgeImpl.kt\ncom/etouch/UnityBridgeImpl$importFile$1\n*L\n107#1:472,2\n132#1:474\n132#1:475,3\n133#1:478\n133#1:479,3\n*E\n"})
    static final class UnityBridgeImpl$importFile$1
            extends SuspendLambda
            implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
        Object L$0;


        Object L$1;


        Object L$2;


        int label;


        UnityBridgeImpl$importFile$1(List<Uri> $uris, MediaParser $mediaParser, Context $context, Function1<ParsingErrorType, Unit> $onError, Function1<List<AudioFile>, Unit> $onSuccess, Continuation $completion) {
            super(2, $completion);
        }


        @Nullable
        public final Object invokeSuspend(@NotNull Object $result) {
            // Byte code:
            //   0: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
            //   3: astore #22
            //   5: aload_0
            //   6: getfield label : I
            //   9: tableswitch default -> 1019, 0 -> 44, 1 -> 209, 2 -> 805, 3 -> 890, 4 -> 1009
            //   44: aload_1
            //   45: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   48: new java/util/ArrayList
            //   51: dup
            //   52: invokespecial <init> : ()V
            //   55: checkcast java/util/List
            //   58: astore_2
            //   59: aload_0
            //   60: getfield $uris : Ljava/util/List;
            //   63: checkcast java/lang/Iterable
            //   66: astore_3
            //   67: aload_0
            //   68: getfield $context : Landroid/content/Context;
            //   71: astore #4
            //   73: iconst_0
            //   74: istore #5
            //   76: aload_3
            //   77: invokeinterface iterator : ()Ljava/util/Iterator;
            //   82: astore #6
            //   84: aload #6
            //   86: invokeinterface hasNext : ()Z
            //   91: ifeq -> 134
            //   94: aload #6
            //   96: invokeinterface next : ()Ljava/lang/Object;
            //   101: astore #7
            //   103: aload #7
            //   105: checkcast android/net/Uri
            //   108: astore #8
            //   110: iconst_0
            //   111: istore #9
            //   113: nop
            //   114: aload #4
            //   116: invokevirtual getContentResolver : ()Landroid/content/ContentResolver;
            //   119: aload #8
            //   121: iconst_1
            //   122: invokevirtual takePersistableUriPermission : (Landroid/net/Uri;I)V
            //   125: goto -> 130
            //   128: astore #10
            //   130: nop
            //   131: goto -> 84
            //   134: nop
            //   135: aload_0
            //   136: getfield $uris : Ljava/util/List;
            //   139: invokeinterface iterator : ()Ljava/util/Iterator;
            //   144: astore_3
            //   145: aload_3
            //   146: invokeinterface hasNext : ()Z
            //   151: ifeq -> 915
            //   154: aload_3
            //   155: invokeinterface next : ()Ljava/lang/Object;
            //   160: checkcast android/net/Uri
            //   163: astore #4
            //   165: nop
            //   166: aload_0
            //   167: getfield $mediaParser : Lcom/etouch/file/MediaParser;
            //   170: aload #4
            //   172: aload_0
            //   173: checkcast kotlin/coroutines/Continuation
            //   176: aload_0
            //   177: aload_2
            //   178: putfield L$0 : Ljava/lang/Object;
            //   181: aload_0
            //   182: aload_3
            //   183: putfield L$1 : Ljava/lang/Object;
            //   186: aload_0
            //   187: aload #4
            //   189: putfield L$2 : Ljava/lang/Object;
            //   192: aload_0
            //   193: iconst_1
            //   194: putfield label : I
            //   197: invokevirtual validateMediaFile : (Landroid/net/Uri;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   200: dup
            //   201: aload #22
            //   203: if_acmpne -> 240
            //   206: aload #22
            //   208: areturn
            //   209: aload_0
            //   210: getfield L$2 : Ljava/lang/Object;
            //   213: checkcast android/net/Uri
            //   216: astore #4
            //   218: aload_0
            //   219: getfield L$1 : Ljava/lang/Object;
            //   222: checkcast java/util/Iterator
            //   225: astore_3
            //   226: aload_0
            //   227: getfield L$0 : Ljava/lang/Object;
            //   230: checkcast java/util/List
            //   233: astore_2
            //   234: nop
            //   235: aload_1
            //   236: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   239: aload_1
            //   240: checkcast com/etouch/file/MediaParser$ValidationResult
            //   243: astore #5
            //   245: aload #5
            //   247: instanceof com/etouch/file/MediaParser$ValidationResult$Success
            //   250: ifeq -> 748
            //   253: aload #5
            //   255: checkcast com/etouch/file/MediaParser$ValidationResult$Success
            //   258: invokevirtual getFileName : ()Ljava/lang/String;
            //   261: astore #7
            //   263: aload_0
            //   264: getfield $mediaParser : Lcom/etouch/file/MediaParser;
            //   267: aload #7
            //   269: getstatic com/etouch/UnityBridgeImpl.INSTANCE : Lcom/etouch/UnityBridgeImpl;
            //   272: invokevirtual getAudioFiles : ()Ljava/util/List;
            //   275: checkcast java/lang/Iterable
            //   278: astore #9
            //   280: astore #19
            //   282: astore #18
            //   284: iconst_0
            //   285: istore #10
            //   287: aload #9
            //   289: astore #11
            //   291: new java/util/ArrayList
            //   294: dup
            //   295: aload #9
            //   297: bipush #10
            //   299: invokestatic collectionSizeOrDefault : (Ljava/lang/Iterable;I)I
            //   302: invokespecial <init> : (I)V
            //   305: checkcast java/util/Collection
            //   308: astore #12
            //   310: iconst_0
            //   311: istore #13
            //   313: aload #11
            //   315: invokeinterface iterator : ()Ljava/util/Iterator;
            //   320: astore #14
            //   322: aload #14
            //   324: invokeinterface hasNext : ()Z
            //   329: ifeq -> 372
            //   332: aload #14
            //   334: invokeinterface next : ()Ljava/lang/Object;
            //   339: astore #15
            //   341: aload #12
            //   343: aload #15
            //   345: checkcast com/etouch/AudioFile
            //   348: astore #16
            //   350: astore #20
            //   352: iconst_0
            //   353: istore #17
            //   355: aload #16
            //   357: invokevirtual getName : ()Ljava/lang/String;
            //   360: aload #20
            //   362: swap
            //   363: invokeinterface add : (Ljava/lang/Object;)Z
            //   368: pop
            //   369: goto -> 322
            //   372: aload #12
            //   374: checkcast java/util/List
            //   377: nop
            //   378: astore #20
            //   380: aload #18
            //   382: aload #19
            //   384: aload #20
            //   386: checkcast java/util/Collection
            //   389: aload_2
            //   390: checkcast java/lang/Iterable
            //   393: astore #9
            //   395: astore #20
            //   397: astore #19
            //   399: astore #18
            //   401: iconst_0
            //   402: istore #10
            //   404: aload #9
            //   406: astore #11
            //   408: new java/util/ArrayList
            //   411: dup
            //   412: aload #9
            //   414: bipush #10
            //   416: invokestatic collectionSizeOrDefault : (Ljava/lang/Iterable;I)I
            //   419: invokespecial <init> : (I)V
            //   422: checkcast java/util/Collection
            //   425: astore #12
            //   427: iconst_0
            //   428: istore #13
            //   430: aload #11
            //   432: invokeinterface iterator : ()Ljava/util/Iterator;
            //   437: astore #14
            //   439: aload #14
            //   441: invokeinterface hasNext : ()Z
            //   446: ifeq -> 489
            //   449: aload #14
            //   451: invokeinterface next : ()Ljava/lang/Object;
            //   456: astore #15
            //   458: aload #12
            //   460: aload #15
            //   462: checkcast com/etouch/AudioFile
            //   465: astore #16
            //   467: astore #21
            //   469: iconst_0
            //   470: istore #17
            //   472: aload #16
            //   474: invokevirtual getName : ()Ljava/lang/String;
            //   477: aload #21
            //   479: swap
            //   480: invokeinterface add : (Ljava/lang/Object;)Z
            //   485: pop
            //   486: goto -> 439
            //   489: aload #12
            //   491: checkcast java/util/List
            //   494: nop
            //   495: astore #21
            //   497: aload #18
            //   499: aload #19
            //   501: aload #20
            //   503: aload #21
            //   505: checkcast java/lang/Iterable
            //   508: invokestatic plus : (Ljava/util/Collection;Ljava/lang/Iterable;)Ljava/util/List;
            //   511: invokevirtual generateUniqueItemName : (Ljava/lang/String;Ljava/util/List;)Ljava/lang/String;
            //   514: astore #8
            //   516: aload #5
            //   518: checkcast com/etouch/file/MediaParser$ValidationResult$Success
            //   521: invokevirtual getMediaType : ()Lcom/etouch/MediaType;
            //   524: astore #9
            //   526: new android/media/MediaMetadataRetriever
            //   529: dup
            //   530: invokespecial <init> : ()V
            //   533: astore #10
            //   535: ldc ''
            //   537: astore #11
            //   539: nop
            //   540: nop
            //   541: aload #10
            //   543: aload_0
            //   544: getfield $context : Landroid/content/Context;
            //   547: aload #4
            //   549: invokevirtual setDataSource : (Landroid/content/Context;Landroid/net/Uri;)V
            //   552: aload #10
            //   554: iconst_2
            //   555: invokevirtual extractMetadata : (I)Ljava/lang/String;
            //   558: dup
            //   559: ifnonnull -> 581
            //   562: pop
            //   563: aload #10
            //   565: bipush #13
            //   567: invokevirtual extractMetadata : (I)Ljava/lang/String;
            //   570: dup
            //   571: ifnonnull -> 581
            //   574: pop
            //   575: aload #10
            //   577: iconst_3
            //   578: invokevirtual extractMetadata : (I)Ljava/lang/String;
            //   581: astore #14
            //   583: aload #14
            //   585: checkcast java/lang/CharSequence
            //   588: astore #15
            //   590: aload #15
            //   592: ifnull -> 605
            //   595: aload #15
            //   597: invokeinterface length : ()I
            //   602: ifne -> 609
            //   605: iconst_1
            //   606: goto -> 610
            //   609: iconst_0
            //   610: ifne -> 617
            //   613: aload #14
            //   615: astore #11
            //   617: aload #10
            //   619: bipush #9
            //   621: invokevirtual extractMetadata : (I)Ljava/lang/String;
            //   624: astore #15
            //   626: aload #15
            //   628: dup
            //   629: ifnull -> 645
            //   632: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
            //   635: dup
            //   636: ifnull -> 645
            //   639: invokevirtual longValue : ()J
            //   642: goto -> 647
            //   645: pop
            //   646: lconst_0
            //   647: pop2
            //   648: nop
            //   649: aload #10
            //   651: invokevirtual release : ()V
            //   654: goto -> 659
            //   657: astore #14
            //   659: goto -> 694
            //   662: astore #14
            //   664: nop
            //   665: aload #10
            //   667: invokevirtual release : ()V
            //   670: goto -> 675
            //   673: astore #14
            //   675: goto -> 694
            //   678: astore #14
            //   680: nop
            //   681: aload #10
            //   683: invokevirtual release : ()V
            //   686: goto -> 691
            //   689: astore #15
            //   691: aload #14
            //   693: athrow
            //   694: new com/etouch/AudioFile
            //   697: dup
            //   698: getstatic com/etouch/UnityBridgeImpl.INSTANCE : Lcom/etouch/UnityBridgeImpl;
            //   701: invokevirtual getAudioFiles : ()Ljava/util/List;
            //   704: invokeinterface size : ()I
            //   709: aload_2
            //   710: invokeinterface size : ()I
            //   715: iadd
            //   716: iconst_1
            //   717: iadd
            //   718: aload #8
            //   720: aload #11
            //   722: aload #4
            //   724: lconst_0
            //   725: aload #9
            //   727: aconst_null
            //   728: bipush #16
            //   730: aconst_null
            //   731: invokespecial <init> : (ILjava/lang/String;Ljava/lang/String;Landroid/net/Uri;JLcom/etouch/MediaType;Ljava/lang/String;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
            //   734: astore #14
            //   736: aload_2
            //   737: aload #14
            //   739: invokeinterface add : (Ljava/lang/Object;)Z
            //   744: pop
            //   745: goto -> 145
            //   748: invokestatic getMain : ()Lkotlinx/coroutines/MainCoroutineDispatcher;
            //   751: checkcast kotlin/coroutines/CoroutineContext
            //   754: new com/etouch/UnityBridgeImpl$importFile$1$2
            //   757: dup
            //   758: aload_0
            //   759: getfield $onError : Lkotlin/jvm/functions/Function1;
            //   762: aconst_null
            //   763: invokespecial <init> : (Lkotlin/jvm/functions/Function1;Lkotlin/coroutines/Continuation;)V
            //   766: checkcast kotlin/jvm/functions/Function2
            //   769: aload_0
            //   770: checkcast kotlin/coroutines/Continuation
            //   773: aload_0
            //   774: aload_2
            //   775: putfield L$0 : Ljava/lang/Object;
            //   778: aload_0
            //   779: aload_3
            //   780: putfield L$1 : Ljava/lang/Object;
            //   783: aload_0
            //   784: aconst_null
            //   785: putfield L$2 : Ljava/lang/Object;
            //   788: aload_0
            //   789: iconst_2
            //   790: putfield label : I
            //   793: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   796: dup
            //   797: aload #22
            //   799: if_acmpne -> 827
            //   802: aload #22
            //   804: areturn
            //   805: aload_0
            //   806: getfield L$1 : Ljava/lang/Object;
            //   809: checkcast java/util/Iterator
            //   812: astore_3
            //   813: aload_0
            //   814: getfield L$0 : Ljava/lang/Object;
            //   817: checkcast java/util/List
            //   820: astore_2
            //   821: nop
            //   822: aload_1
            //   823: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   826: aload_1
            //   827: pop
            //   828: goto -> 145
            //   831: astore #5
            //   833: invokestatic getMain : ()Lkotlinx/coroutines/MainCoroutineDispatcher;
            //   836: checkcast kotlin/coroutines/CoroutineContext
            //   839: new com/etouch/UnityBridgeImpl$importFile$1$3
            //   842: dup
            //   843: aload_0
            //   844: getfield $onError : Lkotlin/jvm/functions/Function1;
            //   847: aconst_null
            //   848: invokespecial <init> : (Lkotlin/jvm/functions/Function1;Lkotlin/coroutines/Continuation;)V
            //   851: checkcast kotlin/jvm/functions/Function2
            //   854: aload_0
            //   855: checkcast kotlin/coroutines/Continuation
            //   858: aload_0
            //   859: aload_2
            //   860: putfield L$0 : Ljava/lang/Object;
            //   863: aload_0
            //   864: aload_3
            //   865: putfield L$1 : Ljava/lang/Object;
            //   868: aload_0
            //   869: aconst_null
            //   870: putfield L$2 : Ljava/lang/Object;
            //   873: aload_0
            //   874: iconst_3
            //   875: putfield label : I
            //   878: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   881: dup
            //   882: aload #22
            //   884: if_acmpne -> 911
            //   887: aload #22
            //   889: areturn
            //   890: aload_0
            //   891: getfield L$1 : Ljava/lang/Object;
            //   894: checkcast java/util/Iterator
            //   897: astore_3
            //   898: aload_0
            //   899: getfield L$0 : Ljava/lang/Object;
            //   902: checkcast java/util/List
            //   905: astore_2
            //   906: aload_1
            //   907: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   910: aload_1
            //   911: pop
            //   912: goto -> 145
            //   915: aload_2
            //   916: checkcast java/util/Collection
            //   919: invokeinterface isEmpty : ()Z
            //   924: ifne -> 931
            //   927: iconst_1
            //   928: goto -> 932
            //   931: iconst_0
            //   932: ifeq -> 1015
            //   935: getstatic com/etouch/UnityBridgeImpl.INSTANCE : Lcom/etouch/UnityBridgeImpl;
            //   938: invokevirtual getAudioFiles : ()Ljava/util/List;
            //   941: aload_2
            //   942: checkcast java/util/Collection
            //   945: invokeinterface addAll : (Ljava/util/Collection;)Z
            //   950: pop
            //   951: invokestatic getMain : ()Lkotlinx/coroutines/MainCoroutineDispatcher;
            //   954: checkcast kotlin/coroutines/CoroutineContext
            //   957: new com/etouch/UnityBridgeImpl$importFile$1$4
            //   960: dup
            //   961: aload_0
            //   962: getfield $onSuccess : Lkotlin/jvm/functions/Function1;
            //   965: aload_2
            //   966: aconst_null
            //   967: invokespecial <init> : (Lkotlin/jvm/functions/Function1;Ljava/util/List;Lkotlin/coroutines/Continuation;)V
            //   970: checkcast kotlin/jvm/functions/Function2
            //   973: aload_0
            //   974: checkcast kotlin/coroutines/Continuation
            //   977: aload_0
            //   978: aconst_null
            //   979: putfield L$0 : Ljava/lang/Object;
            //   982: aload_0
            //   983: aconst_null
            //   984: putfield L$1 : Ljava/lang/Object;
            //   987: aload_0
            //   988: aconst_null
            //   989: putfield L$2 : Ljava/lang/Object;
            //   992: aload_0
            //   993: iconst_4
            //   994: putfield label : I
            //   997: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   1000: dup
            //   1001: aload #22
            //   1003: if_acmpne -> 1014
            //   1006: aload #22
            //   1008: areturn
            //   1009: aload_1
            //   1010: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   1013: aload_1
            //   1014: pop
            //   1015: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
            //   1018: areturn
            //   1019: new java/lang/IllegalStateException
            //   1022: dup
            //   1023: ldc_w 'call to 'resume' before 'invoke' with coroutine'
            //   1026: invokespecial <init> : (Ljava/lang/String;)V
            //   1029: athrow
            // Line number table:
            //   Java source line number -> byte code offset
            //   #102	-> 3
            //   #104	-> 48
            //   #104	-> 58
            //   #107	-> 59
            //   #472	-> 76
            //   #108	-> 113
            //   #109	-> 114
            //   #110	-> 119
            //   #111	-> 121
            //   #109	-> 122
            //   #113	-> 128
            //   #116	-> 130
            //   #472	-> 131
            //   #473	-> 134
            //   #118	-> 135
            //   #120	-> 165
            //   #121	-> 166
            //   #102	-> 206
            //   #124	-> 245
            //   #126	-> 247
            //   #128	-> 253
            //   #130	-> 263
            //   #131	-> 267
            //   #132	-> 269
            //   #474	-> 287
            //   #475	-> 313
            //   #476	-> 341
            //   #132	-> 355
            //   #476	-> 363
            //   #477	-> 372
            //   #474	-> 377
            //   #133	-> 389
            //   #478	-> 404
            //   #479	-> 430
            //   #480	-> 458
            //   #133	-> 472
            //   #480	-> 480
            //   #481	-> 489
            //   #478	-> 494
            //   #132	-> 508
            //   #130	-> 511
            //   #136	-> 516
            //   #141	-> 526
            //   #143	-> 535
            //   #144	-> 539
            //   #146	-> 540
            //   #147	-> 541
            //   #151	-> 552
            //   #152	-> 554
            //   #151	-> 555
            //   #154	-> 562
            //   #155	-> 565
            //   #154	-> 567
            //   #151	-> 570
            //   #157	-> 575
            //   #158	-> 577
            //   #157	-> 578
            //   #151	-> 581
            //   #150	-> 581
            //   #161	-> 583
            //   #161	-> 610
            //   #162	-> 613
            //   #167	-> 617
            //   #168	-> 619
            //   #167	-> 621
            //   #166	-> 624
            //   #171	-> 626
            //   #176	-> 648
            //   #177	-> 649
            //   #178	-> 657
            //   #180	-> 659
            //   #173	-> 662
            //   #176	-> 664
            //   #177	-> 665
            //   #178	-> 673
            //   #180	-> 675
            //   #176	-> 678
            //   #177	-> 681
            //   #178	-> 689
            //   #182	-> 694
            //   #183	-> 698
            //   #184	-> 718
            //   #185	-> 720
            //   #186	-> 722
            //   #182	-> 724
            //   #187	-> 725
            //   #188	-> 727
            //   #182	-> 728
            //   #196	-> 736
            //   #200	-> 748
            //   #102	-> 802
            //   #200	-> 827
            //   #206	-> 831
            //   #208	-> 833
            //   #102	-> 887
            //   #208	-> 911
            //   #214	-> 915
            //   #214	-> 932
            //   #215	-> 935
            //   #217	-> 951
            //   #102	-> 1006
            //   #221	-> 1014
            //   #102	-> 1019
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   59	72	2	newFiles	Ljava/util/List;
            //   131	4	2	newFiles	Ljava/util/List;
            //   135	74	2	newFiles	Ljava/util/List;
            //   234	126	2	newFiles	Ljava/util/List;
            //   360	18	2	newFiles	Ljava/util/List;
            //   378	99	2	newFiles	Ljava/util/List;
            //   477	18	2	newFiles	Ljava/util/List;
            //   495	115	2	newFiles	Ljava/util/List;
            //   610	52	2	newFiles	Ljava/util/List;
            //   662	16	2	newFiles	Ljava/util/List;
            //   678	127	2	newFiles	Ljava/util/List;
            //   821	69	2	newFiles	Ljava/util/List;
            //   906	26	2	newFiles	Ljava/util/List;
            //   932	68	2	newFiles	Ljava/util/List;
            //   73	11	3	$this$forEach$iv	Ljava/lang/Iterable;
            //   165	44	4	uri	Landroid/net/Uri;
            //   218	142	4	uri	Landroid/net/Uri;
            //   360	18	4	uri	Landroid/net/Uri;
            //   378	99	4	uri	Landroid/net/Uri;
            //   477	18	4	uri	Landroid/net/Uri;
            //   495	115	4	uri	Landroid/net/Uri;
            //   610	52	4	uri	Landroid/net/Uri;
            //   662	16	4	uri	Landroid/net/Uri;
            //   694	30	4	uri	Landroid/net/Uri;
            //   245	115	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   360	18	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   378	99	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   477	18	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   495	31	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   103	7	7	element$iv	Ljava/lang/Object;
            //   263	6	7	originalFileName	Ljava/lang/String;
            //   110	11	8	uri	Landroid/net/Uri;
            //   516	94	8	uniqueName	Ljava/lang/String;
            //   610	52	8	uniqueName	Ljava/lang/String;
            //   662	16	8	uniqueName	Ljava/lang/String;
            //   694	51	8	uniqueName	Ljava/lang/String;
            //   284	26	9	$this$map$iv	Ljava/lang/Iterable;
            //   401	26	9	$this$map$iv	Ljava/lang/Iterable;
            //   526	84	9	mediaType	Lcom/etouch/MediaType;
            //   610	52	9	mediaType	Lcom/etouch/MediaType;
            //   662	16	9	mediaType	Lcom/etouch/MediaType;
            //   694	51	9	mediaType	Lcom/etouch/MediaType;
            //   535	75	10	retriever	Landroid/media/MediaMetadataRetriever;
            //   610	44	10	retriever	Landroid/media/MediaMetadataRetriever;
            //   662	8	10	retriever	Landroid/media/MediaMetadataRetriever;
            //   678	8	10	retriever	Landroid/media/MediaMetadataRetriever;
            //   310	12	11	$this$mapTo$iv$iv	Ljava/lang/Iterable;
            //   427	12	11	$this$mapTo$iv$iv	Ljava/lang/Iterable;
            //   539	71	11	artistName	Ljava/lang/String;
            //   610	7	11	artistName	Ljava/lang/String;
            //   617	45	11	artistName	Ljava/lang/String;
            //   662	16	11	artistName	Ljava/lang/String;
            //   694	51	11	artistName	Ljava/lang/String;
            //   310	64	12	destination$iv$iv	Ljava/util/Collection;
            //   427	64	12	destination$iv$iv	Ljava/util/Collection;
            //   583	27	14	metaArtist	Ljava/lang/String;
            //   610	7	14	metaArtist	Ljava/lang/String;
            //   736	9	14	audioFile	Lcom/etouch/AudioFile;
            //   341	28	15	item$iv$iv	Ljava/lang/Object;
            //   458	28	15	item$iv$iv	Ljava/lang/Object;
            //   626	9	15	durationStr	Ljava/lang/String;
            //   352	8	16	it	Lcom/etouch/AudioFile;
            //   469	8	16	it	Lcom/etouch/AudioFile;
            //   113	18	9	$i$a$-forEach-UnityBridgeImpl$importFile$1$1	I
            //   76	59	5	$i$f$forEach	I
            //   355	5	17	$i$a$-map-UnityBridgeImpl$importFile$1$uniqueName$1	I
            //   313	61	13	$i$f$mapTo	I
            //   287	91	10	$i$f$map	I
            //   472	5	17	$i$a$-map-UnityBridgeImpl$importFile$1$uniqueName$2	I
            //   430	61	13	$i$f$mapTo	I
            //   404	91	10	$i$f$map	I
            //   48	971	0	this	Lcom/etouch/UnityBridgeImpl$importFile$1;
            //   48	971	1	$result	Ljava/lang/Object;
            // Exception table:
            //   from	to	target	type
            //   113	125	128	java/lang/Exception
            //   165	200	831	java/lang/Exception
            //   234	796	831	java/lang/Exception
            //   540	648	662	java/lang/Exception
            //   540	648	678	finally
            //   648	654	657	java/lang/Exception
            //   662	664	678	finally
            //   664	670	673	java/lang/Exception
            //   678	680	678	finally
            //   680	686	689	java/lang/Exception
            //   821	828	831	java/lang/Exception
        }


        @NotNull
        public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeImpl$importFile$1> $completion) {
            return (Continuation<Unit>) new UnityBridgeImpl$importFile$1(this.$uris, this.$mediaParser, this.$context, this.$onError, this.$onSuccess, $completion);
        }


        @Nullable
        public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
            return ((UnityBridgeImpl$importFile$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
        }
    }


    public void importMultiFile(@NotNull CoroutineScope scope, @NotNull List<? extends Uri> uris, @NotNull Function1<? super ParsingErrorType, Unit> onError, @NotNull Function1<? super List<AudioFile>, Unit> onSuccess, @NotNull Context mContext) {
        Intrinsics.checkNotNullParameter(scope, "scope");
        Intrinsics.checkNotNullParameter(uris, "uris");
        Intrinsics.checkNotNullParameter(onError, "onError");
        Intrinsics.checkNotNullParameter(onSuccess, "onSuccess");
        Intrinsics.checkNotNullParameter(mContext, "mContext");
        Context context = mContext;
        MediaParser mediaParser = new MediaParser(context);

        BuildersKt.launch$default(scope, (CoroutineContext) Dispatchers.getIO(), null, new UnityBridgeImpl$importMultiFile$1(uris, mediaParser, context, onError, onSuccess, null), 2, null);
    }


    @DebugMetadata(f = "UnityBridgeImpl.kt", l = {255, 331, 339, 348}, i = {0, 0, 1, 2}, s = {"L$0", "L$2", "L$0", "L$0"}, n = {"newFiles", "uri", "newFiles", "newFiles"}, m = "invokeSuspend", c = "com.etouch.UnityBridgeImpl$importMultiFile$1")
    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
    @SourceDebugExtension({"SMAP\nUnityBridgeImpl.kt\nKotlin\n*S Kotlin\n*F\n+ 1 UnityBridgeImpl.kt\ncom/etouch/UnityBridgeImpl$importMultiFile$1\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,471:1\n1855#2,2:472\n1549#2:474\n1620#2,3:475\n1549#2:478\n1620#2,3:479\n*S KotlinDebug\n*F\n+ 1 UnityBridgeImpl.kt\ncom/etouch/UnityBridgeImpl$importMultiFile$1\n*L\n241#1:472,2\n266#1:474\n266#1:475,3\n267#1:478\n267#1:479,3\n*E\n"})
    static final class UnityBridgeImpl$importMultiFile$1
            extends SuspendLambda
            implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
        Object L$0;


        Object L$1;


        Object L$2;


        int label;


        UnityBridgeImpl$importMultiFile$1(List<Uri> $uris, MediaParser $mediaParser, Context $context, Function1<ParsingErrorType, Unit> $onError, Function1<List<AudioFile>, Unit> $onSuccess, Continuation $completion) {
            super(2, $completion);
        }


        @Nullable
        public final Object invokeSuspend(@NotNull Object $result) {
            // Byte code:
            //   0: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
            //   3: astore #22
            //   5: aload_0
            //   6: getfield label : I
            //   9: tableswitch default -> 1019, 0 -> 44, 1 -> 209, 2 -> 805, 3 -> 890, 4 -> 1009
            //   44: aload_1
            //   45: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   48: new java/util/ArrayList
            //   51: dup
            //   52: invokespecial <init> : ()V
            //   55: checkcast java/util/List
            //   58: astore_2
            //   59: aload_0
            //   60: getfield $uris : Ljava/util/List;
            //   63: checkcast java/lang/Iterable
            //   66: astore_3
            //   67: aload_0
            //   68: getfield $context : Landroid/content/Context;
            //   71: astore #4
            //   73: iconst_0
            //   74: istore #5
            //   76: aload_3
            //   77: invokeinterface iterator : ()Ljava/util/Iterator;
            //   82: astore #6
            //   84: aload #6
            //   86: invokeinterface hasNext : ()Z
            //   91: ifeq -> 134
            //   94: aload #6
            //   96: invokeinterface next : ()Ljava/lang/Object;
            //   101: astore #7
            //   103: aload #7
            //   105: checkcast android/net/Uri
            //   108: astore #8
            //   110: iconst_0
            //   111: istore #9
            //   113: nop
            //   114: aload #4
            //   116: invokevirtual getContentResolver : ()Landroid/content/ContentResolver;
            //   119: aload #8
            //   121: iconst_1
            //   122: invokevirtual takePersistableUriPermission : (Landroid/net/Uri;I)V
            //   125: goto -> 130
            //   128: astore #10
            //   130: nop
            //   131: goto -> 84
            //   134: nop
            //   135: aload_0
            //   136: getfield $uris : Ljava/util/List;
            //   139: invokeinterface iterator : ()Ljava/util/Iterator;
            //   144: astore_3
            //   145: aload_3
            //   146: invokeinterface hasNext : ()Z
            //   151: ifeq -> 915
            //   154: aload_3
            //   155: invokeinterface next : ()Ljava/lang/Object;
            //   160: checkcast android/net/Uri
            //   163: astore #4
            //   165: nop
            //   166: aload_0
            //   167: getfield $mediaParser : Lcom/etouch/file/MediaParser;
            //   170: aload #4
            //   172: aload_0
            //   173: checkcast kotlin/coroutines/Continuation
            //   176: aload_0
            //   177: aload_2
            //   178: putfield L$0 : Ljava/lang/Object;
            //   181: aload_0
            //   182: aload_3
            //   183: putfield L$1 : Ljava/lang/Object;
            //   186: aload_0
            //   187: aload #4
            //   189: putfield L$2 : Ljava/lang/Object;
            //   192: aload_0
            //   193: iconst_1
            //   194: putfield label : I
            //   197: invokevirtual validateMediaFile : (Landroid/net/Uri;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   200: dup
            //   201: aload #22
            //   203: if_acmpne -> 240
            //   206: aload #22
            //   208: areturn
            //   209: aload_0
            //   210: getfield L$2 : Ljava/lang/Object;
            //   213: checkcast android/net/Uri
            //   216: astore #4
            //   218: aload_0
            //   219: getfield L$1 : Ljava/lang/Object;
            //   222: checkcast java/util/Iterator
            //   225: astore_3
            //   226: aload_0
            //   227: getfield L$0 : Ljava/lang/Object;
            //   230: checkcast java/util/List
            //   233: astore_2
            //   234: nop
            //   235: aload_1
            //   236: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   239: aload_1
            //   240: checkcast com/etouch/file/MediaParser$ValidationResult
            //   243: astore #5
            //   245: aload #5
            //   247: instanceof com/etouch/file/MediaParser$ValidationResult$Success
            //   250: ifeq -> 748
            //   253: aload #5
            //   255: checkcast com/etouch/file/MediaParser$ValidationResult$Success
            //   258: invokevirtual getFileName : ()Ljava/lang/String;
            //   261: astore #7
            //   263: aload_0
            //   264: getfield $mediaParser : Lcom/etouch/file/MediaParser;
            //   267: aload #7
            //   269: getstatic com/etouch/UnityBridgeImpl.INSTANCE : Lcom/etouch/UnityBridgeImpl;
            //   272: invokevirtual getAudioMultiFiles : ()Ljava/util/List;
            //   275: checkcast java/lang/Iterable
            //   278: astore #9
            //   280: astore #19
            //   282: astore #18
            //   284: iconst_0
            //   285: istore #10
            //   287: aload #9
            //   289: astore #11
            //   291: new java/util/ArrayList
            //   294: dup
            //   295: aload #9
            //   297: bipush #10
            //   299: invokestatic collectionSizeOrDefault : (Ljava/lang/Iterable;I)I
            //   302: invokespecial <init> : (I)V
            //   305: checkcast java/util/Collection
            //   308: astore #12
            //   310: iconst_0
            //   311: istore #13
            //   313: aload #11
            //   315: invokeinterface iterator : ()Ljava/util/Iterator;
            //   320: astore #14
            //   322: aload #14
            //   324: invokeinterface hasNext : ()Z
            //   329: ifeq -> 372
            //   332: aload #14
            //   334: invokeinterface next : ()Ljava/lang/Object;
            //   339: astore #15
            //   341: aload #12
            //   343: aload #15
            //   345: checkcast com/etouch/AudioFile
            //   348: astore #16
            //   350: astore #20
            //   352: iconst_0
            //   353: istore #17
            //   355: aload #16
            //   357: invokevirtual getName : ()Ljava/lang/String;
            //   360: aload #20
            //   362: swap
            //   363: invokeinterface add : (Ljava/lang/Object;)Z
            //   368: pop
            //   369: goto -> 322
            //   372: aload #12
            //   374: checkcast java/util/List
            //   377: nop
            //   378: astore #20
            //   380: aload #18
            //   382: aload #19
            //   384: aload #20
            //   386: checkcast java/util/Collection
            //   389: aload_2
            //   390: checkcast java/lang/Iterable
            //   393: astore #9
            //   395: astore #20
            //   397: astore #19
            //   399: astore #18
            //   401: iconst_0
            //   402: istore #10
            //   404: aload #9
            //   406: astore #11
            //   408: new java/util/ArrayList
            //   411: dup
            //   412: aload #9
            //   414: bipush #10
            //   416: invokestatic collectionSizeOrDefault : (Ljava/lang/Iterable;I)I
            //   419: invokespecial <init> : (I)V
            //   422: checkcast java/util/Collection
            //   425: astore #12
            //   427: iconst_0
            //   428: istore #13
            //   430: aload #11
            //   432: invokeinterface iterator : ()Ljava/util/Iterator;
            //   437: astore #14
            //   439: aload #14
            //   441: invokeinterface hasNext : ()Z
            //   446: ifeq -> 489
            //   449: aload #14
            //   451: invokeinterface next : ()Ljava/lang/Object;
            //   456: astore #15
            //   458: aload #12
            //   460: aload #15
            //   462: checkcast com/etouch/AudioFile
            //   465: astore #16
            //   467: astore #21
            //   469: iconst_0
            //   470: istore #17
            //   472: aload #16
            //   474: invokevirtual getName : ()Ljava/lang/String;
            //   477: aload #21
            //   479: swap
            //   480: invokeinterface add : (Ljava/lang/Object;)Z
            //   485: pop
            //   486: goto -> 439
            //   489: aload #12
            //   491: checkcast java/util/List
            //   494: nop
            //   495: astore #21
            //   497: aload #18
            //   499: aload #19
            //   501: aload #20
            //   503: aload #21
            //   505: checkcast java/lang/Iterable
            //   508: invokestatic plus : (Ljava/util/Collection;Ljava/lang/Iterable;)Ljava/util/List;
            //   511: invokevirtual generateUniqueItemName : (Ljava/lang/String;Ljava/util/List;)Ljava/lang/String;
            //   514: astore #8
            //   516: aload #5
            //   518: checkcast com/etouch/file/MediaParser$ValidationResult$Success
            //   521: invokevirtual getMediaType : ()Lcom/etouch/MediaType;
            //   524: astore #9
            //   526: new android/media/MediaMetadataRetriever
            //   529: dup
            //   530: invokespecial <init> : ()V
            //   533: astore #10
            //   535: ldc ''
            //   537: astore #11
            //   539: nop
            //   540: nop
            //   541: aload #10
            //   543: aload_0
            //   544: getfield $context : Landroid/content/Context;
            //   547: aload #4
            //   549: invokevirtual setDataSource : (Landroid/content/Context;Landroid/net/Uri;)V
            //   552: aload #10
            //   554: iconst_2
            //   555: invokevirtual extractMetadata : (I)Ljava/lang/String;
            //   558: dup
            //   559: ifnonnull -> 581
            //   562: pop
            //   563: aload #10
            //   565: bipush #13
            //   567: invokevirtual extractMetadata : (I)Ljava/lang/String;
            //   570: dup
            //   571: ifnonnull -> 581
            //   574: pop
            //   575: aload #10
            //   577: iconst_3
            //   578: invokevirtual extractMetadata : (I)Ljava/lang/String;
            //   581: astore #14
            //   583: aload #14
            //   585: checkcast java/lang/CharSequence
            //   588: astore #15
            //   590: aload #15
            //   592: ifnull -> 605
            //   595: aload #15
            //   597: invokeinterface length : ()I
            //   602: ifne -> 609
            //   605: iconst_1
            //   606: goto -> 610
            //   609: iconst_0
            //   610: ifne -> 617
            //   613: aload #14
            //   615: astore #11
            //   617: aload #10
            //   619: bipush #9
            //   621: invokevirtual extractMetadata : (I)Ljava/lang/String;
            //   624: astore #15
            //   626: aload #15
            //   628: dup
            //   629: ifnull -> 645
            //   632: invokestatic toLongOrNull : (Ljava/lang/String;)Ljava/lang/Long;
            //   635: dup
            //   636: ifnull -> 645
            //   639: invokevirtual longValue : ()J
            //   642: goto -> 647
            //   645: pop
            //   646: lconst_0
            //   647: pop2
            //   648: nop
            //   649: aload #10
            //   651: invokevirtual release : ()V
            //   654: goto -> 659
            //   657: astore #14
            //   659: goto -> 694
            //   662: astore #14
            //   664: nop
            //   665: aload #10
            //   667: invokevirtual release : ()V
            //   670: goto -> 675
            //   673: astore #14
            //   675: goto -> 694
            //   678: astore #14
            //   680: nop
            //   681: aload #10
            //   683: invokevirtual release : ()V
            //   686: goto -> 691
            //   689: astore #15
            //   691: aload #14
            //   693: athrow
            //   694: new com/etouch/AudioFile
            //   697: dup
            //   698: getstatic com/etouch/UnityBridgeImpl.INSTANCE : Lcom/etouch/UnityBridgeImpl;
            //   701: invokevirtual getAudioMultiFiles : ()Ljava/util/List;
            //   704: invokeinterface size : ()I
            //   709: aload_2
            //   710: invokeinterface size : ()I
            //   715: iadd
            //   716: iconst_1
            //   717: iadd
            //   718: aload #8
            //   720: aload #11
            //   722: aload #4
            //   724: lconst_0
            //   725: aload #9
            //   727: aconst_null
            //   728: bipush #16
            //   730: aconst_null
            //   731: invokespecial <init> : (ILjava/lang/String;Ljava/lang/String;Landroid/net/Uri;JLcom/etouch/MediaType;Ljava/lang/String;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
            //   734: astore #14
            //   736: aload_2
            //   737: aload #14
            //   739: invokeinterface add : (Ljava/lang/Object;)Z
            //   744: pop
            //   745: goto -> 145
            //   748: invokestatic getMain : ()Lkotlinx/coroutines/MainCoroutineDispatcher;
            //   751: checkcast kotlin/coroutines/CoroutineContext
            //   754: new com/etouch/UnityBridgeImpl$importMultiFile$1$2
            //   757: dup
            //   758: aload_0
            //   759: getfield $onError : Lkotlin/jvm/functions/Function1;
            //   762: aconst_null
            //   763: invokespecial <init> : (Lkotlin/jvm/functions/Function1;Lkotlin/coroutines/Continuation;)V
            //   766: checkcast kotlin/jvm/functions/Function2
            //   769: aload_0
            //   770: checkcast kotlin/coroutines/Continuation
            //   773: aload_0
            //   774: aload_2
            //   775: putfield L$0 : Ljava/lang/Object;
            //   778: aload_0
            //   779: aload_3
            //   780: putfield L$1 : Ljava/lang/Object;
            //   783: aload_0
            //   784: aconst_null
            //   785: putfield L$2 : Ljava/lang/Object;
            //   788: aload_0
            //   789: iconst_2
            //   790: putfield label : I
            //   793: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   796: dup
            //   797: aload #22
            //   799: if_acmpne -> 827
            //   802: aload #22
            //   804: areturn
            //   805: aload_0
            //   806: getfield L$1 : Ljava/lang/Object;
            //   809: checkcast java/util/Iterator
            //   812: astore_3
            //   813: aload_0
            //   814: getfield L$0 : Ljava/lang/Object;
            //   817: checkcast java/util/List
            //   820: astore_2
            //   821: nop
            //   822: aload_1
            //   823: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   826: aload_1
            //   827: pop
            //   828: goto -> 145
            //   831: astore #5
            //   833: invokestatic getMain : ()Lkotlinx/coroutines/MainCoroutineDispatcher;
            //   836: checkcast kotlin/coroutines/CoroutineContext
            //   839: new com/etouch/UnityBridgeImpl$importMultiFile$1$3
            //   842: dup
            //   843: aload_0
            //   844: getfield $onError : Lkotlin/jvm/functions/Function1;
            //   847: aconst_null
            //   848: invokespecial <init> : (Lkotlin/jvm/functions/Function1;Lkotlin/coroutines/Continuation;)V
            //   851: checkcast kotlin/jvm/functions/Function2
            //   854: aload_0
            //   855: checkcast kotlin/coroutines/Continuation
            //   858: aload_0
            //   859: aload_2
            //   860: putfield L$0 : Ljava/lang/Object;
            //   863: aload_0
            //   864: aload_3
            //   865: putfield L$1 : Ljava/lang/Object;
            //   868: aload_0
            //   869: aconst_null
            //   870: putfield L$2 : Ljava/lang/Object;
            //   873: aload_0
            //   874: iconst_3
            //   875: putfield label : I
            //   878: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   881: dup
            //   882: aload #22
            //   884: if_acmpne -> 911
            //   887: aload #22
            //   889: areturn
            //   890: aload_0
            //   891: getfield L$1 : Ljava/lang/Object;
            //   894: checkcast java/util/Iterator
            //   897: astore_3
            //   898: aload_0
            //   899: getfield L$0 : Ljava/lang/Object;
            //   902: checkcast java/util/List
            //   905: astore_2
            //   906: aload_1
            //   907: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   910: aload_1
            //   911: pop
            //   912: goto -> 145
            //   915: aload_2
            //   916: checkcast java/util/Collection
            //   919: invokeinterface isEmpty : ()Z
            //   924: ifne -> 931
            //   927: iconst_1
            //   928: goto -> 932
            //   931: iconst_0
            //   932: ifeq -> 1015
            //   935: getstatic com/etouch/UnityBridgeImpl.INSTANCE : Lcom/etouch/UnityBridgeImpl;
            //   938: invokevirtual getAudioMultiFiles : ()Ljava/util/List;
            //   941: aload_2
            //   942: checkcast java/util/Collection
            //   945: invokeinterface addAll : (Ljava/util/Collection;)Z
            //   950: pop
            //   951: invokestatic getMain : ()Lkotlinx/coroutines/MainCoroutineDispatcher;
            //   954: checkcast kotlin/coroutines/CoroutineContext
            //   957: new com/etouch/UnityBridgeImpl$importMultiFile$1$4
            //   960: dup
            //   961: aload_0
            //   962: getfield $onSuccess : Lkotlin/jvm/functions/Function1;
            //   965: aload_2
            //   966: aconst_null
            //   967: invokespecial <init> : (Lkotlin/jvm/functions/Function1;Ljava/util/List;Lkotlin/coroutines/Continuation;)V
            //   970: checkcast kotlin/jvm/functions/Function2
            //   973: aload_0
            //   974: checkcast kotlin/coroutines/Continuation
            //   977: aload_0
            //   978: aconst_null
            //   979: putfield L$0 : Ljava/lang/Object;
            //   982: aload_0
            //   983: aconst_null
            //   984: putfield L$1 : Ljava/lang/Object;
            //   987: aload_0
            //   988: aconst_null
            //   989: putfield L$2 : Ljava/lang/Object;
            //   992: aload_0
            //   993: iconst_4
            //   994: putfield label : I
            //   997: invokestatic withContext : (Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   1000: dup
            //   1001: aload #22
            //   1003: if_acmpne -> 1014
            //   1006: aload #22
            //   1008: areturn
            //   1009: aload_1
            //   1010: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   1013: aload_1
            //   1014: pop
            //   1015: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
            //   1018: areturn
            //   1019: new java/lang/IllegalStateException
            //   1022: dup
            //   1023: ldc_w 'call to 'resume' before 'invoke' with coroutine'
            //   1026: invokespecial <init> : (Ljava/lang/String;)V
            //   1029: athrow
            // Line number table:
            //   Java source line number -> byte code offset
            //   #236	-> 3
            //   #238	-> 48
            //   #238	-> 58
            //   #241	-> 59
            //   #472	-> 76
            //   #242	-> 113
            //   #243	-> 114
            //   #244	-> 119
            //   #245	-> 121
            //   #243	-> 122
            //   #247	-> 128
            //   #250	-> 130
            //   #472	-> 131
            //   #473	-> 134
            //   #252	-> 135
            //   #254	-> 165
            //   #255	-> 166
            //   #236	-> 206
            //   #258	-> 245
            //   #260	-> 247
            //   #262	-> 253
            //   #264	-> 263
            //   #265	-> 267
            //   #266	-> 269
            //   #474	-> 287
            //   #475	-> 313
            //   #476	-> 341
            //   #266	-> 355
            //   #476	-> 363
            //   #477	-> 372
            //   #474	-> 377
            //   #267	-> 389
            //   #478	-> 404
            //   #479	-> 430
            //   #480	-> 458
            //   #267	-> 472
            //   #480	-> 480
            //   #481	-> 489
            //   #478	-> 494
            //   #266	-> 508
            //   #264	-> 511
            //   #270	-> 516
            //   #275	-> 526
            //   #277	-> 535
            //   #278	-> 539
            //   #280	-> 540
            //   #281	-> 541
            //   #284	-> 552
            //   #285	-> 554
            //   #284	-> 555
            //   #287	-> 562
            //   #288	-> 565
            //   #287	-> 567
            //   #284	-> 570
            //   #290	-> 575
            //   #291	-> 577
            //   #290	-> 578
            //   #284	-> 581
            //   #283	-> 581
            //   #294	-> 583
            //   #294	-> 610
            //   #295	-> 613
            //   #299	-> 617
            //   #300	-> 619
            //   #299	-> 621
            //   #298	-> 624
            //   #303	-> 626
            //   #308	-> 648
            //   #309	-> 649
            //   #310	-> 657
            //   #311	-> 659
            //   #305	-> 662
            //   #308	-> 664
            //   #309	-> 665
            //   #310	-> 673
            //   #311	-> 675
            //   #308	-> 678
            //   #309	-> 681
            //   #310	-> 689
            //   #313	-> 694
            //   #314	-> 698
            //   #315	-> 718
            //   #316	-> 720
            //   #317	-> 722
            //   #313	-> 724
            //   #318	-> 725
            //   #319	-> 727
            //   #313	-> 728
            //   #327	-> 736
            //   #331	-> 748
            //   #236	-> 802
            //   #331	-> 827
            //   #337	-> 831
            //   #339	-> 833
            //   #236	-> 887
            //   #339	-> 911
            //   #345	-> 915
            //   #345	-> 932
            //   #346	-> 935
            //   #348	-> 951
            //   #236	-> 1006
            //   #352	-> 1014
            //   #236	-> 1019
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   59	72	2	newFiles	Ljava/util/List;
            //   131	4	2	newFiles	Ljava/util/List;
            //   135	74	2	newFiles	Ljava/util/List;
            //   234	126	2	newFiles	Ljava/util/List;
            //   360	18	2	newFiles	Ljava/util/List;
            //   378	99	2	newFiles	Ljava/util/List;
            //   477	18	2	newFiles	Ljava/util/List;
            //   495	115	2	newFiles	Ljava/util/List;
            //   610	52	2	newFiles	Ljava/util/List;
            //   662	16	2	newFiles	Ljava/util/List;
            //   678	127	2	newFiles	Ljava/util/List;
            //   821	69	2	newFiles	Ljava/util/List;
            //   906	26	2	newFiles	Ljava/util/List;
            //   932	68	2	newFiles	Ljava/util/List;
            //   73	11	3	$this$forEach$iv	Ljava/lang/Iterable;
            //   165	44	4	uri	Landroid/net/Uri;
            //   218	142	4	uri	Landroid/net/Uri;
            //   360	18	4	uri	Landroid/net/Uri;
            //   378	99	4	uri	Landroid/net/Uri;
            //   477	18	4	uri	Landroid/net/Uri;
            //   495	115	4	uri	Landroid/net/Uri;
            //   610	52	4	uri	Landroid/net/Uri;
            //   662	16	4	uri	Landroid/net/Uri;
            //   694	30	4	uri	Landroid/net/Uri;
            //   245	115	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   360	18	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   378	99	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   477	18	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   495	31	5	validationResult	Lcom/etouch/file/MediaParser$ValidationResult;
            //   103	7	7	element$iv	Ljava/lang/Object;
            //   263	6	7	originalFileName	Ljava/lang/String;
            //   110	11	8	uri	Landroid/net/Uri;
            //   516	94	8	uniqueName	Ljava/lang/String;
            //   610	52	8	uniqueName	Ljava/lang/String;
            //   662	16	8	uniqueName	Ljava/lang/String;
            //   694	51	8	uniqueName	Ljava/lang/String;
            //   284	26	9	$this$map$iv	Ljava/lang/Iterable;
            //   401	26	9	$this$map$iv	Ljava/lang/Iterable;
            //   526	84	9	mediaType	Lcom/etouch/MediaType;
            //   610	52	9	mediaType	Lcom/etouch/MediaType;
            //   662	16	9	mediaType	Lcom/etouch/MediaType;
            //   694	51	9	mediaType	Lcom/etouch/MediaType;
            //   535	75	10	retriever	Landroid/media/MediaMetadataRetriever;
            //   610	44	10	retriever	Landroid/media/MediaMetadataRetriever;
            //   662	8	10	retriever	Landroid/media/MediaMetadataRetriever;
            //   678	8	10	retriever	Landroid/media/MediaMetadataRetriever;
            //   310	12	11	$this$mapTo$iv$iv	Ljava/lang/Iterable;
            //   427	12	11	$this$mapTo$iv$iv	Ljava/lang/Iterable;
            //   539	71	11	artistName	Ljava/lang/String;
            //   610	7	11	artistName	Ljava/lang/String;
            //   617	45	11	artistName	Ljava/lang/String;
            //   662	16	11	artistName	Ljava/lang/String;
            //   694	51	11	artistName	Ljava/lang/String;
            //   310	64	12	destination$iv$iv	Ljava/util/Collection;
            //   427	64	12	destination$iv$iv	Ljava/util/Collection;
            //   583	27	14	metaArtist	Ljava/lang/String;
            //   610	7	14	metaArtist	Ljava/lang/String;
            //   736	9	14	audioFile	Lcom/etouch/AudioFile;
            //   341	28	15	item$iv$iv	Ljava/lang/Object;
            //   458	28	15	item$iv$iv	Ljava/lang/Object;
            //   626	9	15	durationStr	Ljava/lang/String;
            //   352	8	16	it	Lcom/etouch/AudioFile;
            //   469	8	16	it	Lcom/etouch/AudioFile;
            //   113	18	9	$i$a$-forEach-UnityBridgeImpl$importMultiFile$1$1	I
            //   76	59	5	$i$f$forEach	I
            //   355	5	17	$i$a$-map-UnityBridgeImpl$importMultiFile$1$uniqueName$1	I
            //   313	61	13	$i$f$mapTo	I
            //   287	91	10	$i$f$map	I
            //   472	5	17	$i$a$-map-UnityBridgeImpl$importMultiFile$1$uniqueName$2	I
            //   430	61	13	$i$f$mapTo	I
            //   404	91	10	$i$f$map	I
            //   48	971	0	this	Lcom/etouch/UnityBridgeImpl$importMultiFile$1;
            //   48	971	1	$result	Ljava/lang/Object;
            // Exception table:
            //   from	to	target	type
            //   113	125	128	java/lang/Exception
            //   165	200	831	java/lang/Exception
            //   234	796	831	java/lang/Exception
            //   540	648	662	java/lang/Exception
            //   540	648	678	finally
            //   648	654	657	java/lang/Exception
            //   662	664	678	finally
            //   664	670	673	java/lang/Exception
            //   678	680	678	finally
            //   680	686	689	java/lang/Exception
            //   821	828	831	java/lang/Exception
        }


        @NotNull
        public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super UnityBridgeImpl$importMultiFile$1> $completion) {
            return (Continuation<Unit>) new UnityBridgeImpl$importMultiFile$1(this.$uris, this.$mediaParser, this.$context, this.$onError, this.$onSuccess, $completion);
        }


        @Nullable
        public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
            return ((UnityBridgeImpl$importMultiFile$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
        }
    }


    public int getSystemVersionCode() {
        return Build.VERSION.SDK_INT;
    }

    @NotNull
    public String getSystemVersionName() {
        return "Android " + Build.VERSION.RELEASE;
    }

    @NotNull
    public String getDeviceModel() {
        String model = Build.MODEL;
        String manufacturer = Build.MANUFACTURER;
        Intrinsics.checkNotNull(model);
        Intrinsics.checkNotNull(manufacturer);
        return StringsKt.startsWith(model, manufacturer, true) ?
                model : (

                manufacturer + " " + manufacturer);
    }


    public void getSystemDeviceInfo(@NotNull Function1 getSystemVersionCode, @NotNull Function1 getSystemVersionName, @NotNull Function1 getDeviceModel, @NotNull Context context) {
        Intrinsics.checkNotNullParameter(getSystemVersionCode, "getSystemVersionCode");
        Intrinsics.checkNotNullParameter(getSystemVersionName, "getSystemVersionName");
        Intrinsics.checkNotNullParameter(getDeviceModel, "getDeviceModel");
        Intrinsics.checkNotNullParameter(context, "context");
        getSystemVersionCode.invoke(getVersionName(context));
        getSystemVersionName.invoke("Android " + Build.VERSION.RELEASE);

        String model = Build.MODEL;
        String manufacturer = Build.MANUFACTURER;
        Intrinsics.checkNotNull(model);
        Intrinsics.checkNotNull(manufacturer);
        if (StringsKt.startsWith(model, manufacturer, true)) {
            getDeviceModel.invoke(model);
        } else {
            getDeviceModel.invoke(manufacturer + " " + manufacturer);
        }
    }

    public float getSystemVolume(@NotNull Context context) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNull(context.getSystemService("audio"), "null cannot be cast to non-null type android.media.AudioManager");
        AudioManager audioManager = (AudioManager) context.getSystemService("audio");
        int currentVolume = audioManager.getStreamVolume(3);

        int maxVolume = audioManager.getStreamMaxVolume(3);

        return currentVolume / maxVolume;
    }


    public void setSystemVolume(@NotNull Context context, float percentage) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNull(context.getSystemService("audio"), "null cannot be cast to non-null type android.media.AudioManager");
        AudioManager audioManager = (AudioManager) context.getSystemService("audio");
        int maxVolume = audioManager.getStreamMaxVolume(3);
        int volume = (int) (percentage * maxVolume);

        audioManager.setStreamVolume(3, volume, 0);
    }

    public float getScreenBrightness(@NotNull Context context) {
        float f;
        Intrinsics.checkNotNullParameter(context, "context");
        try {
            int brightness = Settings.System.getInt(
                    context.getContentResolver(),
                    "screen_brightness");


            f = brightness / 255.0F;
        } catch (android.provider.Settings.SettingNotFoundException e) {
            f = 0.5F;
        }
        return f;
    }


    public void setScreenBrightness(@NotNull Context context, float percent) {
        Intrinsics.checkNotNullParameter(context, "context");
        if (!Settings.System.canWrite(context)) {
            return;
        }
        Settings.System.putInt(
                context.getContentResolver(),
                "screen_brightness_mode",
                0);


        float clamped = RangesKt.coerceIn(percent, 0.0F, 1.0F);
        int brightnessValue = MathKt.roundToInt(clamped * 'ÿ');

        Settings.System.putInt(
                context.getContentResolver(),
                "screen_brightness",
                brightnessValue);
    }


    @NotNull
    public final String getVersionName(@NotNull Context context) {
        String str;
        Intrinsics.checkNotNullParameter(context, "context");
        try {
            PackageManager packageManager = context.getPackageManager();
            Intrinsics.checkNotNull(packageManager);
            PackageInfo packageInfo = getPackageInfo(context, packageManager);
            if (((packageInfo != null) ? packageInfo.versionName : null) == null)
                (packageInfo != null) ? packageInfo.versionName : null;
            str = "未知版本名称";
        } catch (Exception e) {
            e.printStackTrace();
            str = "未知版本名称";
        }
        return str;
    }


    private final PackageInfo getPackageInfo(Context context, PackageManager packageManager) {
        PackageInfo packageInfo;

        try {
            packageInfo = packageManager.getPackageInfo(context.getPackageName(), 0);
        } catch (android.content.pm.PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            packageInfo = null;
        }
        return packageInfo;
    }
}


