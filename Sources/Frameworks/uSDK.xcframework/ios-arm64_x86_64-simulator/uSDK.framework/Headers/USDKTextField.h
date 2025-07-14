//
//  USDKTextField.h
//  uSDK
//
//  Created by Drew Pitchford on 9/29/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USDKTextField : UITextField

- (nonnull USDKTextField *)initWithFrame:(CGRect)frame;
- (nullable USDKTextField *)initWithCoder:(nonnull NSCoder *)coder;
- (nonnull USDKTextField *)init;
- (void)awakeFromNib;

@end
