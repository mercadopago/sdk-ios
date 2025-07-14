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
//  UICustomization.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 4/27/17.
//  Copyright © 2017 MSIGNIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UButtonType.h"

@class UButtonCustomization, UToolbarCustomization, UTextBoxCustomization, ULabelCustomization;

/**
 Object that contains all needed info for UI customization in the SDK
 */
@interface UUiCustomization: NSObject

/**
 Standard init method inherited by all NSObject subclasses

 @return A UiCustomization object
 */
- (nonnull UUiCustomization *)init;

/**
 Init method that sets the label, textBox (text field), and toolbar (UINavigationBar) properties

 @param labelCustomization a LabelCustomization object that sets label customization for the SDK
 @param textBoxCustomization a TextboxCustomization object that sets text field customizations in the SDK
 @param toolbarCustomization a ToolbarCustomization object that sets the navigation bar customizations in the SDK
 @return UiCustomization object with all properties initialized
 */
- (nonnull UUiCustomization *)initWithLabelCustomization:(nonnull ULabelCustomization *)labelCustomization
                                    textBoxCustomziation:(nonnull UTextBoxCustomization *)textBoxCustomization
                                    toolbarCustomization:(nonnull UToolbarCustomization *)toolbarCustomization NS_SWIFT_NAME(init(with:textBoxCustomization:toolbarCustomization:));

/**
 The setToolbarCustomization method shall accept a ToolbarCustomization object. The 3DS SDK uses this object for customizing navigation bars

 @param toolbarCustomization a toolbar customization
 */
- (void)setToolbarCustomization:(nonnull UToolbarCustomization *)toolbarCustomization;

/**
 The setLabelCustomization method shall accept a LabelCustomization object. The 3DS SDK uses this object for customizing labels.
 
 @param labelCustomization a label customization
 */
- (void)setLabelCustomization:(nonnull ULabelCustomization *)labelCustomization;

/**
 The setTextBoxCustomization method shall accept a TextBoxCustomization object. The 3DS SDK uses this object for customizing text fields.
 
 @param textBoxCustomization textBoxCustomization
 */
- (void)setTextBoxCustomization:(nonnull UTextBoxCustomization *)textBoxCustomization;

/**
 The getButtonCustomization method shall return a ButtonCustomization object for a specified button type.
 
 @param buttonType type used to look up button customization
 @returns button customization
 */
- (nullable UButtonCustomization *)getButtonCustomization:(UButtonType)buttonType;

/**
 The getButtonCustomization method shall return a ButtonCustomization object for an implementer-specific button type.
 
 @param buttonType type used to look up button customization
 @returns button customization
 */
- (nullable UButtonCustomization *)getCustomButtonCustomization:(nonnull NSString *)buttonType;

/**
 The getToolbarCustomization method shall return a ToolbarCustomization object for a toolbar
 
 @return ToolbarCustomization
 */
- (nullable UToolbarCustomization *)getToolbarCustomization;

/**
 The getLabelCustomization method shall return a LabelCustomization object.
 
 @returns LabelCustomization
 */
- (nullable ULabelCustomization *)getLabelCustomization;

/**
 The getTextBoxCustomization method shall return a TextBoxCustomization object.
 
 @returns: TextBoxCustomization
 */
- (nullable UTextBoxCustomization *)getTextBoxCustomization;

/**
 The setButtonCustomization method shall accept a ButtonCustomization object along with a predefined button type. The 3DS SDK uses this object for customizing buttons.
 
 @param buttonCustomization ButtonCustomization
 @param buttonType String
 */
- (void)setButtonCustomization:(nonnull UButtonCustomization *)buttonCustomization
                withButtonType:(UButtonType)buttonType;
/**
 This method is a variation of the setButtonCustomization method. The setButtonCustomization method shall accept a ButtonCustomization object and an implementer-specific button type. The 3DS SDK uses this object for customizing buttons.
 
 Note: This method shall be used when the SDK implementer wants to use a button type that is not included in the predefined Enum MSButtonType. The SDK implementer shall maintain a dictionary of buttons passed via this method for use during customization.
 
 @param buttonCustomization ButtonCustomization
 @param buttonType String
 */
- (void)setCustomButtonCustomization:(nonnull UButtonCustomization *)buttonCustomization
                          withString:(nonnull NSString *)buttonType;

@end
