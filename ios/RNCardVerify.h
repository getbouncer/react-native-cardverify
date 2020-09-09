#import <React/RCTBridgeModule.h>
@import CardVerify;

@interface VerifyViewDelegate : NSObject <CardVerifySimpleResults>

@property RCTPromiseResolveBlock resolve;

- (void)setCallback:(RCTPromiseResolveBlock)resolve;
- (void)dismissView;

@end

@interface RNCardVerify : NSObject <RCTBridgeModule>

@property (nonatomic) VerifyViewDelegate * verifyViewDelegate;

@end