//
//  UPurchaseInfo.h
//  uSDK
//
//  Created by Drew Pitchford on 6/2/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

@protocol UPurchaseInfo

/**
 * An object that conforms to UPurchaseInfo must serialize itself into an NSDictionary (or [String: Any] in Swift)
 */
- (nonnull NSDictionary<NSString *, id> *)toJson;

@end
