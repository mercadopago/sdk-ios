//
//  UChallengeParameters.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/30/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Represents parameters for a CReq
 */
@interface UChallengeParameters: NSObject

/**
 Challenge Parameters constructor

 @param threeDSServerTransactionID The 3DS server's transactionID for the transaction
 @param acsTransactionID The ACS server's transactionID for the the transaction
 @param acsRefNumber The ACS's reference number for the transaction
 @param acsSignedContent Encrypted and signed content sent by the ACS
 @return ChallengeParamters object
 */
- (nonnull UChallengeParameters *)initWithThreeDSServerTransactionID:(nonnull NSString *)threeDSServerTransactionID
                                                    acsTransactionID:(nonnull NSString *)acsTransactionID
                                                        acsRefNumber:(nullable NSString *)acsRefNumber
                                                    acsSignedContent:(nonnull NSString *)acsSignedContent;

/**
 The set3DSServerTransactionID method shall set the 3DS Server Transaction ID. This ID is a transaction identifier assigned by the 3DS Server to uniquely identify a single transaction
 
 @param threeDSServerTransactionID transaction identifier assigned by the 3DS Server to uniquely identify a single transaction.
 */
- (void)set3DSServerTransactionID:(nonnull NSString *)threeDSServerTransactionID;

/**
 The setACSSignedContent method shall set the ACS signed content. This content includes the ACS ephemeral public key, ACS URL, and authentication type.
 
 @param signedContent JWS signed ACS data. This data includes the ACS ephemeral public key, ACS URL, and authentication type.
 */
- (void)setACSSignedContent:(nonnull NSString *)signedContent;

/**
 The setAcsRefNumber method shall set the ACS Reference Number.
 
 @param acsRefNumber unique identifier for the ACS that is assigned by EMVCo through the 3DS 2.0 Testing and Approvals process when the ACS is approved.
 */
- (void)setAcsRefNumber:(NSString * _Nonnull)acsRefNumber;

/**
 * sets the ACS Trans ID
 * @param acsTransactionID the id to be set
 */
- (void)setAcsTransactionID:(nonnull NSString *)acsTransactionID;

/**
 Sets the 3DS Requestor App URL

 @param threeDSRequestorAppURL the url to be set
 */
- (void)setThreeDSRequestorAppURL:(NSString * _Nonnull)threeDSRequestorAppURL;

/**
 The get3DSServerTransactionID method shall return the 3DS Server Transaction ID.
 
 @return 3DS server transaction ID
 */
- (nonnull NSString *)get3DSServerTransactionID;

/**
 The getAcsTransactionID method shall return the ACS Transaction ID.
 */
- (nonnull NSString *)getAcsTransactionID;

/**
 The getAcsRefNumber method shall return the ACS Reference Number.
 
 @return ACSRefNumber
 */
- (nullable NSString *)getAcsRefNumber;

/**
 The getACSSignedContent method shall return the signed ACS data object.
 
 @return ACS Signed Content
 */
- (nonnull NSString *)getACSSignedContent;

/**
 Returns the 3DS Requestor App URL

 @return the 3DS Requestor App URL
 */
- (nonnull NSString *)getThreeDSRequestorAppURL;

/*
 Custom signatures that better utilize data and/or help Swift developers with do-try-catch
 */
/**
 ChallengeParameters constructor that throws if there is an error. This is for Swift do-try-catch

 @param threeDSServerTransactionID The 3DS server's transactionID for the transaction
 @param acsTransactionID The ACS server's transactionID for the the transaction
 @param acsRefNumber The ACS's reference number for the transaction
 @param acsSignedContent Encrypted and signed content sent by the ACS
 @return ChallengeParamters object
 */
- (nullable UChallengeParameters *)initThrowableThreeDSServerTransactionID:(NSString *_Nonnull)threeDSServerTransactionID
                                                          acsTransactionID:(NSString *_Nonnull)acsTransactionID
                                                              acsRefNumber:(NSString *_Nullable)acsRefNumber
                                                          acsSignedContent:(NSString *_Nonnull)acsSignedContent
                                                                     error:(NSError *_Nullable *_Nullable)error NS_SWIFT_NAME(init(threeDSTransID:acsTransactionID:acsRefNumber:acsSignedContent:));

/**
 The set3DSServerTransactionID method shall set the 3DS Server Transaction ID. This ID is a transaction identifier assigned by the 3DS Server to uniquely identify a single transaction
 
 @param threeDSServerTransactionID transaction identifier assigned by the 3DS Server to uniquely identify a single transaction.
 @param error Throws NSError if threeDSServerTransactionID is empty
 */
- (BOOL)u_set3DSServerTransactionID:(nonnull NSString *)threeDSServerTransactionID
                              error:(NSError *_Nullable *_Nullable)error;
/**
 The setAcsRefNumber method shall set the ACS Reference Number.
 
 @param refNumber unique identifier for the ACS that is assigned by EMVCo through the 3DS 2.0 Testing and Approvals process when the ACS is approved.
 @param error Throws NSError if acsRefNumber is empty
 */
- (BOOL)u_setAcsRefNumber:(nonnull NSString *)refNumber
                    error:(NSError *_Nullable *_Nullable)error;
/**
 The setACSSignedContent method shall set the ACS signed content. This content includes the ACS ephemeral public key, ACS URL, and authentication type.
 
 @param signedContent JWS signed ACS data. This data includes the ACS ephemeral public key, ACS URL, and authentication type.
 @param error Throws NSError if signedContent is empty
 */
- (BOOL)u_setACSSignedContent:(nonnull NSString *)signedContent
                        error:(NSError *_Nullable *_Nullable)error;

@end

