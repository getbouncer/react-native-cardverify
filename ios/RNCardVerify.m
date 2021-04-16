#import "RNCardVerify.h"
#import <React/RCTBridgeDelegate.h>
@import Foundation;
@import CardVerify;

//MARK: - Verify Card Delegate Implementation
@implementation VerifyCardDelegate
    - (void)setCallback:(RCTPromiseResolveBlock)resolve {
        self.resolve = resolve;
    }

    - (void)dismissView {
        UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

        while (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        }
        
        [topViewController dismissViewControllerAnimated:YES completion:nil];
    }

- (void)fraudModelResultsVerifyCardWithViewController:(VerifyCardViewController * _Nonnull)viewController creditCard:(CreditCard * _Nonnull)creditCard encryptedPayload:(NSString * _Nullable)encryptedPayload extraData:(NSDictionary<NSString *,id> * _Nonnull)extraData  API_AVAILABLE(ios(11.2)){
    [self dismissView];
    
    NSMutableDictionary *resolveDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *payloadDict = [[NSMutableDictionary alloc] init];
    resolveDict[@"action"] = @"scanned";
    
    payloadDict[@"number"] = creditCard.number;
    payloadDict[@"cardholderName"] = creditCard.name ?: [NSNull null];
    payloadDict[@"expiryMonth"] = creditCard.expiryMonth ?: [NSNull null];
    payloadDict[@"expiryYear"] = creditCard.expiryYear ?: [NSNull null];
    payloadDict[@"payloadVersion"] = @"1";
    
    if (Bouncer.useLocalVerificationOnly) {
        payloadDict[@"verificationPayload"] = [NSNull null];
        payloadDict[@"isCardValid"] = extraData[@"isCardValid"];
        payloadDict[@"cardValidationFailureReason"] = extraData[@"validationFailureReason"] ?: [NSNull null];
    } else {
        payloadDict[@"verificationPayload"] = encryptedPayload ?: [NSNull null];
    }
    
    resolveDict[@"payload"] = payloadDict;
    self.resolve(resolveDict);
}

- (void)userCanceledVerifyCardWithViewController:(VerifyCardViewController * _Nonnull)viewController  API_AVAILABLE(ios(11.2)){
    [self dismissView];
    self.resolve(@{ @"action": @"canceled",
                    @"canceledReason": @"user_canceled"});
}
@end

//MARK: - Verify Card Add Delegate Implementation
@implementation VerifyCardAddDelegate

- (void)setCallback:(RCTPromiseResolveBlock)resolve {
    self.resolve = resolve;
}

- (void)dismissView {
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    
    [topViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidCancelCardAdd:(UIViewController * _Nonnull)viewController API_AVAILABLE(ios(11.2)){
    [self dismissView];
    self.resolve(@{ @"action": @"canceled",
                    @"canceledReason": @"user_canceled"});
}

- (void)userDidPressManualCardAdd:(UIViewController * _Nonnull)viewController API_AVAILABLE(ios(11.2)){
    [self dismissView];
    self.resolve(@{ @"action": @"skipped" });
}

- (void)userDidScanCardAdd:(UIViewController * _Nonnull)viewController creditCard:(CreditCard * _Nonnull)creditCard API_AVAILABLE(ios(11.2)){
}

-(void)fraudModelResultsVerifyCardAddWithViewController:(UIViewController *)viewController creditCard:(CreditCard *)creditCard encryptedPayload:(NSString *)encryptedPayload extraData:(NSDictionary<NSString *,id> *)extraData API_AVAILABLE(ios(11.2)){
    [self dismissView];
    
    NSMutableDictionary *resolveDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *payloadDict = [[NSMutableDictionary alloc] init];
    resolveDict[@"action"] = @"scanned";
    
    payloadDict[@"number"] = creditCard.number;
    payloadDict[@"cardholderName"] = creditCard.name ?: [NSNull null];
    payloadDict[@"expiryMonth"] = creditCard.expiryMonth ?: [NSNull null];
    payloadDict[@"expiryYear"] = creditCard.expiryYear ?: [NSNull null];
    payloadDict[@"payloadVersion"] = @"1";
    
    if (Bouncer.useLocalVerificationOnly) {
        payloadDict[@"verificationPayload"] = [NSNull null];
        payloadDict[@"isCardValid"] = extraData[@"isCardValid"];
        payloadDict[@"cardValidationFailureReason"] = extraData[@"validationFailureReason"] ?: [NSNull null];
    } else {
        payloadDict[@"verificationPayload"] = encryptedPayload ?: [NSNull null];
    }
    
    resolveDict[@"payload"] = payloadDict;
    self.resolve(resolveDict);
}

@end

//MARK: -RNCardVerify Module Implementation
@implementation RNCardVerify

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (id)init {
    if(self = [super init]) {
        self.verifyCardDelegate = [[VerifyCardDelegate alloc] init];
        self.verifyCardAddDelegate = [[VerifyCardAddDelegate alloc] init];
    }
    return self;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(isSupportedAsync:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    resolve(@([Bouncer isCompatible]));
}


RCT_EXPORT_METHOD(scan:(NSString * _Nullable)requiredIin requiredLastFour:(NSString * _Nullable)requiredLastFour skipVerificationOnModelDownloadFailure:(BOOL)skipVerificationOnModelDownloadFailure  :(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject)
{
    [self.verifyCardDelegate setCallback:resolve];
    [self.verifyCardAddDelegate setCallback:resolve];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 11.2, *)) {
            UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

            while (topViewController.presentedViewController) {
                topViewController = topViewController.presentedViewController;
            }
            
            if (requiredIin == NULL && requiredLastFour == NULL) {
                VerifyCardAddViewController *vc = [[VerifyCardAddViewController alloc] initWithUserId:@""];
                vc.cardAddDelegate = self.verifyCardAddDelegate;
                [topViewController presentViewController:vc animated:NO completion:nil];
            } else {
                VerifyCardViewController *vc = [[VerifyCardViewController alloc] initWithUserId:nil lastFour:requiredLastFour bin:requiredIin];
                vc.verifyCardDelegate = self.verifyCardDelegate;
                [topViewController presentViewController:vc animated:NO completion:nil];
            }
        }
    });
}

@end
