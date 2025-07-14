//
//  uRuntimeErrorMessage.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
Event that is passed to ChallengeStatusReceiver in the event of a runtime error
*/
@interface URuntimeErrorEvent : NSObject

/**
 The URuntimeErrorEvent constructor shall create an object with the specified inputs.
 
 @param errorCode the error code
 @param errorMessage the error message
 @return RuntimErrorEvent object
 */
- (nonnull URuntimeErrorEvent *)initWithErrorCode:(nonnull NSString *)errorCode
                                     errorMessage:(nonnull NSString *)errorMessage;

/**
 Returns details about the error.
 
 @return the error message
 */
- (nonnull NSString *)getErrorMessage;

/**
 The getErrorCode method shall return the implementer-specific error code.
 
 @return the error code
 */
- (nonnull NSString *)getErrorCode;

@end
