//
//  ProtocolErrorEvent.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UErrorMessage;

/**
 The event that is passed back to ChallengeStatusReceiver if a Protocol Error has occurred
 */
@interface UProtocolErrorEvent: NSObject

/**
 The ProtocolErrorEvent constructor shall create an object with the specified inputs.
 
 @param sdkTransactionID sdk Transaction ID
 @param errorMessage a UErrorMessage object
 */
- (nonnull UProtocolErrorEvent *)initWithSDKTransactionID:(nonnull NSString *)sdkTransactionID
                                             errorMessage:(nonnull UErrorMessage *)errorMessage;

/**
 The getSdkTransactionId method shall return the 3DS SDK Transaction ID.
 
 @return sdk transaction ID
 */
- (nonnull NSString *)getSDKTransactionID;

/**
 The getErrorMessage method shall return the error message.
 
 @return a UErrorMessage object
 */
- (nonnull UErrorMessage *)getErrorMessage;

@end
