//
//  UButtonType.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/30/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

/**
 Identifies the type of button

 - UButtonTypeSubmitSubmit: a `submit` button
 - UButtonTypeContinue: a `continue` button
 - UButtonTypeNext: a `next` button
 - UButtonTypeCancel: a `cancel` button
 - UButtonTypeResend: a `resend` button
 */
typedef NS_ENUM(NSInteger, UButtonType) {
    
    UButtonTypeSubmit,
    UButtonTypeContinue,
    UButtonTypeNext,
    UButtonTypeCancel,
    UButtonTypeResend
};
