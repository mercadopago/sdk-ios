//
//  UConfigParameters.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/30/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UDirectoryServer;

/**
 Class that manages Configuration Parameters
 */
@interface UConfigParameters: NSObject

/**
 Initializer for ConfigParameters

 @return ConfigParameters object
 */
- (nonnull UConfigParameters *)init;
/**
 Adds a configuration parameter either to the specified group or to the default group.
 
 @param group Group to which the configuration parameter is to be added.
 Note: If a group is not specified, then the default group shall be used.
 @param paramName String Name of the configuration parameter.
 @param paramValue Value of the configuration parameter.
 */
- (void)addParam:(nullable NSString *)group
            name:(nonnull NSString *)paramName
           value:(nonnull NSString *)paramValue;
/**
 Returns a configuration parameter’s value either from the specified group or from the default group.
 
 @param group Group from which the configuration parameter’s value is to be returned.
 Note: If the group is null, then the default group shall be used.
 @param paramName Name of the configuration parameter.
 @return value for param name in group
 */
- (nullable NSString *)getParamValue:(nullable NSString *)group
                           paramName:(nonnull NSString *)paramName;

/**
 The removeParam method removes a configuration parameter either from the specified group or from the default group. It returns the name of the parameter that it removed.
 
 @param group Group from which the configuration parameter is to be removed.
 Note: If group is null, then the default group shall be used.
 @param paramName  Name of the configuration parameter.
 @return param name of value deleted
 */
- (nullable NSString *)removeParam:(nullable NSString *)group
                         paramName:(nonnull NSString *)paramName;


/**
 Custom signature for adding a param

 @param group the group to add the value param to
 @param paramName the name of the param
 @param paramValue the value of the param
  
 */
- (BOOL)u_addParam:(nullable NSString *)group
              name:(nonnull NSString *)paramName
             value:(nonnull NSString *)paramValue
             error:(NSError *_Nullable *_Nullable)error;

/**
 Custom signature for getting a param value

 @param group the group the param is listed under
 @param paramName the name of the param
  
 */
- (nullable NSString *)u_getParamValue:(nullable NSString *)group
                             paramName:(nonnull NSString *)paramName
                                 error:(NSError *_Nullable *_Nullable)error;


/**
 Custom signature for removing a param

 @param group the group the param is part of
 @param paramName the param name
  
 */
- (nullable NSString *)u_removeParam:(nullable NSString *)group
                           paramName:(nonnull NSString *)paramName
                               error:(NSError *_Nullable *_Nullable)error;

/**
 ** Custom methods that allow a client to add DS Servers
*/
- (void)addDirectoryServer:(nonnull UDirectoryServer *)newServer;
- (void)addDirectoryServers:(nonnull NSArray <UDirectoryServer *> *)newServers;

@end
