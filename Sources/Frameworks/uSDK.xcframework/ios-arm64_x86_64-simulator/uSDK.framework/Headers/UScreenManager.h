//
//  UScreenManager.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Allows the delegate to be informed of actions that may compromise security.
 e.g. A screenshot was taken or the screen capture state changed.
*/
@protocol UScreenCaptureDelegate <NSObject>

@required
/**
 Called when a screenshot taken by the user is detected
 */
- (void)userDidTakeScreenshot;
/**
 For iOS 11 and up, called when the screen capture state changes

 @param screenIsBeingCaptured Indicates whether the screen is currently being captured
 */
- (void)screenCaptureStateChanged:(BOOL)screenIsBeingCaptured;

@end

/**
 UScreenManager is used to indicate to the SDK that the device screen should be protected during challenge flows.
 Given Apple's limitations, this protection includes blacking out Airplay monitors during a challenge, notification of screenshots,
 and notification of changes to screen capture state (as seen in ScreenCaptureDelegate docs).
*/
@interface UScreenManager: NSObject

/**
 UScreenManager's delegate
 */
@property (weak, nonatomic)id<UScreenCaptureDelegate> _Nullable delegate;

/**
 The singleton used to interact with UScreenManager
*/
+ (nonnull UScreenManager *)shared;

/**
 Returns the current state of screen protection
*/
- (BOOL)shouldProtectScreens;

/**
Sets the new state for screen protection
*/
- (void)shouldProtectScreens:(BOOL)shouldProtect;

/**
 Releases Airplay monitors after a challenge is over.
 NOTE: The client app MUST call this to relinquish control of Airplay monitors.
*/
- (void)releaseWindows;

@end

