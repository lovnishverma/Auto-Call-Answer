package com.lovnishverma.autocall;

import android.accessibilityservice.AccessibilityService;
import android.view.accessibility.AccessibilityEvent;
import android.content.Context;
import android.telecom.TelecomManager;
import android.os.Build;
import android.os.Handler;

import java.util.List;

public class CallAnswerService extends AccessibilityService {

    // Static whitelist set from Flutter
    public static List<String> whitelist;

    // Delay in seconds (set from Flutter)
    public static int answerDelaySeconds = 0;

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            try {
                String incomingNumber = "";

                // Get number from event text (if available)
                if (event.getText() != null && !event.getText().isEmpty()) {
                    incomingNumber = event.getText().toString();
                }

                // Check whitelist
                if (whitelist != null && !whitelist.contains(incomingNumber)) {
                    return; // Ignore numbers not in whitelist
                }

                // Delay before answering
                Handler handler = new Handler();
                handler.postDelayed(() -> {
                    try {
                        TelecomManager tm = (TelecomManager) getSystemService(Context.TELECOM_SERVICE);
                        if (tm != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            tm.acceptRingingCall();
                        }
                    } catch (SecurityException e) {
                        e.printStackTrace();
                    }
                }, answerDelaySeconds * 1000);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onInterrupt() {
        // Required override
    }
}
