//
//  UCreateTransactionSpec.h
//  uSDK
//
//  Created by Drew Pitchford on 4/22/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCreateTransactionSpec: NSObject

- (nonnull UCreateTransactionSpec *)initWithDirectoryServerID:(nonnull NSString *)directoryServerID
                                               messageVersion:(nonnull NSString *)messageVersion
                                                       cardID:(nullable NSString *)cardID;
- (void)setDirectoryServerID:(nonnull NSString *)directoryServerID;
- (nonnull NSString *)getDirectoryServerID;
- (void)setMessageVersion:(nonnull NSString *)messageVersion;
- (nonnull NSString *)getMessageVersion;
- (void)setCardID:(nonnull NSString *)cardID;
- (nullable NSString *)getCardID;

@end

