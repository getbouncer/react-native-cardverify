#import <React/RCTBridgeModule.h>
@import CardScan;
@import CardVerify;

@interface ScanViewDelegate : NSObject <ScanDelegate>

@property RCTPromiseResolveBlock resolve;

- (void)setCallback:(RCTPromiseResolveBlock)resolve;
- (void)dismissView;

@end

@interface VerifyViewDelegate : NSObject <CardVerifySimpleResults>

@property RCTPromiseResolveBlock resolve;

- (void)setCallback:(RCTPromiseResolveBlock)resolve;
- (void)dismissView;

@end

@interface RNCardscan : NSObject <RCTBridgeModule>

@property (nonatomic) ScanViewDelegate * scanViewDelegate;
@property (nonatomic) VerifyViewDelegate * verifyViewDelegate;

@end
