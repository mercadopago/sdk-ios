//
//  UThreeDS2Service.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import "UTransaction.h"
#import "UAuthenticationDelegate.h"

@class UTransaction, UWarning, UUiCustomization, UConfigParameters, UCreateTransactionSpec, UCloseTransactionSpec, UInitSpec, UAuthenticationSpec;

/**
 The ThreeDS2Service interface is the main 3DS SDK interface. It provides methods to process transactions.
 The ThreeDS2Service protocl as defined in the EMVCO 3DS 2.1.0 Specification
 */
@protocol UThreeDS2Service

/**
 NOTE: All methods prefixed with "u_" are custom method signatures for implementing the 3DS spec. They allow for do-try-catch in Swift apps and error passing in Obj-C apps.
**/

/**
 Initializes the SDK
 @param initSpec an object contianing all needed info to initialize
 @param completion a completion block that passes back an optional error
 */
- (void)initializeWithSpec:(nonnull UInitSpec *)initSpec
                completion:(void (^_Nonnull)(NSError *_Nullable error))completion NS_SWIFT_NAME(initialize(spec:completion:));

/**
 Starts the authentication process. Will handle dual branded cards and challenges as needed.
 @param spec the UAuthenticationSpec object that contains needed info for authenticating the user
 @param delegate the object that will receive updates on the authentication process
 @param currentViewController the view controller used to display the SDK's challenge view controller
 */
- (void)authenticateWithSpec:(nonnull UAuthenticationSpec *)spec
                    delegate:(nonnull id<UAuthenticationDelegate>)delegate
       currentViewController:(nonnull UIViewController *)currentViewController NS_SWIFT_NAME(authenticate(spec:delegate:currentViewController:));

/**
 The 3DS Requestor App calls the initialize method at the start of the payment stage of a transaction. The app passes configuration parameters, UI configuration parameters, and (optionally) user locale to this method. Note: Until the ThreeDS2Service instance is initialized, it shall be unusable.
 
 @param configParameters information that shall be used during initialization
 @param locale represents the locale for the app’s user interface
 @param uiCustomization UI configuration information that is used to specify the UI layout and theme. For example, font style and font size.
 @param completion Completion block; error is not nil in case of a failed initialization
 */
- (void)u_initialize:(nonnull UConfigParameters *)configParameters
              locale:(nonnull NSString *)locale
     uiCustomization:(nonnull UUiCustomization *)uiCustomization
          completion:(void (^_Nonnull)(NSError *_Nullable error))completion;

/**
 The 3DS Requestor App calls the initialize method at the start of the payment stage of a transaction. The app passes configuration parameters, UI configuration parameters, and (optionally) user locale to this method. Note: Until the ThreeDS2Service instance is initialized, it shall be unusable.
 
 @param configParameters information that shall be used during initialization
 @param licenseKey the licenseKey for the uSDK
 @param locale represents the locale for the app’s user interface
 @param uiCustomization UI configuration information that is used to specify the UI layout and theme. For example, font style and font size.
 @param completion Completion block; error is not nil in case of a failed initialization
 */
- (void)u_initialize:(nonnull UConfigParameters *)configParameters
          licenseKey:(nonnull NSString *)licenseKey
              locale:(nonnull NSString *)locale
     uiCustomization:(nonnull UUiCustomization *)uiCustomization
          completion:(void (^_Nonnull)(NSError *_Nullable error))completion;

/**
 The createTransaction method creates an instance of Transaction through which the 3DS Requestor App gets the data that is required to perform the transaction.
 
 @param directoryServerID Registered Application Provider Identifier (RID) that is unique to the Payment System, RIDs are defined by the ISO 7816-5 standard.
 @param messageVersion The message version for the SDK. E.g. "2.1.0"
 @return Transaction object
 */
- (nullable id<UTransaction>)createTransaction:(nonnull NSString *)directoryServerID
                                messageVersion:(nullable NSString *)messageVersion;

/**
* Custom mSIGNIA createTransaction method that supports SCA functions
* @param spec the UCreateTransactionSpec object
* @param error an error object (For Swift, it throws the error)
*/
- (nullable id<UTransaction>)createTransactionWithSpec:(nonnull UCreateTransactionSpec *)spec
                                                 error:(NSError *__autoreleasing  _Nullable *_Nullable)error;

/**
 Convenience method. Supports do-try-catch for Swift

 @param directoryServerID Registered Application Provider Identifier (RID) that is unique to the Payment System, RIDs are defined by the ISO 7816-5 standard.
 @param messageVersion The message version for the SDK. E.g. "2.1.0"
 @return Transaction object
 */
- (nullable id<UTransaction>)u_createTransaction:(nonnull NSString *)directoryServerID
                                  messageVersion:(nullable NSString *)messageVersion
                                           error:(NSError *__autoreleasing  _Nullable *_Nullable)error;

/**
 The cleanup method frees up resources that are used by the 3DS SDK. It is called only once during a single 3DS Requestor App session.
 */
- (void)cleanup;


/**
 Convenience method. Supports do-try-catch for Swift
 */
- (BOOL)u_cleanup:(NSError *__autoreleasing  _Nullable *_Nullable)error;

/**
 The getSDKVersion method shall return the version of the 3DS SDK that is integrated with the 3DS Requestor App.

 @return SDK version
 */
- (nullable NSString *)getSDKVersion;


/**
 Convenience method. Supports do-try-catch for Swift
 
 @return SDK version
 */
- (nullable NSString *)u_getSDKVersion:(NSError *__autoreleasing  _Nullable *_Nullable)error;

/**
 The getWarnings method shall return the warnings produced by the 3DS SDK during initialization.
 
 @return Array of UWarning objects
 */
- (nullable NSArray<UWarning *> *)getWarnings;


/**
 Convenience method. Supports do-try-catch for Swift

 @return Array of UWarning objects
 */
- (nullable NSArray<UWarning *> *)u_getWarnings:(NSError *__autoreleasing  _Nullable *_Nullable)error;

/**
    For old (2.0.1) OOB flow
*/
- (BOOL)handleOpenUrl:(nonnull UIApplication *)application
              openURL:(nonnull NSURL *)openURL
    sourceApplication:(nullable NSString *)sourceApplication
           annotation:(nonnull id)annotation;

/**
* For mSignia testing
*/
- (void)deinitialize;

@end
