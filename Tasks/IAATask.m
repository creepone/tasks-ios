//
//  IAATask.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "BSONIdGenerator.h"
#import "IAATask.h"
#import "IAATaskChanges.h"
#import "IAADataAccess.h"
#import "IAAErrorManager.h"
#import "IAANotificationManager.h"
#import "IAAUtils.h"

@implementation IAATask

@dynamic id;
@dynamic name;
@dynamic reminderDate;
@dynamic reminderImportant;
@dynamic lastClientPatchId;
@dynamic notes;
@dynamic categories;

+ (void)insert:(IAATaskChanges *)taskChanges
{
    BOOL needsReschedule = taskChanges.reminderDate != nil;
    NSString *taskId = [BSONIdGenerator generate];
    IAAPatch *patch = [IAAPatch generateInsertPatch:taskChanges id:taskId];
        
    IAATask *task = [[IAADataAccess sharedDataAccess] createObject:[IAATask class]];
    [task setId:taskId];
    [task setName:taskChanges.name];
    [task setReminderDate:taskChanges.reminderDate];
    [task setReminderImportant:taskChanges.reminderImportant];
    [task setNotes:taskChanges.notes];
    [task setCategories:taskChanges.categories];
    [task setLastClientPatchId:patch.clientPatchId];
    
    NSError *error;
    [[IAADataAccess sharedDataAccess] saveChanges:&error];
    [IAAErrorManager checkError:error];
    
    if (needsReschedule)
        [[IAANotificationManager sharedManager] rescheduleAll];
}

+ (void)update:(IAATask *)task with:(IAATaskChanges *)taskChanges
{
    BOOL needsReschedule = [task.reminderDate compare:taskChanges.reminderDate] != NSOrderedSame || task.reminderImportant != taskChanges.reminderImportant;
    IAAPatch *patch = [IAAPatch generateUpdatePatch:taskChanges forTask:task];
    
    [task setName:taskChanges.name];
    [task setNotes:taskChanges.notes];
    [task setCategories:taskChanges.categories];
    [task setReminderImportant:taskChanges.reminderImportant];
    [task setReminderDate:taskChanges.reminderDate];
    [task setLastClientPatchId:patch.clientPatchId];
    
    NSError *error;
    [[IAADataAccess sharedDataAccess] saveChanges:&error];
    [IAAErrorManager checkError:error];
    
    if (needsReschedule)
        [[IAANotificationManager sharedManager] rescheduleAll];
}

+ (void)remove:(IAATask *)task
{
    BOOL needsReschedule = task.reminderDate != nil;
    [IAAPatch generateRemovePatch:task];
    
    NSError *error;
    [[IAADataAccess sharedDataAccess] deleteObject:task error:&error];
    [IAAErrorManager checkError:error];
    
    if (needsReschedule)
        [[IAANotificationManager sharedManager] rescheduleAll];
}

@end
