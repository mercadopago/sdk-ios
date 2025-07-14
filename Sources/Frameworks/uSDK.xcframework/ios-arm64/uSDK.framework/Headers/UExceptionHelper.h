//
//  UExceptionHelper.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UException.h"

/**
 Helper class that provides a method for obtaining a message for a given Exception case.
 Acts as a workaround since ObjC doesn't support Associated Types for enums.
*/
@interface UExceptionHelper: NSObject


/**
 Returns the message for the given exception

 @param exception the excpetion
 @return the message for the exception
 */
+ (nonnull NSString *)messageFor:(UException)exception;

@end

