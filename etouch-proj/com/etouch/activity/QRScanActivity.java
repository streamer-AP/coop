package com.etouch.activity;

import com.journeyapps.barcodescanner.CaptureActivity;
import kotlin.Metadata;


public final class QRScanActivity
        extends CaptureActivity {
    protected void onResume() {
        super.onResume();

        setRequestedOrientation(1);
    }

    protected void onPause() {
        super.onPause();

        setRequestedOrientation(-1);
    }
}


