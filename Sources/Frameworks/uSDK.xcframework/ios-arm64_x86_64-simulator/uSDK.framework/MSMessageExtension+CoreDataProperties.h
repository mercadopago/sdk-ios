//
//  MSMessageExtension+CoreDataProperties.h
//  
//
//  Created by distiller on 6/6/24.
//
//  This file was automatically generated and should not be edited.
//

#import "MSMessageExtension+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSMessageExtension (CoreDataProperties)

+ (NSFetchRequest<MSMessageExtension *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *cardID;
@property (nonatomic) BOOL criticalityIndicator;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) MSMessageExtensionData *data;

@end

NS_ASSUME_NONNULL_END
