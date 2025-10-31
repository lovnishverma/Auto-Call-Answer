package com.lovnishverma.autocall;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.provider.Settings;
import android.os.Build;
import android.os.PowerManager;
import android.net.Uri;
import android.content.Context;
import android.view.accessibility.AccessibilityManager;
import android.accessibilityservice.AccessibilityServiceInfo;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.lovnishverma.autocall/accessibility";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "checkAccessibilityStatus":
                            boolean isEnabled = isAccessibilityServiceEnabled(this);
                            result.success(isEnabled);
                            break;

                        case "openAccessibilitySettings":
                            Intent intent = new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            startActivity(intent);
                            result.success(null);
                            break;

                        case "setWhitelist":
                            List<String> whitelist = call.argument("arg");
                            CallAnswerService.whitelist = whitelist;
                            result.success(null);
                            break;

                        case "setDelay":
                            Integer delay = call.argument("arg");
                            if (delay != null) {
                                CallAnswerService.answerDelaySeconds = delay;
                            }
                            result.success(null);
                            break;

                        case "requestBatteryExemption":
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                PowerManager pm = (PowerManager) getSystemService(POWER_SERVICE);
                                if (!pm.isIgnoringBatteryOptimizations(getPackageName())) {
                                    Intent intentOpt = new Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
                                    intentOpt.setData(Uri.parse("package:" + getPackageName()));
                                    intentOpt.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                    startActivity(intentOpt);
                                }
                            }
                            result.success(null);
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    private boolean isAccessibilityServiceEnabled(Context context) {
        AccessibilityManager am = (AccessibilityManager) context.getSystemService(Context.ACCESSIBILITY_SERVICE);
        List<AccessibilityServiceInfo> enabledServices = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK);

        String packageName = context.getPackageName();

        for (AccessibilityServiceInfo service : enabledServices) {
            String serviceId = service.getId();
            // Check if the service belongs to this app
            if (serviceId.contains(packageName)) {
                return true;
            }
        }
        return false;
    }
}