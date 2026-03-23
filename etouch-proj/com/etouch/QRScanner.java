package com.etouch;

import android.app.Activity;
import android.content.Intent;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import kotlin.jvm.internal.Intrinsics;
import org.jetbrains.annotations.Nullable;


public final class QRScanner {
    @Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\000,\n\002\030\002\n\002\020\000\n\002\b\002\n\002\020\b\n\000\n\002\020\016\n\002\b\003\n\002\030\002\n\000\n\002\020\002\n\000\n\002\030\002\n\000\b\003\030\0002\0020\001B\007\b\002¢\006\002\020\002J\"\020\005\032\004\030\0010\0062\006\020\007\032\0020\0042\006\020\b\032\0020\0042\b\020\t\032\004\030\0010\nJ\016\020\013\032\0020\f2\006\020\r\032\0020\016R\016\020\003\032\0020\004XD¢\006\002\n\000¨\006\017"}, d2 = {"Lcom/etouch/QRScanner$Companion;", "", "()V", "REQUEST_SCAN_CODE", "", "handleScanResult", "", "requestCode", "resultCode", "data", "Landroid/content/Intent;", "startScan", "", "activity", "Landroid/app/Activity;", "sdk_android_unity_bridge_v1_debug"})
    public static final class Companion {
        public final void startScan(@NotNull Activity activity) {
            Intrinsics.checkNotNullParameter(activity, "activity");
            IntentIntegrator integrator = new IntentIntegrator(activity);
            integrator.setDesiredBarcodeFormats(IntentIntegrator.ALL_CODE_TYPES);
            integrator.setPrompt("Scan a barcode or QR code");
            integrator.setCameraId(0);
            integrator.setBeepEnabled(true);
            integrator.setBarcodeImageEnabled(false);
            integrator.setRequestCode(49374);
            integrator.initiateScan();
        }

        private Companion() {
        }

        @Nullable
        public final String handleScanResult(int requestCode, int resultCode, @Nullable Intent data) {
            Intrinsics.checkNotNullExpressionValue(IntentIntegrator.parseActivityResult(requestCode, resultCode, data), "parseActivityResult(...)");
            IntentResult result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
            return result.getContents();
        }
    }

    @NotNull
    public static final Companion Companion = new Companion(null);
    private static final int REQUEST_SCAN_CODE = 1004;
}


