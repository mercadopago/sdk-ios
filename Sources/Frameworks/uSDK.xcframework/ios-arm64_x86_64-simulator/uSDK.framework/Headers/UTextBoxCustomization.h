//
//  TextBoxCustomization.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/30/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import "UCustomization.h"

/**
 * A class for specifying the customization of text fields displayed by the SDK
 */
@interface UTextBoxCustomization: UCustomization

/**
 * Custom Initializer
 */
- (nonnull UTextBoxCustomization *)init;

/**
 The setBorderWidth method shall set the width of the text box border.

 @param borderWidth Int width (integer value) for the text border width.
 
 */
- (void)setBorderWidth:(NSInteger)borderWidth;

/**
 The setBorderColor method shall set the color for the border of the text box.

 @param hexColorCode String Color code in Hex format. For example, the color code can be "#999999".
 
 */
- (void)setBorderColor:(nonnull NSString *)hexColorCode;

/**
 The setCornerRadius method shall set the radius for the text box corners.

 @param cornerRadius Int radius (integer value) for the text box corners.
 
 */
- (void)setCornerRadius:(NSInteger) cornerRadius;

/**
 The getBorderWidth method shall return the width of the text box border.

 @return border witdh of text field
 
 */
- (NSInteger)getBorderWidth;

/**
 The getBorderColor method shall return the color of the text box border.
 
 @return border color of text field
 
 */
- (nonnull NSString *)getBorderColor;

/**
 The getCornerRadius method shall return the radius for the text box corners.

 @return corner radius of text field
 
 */
- (NSInteger)getCornerRadius;


/**
 Custom signature that sets the border width on the text field. Supports do-try-catch for Swift.

 @param borderWidth the width of the text field's border
 */
- (BOOL)u_setBorderWidth:(NSInteger)borderWidth
                   error:(NSError *_Nullable *_Nullable)error;


/**
 Custom signature that sets the border color for the text field. Supports do-try-catch for Swift.

 @param hexColorCode color code representing the border color
 */
- (BOOL)u_setBorderColor:(nonnull NSString *)hexColorCode
                   error:(NSError *_Nullable *_Nullable)error;


/**
 Custom signature that sets the corner radius on the text field. Supports do-try-catch for Swift.

 @param cornerRadius the corner radius for the text field
 */
- (BOOL)u_setCornerRadius:(NSInteger)cornerRadius
                    error:(NSError *_Nullable *_Nullable)error;

@end

