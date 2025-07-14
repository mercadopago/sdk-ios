//
//  CloseTransactionSpec.h
//  uSDK
//
//  Created by Drew Pitchford on 4/22/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UMessageExtension;

@interface UCloseTransactionSpec: NSObject

- (nonnull UCloseTransactionSpec *)init;
- (nonnull UCloseTransactionSpec *)initWithMessageExtensions:(nonnull NSArray<UMessageExtension *> *)messageExtensions;
- (void)setMessageExtensions:(nonnull NSMutableArray<UMessageExtension *> *)messageExtensions;
- (nonnull NSArray<UMessageExtension *> *)getMessageExtensions;

@end
