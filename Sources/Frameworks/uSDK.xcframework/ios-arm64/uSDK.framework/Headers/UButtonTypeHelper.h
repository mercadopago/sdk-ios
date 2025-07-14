//
//  UButtonTypeHelper.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/30/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UButtonType.h"

/**
 * Helper class that provides a method for obtaining a a string representation for a UButtonType.
 * Acts as a workaround since ObjC doesn't support Associated Types for enums.
 */
@interface UButtonTypeHelper : NSObject

/**
 Provides a string description for the button type passed in.

 @param buttonType the button type
 @return string description of the button type
 */
+ (nonnull NSString *)stringForType:(UButtonType)buttonType;

@end

