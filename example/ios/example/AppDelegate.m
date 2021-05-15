/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

@import CardVerify;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"example"
                                            initialProperties:nil];

  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  [Bouncer configureWithApiKey:@"ENTER_API_KEY"];
  
  if (@available(iOS 11.2, *)) {
    UIImage *closeBtnImage = [UIImage imageNamed:@"outline_arrow_back_white_36pt.png"];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setImage:closeBtnImage forState:UIControlStateNormal];
    closeButton.tintColor = [UIColor whiteColor];
    [closeButton sizeToFit];
    
    UIImage *torchBtnImage = [UIImage imageNamed:@"outline_highlight_white_36pt.png"];
    UIButton *torchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [torchButton setImage:torchBtnImage forState:UIControlStateNormal];
    torchButton.tintColor = [UIColor whiteColor];
    [torchButton sizeToFit];
    
    VerifyCardAddViewController.descriptionString = @"description text";
    VerifyCardAddViewController.enableCameraPermissionString = @"enable camera";
    VerifyCardAddViewController.enableCameraPermissionsDescriptionString = @"enable camera description";
    VerifyCardAddViewController.torchButton = torchButton;
    VerifyCardAddViewController.closeButton = closeButton;
    
    VerifyCardViewController.descriptionString = @"description text";
    VerifyCardViewController.enableCameraPermissionString = @"enable camera";
    VerifyCardViewController.enableCameraPermissionsDescriptionString = @"enable camera description";
    VerifyCardViewController.torchButton = torchButton;
    VerifyCardViewController.closeButton = closeButton;
    VerifyCardViewController.wrongCardString = @"wrong card";
  }

  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
