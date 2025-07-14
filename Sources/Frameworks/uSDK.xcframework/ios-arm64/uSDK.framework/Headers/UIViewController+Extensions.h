//
//  UIViewController+Extensions.h
//  uSDK
//
//  Created by Drew Pitchford on 9/29/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (USDKVCExtensions)

- (void)u_startCollectingTouchData;
- (void)u_stopCollectingData;

@end
