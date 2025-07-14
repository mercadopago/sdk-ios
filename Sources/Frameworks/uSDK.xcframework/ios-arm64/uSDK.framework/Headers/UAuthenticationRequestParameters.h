//
//  UAuthenticationRequestParameters.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Contains AReq parameters
 */
@interface UAuthenticationRequestParameters: NSObject

/**
 The AuthenticationRequestParameters constructor shall create an object that shall be used by the Merchant App
 to obtain the required authentication parameters for AReq processing. Under normal circumstances, this should
 not need to be called.
 
 @param sdkTransactionID The SDK's transactionID
 @param deviceData Device data that is gathered by the SDK
 @param sdkEphemeralPublicKey The publick key used to encrypt the device data
 @param sdkAppID The SDK's appID
 @param sdkReferenceNumber The SDK's reference number
 @return AuthenticationRequestParameters object
 */
- (nonnull id)initWithSDKTransactionId:(nonnull NSString *)sdkTransactionID
                            deviceData:(nonnull NSString *)deviceData
                 sdkEphemeralPublicKey:(nonnull NSString *)sdkEphemeralPublicKey
                              sdkAppID:(nonnull NSString *)sdkAppID
                    sdkReferenceNumber:(nonnull NSString *)sdkReferenceNumber
                        messageVersion:(nonnull NSString *)messageVersion;

/**
 The SDK's transactionID
 */
- (nonnull NSString *)getSDKTransactionID;
/**
 Device data gathered by the SDK
 */
- (nonnull NSString *)getDeviceData;
/**
 The public key used to encrypt the device data
 */
- (nonnull NSString *)getSDKEphemeralPublicKey;
/**
 the SDK's appID
 */
- (nonnull NSString *)getSDKAppID;
/**
 The SDK's reference number
 */
- (nonnull NSString *)getSDKReferenceNumber;
/**
 The 3DS message version being sent by the SDK.
 */
- (nonnull NSString *)getMessageVersion;

/*
 The SDK's type
 */
- (nonnull NSString *)getSDKType;

@end
