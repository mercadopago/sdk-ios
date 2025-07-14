//
//  UCustomization.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/30/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A parent class that contains common customizations that all objects might need
 */
@interface UCustomization : NSObject

/**
 * Custom initializer
 */
- (nonnull UCustomization *)init;

/**
 The setTextFontName method shall set the font type for a UI element.

 @param fontName String Font type for the UI element.
 */
- (void)setTextFontName:(nonnull NSString *)fontName;

/**
 The setTextColor method shall set the text color for a UI element .

 @param hexColorCode String Color code in Hex format. For example, the color code can be "#999999".
 */
- (void)setTextColor:(nonnull NSString *)hexColorCode;

/**
 The setTextFontSize method shall set the font size for a UI element.

 @param fontSize size for the UI element.
 */
- (void)setTextFontSize: (NSInteger)fontSize;

/**
 The getTextFontName method shall return the font type for a UI element.
 */
- (nonnull NSString *)getTextFontName;

/**
 The getTextColor method shall return the hex color code for a UI element.
 */
- (nonnull NSString *)getTextColor;

/**
 The getTextFontSize method shall return the font size for a UI element.
 */
- (NSInteger)getTextFontSize;

/**
 Custom signature that sets the font. Supports do-try-catch for Swift

 @param fontName name of font
 */
- (BOOL)u_setTextFontName:(nonnull NSString *)fontName
                    error:(NSError *_Nullable *_Nullable)error;

/**
 Custom signature that sets the text color. Supports do-try-catch for Swift

 @param hexColorCode color code for text
 */
- (BOOL)u_setTextColor:(nonnull NSString *)hexColorCode
                 error:(NSError *_Nullable *_Nullable)error;

/**
 Custom signature that sets the text size. Supports do-try-catch for Swift

 @param fontSize size of the font
 */
- (BOOL)u_setTextFontSize:(NSInteger)fontSize
                    error:(NSError *_Nullable *_Nullable)error;

@end

