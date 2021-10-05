package com.getbouncer;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.getbouncer.cardverify.ui.network.CardVerifyActivity;
import com.getbouncer.cardverify.ui.network.CardVerifyActivityResult;
import com.getbouncer.cardverify.ui.network.CardVerifyActivityResultHandler;
import com.getbouncer.scan.payment.card.PaymentCardUtils;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;

public class RNCardVerifyModule extends ReactContextBaseJavaModule {
    private static final int SCAN_REQUEST_CODE = 51235;

    public static String apiKey = null;
    public static boolean enableEnterCardManually = true;
    public static boolean enableMissingCard = true;
    public static boolean enableExpiryExtraction = true;
    public static boolean enableNameExtraction = true;
    public static boolean useLocalVerificationOnly = false;
    public static boolean deferModelDownloads = false;

    private final ReactApplicationContext reactContext;

    private Promise scanPromise;
    private Promise modelsDownloadPromise;
    private boolean modelsDownloaded = false;

    @Override
    public void initialize() {
        if (!deferModelDownloads) {
            downloadModels(null);
        }
    }

    public RNCardVerifyModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.reactContext.addActivityEventListener(new ActivityEventListener() {

            @Override
            public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
                if (requestCode == SCAN_REQUEST_CODE && useLocalVerificationOnly) {
                    com.getbouncer.cardverify.ui.local.CardVerifyActivity.parseVerifyResult(resultCode, data, new com.getbouncer.cardverify.ui.local.CardVerifyActivityResultHandler() {
                        @Override
                        public void cardScanned(
                            @NotNull String cardPan,
                            @Nullable String cardName,
                            @Nullable String cardExpiryMonth,
                            @Nullable String cardExpiryYear,
                            boolean isCardValid,
                            @Nullable String cardValidationFailureReason,
                            @Nullable String cardValidationDetails
                        ) {
                            final String issuer = PaymentCardUtils.getCardIssuer(cardPan).getDisplayName();
                            final WritableMap cardMap = new WritableNativeMap();
                            cardMap.putString("number", cardPan);
                            cardMap.putString("expiryDay", null);
                            cardMap.putString("expiryMonth", cardExpiryMonth);
                            cardMap.putString("expiryYear", cardExpiryYear);
                            cardMap.putString("issuer", issuer);
                            cardMap.putString("cvc", null);
                            cardMap.putString("cardholderName", cardName);
                            cardMap.putString("payloadVersion", "2");
                            cardMap.putString("verificationPayload", null);
                            cardMap.putBoolean("isCardValid", isCardValid);
                            cardMap.putString("cardValidationFailureReason", cardValidationFailureReason);

                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "scanned");
                            map.putMap("payload", cardMap);

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void userCanceled() {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "user_canceled");

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void userMissingCard() {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "user_missing_card");

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void enterManually() {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "enter_card_manually");

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void cameraError() {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "camera_error");

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void analyzerFailure() {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "fatal_error");

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void canceledUnknown() {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "unknown");

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }
                    });
                } else if (requestCode == SCAN_REQUEST_CODE) {
                    CardVerifyActivity.parseVerifyResult(resultCode, data, new CardVerifyActivityResultHandler() {
                        @Override
                        public void cardScanned(
                            @Nullable String scanId,
                            @Nullable String instanceId,
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

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void enterManually(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "enter_card_manually");
                            map.putString("scanId", scanId);

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void userMissingCard(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "user_missing_card");
                            map.putString("scanId", scanId);

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void userCanceled(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "user_canceled");
                            map.putString("scanId", scanId);

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void cameraError(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "camera_error");
                            map.putString("scanId", scanId);

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void analyzerFailure(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "fatal_error");
                            map.putString("scanId", scanId);

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
                        }

                        @Override
                        public void canceledUnknown(String scanId) {
                            final WritableMap map = new WritableNativeMap();
                            map.putString("action", "canceled");
                            map.putString("canceledReason", "unknown");
                            map.putString("scanId", scanId);

                            if (scanPromise != null) {
                                scanPromise.resolve(map);
                                scanPromise = null;
                            }
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
    public void awaitReady(@NotNull final Promise promise) {
        // Force this to the UI thread to avoid a race condition with [handleModelsDownloaded]
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (modelsDownloaded) {
                    promise.resolve(true);
                } else {
                    modelsDownloadPromise = promise;
                }
            }
        });
    }

    @ReactMethod
    public void downloadModels(@Nullable final Promise promise) {
        if (useLocalVerificationOnly) {
            com.getbouncer.cardverify.ui.local.CardVerifyActivity.prepareScan(this.reactContext.getApplicationContext(), apiKey, enableExpiryExtraction || enableNameExtraction, false, new Function0<Unit>() {
                @Override
                public Unit invoke() {
                    handleModelsDownloaded(promise);
                    return Unit.INSTANCE;
                }
            });
        } else {
            CardVerifyActivity.prepareScan(this.reactContext.getApplicationContext(), apiKey, enableExpiryExtraction || enableNameExtraction, false, new Function0<Unit>() {
                @Override
                public Unit invoke() {
                    handleModelsDownloaded(promise);
                    return Unit.INSTANCE;
                }
            });
        }
    }

    private void handleModelsDownloaded(@Nullable final Promise promise) {
        // Force this to the UI thread to avoid a race condition with [awaitReady]
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                modelsDownloaded = true;
                if (promise != null) {
                    promise.resolve(true);
                }
                if (modelsDownloadPromise != null) {
                    modelsDownloadPromise.resolve(true);
                }
            }
        });
    }

    @ReactMethod
    public void scan(@Nullable String requiredCardIin, @Nullable String requiredCardLastFour, Boolean skipVerificationOnDownloadFailure, @NotNull Promise promise) {
        scanPromise = promise;

        final Intent intent;
        if (useLocalVerificationOnly) {
            intent = com.getbouncer.cardverify.ui.local.CardVerifyActivity.buildIntent(
                /* context */ this.reactContext.getApplicationContext(),
                /* iin */ requiredCardIin,
                /* lastFour */ requiredCardLastFour,
                /* enableEnterCardManually */ enableEnterCardManually,
                /* enableMissingCard */ enableMissingCard,
                /* enableNameExtraction */ enableNameExtraction,
                /* enableExpiryExtraction */ enableExpiryExtraction
            );
        } else {
            intent = CardVerifyActivity.buildIntent(
                /* context */ this.reactContext.getApplicationContext(),
                /* apiKey */ apiKey,
                /* iin */ requiredCardIin,
                /* lastFour */ requiredCardLastFour,
                /* enableEnterCardManually */ enableEnterCardManually,
                /* enableMissingCard */ enableMissingCard,
                /* enableNameExtraction */ enableNameExtraction,
                /* enableExpiryExtraction */ enableExpiryExtraction,
                /* skipVerificationOnDownloadFailure */ skipVerificationOnDownloadFailure
            );
        }
        this.reactContext.startActivityForResult(intent, SCAN_REQUEST_CODE, null);
    }
}
