//
//  UTransaction.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import "UChallengeStatusReceiver.h"


@class UChallengeParameters, UAuthenticationRequestParameters, UIViewController, UIView, UProgressDialog, UMessageExtension, UCloseTransactionSpec;

/**
 Represents a Transaction
 */
@protocol UTransaction <NSObject>

/**
 NOTE: All methods prefixed with "u_" are custom method signatures for implementing the 3DS spec. They allow for do-try-catch in Swift apps and error passing in Obj-C apps.
 **/

/**
 When the 3DS Requestor App calls the getAuthenticationRequestParameters method, the 3DS SDK shall encrypt the device information that it collects during initialization and send this information along with the SDK information to the 3DS Requestor App. The app includes this information in its message to the 3DS Server. This getAuthenticationRequestParameters method shall be called for every transaction.
 
 @return AuthenticationRequestParameters object
 */
- (nullable UAuthenticationRequestParameters *)getAuthenticationRequestParameters;


/**
 Convenience method. Supports do-try-catch for Swift

 @return AuthenticationRequestParameters object
 */
- (nullable UAuthenticationRequestParameters *)u_getAuthenticationRequestParameters:(NSError *_Nullable *_Nullable)error;

/**
 If the ARes that is returned indicates that the Challenge Flow must be applied, the 3DS Requestor App calls the doChallenge method with the required input parameters. The doChallenge method initiates the challenge process.
 
 Note: The doChallenge method shall be called only when the Challenge Flow is to be applied.
 
 The 3DS SDK shall display the challenge to the Cardholder.
 The 3DS SDK shall exchange two or more CReq and CRes messages with the ACS.
 The challenge status shall be communicated back to the Merchant App by the 3DS SDK by using the ChallengeStatusReceiver callback functions.
 
 @param currentNavController The UINavigationController inside which the SDK UI will be presented.
 @param challengeParameters ACS details required by the 3DS SDK to conduct the challenge process during the transaction. The following details are mandatory: MI transaction ID, ACS account ID, ACS certificate, ACS signature, ACS rendering type, Protocol, ACS reference number, JWS signed ACS data.
 @param challengeStatusReceiver Callback object for notifying the 3DS Requestor App about the challenge status.
 @param timeOut interval within which the challenge process must be completed.
 */
- (void)doChallenge:(nonnull UINavigationController *)currentNavController
challengeParameters:(nonnull UChallengeParameters *)challengeParameters
challengeStatusReceiver:(nonnull id<UChallengeStatusReceiver>)challengeStatusReceiver
            timeOut:(int)timeOut;

/**
 Convenience method. Supports do-try-catch for Swift

 @param currentNavController The UINavigationController inside which the SDK UI will be presented
 @param challengeParameters ACS details required by the 3DS SDK to conduct the challenge process during the transaction. The following details are mandatory: MI transaction ID, ACS account ID, ACS certificate, ACS signature, ACS rendering type, Protocol, ACS reference number, JWS signed ACS data.
 @param challengeStatusReceiver Callback object for notifying the 3DS Requestor App about the challenge status.
 @param timeOut interval within which the challenge process must be completed.
 */
- (BOOL)u_doChallenge:(nonnull UINavigationController *)currentNavController
  challengeParameters:(nonnull UChallengeParameters *)challengeParameters
challengeStatusReceiver:(nonnull id<UChallengeStatusReceiver>)challengeStatusReceiver
              timeOut:(int)timeOut
                error:(NSError *_Nullable *_Nullable)error;

/**
 * mSignia method that allows the SDK to provide a prompt for the user to enter. The typing data is captured and encrypted into the deviceData property from     getAuthenticationRequestParameters on MSTransaction
 * @param viewController the view controller used to present the alert
 * @param completion completion block called once the user taps done (or if there is no SCA data to prompt the user)
*/
- (void)u_doPrompt:(nonnull UIViewController *)viewController
        completion:(void (^ _Nonnull)(BOOL wasCancelled))completion;

/*
 mSignia method that allows the SDK to authenticate a user using biotmetric security on the device. The result is captured into the deviceData property from getAuthenticationRequestParameters on UTransaction
@param viewController the view controller used to present the biometric authentication
@param completion completion block called once the user is done authenticating
 */
- (void)u_doBiometricAuthenticationWithCompletion:(void (^ _Nonnull)(BOOL shouldContinueTransaction, NSError *_Nullable laError, NSString *_Nullable errorMessage))completion;

/**
 mSIGNIA method that allows the SDK to authenticate a user using Fido. The result is captured into the deviceData property from getAuthenticationRequestParameters on UTransaction
 @param userDidCancel indicates if the user cancelled the fido operation
 @param error if the fido operation encounters an error, this object is filled
 @param errorMessage contains the localized description of the error if a fido operation encounters an error
 */
- (void)u_doFidoWithCompletion:(void (^_Nonnull)(BOOL userDidCancel, NSError *_Nullable error, NSString *_Nullable errorMessage))completion;

/**
 The getProgressView method shall return an instance of Progress View (processing screen) that the 3DS Requestor App uses. The processing screen displays the Directory Server logo, and a graphical element to indicate that an activity is being processed. The ProgressView object is created by the 3DS SDK.
 
 @return ProgressDialog
 */
- (nullable UProgressDialog *)getProgressView:(NSError *__autoreleasing  _Nullable *_Nullable)error;

/**
 The close method is called to clean up resources that are held by the Transaction object. It shall be called when the transaction is completed. The following are some examples of transaction completion events:
 
 - The Cardholder completes the challenge.
 - An error occurs
 - The Cardholder chooses to cancel the transaction.
 - The ACS recommends a challenge, but the Merchant overrides the recommendation and chooses to complete the transaction without a challenge
 */
- (BOOL)close:(NSError *__autoreleasing  _Nullable *_Nullable)error;

/**
 * Custom mSIGNIA close method that support SCA functions
 * @param spec the UTransactionClose spec object
 * @param error An error object (For Swift, it is a thrown error)
 */
- (BOOL)closeWithSpec:(nonnull UCloseTransactionSpec *)spec
                error:(NSError *__autoreleasing  _Nullable *_Nullable)error;

@end

