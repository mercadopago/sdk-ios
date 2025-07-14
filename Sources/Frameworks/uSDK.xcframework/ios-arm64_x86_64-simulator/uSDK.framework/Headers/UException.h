//
//  UException.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/31/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

/**
 Exception types that the SDK might throw
 */
typedef NS_ENUM(NSInteger, UException) {
    
    /**
     Thrown when an invalid value is found
     */
    UExceptionInvalidInputException,
    /**
     Thrown if the SDK is already initialized
     */
    UExceptionSDKAlreadyInitializedException,
    /**
     Thrown if the SDK has not been initialized
     */
    UExceptionSDKNotInitializedException,
    /**
     Thrown if an exception does not cause a crash
     */
    UExceptionSDKRuntimeException,
    /**
     Thrown for generic exceptions. Usually seen if there was a web call error
     */
    UExceptionGenericError
};
