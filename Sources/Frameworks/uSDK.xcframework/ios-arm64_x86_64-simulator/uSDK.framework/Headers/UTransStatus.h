//
//  UTransStatus.h
//  uSDK
//
//  Created by Drew Pitchford on 6/2/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

typedef NS_ENUM(NSInteger, UTransStatus) {
    UTransStatusAccept,
    UTransStatusDeny,
    UTransStatusChallenge,
    UTransStatusAttempted,
    UTransStatusNotPerformed,
    UTransStatusDecoupledAuthentication,
    UTransStatusInformationOnly,
    UTransStatusRejected
};
