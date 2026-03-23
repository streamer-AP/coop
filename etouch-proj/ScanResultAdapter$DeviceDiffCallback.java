import androidx.recyclerview.widget.DiffUtil;
import com.etouch.bt.BluetoothManager;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.NotNull;



public final class DeviceDiffCallback
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


