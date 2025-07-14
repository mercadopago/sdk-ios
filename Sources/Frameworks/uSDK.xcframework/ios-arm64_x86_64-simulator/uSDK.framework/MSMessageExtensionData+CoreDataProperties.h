//
//  MSMessageExtensionData+CoreDataProperties.h
//  
//
//  Created by distiller on 6/6/24.
//
//  This file was automatically generated and should not be edited.
//

#import "MSMessageExtensionData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSMessageExtensionData (CoreDataProperties)

+ (NSFetchRequest<MSMessageExtensionData *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *acsReference;
@property (nullable, nonatomic, copy) NSString *bankId;
@property (nullable, nonatomic, copy) NSString *deviceCookie;
@property (nullable, nonatomic, retain) NSData *fidoOptions;
@property (nullable, nonatomic, retain) NSArray *methods;
@property (nullable, nonatomic, retain) MSMessageExtensionDataPublicKey *acsEphemPubKey;
@property (nullable, nonatomic, retain) MSMessageExtension *messageExtension;
@property (nullable, nonatomic, retain) MSSDKPrompt *sdkPrompt;

@end

NS_ASSUME_NONNULL_END
