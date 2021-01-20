#import "RNCardVerify.h"
#import <React/RCTBridgeDelegate.h>
@import Foundation;
@import CardVerify;

//MARK: - Verify View Delegate Implementation
@implementation VerifyViewDelegate
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

- (void)fraudModelResultsVerifyCardWithViewController:(VerifyCardViewController * _Nonnull)viewController creditCard:(CreditCard * _Nonnull)creditCard encryptedPayload:(NSString * _Nullable)encryptedPayload extraData:(NSDictionary<NSString *,id> * _Nonnull)extraData {
    [self dismissView];
    self.resolve(@{@"action" : @"scanned",
                   @"payload": @{
                       @"number": creditCard.number,
                       @"cardholderName": creditCard.name ?: [NSNull null],
                       @"expiryMonth": creditCard.expiryMonth ?: [NSNull null],
                       @"expiryYear": creditCard.expiryYear ?: [NSNull null],
                       @"payloadVersion": @"1",
                       @"verificationPayload": encryptedPayload ?: [NSNull null]
                    }});
}

- (void)userCanceledVerifyCardWithViewController:(VerifyCardViewController * _Nonnull)viewController {
    [self dismissView];
    self.resolve(@{ @"action": @"canceled",
                    @"canceledReason": @"user_canceled"});
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
        self.verifyViewDelegate = [[VerifyViewDelegate alloc] init];
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
    [self.verifyViewDelegate setCallback:resolve];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 11.2, *)) {
            UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

            while (topViewController.presentedViewController) {
                topViewController = topViewController.presentedViewController;
            }
            
            VerifyCardViewController *vc = [[VerifyCardViewController alloc] initWithUserId:nil lastFour:requiredLastFour bin:requiredIin];
            vc.verifyCardDelegate = self.verifyViewDelegate;
            
            [topViewController presentViewController:vc animated:NO completion:nil];
        } else {
            // Fallback on earlier versions
        }
    });
}

@end
