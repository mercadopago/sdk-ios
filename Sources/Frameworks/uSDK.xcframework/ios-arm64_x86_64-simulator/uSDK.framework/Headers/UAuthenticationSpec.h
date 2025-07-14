//
//  UAuthenticationSpec.h
//  uSDK
//
//  Created by Drew Pitchford on 6/2/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPurchaseInfo.h"

@interface UAuthenticationSpec : NSObject

/**
 * Initializer that takes all parameters
 * @param cardId The card's id
 * @param purchaseInfo an object that conforms to the UPurchaseInfo protocol
 * @param isPaymentAuthentication true if transaction is a payment authentication; false otherwise
 * @param supportedVersionsURL the url to get supported versions of the message specification to use
 * @param authURL the url that the AReq will be sent to
 * @param authorizationHeaders any headers needed to the AReq request
 */
- (nonnull UAuthenticationSpec *)initWithCardId:(nonnull NSString *)cardId
                                   purchaseInfo:(id<UPurchaseInfo> _Nonnull)purchaseInfo
                        isPaymentAuthentication:(BOOL)isPaymentAuthentication
                           supportedVersionsURL:(nonnull NSString *)supportedVersionsURL
                                        authURL:(nonnull NSString *)authURL
                         threeDSRequestorAppURL:(nonnull NSString *)threeDSRequestorAppURL
                           authorizationHeaders:(nullable NSDictionary <NSString *, NSString *> *)authorizationHeaders;

/**
* Initializer that takes all parameters
* @param cardId The card's id
* @param purchaseInfo an object that conforms to the UPurchaseInfo protocol
* @param supportedVersionsURL the url to get supported versions of the message specification to use
* @param authURL the url that the AReq will be sent to
* @param authorizationHeaders any headers needed to the AReq request
*/
- (nonnull UAuthenticationSpec *)initWithCardId:(nonnull NSString *)cardId
                                   purchaseInfo:(id<UPurchaseInfo> _Nonnull)purchaseInfo
                           supportedVersionsURL:(nonnull NSString *)supportedVersionsURL
                                        authURL:(nonnull NSString *)authURL
                         threeDSRequestorAppURL:(nonnull NSString *)threeDSRequestorAppURL
                           authorizationHeaders:(nullable NSDictionary <NSString *, NSString *> *)authorizationHeaders;

/**
* Initializer that takes all parameters
* @param cardId The card's id
* @param purchaseInfo an object that conforms to the UPurchaseInfo protocol
* @param isPaymentAuthentication true if transaction is a payment authentication; false otherwise
* @param supportedVersionsURL the url to get supported versions of the message specification to use
* @param authURL the url that the AReq will be sent to
*/
- (nonnull UAuthenticationSpec *)initWithCardId:(nonnull NSString *)cardId
                                   purchaseInfo:(id<UPurchaseInfo> _Nonnull)purchaseInfo
                        isPaymentAuthentication:(BOOL)isPaymentAuthentication
                           supportedVersionsURL:(nonnull NSString *)supportedVersionsURL
                                        authURL:(nonnull NSString *)authURL
                         threeDSRequestorAppURL:(nonnull NSString *)threeDSRequestorAppURL;


/**
* Initializer that takes all parameters
* @param cardId The card's id
* @param purchaseInfo an object that conforms to the UPurchaseInfo protocol
* @param supportedVersionsURL the url to get supported versions of the message specification to use
* @param authURL the url that the AReq will be sent to
*/
- (nonnull UAuthenticationSpec *)initWithCardId:(nonnull NSString *)cardId
                                   purchaseInfo:(id<UPurchaseInfo> _Nonnull)purchaseInfo
                           supportedVersionsURL:(nonnull NSString *)supportedVersionsURL
                                        authURL:(nonnull NSString *)authURL
                         threeDSRequestorAppURL:(nonnull NSString *)threeDSRequestorAppURL
;


#pragma mark Setters
- (void)setCardId:(nonnull NSString *)cardId;
- (void)setPurchaseInfo:(nonnull id<UPurchaseInfo>)purchaseInfo;
- (void)setIsPaymentAuthentication:(BOOL)isPaymentAuthentication;
- (void)setSupportedVersionsURL:(nonnull NSString *)supportedVersionURL;
- (void)setAuthURL:(nonnull NSString *)authURL;
- (void)setAuthorizationHeaders:(nullable NSDictionary <NSString *, NSString *> *)authorizationHeaders;
- (void)setThreeDSREquestorAppURL:(nonnull NSString *)threeDSRequestorAppURL;

#pragma mark Getters
- (nonnull NSString *)getCardId;
- (nonnull id<UPurchaseInfo>)getPurchaseInfo;
- (BOOL)getIsPaymentAuthentication;
- (nonnull NSString *)getSupportedVersionsURL;
- (nonnull NSString *)getAuthURL;
- (nullable NSDictionary <NSString *, NSString *> *)getAuthorizationHeaders;
- (nonnull NSString *)getThreeDSRequestorAppURL;

@end

