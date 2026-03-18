import android.view.View;
import com.etouch.bt.BluetoothManager;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;


public final class ScanResultAdapter extends ListAdapter<BluetoothManager.BluetoothDeviceInfo, ScanResultAdapter.DeviceViewHolder> {
    @Nullable
    private Function1<? super BluetoothManager.BluetoothDeviceInfo, Unit> onItemClickListener;

    public ScanResultAdapter() {
        super(new DeviceDiffCallback());
    }


    public final void setOnItemClickListener(@NotNull Function1<? super BluetoothManager.BluetoothDeviceInfo, Unit> listener) {
        Intrinsics.checkNotNullParameter(listener, "listener");
        this.onItemClickListener = listener;
    }

    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000&\n\002\030\002\n\002\030\002\n\000\n\002\030\002\n\002\b\002\n\002\030\002\n\002\b\r\n\002\020\002\n\000\n\002\030\002\n\000\b\004\030\0002\0020\001B\r\022\006\020\002\032\0020\003¢\006\002\020\004J\016\020\023\032\0020\0242\006\020\025\032\0020\026R\021\020\005\032\0020\006¢\006\b\n\000\032\004\b\007\020\bR\021\020\t\032\0020\006¢\006\b\n\000\032\004\b\n\020\bR\021\020\013\032\0020\006¢\006\b\n\000\032\004\b\f\020\bR\021\020\r\032\0020\006¢\006\b\n\000\032\004\b\016\020\bR\021\020\017\032\0020\006¢\006\b\n\000\032\004\b\020\020\bR\021\020\021\032\0020\006¢\006\b\n\000\032\004\b\022\020\b¨\006\027"}, d2 = {"LScanResultAdapter$DeviceViewHolder;", "Landroidx/recyclerview/widget/RecyclerView$ViewHolder;", "itemView", "Landroid/view/View;", "(LScanResultAdapter;Landroid/view/View;)V", "tvConnectedStatus", "Landroid/widget/TextView;", "getTvConnectedStatus", "()Landroid/widget/TextView;", "tvDeviceAddress", "getTvDeviceAddress", "tvDeviceName", "getTvDeviceName", "tvPairedStatus", "getTvPairedStatus", "tvRssi", "getTvRssi", "tvTargetStatus", "getTvTargetStatus", "bind", "", "deviceInfo", "Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;", "sdk_android_unity_bridge_v1_debug"})
    public final class DeviceViewHolder extends RecyclerView.ViewHolder {
        @NotNull
        private final TextView tvDeviceName;
        @NotNull
        private final TextView tvDeviceAddress;
        @NotNull
        private final TextView tvRssi;

        public DeviceViewHolder(View itemView) {
            super(itemView);

            Intrinsics.checkNotNullExpressionValue(itemView.findViewById(R.id.tv_device_name), "findViewById(...)");
            this.tvDeviceName = (TextView) itemView.findViewById(R.id.tv_device_name);
            Intrinsics.checkNotNullExpressionValue(itemView.findViewById(R.id.tv_device_address), "findViewById(...)");
            this.tvDeviceAddress = (TextView) itemView.findViewById(R.id.tv_device_address);
            Intrinsics.checkNotNullExpressionValue(itemView.findViewById(R.id.tv_device_rssi), "findViewById(...)");
            this.tvRssi = (TextView) itemView.findViewById(R.id.tv_device_rssi);
            Intrinsics.checkNotNullExpressionValue(itemView.findViewById(R.id.tv_paired_status), "findViewById(...)");
            this.tvPairedStatus = (TextView) itemView.findViewById(R.id.tv_paired_status);
            Intrinsics.checkNotNullExpressionValue(itemView.findViewById(R.id.tv_connected_status), "findViewById(...)");
            this.tvConnectedStatus = (TextView) itemView.findViewById(R.id.tv_connected_status);
            Intrinsics.checkNotNullExpressionValue(itemView.findViewById(R.id.tv_target_device_status), "findViewById(...)");
            this.tvTargetStatus = (TextView) itemView.findViewById(R.id.tv_target_device_status);
        }

        @NotNull
        private final TextView tvPairedStatus;
        @NotNull
        private final TextView tvConnectedStatus;
        @NotNull
        private final TextView tvTargetStatus;

        @NotNull
        public final TextView getTvDeviceName() {
            return this.tvDeviceName;
        }

        @NotNull
        public final TextView getTvDeviceAddress() {
            return this.tvDeviceAddress;
        }

        @NotNull
        public final TextView getTvTargetStatus() {
            return this.tvTargetStatus;
        }

        @NotNull
        public final TextView getTvRssi() {
            return this.tvRssi;
        }

        @NotNull
        public final TextView getTvPairedStatus() {
            return this.tvPairedStatus;
        }

        @NotNull
        public final TextView getTvConnectedStatus() {
            return this.tvConnectedStatus;
        }

        public final void bind(@NotNull BluetoothManager.BluetoothDeviceInfo deviceInfo) {
            // Byte code:
            //   0: aload_1
            //   1: ldc 'deviceInfo'
            //   3: invokestatic checkNotNullParameter : (Ljava/lang/Object;Ljava/lang/String;)V
            //   6: aload_0
            //   7: getfield tvDeviceName : Landroid/widget/TextView;
            //   10: aload_1
            //   11: invokevirtual getName : ()Ljava/lang/String;
            //   14: checkcast java/lang/CharSequence
            //   17: astore_2
            //   18: aload_2
            //   19: ifnull -> 31
            //   22: aload_2
            //   23: invokeinterface length : ()I
            //   28: ifne -> 35
            //   31: iconst_1
            //   32: goto -> 36
            //   35: iconst_0
            //   36: ifeq -> 47
            //   39: ldc '未知设备'
            //   41: checkcast java/lang/CharSequence
            //   44: goto -> 54
            //   47: aload_1
            //   48: invokevirtual getName : ()Ljava/lang/String;
            //   51: checkcast java/lang/CharSequence
            //   54: invokevirtual setText : (Ljava/lang/CharSequence;)V
            //   57: aload_0
            //   58: getfield tvDeviceAddress : Landroid/widget/TextView;
            //   61: aload_1
            //   62: invokevirtual getAddress : ()Ljava/lang/String;
            //   65: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
            //   70: checkcast java/lang/CharSequence
            //   73: invokevirtual setText : (Ljava/lang/CharSequence;)V
            //   76: aload_0
            //   77: getfield tvRssi : Landroid/widget/TextView;
            //   80: aload_1
            //   81: invokevirtual getRssi : ()Ljava/lang/Integer;
            //   84: <illegal opcode> makeConcatWithConstants : (Ljava/lang/Integer;)Ljava/lang/String;
            //   89: checkcast java/lang/CharSequence
            //   92: invokevirtual setText : (Ljava/lang/CharSequence;)V
            //   95: aload_0
            //   96: getfield tvPairedStatus : Landroid/widget/TextView;
            //   99: aload_1
            //   100: invokevirtual isPaired : ()Ljava/lang/Boolean;
            //   103: dup
            //   104: invokestatic checkNotNull : (Ljava/lang/Object;)V
            //   107: invokevirtual booleanValue : ()Z
            //   110: ifeq -> 118
            //   113: ldc '是'
            //   115: goto -> 120
            //   118: ldc '否'
            //   120: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
            //   125: checkcast java/lang/CharSequence
            //   128: invokevirtual setText : (Ljava/lang/CharSequence;)V
            //   131: aload_0
            //   132: getfield tvConnectedStatus : Landroid/widget/TextView;
            //   135: aload_1
            //   136: invokevirtual isConnected : ()Ljava/lang/Boolean;
            //   139: dup
            //   140: invokestatic checkNotNull : (Ljava/lang/Object;)V
            //   143: invokevirtual booleanValue : ()Z
            //   146: ifeq -> 154
            //   149: ldc '是'
            //   151: goto -> 156
            //   154: ldc '否'
            //   156: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
            //   161: checkcast java/lang/CharSequence
            //   164: invokevirtual setText : (Ljava/lang/CharSequence;)V
            //   167: aload_0
            //   168: getfield tvTargetStatus : Landroid/widget/TextView;
            //   171: aload_1
            //   172: invokevirtual isTargetDevice : ()Ljava/lang/Boolean;
            //   175: dup
            //   176: invokestatic checkNotNull : (Ljava/lang/Object;)V
            //   179: invokevirtual booleanValue : ()Z
            //   182: ifeq -> 190
            //   185: ldc '是'
            //   187: goto -> 192
            //   190: ldc '否'
            //   192: <illegal opcode> makeConcatWithConstants : (Ljava/lang/String;)Ljava/lang/String;
            //   197: checkcast java/lang/CharSequence
            //   200: invokevirtual setText : (Ljava/lang/CharSequence;)V
            //   203: aload_0
            //   204: getfield itemView : Landroid/view/View;
            //   207: aload_0
            //   208: getfield this$0 : LScanResultAdapter;
            //   211: aload_1
            //   212: <illegal opcode> onClick : (LScanResultAdapter;Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;)Landroid/view/View$OnClickListener;
            //   217: invokevirtual setOnClickListener : (Landroid/view/View$OnClickListener;)V
            //   220: return
            // Line number table:
            //   Java source line number -> byte code offset
            //   #33	-> 6
            //   #33	-> 36
            //   #34	-> 57
            //   #35	-> 76
            //   #36	-> 95
            //   #37	-> 131
            //   #38	-> 167
            //   #41	-> 203
            //   #44	-> 220
            // Local variable table:
            //   start	length	slot	name	descriptor
            //   0	221	0	this	LScanResultAdapter$DeviceViewHolder;
            //   0	221	1	deviceInfo	Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;
        }

        private static final void bind$lambda$0(ScanResultAdapter this$0, BluetoothManager.BluetoothDeviceInfo $deviceInfo, View it) {
            Intrinsics.checkNotNullParameter(ScanResultAdapter.this, "this$0");
            Intrinsics.checkNotNullParameter($deviceInfo, "$deviceInfo");
            if (ScanResultAdapter.this.onItemClickListener != null) {
                ScanResultAdapter.this.onItemClickListener.invoke($deviceInfo);
            } else {
                ScanResultAdapter.this.onItemClickListener;
            }

        }
    }


    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000\030\n\002\030\002\n\002\030\002\n\002\030\002\n\002\b\002\n\002\020\013\n\002\b\004\030\0002\b\022\004\022\0020\0020\001B\005¢\006\002\020\003J\030\020\004\032\0020\0052\006\020\006\032\0020\0022\006\020\007\032\0020\002H\026J\030\020\b\032\0020\0052\006\020\006\032\0020\0022\006\020\007\032\0020\002H\026¨\006\t"}, d2 = {"LScanResultAdapter$DeviceDiffCallback;", "Landroidx/recyclerview/widget/DiffUtil$ItemCallback;", "Lcom/etouch/bt/BluetoothManager$BluetoothDeviceInfo;", "()V", "areContentsTheSame", "", "oldItem", "newItem", "areItemsTheSame", "sdk_android_unity_bridge_v1_debug"})
    public static final class DeviceDiffCallback
            extends DiffUtil.ItemCallback<BluetoothManager.BluetoothDeviceInfo> {
        public boolean areItemsTheSame(@NotNull BluetoothManager.BluetoothDeviceInfo oldItem, @NotNull BluetoothManager.BluetoothDeviceInfo newItem) {
            Intrinsics.checkNotNullParameter(oldItem, "oldItem");
            Intrinsics.checkNotNullParameter(newItem, "newItem");
            return Intrinsics.areEqual(oldItem.getAddress(), newItem.getAddress());
        }


        public boolean areContentsTheSame(@NotNull BluetoothManager.BluetoothDeviceInfo oldItem, @NotNull BluetoothManager.BluetoothDeviceInfo newItem) {
            Intrinsics.checkNotNullParameter(oldItem, "oldItem");
            Intrinsics.checkNotNullParameter(newItem, "newItem");
            return (Intrinsics.areEqual(oldItem.getName(), newItem.getName()) &&
                    Intrinsics.areEqual(oldItem.getRssi(), newItem.getRssi()) &&
                    Intrinsics.areEqual(oldItem.isPaired(), newItem.isPaired()) &&
                    Intrinsics.areEqual(oldItem.isConnected(), newItem.isConnected()) &&
                    Intrinsics.areEqual(oldItem.isTargetDevice(), newItem.isTargetDevice()) &&
                    Intrinsics.areEqual(oldItem.getServiceUuids(), newItem.getServiceUuids()));
        }
    }

    @NotNull
    public DeviceViewHolder onCreateViewHolder(@NotNull ViewGroup parent, int viewType) {
        Intrinsics.checkNotNullParameter(parent, "parent");
        View itemView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_bluetooth_device, parent, false);
        Intrinsics.checkNotNull(itemView);
        return new DeviceViewHolder(itemView);
    }


    public void onBindViewHolder(@NotNull DeviceViewHolder holder, int position) {
        Intrinsics.checkNotNullParameter(holder, "holder");
        BluetoothManager.BluetoothDeviceInfo currentDevice = (BluetoothManager.BluetoothDeviceInfo) getItem(position);
        Intrinsics.checkNotNull(currentDevice);
        holder.bind(currentDevice);
    }
}


