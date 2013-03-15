//
//  IAACategory.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IAATask;

@interface IAACategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t order;
@property (nonatomic, retain) NSSet *tasks;

+ (void)renumberAll:(NSArray *)allCategories;

@end

@interface IAACategory (CoreDataGeneratedAccessors)

- (void)addTasksObject:(IAATask *)value;
- (void)removeTasksObject:(IAATask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
