//
//  UCompletionEvent.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
The event that is passed back to ChallengeStatusReceiver upon completion of a challenge
*/
@interface UCompletionEvent: NSObject

/**
 The CompletionEvent class shall hold data about completion of the challenge process.
 
 @param sdkTransactionID the sdk's transaction ID
 @param transactionStatus the transaction status
 */
- (nonnull UCompletionEvent *)initWithsdkTransactionID:(nonnull NSString *)sdkTransactionID
                                     transactionStatus:(nonnull NSString *)transactionStatus;

/**
 The getSdkTransactionID method shall return the 3DS SDK transaction ID. The EMV® 3-D Secure 2.0 Protocol and Core Functions Specification defines this transaction ID.
 
 @return the sdk transaction ID
 */
- (nonnull NSString *)getSDKTransactionID;

/**
 The getTransactionStatus method shall return a string with the transaction status that was received in the CRes.
 
 @return the transaction status
 */
- (nonnull NSString *)getTransactionStatus;

@end

