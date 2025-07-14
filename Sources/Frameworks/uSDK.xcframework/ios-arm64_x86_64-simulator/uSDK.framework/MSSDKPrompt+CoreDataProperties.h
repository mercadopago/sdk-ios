//
//  MSSDKPrompt+CoreDataProperties.h
//  
//
//  Created by distiller on 6/6/24.
//
//  This file was automatically generated and should not be edited.
//

#import "MSSDKPrompt+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSSDKPrompt (CoreDataProperties)

+ (NSFetchRequest<MSSDKPrompt *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *heading;
@property (nullable, nonatomic, copy) NSString *keyboard;
@property (nullable, nonatomic, copy) NSString *message;
@property (nullable, nonatomic, retain) MSMessageExtensionData *data;

@end

NS_ASSUME_NONNULL_END
