//
//  UProgressDialog.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 ProgressDialog is a view that includes a UIActivityIndicator and UIImage
**/
@interface UProgressDialog: UIView

/**
 Sets a custom image on the ProgressDialog. The image is displayed above the UIActivityIndicator

 @param image The image to be shown
 */
- (void)setProgressViewImage:(nonnull UIImage *)image;

/**
 Start animating the UIActivityIndicator
**/
- (void)start;

/**
 Stop animating the UIActivityIndicator
**/
- (void)stop;

@end

