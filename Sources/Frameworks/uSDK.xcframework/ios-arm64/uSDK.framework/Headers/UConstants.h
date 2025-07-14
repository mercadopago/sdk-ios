//Copyright © mSIGNIA, Incorporated, 2007.  All rights reserved.
//
//Software is protected by one or more of U.S. Patent No. 9,559,852, 9294448, 8,817,984,
//international patents and others pending. For more information see www.mSIGNIA.com.  User agrees
//that they will not them self, or through any affiliate, agent or other third-party, entity or
//other business structure remove, alter, cover or obfuscate any copyright notices or other
//proprietary rights notices of mSIGNIA or its licensors.  User agrees that they will not them
//self, or through any affiliate, agent or other third party, entity or other business structure
//(a) reproduce, sell, lease, license or sublicense this software or any part thereof, (b)
//decompile, disassemble, re-program, reverse engineer or otherwise attempt to derive or modify
//this software in whole or in part, (c) write or develop any derivative software or any other
//software program based upon this software, (d) provide, copy, transmit, disclose, divulge, or
//make available to, or permit use of this software by any third party or entity or machine without
//software owner's prior written consent, (e) circumvent or disable any security or other
//technological features or measures used by this software.
//
//  uConstants.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 11/21/17.
//  Copyright © 2017 MSIGNIA. All rights reserved.
//

/**
 Key for error messages passed in an NSError's userInfo dictionary
*/
static NSString * const kUSDKErrorUserInfoMessageKey = @"message";

/**
 Key for error code passed in an NSError's userInfo dictionary
 */
static NSString * const kUSDKErrorUserInfoCodeKey = @"code";

/**
 The group that mSigniaSDK uses to look for client information
 */
static NSString * const kUConfigParamGroup = @"com.u.3ds";

/**
 The name that mSigniaSDK uses to look for client information within the group
 */
static NSString * const kUConfigParamNameDSPublicKeys = @"ds-public-keys";

/**
 A key for the DS ID value passed by the client
 */
static NSString * const kUConfigParamDSID = @"dsId";

/**
 A key for the public key value passed by the client
 */
static NSString * const kUConfigParamPublicKey = @"publicKey";

/**
 A key for the key ID value passed by the client
 */
static NSString * const kUConfigParamKeyIDKey = @"keyID";

/**
 A key for the bins value passed by the client
 */
static NSString * const kUConfigParamBins = @"bins";

/**
 A key for the Fido registration page url passed by the client
 */
static NSString * const kUConfigParamRegistrationURL = @"usdk-webauthn-registration-url";

/**
 A key for the Fido login page url passed by the client
 */
static NSString * const kUConfigParamLoginURL = @"usdk-webauthn-login-url";

/**
 A key for the callback url scheme to be utilized by the Fido web app upon completion
 */
static NSString * const kUConfigParamCallbackURL = @"usdk-webauthn-callback-url";

/**
 A key for disabling acsSignedContent verification. To turn verification off, put this key in the MSConfigParams object passed to the SDK.
 To turn verification on, omit this key from the MSConfigParams object.
*/
static NSString * const kUConfigParamsDisableVerifyACSSignedContentKey = @"acs_signed_content_verifying_key";

/**
 A group to put client input into.
 */
static NSString * const kUUSDKGroup = @"usdk.config";

/**
 A key for adding the license key when initializing the SDK
 */
static NSString * const kUUSDKParamLicenseKey = @"license-key";

/**
 A key for passing a deviceInfo attributes exclude list
 */
static NSString * const kUUSDKParamDeviceInfoExcludeList = @"device-info-exclude-list";

/**
 For UL
 */
static NSString * const kUVCDisplayed = @"sdk_vc_is_displayed";

