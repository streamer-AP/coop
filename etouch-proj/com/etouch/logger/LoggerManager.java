package com.etouch.logger;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkCapabilities;
import android.util.Log;
import com.etouch.MediaType;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import kotlin.Metadata;
import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.collections.CollectionsKt;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.CoroutineContext;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.jvm.internal.Intrinsics;
import kotlin.jvm.internal.Lambda;
import kotlin.text.StringsKt;
import kotlinx.coroutines.BuildersKt;
import kotlinx.coroutines.CoroutineScope;
import kotlinx.coroutines.DelayKt;
import kotlinx.coroutines.Dispatchers;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;



public final class LoggerManager {
    @NotNull
    public static final LoggerManager INSTANCE = new LoggerManager();
    @NotNull
    private static final String TAG = "LoggerManager";
    @NotNull
    private static final String PREFS_NAME = "etouch_logs";
    @NotNull
    private static final String KEY_IMPORT_LOGS = "import_logs";
    @NotNull
    private static final String KEY_RESONANCE_LOGS = "resonance_logs";
    @NotNull
    private static final String KEY_USER_ID = "user_id";
    private static final int MAX_LOCAL_LOGS = 1000;
    private static SharedPreferences prefs;
    private static Context context;
    @NotNull
    private static String userId = "default_user";

    @NotNull
    public final String getUserId() {
        return userId;
    }

    public final void setUserId(@NotNull String<set-?>) {
        Intrinsics.checkNotNullParameter( < set - ? >, "<set-?>");
        userId = < set - ? >;
    }


    public final void init(@NotNull Context ctx, @NotNull String uid) {
        Intrinsics.checkNotNullParameter(ctx, "ctx");
        Intrinsics.checkNotNullParameter(uid, "uid");
        Intrinsics.checkNotNullExpressionValue(ctx.getApplicationContext(), "getApplicationContext(...)");
        context = ctx.getApplicationContext();
        if (context == null) Intrinsics.throwUninitializedPropertyAccessException("context");
        Intrinsics.checkNotNullExpressionValue(null.getSharedPreferences("etouch_logs", 0), "getSharedPreferences(...)");
        prefs = null.getSharedPreferences("etouch_logs", 0);
        userId = uid;


        if (prefs == null) Intrinsics.throwUninitializedPropertyAccessException("prefs");
        null.edit().putString("user_id", userId).apply();

        Log.d("LoggerManager", "日志管理器初始化完成，用户ID: " + userId);


        uploadPendingLogs();
    }


    public final void logImport(long fileSize, long mediaDuration, @NotNull MediaType mediaType, long parseTimeMs, boolean parseSuccess, @Nullable String errorMessage) {
        Intrinsics.checkNotNullParameter(mediaType, "mediaType");
        try {
            Intrinsics.checkNotNullExpressionValue(UUID.randomUUID().toString(), "toString(...)");


            Intrinsics.checkNotNullExpressionValue(Build.MODEL, "MODEL");
            ImportLog log = new ImportLog(UUID.randomUUID().toString(), userId, System.currentTimeMillis(), Build.MODEL, "Android " +
                    Build.VERSION.RELEASE,
                    getAppVersion(), null,
                    fileSize,
                    mediaDuration,
                    mediaType,
                    parseTimeMs,
                    parseSuccess,
                    errorMessage, false, null, 24640, null);


            saveLogLocally(log);
            Log.d("LoggerManager", "记录导入日志: " + log.getId() + ", 成功=" + log.getParseSuccess() + ", 耗时=" + log.getParseTimeMs() + "ms");


            if (isNetworkAvailable()) {
                uploadLog(log);
            }
        } catch (Exception e) {
            Log.e("LoggerManager", "记录日志失败: " + e.getMessage(), e);
        }
    }


    private final void saveLogLocally(ImportLog log) {

        try {
            List<ImportLog> existingLogs = CollectionsKt.toMutableList(getAllLogs());
            existingLogs.add(log);


            if (existingLogs.size() > 1000) {
                int toRemove = existingLogs.size() - 1000;
                existingLogs.subList(0, toRemove).clear();
                Log.d("LoggerManager", "删除了 " + toRemove + " 条最早的日志");
            }


            String jsonArray = CollectionsKt.joinToString$default(existingLogs, ",\n", "[", "]", 0, null, LoggerManager$saveLogLocally$jsonArray$1.INSTANCE, 24, null);

            if (prefs == null) Intrinsics.throwUninitializedPropertyAccessException("prefs");
            null.edit().putString("import_logs", jsonArray).apply();
            Log.d("LoggerManager", "日志已保存到本地，当前共 " + existingLogs.size() + " 条");
        } catch (Exception e) {
            Log.e("LoggerManager", "保存日志到本地失败: " + e.getMessage(), e);
        }
    }

    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\r\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "it", "Lcom/etouch/logger/ImportLog;", "invoke"})
    static final class LoggerManager$saveLogLocally$jsonArray$1 extends Lambda implements Function1<ImportLog, CharSequence> {
        public static final LoggerManager$saveLogLocally$jsonArray$1 INSTANCE = new LoggerManager$saveLogLocally$jsonArray$1();

        LoggerManager$saveLogLocally$jsonArray$1() {
            super(1);
        }

        @NotNull
        public final CharSequence invoke(@NotNull ImportLog it) {
            Intrinsics.checkNotNullParameter(it, "it");
            return it.toJson();
        }
    }

    private final void uploadLog(ImportLog log) {
        BuildersKt.launch$default(CoroutineScopeKt.CoroutineScope((CoroutineContext) Dispatchers.getIO()), null, null, new LoggerManager$uploadLog$1(log, null), 3, null);
    }

    @DebugMetadata(f = "LoggerManager.kt", l = {153}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.logger.LoggerManager$uploadLog$1")
    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
    static final class LoggerManager$uploadLog$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
        int label;

        LoggerManager$uploadLog$1(ImportLog $log, Continuation $completion) {
            super(2, $completion);
        }

        @Nullable
        public final Object invokeSuspend(@NotNull Object $result) {
            Object object = IntrinsicsKt.getCOROUTINE_SUSPENDED();
            switch (this.label) {
                case 0:
                    ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                    try {
                        Log.d("LoggerManager", "正在上传日志: " + this.$log.getId());
                        this.label = 1;
                        if (DelayKt.delay(100L, (Continuation) this) == object) return object;
                        DelayKt.delay(100L, (Continuation) this);
                        LoggerManager.INSTANCE.markAsUploaded(this.$log.getId());
                        Log.d("LoggerManager", "日志上传成功: " + this.$log.getId());
                    } catch (Exception e) {
                        Log.e("LoggerManager", "上传日志失败: " + this.$log.getId() + ", " + e.getMessage(), e);
                    }
                    return Unit.INSTANCE;
                case 1:
                    ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                    LoggerManager.INSTANCE.markAsUploaded(this.$log.getId());
                    Log.d("LoggerManager", "日志上传成功: " + this.$log.getId());
            }
            throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
        }

        @NotNull
        public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super LoggerManager$uploadLog$1> $completion) {
            return (Continuation<Unit>) new LoggerManager$uploadLog$1(this.$log, $completion);
        }

        @Nullable
        public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
            return ((LoggerManager$uploadLog$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
        }
    }

    public final void uploadPendingLogs() {
        if (!isNetworkAvailable()) {
            Log.d("LoggerManager", "无网络连接，跳过日志上传");
            return;
        }
        BuildersKt.launch$default(CoroutineScopeKt.CoroutineScope((CoroutineContext) Dispatchers.getIO()), null, null, new LoggerManager$uploadPendingLogs$1(null), 3, null);
    }

    @DebugMetadata(f = "LoggerManager.kt", l = {186}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.logger.LoggerManager$uploadPendingLogs$1")
    @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
    @SourceDebugExtension({"SMAP\nLoggerManager.kt\nKotlin\n*S Kotlin\n*F\n+ 1 LoggerManager.kt\ncom/etouch/logger/LoggerManager$uploadPendingLogs$1\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,455:1\n766#2:456\n857#2,2:457\n1855#2,2:459\n*S KotlinDebug\n*F\n+ 1 LoggerManager.kt\ncom/etouch/logger/LoggerManager$uploadPendingLogs$1\n*L\n175#1:456\n175#1:457,2\n184#1:459,2\n*E\n"})
    static final class LoggerManager$uploadPendingLogs$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
        Object L$0;
        int label;

        LoggerManager$uploadPendingLogs$1(Continuation $completion) {
            super(2, $completion);
        }

        @Nullable
        public final Object invokeSuspend(@NotNull Object $result) { // Byte code:
            //   0: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
            //   3: astore #12
            //   5: aload_0
            //   6: getfield label : I
            //   9: tableswitch default -> 321, 0 -> 32, 1 -> 260
            //   32: aload_1
            //   33: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   36: nop
            //   37: getstatic com/etouch/logger/LoggerManager.INSTANCE : Lcom/etouch/logger/LoggerManager;
            //   40: invokestatic access$getAllLogs : (Lcom/etouch/logger/LoggerManager;)Ljava/util/List;
            //   43: checkcast java/lang/Iterable
            //   46: astore_3
            //   47: iconst_0
            //   48: istore #4
            //   50: aload_3
            //   51: astore #5
            //   53: new java/util/ArrayList
            //   56: dup
            //   57: invokespecial <init> : ()V
            //   60: checkcast java/util/Collection
            //   63: astore #6
            //   65: iconst_0
            //   66: istore #7
            //   68: aload #5
            //   70: invokeinterface iterator : ()Ljava/util/Iterator;
            //   75: astore #8
            //   77: aload #8
            //   79: invokeinterface hasNext : ()Z
            //   84: ifeq -> 135
            //   87: aload #8
            //   89: invokeinterface next : ()Ljava/lang/Object;
            //   94: astore #9
            //   96: aload #9
            //   98: checkcast com/etouch/logger/ImportLog
            //   101: astore #10
            //   103: iconst_0
            //   104: istore #11
            //   106: aload #10
            //   108: invokevirtual getUploaded : ()Z
            //   111: ifne -> 118
            //   114: iconst_1
            //   115: goto -> 119
            //   118: iconst_0
            //   119: ifeq -> 77
            //   122: aload #6
            //   124: aload #9
            //   126: invokeinterface add : (Ljava/lang/Object;)Z
            //   131: pop
            //   132: goto -> 77
            //   135: aload #6
            //   137: checkcast java/util/List
            //   140: nop
            //   141: astore_2
            //   142: aload_2
            //   143: invokeinterface isEmpty : ()Z
            //   148: ifeq -> 163
            //   151: ldc 'LoggerManager'
            //   153: ldc '没有待上传的日志'
            //   155: invokestatic d : (Ljava/lang/String;Ljava/lang/String;)I
            //   158: pop
            //   159: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
            //   162: areturn
            //   163: ldc 'LoggerManager'
            //   165: aload_2
            //   166: invokeinterface size : ()I
            //   171: <illegal opcode> makeConcatWithConstants : (I)Ljava/lang/String;
            //   176: invokestatic d : (Ljava/lang/String;Ljava/lang/String;)I
            //   179: pop
            //   180: aload_2
            //   181: checkcast java/lang/Iterable
            //   184: astore_3
            //   185: iconst_0
            //   186: istore #4
            //   188: aload_3
            //   189: invokeinterface iterator : ()Ljava/util/Iterator;
            //   194: astore #5
            //   196: aload #5
            //   198: invokeinterface hasNext : ()Z
            //   203: ifeq -> 285
            //   206: aload #5
            //   208: invokeinterface next : ()Ljava/lang/Object;
            //   213: astore #6
            //   215: aload #6
            //   217: checkcast com/etouch/logger/ImportLog
            //   220: astore #7
            //   222: iconst_0
            //   223: istore #8
            //   225: getstatic com/etouch/logger/LoggerManager.INSTANCE : Lcom/etouch/logger/LoggerManager;
            //   228: aload #7
            //   230: invokestatic access$uploadLog : (Lcom/etouch/logger/LoggerManager;Lcom/etouch/logger/ImportLog;)V
            //   233: ldc2_w 50
            //   236: aload_0
            //   237: aload_0
            //   238: aload #5
            //   240: putfield L$0 : Ljava/lang/Object;
            //   243: aload_0
            //   244: iconst_1
            //   245: putfield label : I
            //   248: invokestatic delay : (JLkotlin/coroutines/Continuation;)Ljava/lang/Object;
            //   251: dup
            //   252: aload #12
            //   254: if_acmpne -> 281
            //   257: aload #12
            //   259: areturn
            //   260: iconst_0
            //   261: istore #4
            //   263: iconst_0
            //   264: istore #8
            //   266: aload_0
            //   267: getfield L$0 : Ljava/lang/Object;
            //   270: checkcast java/util/Iterator
            //   273: astore #5
            //   275: nop
            //   276: aload_1
            //   277: invokestatic throwOnFailure : (Ljava/lang/Object;)V
            //   280: aload_1
            //   281: pop
            //   282: goto -> 196
            //   285: nop
            //   286: ldc 'LoggerManager'
            //   288: ldc '所有待上传日志处理完成'
            //   290: invokestatic d : (Ljava/lang/String;Ljava/lang/String;)I
            //   293: pop
            //   294: goto -> 317
            //   297: astore_2
            //   298: ldc 'LoggerManager'
            //   300: aload_2
            //   301: invokevirtual getMessage : ()Ljava/lang/String;
            //   304: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
            //   309: aload_2
            //   310: checkcast java/lang/Throwable
            //   313: invokestatic e : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
            //   316: pop
            //   317: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
            //   320: areturn
            //   321: new java/lang/IllegalStateException
            //   324: dup
            //   325: ldc 'call to 'resume' before 'invoke' with coroutine'
            //   327: invokespecial <init> : (Ljava/lang/String;)V
            //   330: athrow
            // Line number table:
            //   Java source line number -> byte code offset
            //   #173	-> 3
            //   #174	-> 36
            //   #175	-> 37
            //   #456	-> 50
            //   #457	-> 68
            //   #175	-> 106
            //   #457	-> 119
            //   #458	-> 135
            //   #456	-> 140
            //   #175	-> 141
            //   #177	-> 142
            //   #178	-> 151
            //   #179	-> 159
            //   #182	-> 163
            //   #184	-> 180
            //   #459	-> 188
            //   #185	-> 225
            //   #186	-> 233
            //   #173	-> 257
            //   #187	-> 281
            //   #459	-> 282
            //   #460	-> 285
            //   #189	-> 286
            //   #190	-> 297
            //   #191	-> 298
            //   #193	-> 317
            //   #173	-> 321
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   142	9	2	pendingLogs	Ljava/util/List;
            //   163	22	2	pendingLogs	Ljava/util/List;
            //   298	19	2	e	Ljava/lang/Exception;
            //   47	18	3	$this$filter$iv	Ljava/lang/Iterable;
            //   185	11	3	$this$forEach$iv	Ljava/lang/Iterable;
            //   65	12	5	$this$filterTo$iv$iv	Ljava/lang/Iterable;
            //   65	72	6	destination$iv$iv	Ljava/util/Collection;
            //   215	7	6	element$iv	Ljava/lang/Object;
            //   222	11	7	log	Lcom/etouch/logger/ImportLog;
            //   96	36	9	element$iv$iv	Ljava/lang/Object;
            //   103	15	10	it	Lcom/etouch/logger/ImportLog;
            //   106	13	11	$i$a$-filter-LoggerManager$uploadPendingLogs$1$pendingLogs$1	I
            //   68	69	7	$i$f$filterTo	I
            //   50	91	4	$i$f$filter	I
            //   225	35	8	$i$a$-forEach-LoggerManager$uploadPendingLogs$1$1	I
            //   188	72	4	$i$f$forEach	I
            //   36	285	0	this	Lcom/etouch/logger/LoggerManager$uploadPendingLogs$1;
            //   36	285	1	$result	Ljava/lang/Object;
            //   266	16	8	$i$a$-forEach-LoggerManager$uploadPendingLogs$1$1	I
            //   263	23	4	$i$f$forEach	I
            // Exception table:
            //   from	to	target	type
            //   36	251	297	java/lang/Exception
            //   275	294	297	java/lang/Exception } @NotNull public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super LoggerManager$uploadPendingLogs$1> $completion) { return (Continuation<Unit>)new LoggerManager$uploadPendingLogs$1($completion); } @Nullable public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) { return ((LoggerManager$uploadPendingLogs$1)create(p1, p2)).invokeSuspend(Unit.INSTANCE); } } private final List<ImportLog> getAllLogs() { List<ImportLog> list; try { if (prefs == null) Intrinsics.throwUninitializedPropertyAccessException("prefs");  if (null.getString("import_logs", "[]") == null) null.getString("import_logs", "[]");  String jsonArray = "[]";


            if (Intrinsics.areEqual(jsonArray, "[]")) {
            } else {
                String[] arrayOfString = new String[1];
                arrayOfString[0] = "},";
                List list1 = StringsKt.split$default(StringsKt.removeSuffix(StringsKt.removePrefix(jsonArray, "["), "]"), arrayOfString, false, 0, 6, null);
                int $i$f$mapNotNull = 0;


                List list2 = list1;
                Collection destination$iv$iv = new ArrayList();
                int $i$f$mapNotNullTo = 0;


                Iterable $this$forEach$iv$iv$iv = list2;
                int $i$f$forEach = 0;
                Iterator iterator = $this$forEach$iv$iv$iv.iterator();
                if (iterator.hasNext()) {
                    Object element$iv$iv$iv = iterator.next(), element$iv$iv = element$iv$iv$iv;
                    int $i$a$ -forEach - CollectionsKt___CollectionsKt$mapNotNullTo$1$iv$iv = 0;
                    String jsonStr = (String) element$iv$iv;
                    int $i$a$ -mapNotNull - LoggerManager$getAllLogs$1 = 0;
                }
            } jsonArray = null.getString("import_logs", "[]");
        } catch(
        Exception e)

        {
            Iterable $this$mapNotNull$iv;
            Log.e("LoggerManager", "读取本地日志失败: " + $this$mapNotNull$iv.getMessage(), (Throwable) $this$mapNotNull$iv);
            list = CollectionsKt.emptyList();
        }  return list;
    }

    private final void markAsUploaded(String logId) { // Byte code:
        //   0: nop
        //   1: aload_0
        //   2: invokespecial getAllLogs : ()Ljava/util/List;
        //   5: checkcast java/util/Collection
        //   8: invokestatic toMutableList : (Ljava/util/Collection;)Ljava/util/List;
        //   11: astore_2
        //   12: aload_2
        //   13: astore #4
        //   15: iconst_0
        //   16: istore #5
        //   18: iconst_0
        //   19: istore #6
        //   21: aload #4
        //   23: invokeinterface iterator : ()Ljava/util/Iterator;
        //   28: astore #7
        //   30: aload #7
        //   32: invokeinterface hasNext : ()Z
        //   37: ifeq -> 82
        //   40: aload #7
        //   42: invokeinterface next : ()Ljava/lang/Object;
        //   47: astore #8
        //   49: aload #8
        //   51: checkcast com/etouch/logger/ImportLog
        //   54: astore #9
        //   56: iconst_0
        //   57: istore #10
        //   59: aload #9
        //   61: invokevirtual getId : ()Ljava/lang/String;
        //   64: aload_1
        //   65: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
        //   68: ifeq -> 76
        //   71: iload #6
        //   73: goto -> 83
        //   76: iinc #6, 1
        //   79: goto -> 30
        //   82: iconst_m1
        //   83: istore_3
        //   84: iload_3
        //   85: iconst_m1
        //   86: if_icmpeq -> 238
        //   89: aload_2
        //   90: iload_3
        //   91: aload_2
        //   92: iload_3
        //   93: invokeinterface get : (I)Ljava/lang/Object;
        //   98: checkcast com/etouch/logger/ImportLog
        //   101: aconst_null
        //   102: aconst_null
        //   103: lconst_0
        //   104: aconst_null
        //   105: aconst_null
        //   106: aconst_null
        //   107: aconst_null
        //   108: lconst_0
        //   109: lconst_0
        //   110: aconst_null
        //   111: lconst_0
        //   112: iconst_0
        //   113: aconst_null
        //   114: iconst_1
        //   115: invokestatic currentTimeMillis : ()J
        //   118: invokestatic valueOf : (J)Ljava/lang/Long;
        //   121: sipush #8191
        //   124: aconst_null
        //   125: invokestatic copy$default : (Lcom/etouch/logger/ImportLog;Ljava/lang/String;Ljava/lang/String;JLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;JJLcom/etouch/MediaType;JZLjava/lang/String;ZLjava/lang/Long;ILjava/lang/Object;)Lcom/etouch/logger/ImportLog;
        //   128: invokeinterface set : (ILjava/lang/Object;)Ljava/lang/Object;
        //   133: pop
        //   134: aload_2
        //   135: checkcast java/lang/Iterable
        //   138: ldc ',\\n'
        //   140: checkcast java/lang/CharSequence
        //   143: ldc '['
        //   145: checkcast java/lang/CharSequence
        //   148: ldc ']'
        //   150: checkcast java/lang/CharSequence
        //   153: iconst_0
        //   154: aconst_null
        //   155: getstatic com/etouch/logger/LoggerManager$markAsUploaded$jsonArray$1.INSTANCE : Lcom/etouch/logger/LoggerManager$markAsUploaded$jsonArray$1;
        //   158: checkcast kotlin/jvm/functions/Function1
        //   161: bipush #24
        //   163: aconst_null
        //   164: invokestatic joinToString$default : (Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;
        //   167: astore #4
        //   169: getstatic com/etouch/logger/LoggerManager.prefs : Landroid/content/SharedPreferences;
        //   172: dup
        //   173: ifnonnull -> 183
        //   176: pop
        //   177: ldc 'prefs'
        //   179: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
        //   182: aconst_null
        //   183: invokeinterface edit : ()Landroid/content/SharedPreferences$Editor;
        //   188: ldc_w 'import_logs'
        //   191: aload #4
        //   193: invokeinterface putString : (Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
        //   198: invokeinterface apply : ()V
        //   203: ldc 'LoggerManager'
        //   205: aload_1
        //   206: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
        //   211: invokestatic d : (Ljava/lang/String;Ljava/lang/String;)I
        //   214: pop
        //   215: goto -> 238
        //   218: astore_2
        //   219: ldc 'LoggerManager'
        //   221: aload_2
        //   222: invokevirtual getMessage : ()Ljava/lang/String;
        //   225: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
        //   230: aload_2
        //   231: checkcast java/lang/Throwable
        //   234: invokestatic e : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
        //   237: pop
        //   238: return
        // Line number table:
        //   Java source line number -> byte code offset
        //   #200	-> 0
        //   #201	-> 1
        //   #202	-> 12
        //   #469	-> 18
        //   #470	-> 21
        //   #471	-> 49
        //   #202	-> 59
        //   #471	-> 68
        //   #472	-> 71
        //   #473	-> 76
        //   #475	-> 82
        //   #202	-> 83
        //   #204	-> 84
        //   #205	-> 89
        //   #206	-> 114
        //   #207	-> 115
        //   #205	-> 121
        //   #211	-> 134
        //   #212	-> 169
        //   #214	-> 203
        //   #216	-> 218
        //   #217	-> 219
        //   #219	-> 238
        // Local variable table:
        //   start	length	slot	name	descriptor
        //   59	9	10	$i$a$-indexOfFirst-LoggerManager$markAsUploaded$index$1	I
        //   56	12	9	it	Lcom/etouch/logger/ImportLog;
        //   49	30	8	item$iv	Ljava/lang/Object;
        //   18	65	5	$i$f$indexOfFirst	I
        //   21	62	6	index$iv	I
        //   15	68	4	$this$indexOfFirst$iv	Ljava/util/List;
        //   169	46	4	jsonArray	Ljava/lang/String;
        //   12	203	2	allLogs	Ljava/util/List;
        //   84	131	3	index	I
        //   219	19	2	e	Ljava/lang/Exception;
        //   0	239	0	this	Lcom/etouch/logger/LoggerManager;
        //   0	239	1	logId	Ljava/lang/String;
        // Exception table:
        //   from	to	target	type
        //   0	215	218	java/lang/Exception }
        @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\r\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "it", "Lcom/etouch/logger/ImportLog;", "invoke"})
        static final class LoggerManager$markAsUploaded$jsonArray$1 extends Lambda implements Function1<ImportLog, CharSequence> {
            public static final LoggerManager$markAsUploaded$jsonArray$1 INSTANCE = new LoggerManager$markAsUploaded$jsonArray$1();

            LoggerManager$markAsUploaded$jsonArray$1() {
                super(1);
            }

            @NotNull
            public final CharSequence invoke(@NotNull ImportLog it) {
                Intrinsics.checkNotNullParameter(it, "it");
                return it.toJson();
            }
        }
        @RequiresPermission("android.permission.ACCESS_NETWORK_STATE") private final boolean isNetworkAvailable () {
            boolean bool;
            try {
                Network network;
                NetworkCapabilities capabilities;
                if (context == null)
                    Intrinsics.throwUninitializedPropertyAccessException("context");
                Intrinsics.checkNotNull(null.getSystemService("connectivity"), "null cannot be cast to non-null type android.net.ConnectivityManager");
                ConnectivityManager connectivityManager = (ConnectivityManager) null.getSystemService("connectivity");
                if (connectivityManager.getActiveNetwork() == null) {
                    connectivityManager.getActiveNetwork();
                    return false;
                }
                if (connectivityManager.getNetworkCapabilities(network) == null) {
                    connectivityManager.getNetworkCapabilities(network);
                    return false;
                }
                NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
                bool = (Build.VERSION.SDK_INT >= 23) ? ((capabilities.hasTransport(1) || capabilities.hasTransport(0) || capabilities.hasTransport(3)) ? true : false) : ((networkInfo != null) ? ((networkInfo.isConnected() == true) ? true : false) : false);
            } catch (Exception e) {
                Log.e("LoggerManager", "检查网络状态失败: " + e.getMessage(), e);
                bool = false;
            }
            return bool;
        }
        private final String getAppVersion () {
            String str;
            try {
                if (context == null)
                    Intrinsics.throwUninitializedPropertyAccessException("context");
                if (context == null)
                    Intrinsics.throwUninitializedPropertyAccessException("context");
                PackageInfo packageInfo = context.getPackageInfo(null.getPackageName(), 0);
                str = packageInfo.versionName + " (" + packageInfo.versionName + ")";
            } catch (Exception e) {
                str = "Unknown";
            }
            return str;
        }
        @NotNull public final String getStats () {
            List<ImportLog> allLogs = getAllLogs();
            Iterable<ImportLog> $this$count$iv = allLogs;
            int $i$f$count = 0;
            int count$iv = 0;
            for (ImportLog element$iv : $this$count$iv) {
                ImportLog it = element$iv;
                int $i$a$ -count - LoggerManager$getStats$uploaded$1 = 0;
                if (it.getUploaded() && ++count$iv < 0) CollectionsKt.throwCountOverflow();
            }
            int uploaded = ($this$count$iv instanceof Collection && ((Collection) $this$count$iv).isEmpty()) ? 0 : count$iv;
            Iterable<ImportLog> iterable1 = allLogs;
            int i = 0;
            int k = 0;
            for (ImportLog element$iv : iterable1) {
                ImportLog it = element$iv;
                int $i$a$ -count - LoggerManager$getStats$pending$1 = 0;
                if ((!it.getUploaded()) && ++k < 0) CollectionsKt.throwCountOverflow();
            }
            int pending = (iterable1 instanceof Collection && ((Collection) iterable1).isEmpty()) ? 0 : k;
            Iterable<ImportLog> iterable2 = allLogs;
            int j = 0;
            int m = 0;
            for (ImportLog element$iv : iterable2) {
                ImportLog it = element$iv;
                int $i$a$ -count - LoggerManager$getStats$successRate$1 = 0;
                if (it.getParseSuccess() && ++m < 0) CollectionsKt.throwCountOverflow();
            }
            float successRate = ((iterable2 instanceof Collection && ((Collection) iterable2).isEmpty()) ? false : m) / RangesKt.coerceAtLeast(allLogs.size(), 1) * 100;
            String str = "%.1f";
            Object[] arrayOfObject = new Object[1];
            arrayOfObject[0] = Float.valueOf(successRate);
            arrayOfObject = arrayOfObject;
            Intrinsics.checkNotNullExpressionValue(String.format(str, Arrays.copyOf(arrayOfObject, arrayOfObject.length)), "format(...)");
            return StringsKt.trimIndent("\n            总日志数: " + allLogs.size() + "\n            已上传: " + uploaded + "\n            待上传: " + pending + "\n            解析成功率: " + String.format(str, Arrays.copyOf(arrayOfObject, arrayOfObject.length)) + "%\n        ");
        } public final void clearAllLogs () {
            if (prefs == null) Intrinsics.throwUninitializedPropertyAccessException("prefs");
            null.edit().remove("import_logs").apply();
            if (prefs == null) Intrinsics.throwUninitializedPropertyAccessException("prefs");
            null.edit().remove("resonance_logs").apply();
            Log.d("LoggerManager", "所有本地日志已清空");
        }
        public final void logResonanceExperience (@NotNull ResonanceExperienceLog log){
            Intrinsics.checkNotNullParameter(log, "log");
            try {
                saveResonanceLogLocally(log);
                Log.d("LoggerManager", "记录共鸣体验日志: " + log.getId() + ", 媒体=" + log.getMediaName() + ", 播放时长=" + log.getPlayDurationMs() + "ms");
                if (isNetworkAvailable()) uploadResonanceLog(log);
            } catch (Exception e) {
                Log.e("LoggerManager", "记录共鸣体验日志失败: " + e.getMessage(), e);
            }
        }
        private final void saveResonanceLogLocally (ResonanceExperienceLog log){
            try {
                List<ResonanceExperienceLog> existingLogs = CollectionsKt.toMutableList(getAllResonanceLogs());
                existingLogs.add(log);
                if (existingLogs.size() > 1000) {
                    int toRemove = existingLogs.size() - 1000;
                    existingLogs.subList(0, toRemove).clear();
                    Log.d("LoggerManager", "删除了 " + toRemove + " 条最早的共鸣体验日志");
                }
                String jsonArray = CollectionsKt.joinToString$default(existingLogs, ",\n", "[", "]", 0, null, LoggerManager$saveResonanceLogLocally$jsonArray$1.INSTANCE, 24, null);
                if (prefs == null) Intrinsics.throwUninitializedPropertyAccessException("prefs");
                null.edit().putString("resonance_logs", jsonArray).apply();
                Log.d("LoggerManager", "共鸣体验日志已保存到本地，当前共 " + existingLogs.size() + " 条");
            } catch (Exception e) {
                Log.e("LoggerManager", "保存共鸣体验日志到本地失败: " + e.getMessage(), e);
            }
        }
        @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\r\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "it", "Lcom/etouch/logger/ResonanceExperienceLog;", "invoke"})
        static final class LoggerManager$saveResonanceLogLocally$jsonArray$1 extends Lambda implements Function1<ResonanceExperienceLog, CharSequence> {
            public static final LoggerManager$saveResonanceLogLocally$jsonArray$1 INSTANCE = new LoggerManager$saveResonanceLogLocally$jsonArray$1();

            LoggerManager$saveResonanceLogLocally$jsonArray$1() {
                super(1);
            }

            @NotNull
            public final CharSequence invoke(@NotNull ResonanceExperienceLog it) {
                Intrinsics.checkNotNullParameter(it, "it");
                return it.toJson();
            }
        }
        private final List<ResonanceExperienceLog> getAllResonanceLogs () {
            List<ResonanceExperienceLog> list;
            try {
                if (prefs == null) Intrinsics.throwUninitializedPropertyAccessException("prefs");
                if (null.getString("resonance_logs", "[]") == null) null.getString("resonance_logs", "[]");
                String jsonArray = "[]";
                if (Intrinsics.areEqual(jsonArray, "[]")) {
                } else {
                    String[] arrayOfString = new String[1];
                    arrayOfString[0] = "},";
                    List list1 = StringsKt.split$default(StringsKt.removeSuffix(StringsKt.removePrefix(jsonArray, "["), "]"), arrayOfString, false, 0, 6, null);
                    int $i$f$mapNotNull = 0;
                    List list2 = list1;
                    Collection destination$iv$iv = new ArrayList();
                    int $i$f$mapNotNullTo = 0;


                    Iterable $this$forEach$iv$iv$iv = list2;
                    int $i$f$forEach = 0;
                    Iterator iterator = $this$forEach$iv$iv$iv.iterator();
                    if (iterator.hasNext()) {
                        Object element$iv$iv$iv = iterator.next(), element$iv$iv = element$iv$iv$iv;
                        int $i$a$ -forEach - CollectionsKt___CollectionsKt$mapNotNullTo$1$iv$iv = 0;
                        String jsonStr = (String) element$iv$iv;
                        int $i$a$ -mapNotNull - LoggerManager$getAllResonanceLogs$1 = 0;
                    }
                } jsonArray = null.getString("resonance_logs", "[]");
            } catch (Exception e) {
                Iterable $this$mapNotNull$iv;
                Log.e("LoggerManager", "读取本地共鸣体验日志失败: " + $this$mapNotNull$iv.getMessage(), (Throwable) $this$mapNotNull$iv);
                list = CollectionsKt.emptyList();
            } return list;
        } private final void uploadResonanceLog (ResonanceExperienceLog log){
            BuildersKt.launch$default(CoroutineScopeKt.CoroutineScope((CoroutineContext) Dispatchers.getIO()), null, null, new LoggerManager$uploadResonanceLog$1(log, null), 3, null);
        }
        @DebugMetadata(f = "LoggerManager.kt", l = {368}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.logger.LoggerManager$uploadResonanceLog$1")
        @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
        static final class LoggerManager$uploadResonanceLog$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
            int label;

            LoggerManager$uploadResonanceLog$1(ResonanceExperienceLog $log, Continuation $completion) {
                super(2, $completion);
            }

            @Nullable
            public final Object invokeSuspend(@NotNull Object $result) {
                Object object = IntrinsicsKt.getCOROUTINE_SUSPENDED();
                switch (this.label) {
                    case 0:
                        ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                        try {
                            Log.d("LoggerManager", "正在上传共鸣体验日志: " + this.$log.getId());
                            this.label = 1;
                            if (DelayKt.delay(100L, (Continuation) this) == object) return object;
                            DelayKt.delay(100L, (Continuation) this);
                            LoggerManager.INSTANCE.markResonanceLogAsUploaded(this.$log.getId());
                            Log.d("LoggerManager", "共鸣体验日志上传成功: " + this.$log.getId());
                        } catch (Exception e) {
                            Log.e("LoggerManager", "上传共鸣体验日志失败: " + this.$log.getId() + ", " + e.getMessage(), e);
                        }
                        return Unit.INSTANCE;
                    case 1:
                        ResultKt.throwOnFailure(SYNTHETIC_LOCAL_VARIABLE_1);
                        LoggerManager.INSTANCE.markResonanceLogAsUploaded(this.$log.getId());
                        Log.d("LoggerManager", "共鸣体验日志上传成功: " + this.$log.getId());
                }
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }

            @NotNull
            public final Continuation<Unit> create(@Nullable Object value, @NotNull Continuation<? super LoggerManager$uploadResonanceLog$1> $completion) {
                return (Continuation<Unit>) new LoggerManager$uploadResonanceLog$1(this.$log, $completion);
            }

            @Nullable
            public final Object invoke(@NotNull CoroutineScope p1, @Nullable Continuation<?> p2) {
                return ((LoggerManager$uploadResonanceLog$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
            }
        }
        public final void uploadPendingResonanceLogs () {
            if (!isNetworkAvailable()) {
                Log.d("LoggerManager", "无网络连接，跳过共鸣体验日志上传");
                return;
            }
            BuildersKt.launch$default(CoroutineScopeKt.CoroutineScope((CoroutineContext) Dispatchers.getIO()), null, null, new LoggerManager$uploadPendingResonanceLogs$1(null), 3, null);
        }
        @DebugMetadata(f = "LoggerManager.kt", l = {401}, i = {}, s = {}, n = {}, m = "invokeSuspend", c = "com.etouch.logger.LoggerManager$uploadPendingResonanceLogs$1")
        @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\n\n\000\n\002\020\002\n\002\030\002\020\000\032\0020\001*\0020\002H@"}, d2 = {"<anonymous>", "", "Lkotlinx/coroutines/CoroutineScope;"})
        @SourceDebugExtension({"SMAP\nLoggerManager.kt\nKotlin\n*S Kotlin\n*F\n+ 1 LoggerManager.kt\ncom/etouch/logger/LoggerManager$uploadPendingResonanceLogs$1\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,455:1\n766#2:456\n857#2,2:457\n1855#2,2:459\n*S KotlinDebug\n*F\n+ 1 LoggerManager.kt\ncom/etouch/logger/LoggerManager$uploadPendingResonanceLogs$1\n*L\n390#1:456\n390#1:457,2\n399#1:459,2\n*E\n"})
        static final class LoggerManager$uploadPendingResonanceLogs$1 extends SuspendLambda implements Function2<CoroutineScope, Continuation<? super Unit>, Object> {
            Object L$0;
            int label;

            LoggerManager$uploadPendingResonanceLogs$1(Continuation $completion) {
                super(2, $completion);
            }

            @Nullable
            public final Object invokeSuspend(@NotNull Object $result) { // Byte code:
                //   0: invokestatic getCOROUTINE_SUSPENDED : ()Ljava/lang/Object;
                //   3: astore #12
                //   5: aload_0
                //   6: getfield label : I
                //   9: tableswitch default -> 321, 0 -> 32, 1 -> 260
                //   32: aload_1
                //   33: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                //   36: nop
                //   37: getstatic com/etouch/logger/LoggerManager.INSTANCE : Lcom/etouch/logger/LoggerManager;
                //   40: invokestatic access$getAllResonanceLogs : (Lcom/etouch/logger/LoggerManager;)Ljava/util/List;
                //   43: checkcast java/lang/Iterable
                //   46: astore_3
                //   47: iconst_0
                //   48: istore #4
                //   50: aload_3
                //   51: astore #5
                //   53: new java/util/ArrayList
                //   56: dup
                //   57: invokespecial <init> : ()V
                //   60: checkcast java/util/Collection
                //   63: astore #6
                //   65: iconst_0
                //   66: istore #7
                //   68: aload #5
                //   70: invokeinterface iterator : ()Ljava/util/Iterator;
                //   75: astore #8
                //   77: aload #8
                //   79: invokeinterface hasNext : ()Z
                //   84: ifeq -> 135
                //   87: aload #8
                //   89: invokeinterface next : ()Ljava/lang/Object;
                //   94: astore #9
                //   96: aload #9
                //   98: checkcast com/etouch/logger/ResonanceExperienceLog
                //   101: astore #10
                //   103: iconst_0
                //   104: istore #11
                //   106: aload #10
                //   108: invokevirtual getUploaded : ()Z
                //   111: ifne -> 118
                //   114: iconst_1
                //   115: goto -> 119
                //   118: iconst_0
                //   119: ifeq -> 77
                //   122: aload #6
                //   124: aload #9
                //   126: invokeinterface add : (Ljava/lang/Object;)Z
                //   131: pop
                //   132: goto -> 77
                //   135: aload #6
                //   137: checkcast java/util/List
                //   140: nop
                //   141: astore_2
                //   142: aload_2
                //   143: invokeinterface isEmpty : ()Z
                //   148: ifeq -> 163
                //   151: ldc 'LoggerManager'
                //   153: ldc '没有待上传的共鸣体验日志'
                //   155: invokestatic d : (Ljava/lang/String;Ljava/lang/String;)I
                //   158: pop
                //   159: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                //   162: areturn
                //   163: ldc 'LoggerManager'
                //   165: aload_2
                //   166: invokeinterface size : ()I
                //   171: <illegal opcode> makeConcatWithConstants : (I)Ljava/lang/String;
                //   176: invokestatic d : (Ljava/lang/String;Ljava/lang/String;)I
                //   179: pop
                //   180: aload_2
                //   181: checkcast java/lang/Iterable
                //   184: astore_3
                //   185: iconst_0
                //   186: istore #4
                //   188: aload_3
                //   189: invokeinterface iterator : ()Ljava/util/Iterator;
                //   194: astore #5
                //   196: aload #5
                //   198: invokeinterface hasNext : ()Z
                //   203: ifeq -> 285
                //   206: aload #5
                //   208: invokeinterface next : ()Ljava/lang/Object;
                //   213: astore #6
                //   215: aload #6
                //   217: checkcast com/etouch/logger/ResonanceExperienceLog
                //   220: astore #7
                //   222: iconst_0
                //   223: istore #8
                //   225: getstatic com/etouch/logger/LoggerManager.INSTANCE : Lcom/etouch/logger/LoggerManager;
                //   228: aload #7
                //   230: invokestatic access$uploadResonanceLog : (Lcom/etouch/logger/LoggerManager;Lcom/etouch/logger/ResonanceExperienceLog;)V
                //   233: ldc2_w 50
                //   236: aload_0
                //   237: aload_0
                //   238: aload #5
                //   240: putfield L$0 : Ljava/lang/Object;
                //   243: aload_0
                //   244: iconst_1
                //   245: putfield label : I
                //   248: invokestatic delay : (JLkotlin/coroutines/Continuation;)Ljava/lang/Object;
                //   251: dup
                //   252: aload #12
                //   254: if_acmpne -> 281
                //   257: aload #12
                //   259: areturn
                //   260: iconst_0
                //   261: istore #4
                //   263: iconst_0
                //   264: istore #8
                //   266: aload_0
                //   267: getfield L$0 : Ljava/lang/Object;
                //   270: checkcast java/util/Iterator
                //   273: astore #5
                //   275: nop
                //   276: aload_1
                //   277: invokestatic throwOnFailure : (Ljava/lang/Object;)V
                //   280: aload_1
                //   281: pop
                //   282: goto -> 196
                //   285: nop
                //   286: ldc 'LoggerManager'
                //   288: ldc '所有待上传共鸣体验日志处理完成'
                //   290: invokestatic d : (Ljava/lang/String;Ljava/lang/String;)I
                //   293: pop
                //   294: goto -> 317
                //   297: astore_2
                //   298: ldc 'LoggerManager'
                //   300: aload_2
                //   301: invokevirtual getMessage : ()Ljava/lang/String;
                //   304: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
                //   309: aload_2
                //   310: checkcast java/lang/Throwable
                //   313: invokestatic e : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
                //   316: pop
                //   317: getstatic kotlin/Unit.INSTANCE : Lkotlin/Unit;
                //   320: areturn
                //   321: new java/lang/IllegalStateException
                //   324: dup
                //   325: ldc 'call to 'resume' before 'invoke' with coroutine'
                //   327: invokespecial <init> : (Ljava/lang/String;)V
                //   330: athrow
                // Line number table:
                //   Java source line number -> byte code offset
                //   #388	-> 3
                //   #389	-> 36
                //   #390	-> 37
                //   #456	-> 50
                //   #457	-> 68
                //   #390	-> 106
                //   #457	-> 119
                //   #458	-> 135
                //   #456	-> 140
                //   #390	-> 141
                //   #392	-> 142
                //   #393	-> 151
                //   #394	-> 159
                //   #397	-> 163
                //   #399	-> 180
                //   #459	-> 188
                //   #400	-> 225
                //   #401	-> 233
                //   #388	-> 257
                //   #402	-> 281
                //   #459	-> 282
                //   #460	-> 285
                //   #404	-> 286
                //   #405	-> 297
                //   #406	-> 298
                //   #408	-> 317
                //   #388	-> 321
                // Local variable table:
                //   start	length	slot	name	descriptor
                //   142	9	2	pendingLogs	Ljava/util/List;
                //   163	22	2	pendingLogs	Ljava/util/List;
                //   298	19	2	e	Ljava/lang/Exception;
                //   47	18	3	$this$filter$iv	Ljava/lang/Iterable;
                //   185	11	3	$this$forEach$iv	Ljava/lang/Iterable;
                //   65	12	5	$this$filterTo$iv$iv	Ljava/lang/Iterable;
                //   65	72	6	destination$iv$iv	Ljava/util/Collection;
                //   215	7	6	element$iv	Ljava/lang/Object;
                //   222	11	7	log	Lcom/etouch/logger/ResonanceExperienceLog;
                //   96	36	9	element$iv$iv	Ljava/lang/Object;
                //   103	15	10	it	Lcom/etouch/logger/ResonanceExperienceLog;
                //   106	13	11	$i$a$-filter-LoggerManager$uploadPendingResonanceLogs$1$pendingLogs$1	I
                //   68	69	7	$i$f$filterTo	I
                //   50	91	4	$i$f$filter	I
                //   225	35	8	$i$a$-forEach-LoggerManager$uploadPendingResonanceLogs$1$1	I
                //   188	72	4	$i$f$forEach	I
                //   36	285	0	this	Lcom/etouch/logger/LoggerManager$uploadPendingResonanceLogs$1;
                //   36	285	1	$result	Ljava/lang/Object;
                //   266	16	8	$i$a$-forEach-LoggerManager$uploadPendingResonanceLogs$1$1	I
                //   263	23	4	$i$f$forEach	I
                // Exception table:
                //   from	to	target	type
                //   36	251	297	java/lang/Exception
                //   275	294	297	java/lang/Exception }
                @NotNull public final Continuation<Unit> create (@Nullable Object value, @NotNull Continuation < ? super
                LoggerManager$uploadPendingResonanceLogs$1 > $completion){
                    return (Continuation<Unit>) new LoggerManager$uploadPendingResonanceLogs$1($completion);
                }
                @Nullable public final Object invoke (@NotNull CoroutineScope p1, @Nullable Continuation < ? > p2){
                    return ((LoggerManager$uploadPendingResonanceLogs$1) create(p1, p2)).invokeSuspend(Unit.INSTANCE);
                }
            }

            private final void markResonanceLogAsUploaded(String logId) { // Byte code:
                //   0: nop
                //   1: aload_0
                //   2: invokespecial getAllResonanceLogs : ()Ljava/util/List;
                //   5: checkcast java/util/Collection
                //   8: invokestatic toMutableList : (Ljava/util/Collection;)Ljava/util/List;
                //   11: astore_2
                //   12: aload_2
                //   13: astore #4
                //   15: iconst_0
                //   16: istore #5
                //   18: iconst_0
                //   19: istore #6
                //   21: aload #4
                //   23: invokeinterface iterator : ()Ljava/util/Iterator;
                //   28: astore #7
                //   30: aload #7
                //   32: invokeinterface hasNext : ()Z
                //   37: ifeq -> 82
                //   40: aload #7
                //   42: invokeinterface next : ()Ljava/lang/Object;
                //   47: astore #8
                //   49: aload #8
                //   51: checkcast com/etouch/logger/ResonanceExperienceLog
                //   54: astore #9
                //   56: iconst_0
                //   57: istore #10
                //   59: aload #9
                //   61: invokevirtual getId : ()Ljava/lang/String;
                //   64: aload_1
                //   65: invokestatic areEqual : (Ljava/lang/Object;Ljava/lang/Object;)Z
                //   68: ifeq -> 76
                //   71: iload #6
                //   73: goto -> 83
                //   76: iinc #6, 1
                //   79: goto -> 30
                //   82: iconst_m1
                //   83: istore_3
                //   84: iload_3
                //   85: iconst_m1
                //   86: if_icmpeq -> 243
                //   89: aload_2
                //   90: iload_3
                //   91: aload_2
                //   92: iload_3
                //   93: invokeinterface get : (I)Ljava/lang/Object;
                //   98: checkcast com/etouch/logger/ResonanceExperienceLog
                //   101: aconst_null
                //   102: aconst_null
                //   103: lconst_0
                //   104: aconst_null
                //   105: aconst_null
                //   106: aconst_null
                //   107: aconst_null
                //   108: lconst_0
                //   109: aconst_null
                //   110: lconst_0
                //   111: lconst_0
                //   112: iconst_0
                //   113: iconst_0
                //   114: iconst_0
                //   115: iconst_0
                //   116: aconst_null
                //   117: aconst_null
                //   118: iconst_0
                //   119: iconst_1
                //   120: invokestatic currentTimeMillis : ()J
                //   123: invokestatic valueOf : (J)Ljava/lang/Long;
                //   126: ldc_w 262143
                //   129: aconst_null
                //   130: invokestatic copy$default : (Lcom/etouch/logger/ResonanceExperienceLog;Ljava/lang/String;Ljava/lang/String;JLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;JLcom/etouch/MediaType;JJZZZZLjava/lang/String;Ljava/lang/String;IZLjava/lang/Long;ILjava/lang/Object;)Lcom/etouch/logger/ResonanceExperienceLog;
                //   133: invokeinterface set : (ILjava/lang/Object;)Ljava/lang/Object;
                //   138: pop
                //   139: aload_2
                //   140: checkcast java/lang/Iterable
                //   143: ldc ',\\n'
                //   145: checkcast java/lang/CharSequence
                //   148: ldc '['
                //   150: checkcast java/lang/CharSequence
                //   153: ldc ']'
                //   155: checkcast java/lang/CharSequence
                //   158: iconst_0
                //   159: aconst_null
                //   160: getstatic com/etouch/logger/LoggerManager$markResonanceLogAsUploaded$jsonArray$1.INSTANCE : Lcom/etouch/logger/LoggerManager$markResonanceLogAsUploaded$jsonArray$1;
                //   163: checkcast kotlin/jvm/functions/Function1
                //   166: bipush #24
                //   168: aconst_null
                //   169: invokestatic joinToString$default : (Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;
                //   172: astore #4
                //   174: getstatic com/etouch/logger/LoggerManager.prefs : Landroid/content/SharedPreferences;
                //   177: dup
                //   178: ifnonnull -> 188
                //   181: pop
                //   182: ldc 'prefs'
                //   184: invokestatic throwUninitializedPropertyAccessException : (Ljava/lang/String;)V
                //   187: aconst_null
                //   188: invokeinterface edit : ()Landroid/content/SharedPreferences$Editor;
                //   193: ldc_w 'resonance_logs'
                //   196: aload #4
                //   198: invokeinterface putString : (Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
                //   203: invokeinterface apply : ()V
                //   208: ldc 'LoggerManager'
                //   210: aload_1
                //   211: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
                //   216: invokestatic d : (Ljava/lang/String;Ljava/lang/String;)I
                //   219: pop
                //   220: goto -> 243
                //   223: astore_2
                //   224: ldc 'LoggerManager'
                //   226: aload_2
                //   227: invokevirtual getMessage : ()Ljava/lang/String;
                //   230: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
                //   235: aload_2
                //   236: checkcast java/lang/Throwable
                //   239: invokestatic e : (Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
                //   242: pop
                //   243: return
                // Line number table:
                //   Java source line number -> byte code offset
                //   #415	-> 0
                //   #416	-> 1
                //   #417	-> 12
                //   #501	-> 18
                //   #502	-> 21
                //   #503	-> 49
                //   #417	-> 59
                //   #503	-> 68
                //   #504	-> 71
                //   #505	-> 76
                //   #507	-> 82
                //   #417	-> 83
                //   #419	-> 84
                //   #420	-> 89
                //   #421	-> 119
                //   #422	-> 120
                //   #420	-> 126
                //   #426	-> 139
                //   #427	-> 174
                //   #429	-> 208
                //   #431	-> 223
                //   #432	-> 224
                //   #434	-> 243
                // Local variable table:
                //   start	length	slot	name	descriptor
                //   59	9	10	$i$a$-indexOfFirst-LoggerManager$markResonanceLogAsUploaded$index$1	I
                //   56	12	9	it	Lcom/etouch/logger/ResonanceExperienceLog;
                //   49	30	8	item$iv	Ljava/lang/Object;
                //   18	65	5	$i$f$indexOfFirst	I
                //   21	62	6	index$iv	I
                //   15	68	4	$this$indexOfFirst$iv	Ljava/util/List;
                //   174	46	4	jsonArray	Ljava/lang/String;
                //   12	208	2	allLogs	Ljava/util/List;
                //   84	136	3	index	I
                //   224	19	2	e	Ljava/lang/Exception;
                //   0	244	0	this	Lcom/etouch/logger/LoggerManager;
                //   0	244	1	logId	Ljava/lang/String;
                // Exception table:
                //   from	to	target	type
                //   0	220	223	java/lang/Exception }
                @Metadata(mv = {1, 9, 0}, k = 3, xi = 48, d1 = {"\000\016\n\000\n\002\020\r\n\000\n\002\030\002\n\000\020\000\032\0020\0012\006\020\002\032\0020\003H\n¢\006\002\b\004"}, d2 = {"<anonymous>", "", "it", "Lcom/etouch/logger/ResonanceExperienceLog;", "invoke"})
                static final class LoggerManager$markResonanceLogAsUploaded$jsonArray$1 extends Lambda implements Function1<ResonanceExperienceLog, CharSequence> {
                    public static final LoggerManager$markResonanceLogAsUploaded$jsonArray$1 INSTANCE = new LoggerManager$markResonanceLogAsUploaded$jsonArray$1();

                    LoggerManager$markResonanceLogAsUploaded$jsonArray$1() {
                        super(1);
                    }

                    @NotNull
                    public final CharSequence invoke(@NotNull ResonanceExperienceLog it) {
                        Intrinsics.checkNotNullParameter(it, "it");
                        return it.toJson();
                    }
                }
                @NotNull public final String getResonanceStats () {
                    List<ResonanceExperienceLog> allLogs = getAllResonanceLogs();
                    Iterable<ResonanceExperienceLog> $this$count$iv = allLogs;
                    int $i$f$count = 0;
                    int count$iv = 0;
                    for (ResonanceExperienceLog element$iv : $this$count$iv) {
                        ResonanceExperienceLog it = element$iv;
                        int $i$a$ -count - LoggerManager$getResonanceStats$uploaded$1 = 0;
                        if (it.getUploaded() && ++count$iv < 0) CollectionsKt.throwCountOverflow();
                    }
                    int uploaded = ($this$count$iv instanceof Collection && ((Collection) $this$count$iv).isEmpty()) ? 0 : count$iv;
                    Iterable<ResonanceExperienceLog> iterable1 = allLogs;
                    int i = 0;
                    int j = 0;
                    for (ResonanceExperienceLog element$iv : iterable1) {
                        ResonanceExperienceLog it = element$iv;
                        int $i$a$ -count - LoggerManager$getResonanceStats$pending$1 = 0;
                        if ((!it.getUploaded()) && ++j < 0) CollectionsKt.throwCountOverflow();
                    }
                    int pending = (iterable1 instanceof Collection && ((Collection) iterable1).isEmpty()) ? 0 : j;
                    List<ResonanceExperienceLog> list1 = allLogs;
                    long l1 = 0L;
                    for (ResonanceExperienceLog resonanceExperienceLog1 : list1) {
                        ResonanceExperienceLog resonanceExperienceLog2 = resonanceExperienceLog1;
                        long l2 = l1;
                        int $i$a$ -sumOfLong - LoggerManager$getResonanceStats$totalPlayTime$1 = 0;
                        long l3 = resonanceExperienceLog2.getPlayDurationMs();
                        l1 = l2 + l3;
                    }
                    long totalPlayTime = l1;
                    long avgPlayTime = (!allLogs.isEmpty()) ? (totalPlayTime / allLogs.size()) : 0L;
                    return StringsKt.trimIndent("\n            共鸣体验日志总数: " + allLogs.size() + "\n            已上传: " + uploaded + "\n            待上传: " + pending + "\n            总播放时长: " + totalPlayTime + "ms\n            平均播放时长: " + avgPlayTime + "ms\n        ");
                }

            }


