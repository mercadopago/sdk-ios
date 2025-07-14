//
//  LabelCustomization.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/30/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import "UCustomization.h"

/**
 * A class for specifying the customization of labels displayed by the SDK
 */
@interface ULabelCustomization: UCustomization

/**
 * Custom Initializer
 */
- (nonnull ULabelCustomization *)init;

/**
 The setHeadingTextColor method shall set the color for the heading label text.
 
 @param hexColorCode color code in Hex format. For example, the color code can be "#999999".
 */

- (void)setHeadingTextColor:(nonnull NSString *)hexColorCode;

/**
 The setHeadingTextFontName method shall set the font type for the heading label text.
 
 @param fontName fontName Font type for the heading label text.
 
 */
- (void)setHeadingTextFontName:(nonnull NSString *) fontName;

/**
 The setHeadingTextFontSize method shall set the font size for the heading label text.
 
 @param fontSize font size for the heading label text
 
 */
- (void)setHeadingTextFontSize:(NSInteger) fontSize;

/**
 The getHeadingTextColor method shall return the hex color code of the heading label text.
 
 @returns heading labe's font name
 
 */
- (nonnull NSString *)getHeadingTextFontName;

/**
 The getHeadingTextFontName method shall return the font type for the heading label text.
 
 @returns heading label's text color
 
 */
- (nonnull NSString *)getHeadingTextColor;

/**
 The getHeadingTextFontSize method shall return the font size for the heading label text.
 
 @returns heading label's font size
 
 */
- (NSInteger)getHeadingTextFontSize;


/**
 Custom signature for setting the text color for the heading label. Supports do-try-catch for Swift.

 @param hexColorCode color code for the heading label
 */
- (BOOL)u_setHeadingTextColor:(nonnull NSString *)hexColorCode
                        error:(NSError *_Nullable *_Nullable)error;


/**
 Custom signature for setting the font for the heading label. Supports do-try-catch for Swift.

 @param fontName the font name for the heading label
 */
- (BOOL)u_setHeadingTextFontName:(nonnull NSString *)fontName
                           error:(NSError *_Nullable *_Nullable)error;


/**
 Custom signature for setting the heading label's text size

 @param fontSize size of the text
 */
- (BOOL)u_setHeadingTextFontSize:(NSInteger)fontSize
                           error:(NSError *_Nullable *_Nullable)error;

@end
