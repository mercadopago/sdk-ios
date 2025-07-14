//
//  UThreeDSThemeManager.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UThemable.h"

/**
Manages the theme for the Challenge Screens.
*/
@interface UThreeDSThemeManager: NSObject

/**
 Singleton object for managing themes

 @return The singleton object
 */
+ (nonnull UThreeDSThemeManager *) shared;

/**
 Sets a new theme for the SDK to use on the Challenge screens

 @param theme A UThemable compilant object
 */
- (void)setCurrentTheme:(nonnull id<UThemable>)theme;

/**
 Returns the current theme being used by the SDK for the Challenge Screens

 @return The currently used theme
 */
- (nullable id<UThemable>)getCurrentTheme;

@end

