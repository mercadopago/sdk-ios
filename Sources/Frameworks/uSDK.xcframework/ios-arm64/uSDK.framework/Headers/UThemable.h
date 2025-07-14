//
//  UThemable.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 4/30/19.
//  Copyright © 2019 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 A protocol that defines properties to theme the challenge screens
 */
@protocol UThemable

/**
 Sets the background color for views
 */
@property (strong, nonatomic)UIColor *_Nonnull primaryBackgroundColor;

/**
 Sets the background color for "secondary" views in order to differentiate from the primary background view.
 For example, this would set a text field's background color so it can be different than the surrounding background color
 */
@property (strong, nonatomic)UIColor *_Nonnull secondaryBackgroundColor;

/**
 Sets the background color for buttons
 */
@property (strong, nonatomic)UIColor *_Nonnull buttonBackgroundColor;

/**
 Sets the textColor property on UIButtons
 */
@property (strong, nonatomic)UIColor *_Nonnull buttonTextColor;

/**
 Sets the background color for labels
 */
@property (strong, nonatomic)UIColor *_Nonnull labelBackgroundColor;

/**
 Sets the navigation bar's barTintColor property
 */
@property (strong, nonatomic)UIColor *_Nonnull navigationBarBarTintColor;

/**
 Sets the navigation bar's tintColor property
 */
@property (strong, nonatomic)UIColor *_Nonnull navigationBarTintColor;

/**
 Sets the navigation bar's title's text color
 */
@property (strong, nonatomic)UIColor *_Nonnull navigationBarTitleTextColor;

/**
 Sets the text color for labels, text fields, text views, etc.
 */
@property (strong, nonatomic)UIColor *_Nonnull standardTextColor;

/**
 Sets the tintColor for various controls like UITextField, UITextView, etc
 */
@property (strong, nonatomic)UIColor *_Nonnull tintColor;

/**
 Sets the cornerRadius for various controls like UIButton, UITextField, etc.
 */
@property (assign)CGFloat cornerRadius;

/**
 Sets the font for the headers on challenge screens
 */
@property (strong, nonatomic)UIFont *_Nonnull headerFont;

/**
 Sets the text color for labels used as headers
 */
@property (strong, nonatomic)UIColor *_Nonnull headerTextColor;

/**
 Sets the font for standard controls like UILabel, UITextField, UITextView
 */
@property (strong, nonatomic)UIFont *_Nonnull standardFont;

/**
 Sets the font for buttons
 */
@property (strong, nonatomic)UIFont *_Nonnull buttonTitleFont;

/**
 Sets the border color for UITextField on challenge screens
 */
@property (strong, nonatomic)UIColor *_Nonnull borderColor;

/**
 Sets the width of the border around a text field
 */
@property (assign)CGFloat borderWidth;

/**
 Set the keyboardApperance on controls that present a keyboard
 */
@property (assign)UIKeyboardAppearance keyboardApperance;

/**
 Sets the title of the navigation bar during the challenge process
 */
@property (strong, nonatomic)NSString *_Nonnull title;

/**
 Sets the color for the navigation bar title during the challenge process
 */
@property (strong, nonatomic)UIColor *_Nonnull titleColor;

@end
