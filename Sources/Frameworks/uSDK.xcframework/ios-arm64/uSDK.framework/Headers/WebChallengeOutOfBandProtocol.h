//
//  WebChallengeOutOfBandProtocol.h
//  ThreeDSSDK
//
//  Created by Sergey Klymenko on 21.07.2023.
//  Copyright © 2023 mSignia. All rights reserved.
//

#import <WebKit/WebKit.h>

@protocol WebChallengeOutOfBandProtocol <GenericChallengeProtocol>

- (nonnull WKWebView *)getWebView;

@end
