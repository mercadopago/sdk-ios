//
//  USDKAnonymizedTextField.h
//  uSDK
//
//  Created by Drew Pitchford on 10/5/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface USDKAnonymizedTextField : UITextField

- (nonnull USDKAnonymizedTextField *)initWithFrame:(CGRect)frame;
- (nullable USDKAnonymizedTextField *)initWithCoder:(nonnull NSCoder *)coder;
- (nonnull USDKAnonymizedTextField *)init;
- (void)awakeFromNib;

@end

