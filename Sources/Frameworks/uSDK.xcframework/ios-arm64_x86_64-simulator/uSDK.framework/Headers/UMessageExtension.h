//
//  UMessageExtension.h
//  uSDK
//
//  Created by Drew Pitchford on 2/20/20.
//  Copyright © 2020 mSignia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UMessageExtension: NSObject

// Acs Ephem Pub Key
@property (strong, nonatomic)NSString *_Nonnull x;
@property (strong, nonatomic)NSString *_Nonnull y;
@property (strong, nonatomic)NSString *_Nonnull kty;
@property (strong, nonatomic)NSString *_Nonnull crv;

// Data
@property (strong, nonatomic)NSString *_Nonnull deviceCookie;
@property (strong, nonatomic)NSString *_Nonnull acsReference;
@property (strong, nonatomic)NSArray<NSString *> *_Nonnull methods;
@property (strong, nonatomic)NSString *_Nonnull bankID;
@property (strong, nonatomic)NSData *_Nullable fidoOptions;

// USDK Prompt
@property (strong, nonatomic)NSString *_Nonnull heading;
@property (strong, nonatomic)NSString *_Nonnull message;
@property (assign, nonatomic)UIKeyboardType keyboardType;

// Message Extension
@property (strong, nonatomic)NSString *_Nonnull ID;
@property (strong, nonatomic)NSString *_Nonnull name;
@property (assign, nonatomic)BOOL criticalityIndicator;

- (nonnull UMessageExtension *)initWithID:(nonnull NSString *)ID
                                     name:(nonnull NSString *)name
                     criticalityIndicator:(BOOL)criticalityIndicator
                             deviceCookie:(nonnull NSString *)deviceCookie
                             acsReference:(nonnull NSString *)acsReference
                                   bankID:(nonnull NSString *)bankID
                                  methods:(nonnull NSArray<NSString *> *)methods
                                        x:(nonnull NSString *)x
                                        y:(nonnull NSString *)y
                                      kty:(nonnull NSString *)kty
                                      crv:(nonnull NSString *)crv
                                  heading:(nonnull NSString *)heading
                                  message:(nonnull NSString *)message
                             keyboardType:(UIKeyboardType)keyboardType
                              fidoOptions:(nullable NSData *)fidoOptions;

@end

