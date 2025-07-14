//
//  MSMessageExtensionDataPublicKey+CoreDataProperties.h
//  
//
//  Created by distiller on 6/6/24.
//
//  This file was automatically generated and should not be edited.
//

#import "MSMessageExtensionDataPublicKey+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSMessageExtensionDataPublicKey (CoreDataProperties)

+ (NSFetchRequest<MSMessageExtensionDataPublicKey *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *crv;
@property (nullable, nonatomic, copy) NSString *kty;
@property (nullable, nonatomic, copy) NSString *x;
@property (nullable, nonatomic, copy) NSString *y;
@property (nullable, nonatomic, retain) MSMessageExtensionData *messageExtensionData;

@end

NS_ASSUME_NONNULL_END
