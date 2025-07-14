//
//  UAuthenticationDelegate.h
//  uSDK
//
//  Created by Drew Pitchford on 6/2/20.
//  Copyright © 2020 mSignia. All rights reserved.
//]

#import "UTransStatus.h"

@protocol UAuthenticationDelegate

/**
 * Called when the authentication succeeded (transStatus=UTransStatusAccept)
 * @param threeDSServerTransID The 3DS server's transaction ID
 * @param status The transaction status
 */
- (void)authenticated:(nonnull NSString *)threeDSServerTransID
               status:(UTransStatus)status;

/**
 * Called when the authentication did NOT succeed (transStatus!=UTransStatusAccept|UTransStatusDecoupledAuthentication)
 * @param threeDSServerTransID The 3DS server's transaction ID
 * @param status The transaction status
 */
- (void)notAuthenticated:(nonnull NSString *)threeDSServerTransID
                  status:(UTransStatus)status;

/*
 * Called when decoupled authentication is performed (transStatus=UTransStatusDecoupledAuthentication). Thus, the end result is not known at the moment of the call.
 * @param threeDSServerTransID The 3DS server's transaction ID
 * @param status The transaction status
 */
- (void)decoupledAuthBeingPerformed:(nonnull NSString *)threeDSServerTransID
                             status:(UTransStatus)status;

/**
 * Called when user cancels a challenge
 * @param threeDSServerTransID The 3DS server's transaction ID
 */
- (void)cancelled:(nonnull NSString *)threeDSServerTransID;

/**
 * Called when any error occured during the 3DS transaction
 * @param threeDSServerTransID The 3DS server's transaction ID
 * @param error An error object specifying what error occurred. Check userInfo[NSLocalizedDescriptionKey]
 */
- (void)error:(nonnull NSString *)threeDSServerTransID
        error:(nonnull NSError *)error;

@end

