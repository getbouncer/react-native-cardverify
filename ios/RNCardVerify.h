#import <React/RCTBridgeModule.h>
@import CardVerify;

@interface VerifyCardDelegate : NSObject <VerifyCardResult>

@property RCTPromiseResolveBlock resolve;

- (void)setCallback:(RCTPromiseResolveBlock)resolve;
- (void)dismissView;

@end

@interface VerifyCardAddDelegate : NSObject <VerifyCardAddResult>

@property RCTPromiseResolveBlock resolve;

- (void)setCallback:(RCTPromiseResolveBlock)resolve;
- (void)dismissView;

@end

@interface RNCardVerify : NSObject <RCTBridgeModule>

@property (nonatomic) VerifyCardDelegate * verifyCardDelegate;
@property (nonatomic) VerifyCardAddDelegate * verifyCardAddDelegate;

@end
