//
//  IAATask.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IAATask : NSManagedObject

@property (nonatomic) BOOL done;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * reminderDate;
@property (nonatomic) BOOL reminderImportant;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet *categories;
@end

@interface IAATask (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(NSManagedObject *)value;
- (void)removeCategoriesObject:(NSManagedObject *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
