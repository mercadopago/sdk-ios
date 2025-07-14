//
//  UDirectoryServer.h
//  ThreeDSSDK
//
//  Created by Drew Pitchford on 1/30/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * An object that represents a Directory Server
 */
@interface UDirectoryServer : NSObject

/**
 * The id for this Directory Server
 */
@property (strong, nonatomic)NSString *_Nonnull dsID;

/**
 * The publick key for this Directory Server
 */
@property (strong, nonatomic)NSString *_Nonnull publicKey;

/**
 * The key id for this Directory Server
 */
@property (strong, nonatomic)NSString *_Nonnull keyID;

/**
 * The certificate authority's certificate for this Directory Server
 */
@property (strong, nonatomic)NSString *_Nonnull dsCACertificate;

/**
 * The name for the server that will be displayed in UI
 */
@property (strong, nonatomic)NSString *_Nonnull providerName;

/**
 * The image for the server that will be displayed in UI
 */
@property (strong, nonatomic)UIImage *_Nullable dsLogo;

/** Initializer for constructing a UDirectoryServer
 * @param dsID the ID for this Directory server
 * @param publicKey the public key for this Directory Server
 * @param keyID the key ID for this Directory Server
 * @param dsCACertificate the certficate authority certificate for this Directory Server
 */
- (nonnull UDirectoryServer *)initWithDSID:(nonnull NSString *)dsID
                                 publicKey:(nonnull NSString *)publicKey
                                     keyID:(nonnull NSString *)keyID
                           dsCACertificate:(nonnull NSString *)dsCACertificate
                              providerName:(nonnull NSString *)providerName
                                    dsLogo:(nullable UIImage *)dsLogo;

@end

