//
//  UInitSpec.h
//  uSDK
//
//  Created by Drew Pitchford on 6/2/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UConfigParameters, UUiCustomization;

@interface UInitSpec : NSObject

/**
 Init method for UInitSpec that takes both required params
 @param licenseKey your license key
 @param configParameters config parameters for the 3DS SDK as defined in the EMVCo 3DS Spec
 */
- (nonnull UInitSpec *)initWithLicenseKey:(nonnull NSString *)licenseKey
                         configParameters:(nonnull UConfigParameters *)configParameters;

/**
Init method for UInitSpec that takes both required params and optional UICustomization
@param licenseKey your license key
@param uiCustomization the UI customization for the 3DS SDK as defined in the EMVCo 3DS Spec
@param configParameters config parameters for the 3DS SDK as defined in the EMVCo 3DS Spec
*/
- (nonnull UInitSpec *)initWithLicenseKey:(nonnull NSString *)licenseKey
                          uiCustomization:(nullable UUiCustomization *)uiCustomization
                         configParameters:(nonnull UConfigParameters *)configParameters;

/**
Init method for UInitSpec that takes both required params and optional locale
@param licenseKey your license key
@param locale the locale of your app
@param configParameters config parameters for the 3DS SDK as defined in the EMVCo 3DS Spec
*/
- (nonnull UInitSpec *)initWithLicenseKey:(nonnull NSString *)licenseKey
                                   locale:(nullable NSString *)locale
                         configParameters:(nonnull UConfigParameters *)configParameters;

/**
Init method for UInitSpec that takes all params
@param licenseKey your license key
 @param locale the locale of your app
 @param uiCustomization the UI customization for the 3DS SDK as defined in the EMVCo 3DS Spec
@param configParameters config parameters for the 3DS SDK as defined in the EMVCo 3DS Spec
*/
- (nonnull UInitSpec *)initWithLicenseKey:(nonnull NSString *)licenseKey
                                   locale:(nullable NSString *)locale
                          uiCustomization:(nullable UUiCustomization *)uiCustomization
                         configParameters:(nonnull UConfigParameters *)configParameters;

#pragma mark Setters
- (void)setLicenseKey:(nonnull NSString *)licenseKey;
- (void)setLocale:(nullable NSString *)locale;
- (void)setUICustomization:(nullable UUiCustomization *)uiCustomization;
- (void)setConfigParameters:(nonnull UConfigParameters *)configParameters;

#pragma mark Getters
- (nonnull NSString *)getLicenseKey;
- (nullable NSString *)getLocale;
- (nullable UUiCustomization *)getUICustomization;
- (nonnull UConfigParameters *)getConfigParameters;

@end

