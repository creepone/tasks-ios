//
//  IAAPatch.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAAPatch.h"
#import "IAADataAccess.h"
#import "IAATaskChanges.h"
#import "NSArray+Extensions.h"
#import "IAAUtils.h"
#import "IAALog.h"
#import "NSSet+Extensions.h"
#import "NSObject+SBJson.h"

@interface IAAPatch()

+ (BOOL)isDate:(NSDate *)first equalTo:(NSDate *)second;
+ (NSArray *)categoryNames:(NSSet *)categories;
+ (NSString *)stringForOperation:(IAAPatchOperation)operation;

@end

@implementation IAAPatch

@dynamic body;
@dynamic id;
@dynamic operation;
@dynamic taskId;
@dynamic timestamp;

+ (void)generateInsertPatch:(IAATaskChanges *)taskChanges id:(NSString *)uuid
{
    IAAPatch *patch = [[IAADataAccess sharedDataAccess] createObject:[IAAPatch class]];
    [patch setOperation:kIAAPatchOperationAdd];
    [patch setTimestamp:[NSDate date]];
    [patch setTaskId:uuid];
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setObject:taskChanges.name forKey:@"name"];
    [body setObject:taskChanges.notes forKey:@"notes"];
    
    if (taskChanges.reminderDate != nil) {
        NSDictionary *reminder = @{
            @"important": @(taskChanges.reminderImportant),
            @"time": @([taskChanges.reminderDate timeIntervalSince1970] * 1000)
        };
        [body setObject:reminder forKey:@"reminder"];
    }
    
    [body setObject:[self categoryNames:taskChanges.categories]  forKey:@"categories"];
    [patch setBody:[NSKeyedArchiver archivedDataWithRootObject:body]];
    DDLogInfo(@"add = %@", [patch JSONRepresentation]);
}

+ (void)generateUpdatePatch:(IAATaskChanges *)taskChanges forTask:(IAATask *)task
{
    IAAPatch *patch = [[IAADataAccess sharedDataAccess] createObject:[IAAPatch class]];
    [patch setOperation:kIAAPatchOperationEdit];
    [patch setTimestamp:[NSDate date]];
    [patch setTaskId:task.id];
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    if (![taskChanges.name isEqualToString:task.name]) {
        NSDictionary *change = @{
            @"old": task.name,
            @"new": taskChanges.name
        };
        [body setObject:change forKey:@"name"];
    }
    
    if (![taskChanges.notes isEqualToString:task.notes]) {
        NSDictionary *change = @{
            @"old": task.notes,
            @"new": taskChanges.notes
        };
        [body setObject:change forKey:@"notes"];
    }
    
    BOOL reminderImportantChanged = task.reminderImportant != taskChanges.reminderImportant;
    BOOL reminderDateChanged = ![self isDate:task.reminderDate equalTo:taskChanges.reminderDate];
    if (reminderDateChanged || reminderImportantChanged) {
        NSMutableDictionary *change = [NSMutableDictionary dictionary];
        if (reminderImportantChanged)
            [change setObject:@(taskChanges.reminderImportant) forKey:@"important"];
        if (reminderDateChanged) {
            if (taskChanges.reminderDate == nil)
                [change setObject:[NSNull null] forKey:@"time"];
            else
                [change setObject:@([taskChanges.reminderDate timeIntervalSince1970] * 1000) forKey:@"time"];
        }
        [body setObject:change forKey:@"reminder"];
    }

    NSSet *removed = [task.categories difference:taskChanges.categories];
    NSSet *added = [taskChanges.categories difference:task.categories];
    if ([removed count] > 0 || [added count] > 0) {
        NSMutableDictionary *change = [NSMutableDictionary dictionary];
        if ([removed count] > 0)
            [change setObject:[self categoryNames:removed] forKey:@"$remove"];
        if ([added count] > 0)
            [change setObject:[self categoryNames:added] forKey:@"$add"];
        [body setObject:change forKey:@"categories"];
    }
    
    [patch setBody:[NSKeyedArchiver archivedDataWithRootObject:body]];
    DDLogInfo(@"edit = %@", [patch JSONRepresentation]);
}

+ (void)generateRemovePatch:(IAATask *)task
{
    IAAPatch *patch = [[IAADataAccess sharedDataAccess] createObject:[IAAPatch class]];
    [patch setOperation:kIAAPatchOperationRemove];
    [patch setTimestamp:[NSDate date]];
    [patch setTaskId:task.id];
    
    DDLogInfo(@"delete = %@", [patch JSONRepresentation]);
}

- (NSString *)JSONRepresentation
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setObject:self.taskId forKey:@"taskId"];
    [json setObject:@([self.timestamp timeIntervalSince1970] * 1000) forKey:@"clientTimestamp"];
    [json setObject:[IAAPatch stringForOperation:self.operation] forKey:@"operation"];
    
    if (self.body != nil)
        [json setObject:[NSKeyedUnarchiver unarchiveObjectWithData:self.body] forKey:@"body"];
    
    return [json iaa_JSONRepresentation];
}


#pragma mark - Private Helpers

+ (BOOL)isDate:(NSDate *)first equalTo:(NSDate *)second
{
    if (first == nil)
        return second == nil;
    if (second == nil)
        return NO;
    
    return [first isEqualToDate:second];
}

+ (NSArray *)categoryNames:(NSSet *)categories
{
    return [[categories allObjects] iaa_mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
        return [obj name];
    }];
}

+ (NSString *)stringForOperation:(IAAPatchOperation)operation
{
    switch (operation)
    {
        case kIAAPatchOperationAdd:
            return @"add";
        case kIAAPatchOperationEdit:
            return @"edit";
        case kIAAPatchOperationRemove:
            return @"remove";
    }
    
    return @"unknown";
}

@end
