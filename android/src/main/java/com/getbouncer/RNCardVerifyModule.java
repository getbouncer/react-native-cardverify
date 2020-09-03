package com.getbouncer;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.getbouncer.cardverify.ui.CardVerifyActivity;
import com.getbouncer.cardverify.ui.CardVerifyActivityResult;
import com.getbouncer.cardverify.ui.CardVerifyActivityResultHandler;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public class RNCardVerifyModule extends ReactContextBaseJavaModule {
    private static final int SCAN_REQUEST_CODE = 51235;

    public static String apiKey = null;
    public static boolean enableExpiryExtraction = false;
    public static boolean enableNameExtraction = false;

    private final ReactApplicationContext reactContext;

    private Promise scanPromise;

    @Override
    public void initialize() {
        CardVerifyActivity.warmUp(this.reactContext.getApplicationContext(), apiKey);
    }

    public RNCardVerifyModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.reactContext.addActivityEventListener(new ActivityEventListener() {

            @Override
            public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
                if (requestCode == SCAN_REQUEST_CODE) {
                    CardVerifyActivity.parseVerifyResult(resultCode, data, new CardVerifyActivityResultHandler() {
                        @Override
                        public void cardScanned(
                            @Nullable String instanceId,
                            @Nullable String scanId,
                            @NotNull CardVerifyActivityResult result,
                            int payloadVersion,
                            @NotNull String encryptedPayload
                        ) {
                            final String expiryDay;
                            if (result.getExpiryDay() != null) {
                                expiryDay = result.getExpiryDay().toString();
                            } else {
                                expiryDay = null;
                            }

                            final String expiryMonth;
                            if (result.getExpiryMonth() != null) {
                                expiryMonth = result.getExpiryMonth().toString();
                            } else {
                                expiryMonth = null;
                            }

                            final String expiryYear;
                            if (result.getExpiryYear() != null) {
                                expiryYear = result.getExpiryYear().toString();
                            } else {
                                expiryYear = null;
                            }

                            final WritableMap cardMap = new WritableNativeMap();
                            cardMap.putString("number", result.getPan());
                            cardMap.putString("expiryDay", expiryDay);
                            cardMap.putString("expiryMonth", expiryMonth);
                            cardMap.putString("expiryYear", expiryYear);
                            cardMap.putString("issuer", result.getNetworkName());
                            cardMap.putString("cvc", result.getCvc());
                            cardMap.putString("cardholderName", result.getLegalName());
                            cardMap.putString("payloadVersion", String.valueOf(payloadVersion));
                            cardMap.putString("verificationPayload", encryptedPayload);

                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "scanned");
                            map.putMap("payload", cardMap);
                            map.putString("scanId", scanId);

                            scanPromise.resolve(map);
                            scanPromise = null;
                        }

                        @Override
                        public void userMissingCard(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "user_missing_card");
                            map.putString("scanId", scanId);

                            scanPromise.resolve(map);
                            scanPromise = null;
                        }

                        @Override
                        public void userCanceled(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "user_canceled");
                            map.putString("scanId", scanId);

                            scanPromise.resolve(map);
                            scanPromise = null;
                        }

                        @Override
                        public void cameraError(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "camera_error");
                            map.putString("scanId", scanId);

                            scanPromise.resolve(map);
                            scanPromise = null;
                        }

                        @Override
                        public void analyzerFailure(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "fatal_error");
                            map.putString("scanId", scanId);

                            scanPromise.resolve(map);
                            scanPromise = null;
                        }

                        @Override
                        public void canceledUnknown(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "unknown");
                            map.putString("scanId", scanId);

                            scanPromise.resolve(map);
                            scanPromise = null;
                        }
                    });
                }
            }

            @Override
            public void onNewIntent(Intent intent) { }
        });
    }

    @Override
    @NotNull
    public String getName() {
        return "RNCardVerify";
    }

    @ReactMethod
    public void isSupportedAsync(Promise promise) {
        promise.resolve(true);
    }

    @ReactMethod
    public void scan(@Nullable String requiredCardIin, @Nullable String requiredCardLastFour, @NotNull Promise promise) {
        scanPromise = promise;

        final Intent intent = CardVerifyActivity.buildIntent(
                /* context */ this.reactContext.getApplicationContext(),
                /* apiKey */ apiKey,
                /* iin */ requiredCardIin,
                /* lastFour */ requiredCardLastFour,
                /* enableNameExtraction */ enableNameExtraction,
                /* enableExpiryExtraction */ enableExpiryExtraction,
                /* displayCardPan */ true,
                /* displayCardName */ true
        );
        this.reactContext.startActivityForResult(intent, SCAN_REQUEST_CODE, null);
    }
}
