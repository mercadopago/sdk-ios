//
//  UWarning.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The severity of a warning
 */
typedef NS_ENUM(NSInteger, UWarningSeverity){
    
    /**
     Low severity
     */
    UWarningSeverityLow,
    /**
     Medium severity
     */
    UWarningSeverityMedium,
    /**
     High severity
     */
    UWarningSeverityHigh
};

/**
 Class that represents a UWarning from the SDK
 */
@interface UWarning: NSObject

/**
 The UWarning constructor shall create an object with the specified inputs.
 
 @param warningID id for the warning
 @param message message for the warning
 @param severity severity object
 */
- (nonnull UWarning *)initWithID:(nonnull NSString *)warningID
                         message:(nonnull NSString *)message
                        severity:(UWarningSeverity)severity;
/**
 The getID method shall return the warning ID.
 
 @return the warning's ID
 */
- (nonnull NSString *)getID;

/**
 The getMessage method shall return the warning message.
 
 @return the Warning's message
 */
- (nonnull NSString *)getMessage;

/**
 The getSeverity method shall return the severity level of the warning produced by the 3DS SDK.
 
 @return the warning's severity
 */
- (UWarningSeverity)getSeverity;

/**
 Custom UWarning constructor. Supports do-try-catch for Swift

 @param warningID the warning's ID
 @param message the warning's message
 @param severity the warning's severity
 @return UWarning object
 
 */
- (nullable UWarning *)initWithThrowableID:(nonnull NSString *)warningID
                                   message:(nonnull NSString *)message
                                  severity:(UWarningSeverity)severity
                                     error:(NSError *_Nullable *_Nullable)error;

@end

