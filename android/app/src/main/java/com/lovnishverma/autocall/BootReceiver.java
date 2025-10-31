package com.lovnishverma.autocall;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "AutoCallBootReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Log.d(TAG, "Device rebooted - Accessibility service will auto-start if enabled");

            // IMPORTANT: Accessibility Services are automatically restarted by Android
            // after boot if they were enabled before reboot.
            // You CANNOT manually start an accessibility service with startService()

            // The service will be automatically bound by the system if:
            // 1. User has enabled it in Accessibility Settings
            // 2. Battery optimization is disabled for the app

            // Optional: Log or notify that the system is ready
            Log.i(TAG, "Auto Call Answer is ready to work after reboot");
        }
    }
}