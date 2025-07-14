//
//  UErrorMessage.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Represents an error
 */
@interface UErrorMessage: NSObject

/**
 The UErrorMessage 2.1.0 constructor shall create an UErrorMessage object.
 
 @param transactionID the transactionID
 @param errorCode code for the error
 @param errorDescription description of the error
 @param errorDetail details about the error
 @return UErrorMessage object
 */
- (nonnull UErrorMessage *)initWithTransactionID:(nonnull NSString *)transactionID
                                       errorCode:(nonnull NSString *)errorCode
                                errorDescription:(nonnull NSString *)errorDescription
                                     errorDetail:(nonnull NSString *)errorDetail;

/**
 The UErrorMessage 2.2.0 constructor shall create an UErrorMessage object

 @param errorCode code for the error
 @param errorComponent component that identified the error
 @param errorDescription description of the error
 @param errorDetail details about the error
 @param errorMessageType message type that was identified as erroneuos
 @param messageVersionNumber protocol version identier
 @return UErrorMessage object
 */
- (nonnull UErrorMessage *)initWithErrorCode:(nonnull NSString *)errorCode
                              errorComponent:(nonnull NSString *)errorComponent
                            errorDescription:(nonnull NSString *)errorDescription
                                 errorDetail:(nonnull NSString *)errorDetail
                            errorMessageType:(nonnull NSString *)errorMessageType
                        messageVersionNumber:(nonnull NSString *)messageVersionNumber
                                  sdkTransID:(nonnull NSString *)sdkTransID;

/**
 The getTransactionID method shall return the Transaction ID. The EMV® 3-D Secure 2.0 Protocol and Core Functions Specification defines the Transaction ID.
 
 @return the transaction ID
 */
- (nonnull NSString *)getTransactionID;

/**
 The getErrorCode method shall return the error code.
 
 @return the ErrorMessage's code
 */
- (nonnull NSString *)getErrorCode;

/**
 The getErrorDescription method shall return text describing the problem identified in the message. The EMV® 3-D Secure 2.0 Protocol and Core Functions Specification defines error descriptions for a transaction.

 @return the ErrorMessage's description
 */
- (nonnull NSString *)getErrorDescription;

/**
 The getErrorDetails method shall provide error details. The EMV® 3-D Secure 2.0 Protocol and Core Functions Specification defines error details for a transaction.
 
 @return the ErrorMessage's details
 */
- (nonnull NSString *)getErrorDetails;

@end
