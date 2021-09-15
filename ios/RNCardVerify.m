//
//  RCTCardVerify.m
//  RNCardVerify
//
//  Created by Jaime Park on 7/12/21.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(RNCardVerify, NSObject)
RCT_EXTERN_METHOD(isSupportedAsync:(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(scan:(NSString * _Nullable)requiredIin
                  :(NSString * _Nullable)requiredLastFour
                  :(BOOL)skipVerificationOnModelDownloadFailure
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(setiOSVerifyViewStyle:(NSDictionary)styleDictionary)
RCT_EXTERN_METHOD(downloadModels)
@end
