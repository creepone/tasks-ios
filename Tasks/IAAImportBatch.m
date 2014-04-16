//
//  IAAImportBatch.m
//  Tasks
//
//  Created by Tomas Vana on 30/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "NSObject+Extensions.h"

#import "IAAImportBatch.h"
#import "IAADataAccess.h"
#import "IAATextMerge.h"
#import "IAAUtils.h"

@interface IAAImportBatch(){
    IAADataAccess *_dataAccess;
    NSDictionary *_data;
}

- (void)importPatch:(NSDictionary *)patchDict;
- (void)merge;

- (void)insertTask:(IAAPatch *)patch;
- (void)removeTask:(IAAPatch *)patch;
- (void)updateTask:(IAATask *)task withPatch:(IAAPatch *)patch;
- (IAACategory *)addCategory:(NSString *)categoryName;

- (void)simpleMerge:(IAATask *)task patches:(NSArray *)patches;
- (void)fullMerge:(IAATask *)task;

@end

@implementation IAAImportBatch

- (id)initWithDataAccess:(IAADataAccess *)dataAccess andData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _dataAccess = dataAccess;
        _data = data;
    }
    return self;
}

- (BOOL)importAll:(NSError **)error
{
    NSArray *patches = [_data objectForKey:@"patches"];
    
    for (NSDictionary *patch in patches) {
        [self importPatch:patch];
    }
    
    [_dataAccess saveChanges:error];
    if (*error != nil)
        return NO;
    
    [self merge];
    
    [_dataAccess saveChanges:error];
    if (*error != nil)
        return NO;
    
    return YES;
}

- (void)importPatch:(NSDictionary *)patchDict
{
    NSString *clientPatchId = [patchDict objectForKey:@"clientPatchId"];
    
    IAAPatch *patch = [_dataAccess getPatchWithClientId:clientPatchId];
    if (patch != nil)
        return;
    
    patch = [_dataAccess createObject:[IAAPatch class]];
    
    [patch setId:[patchDict objectForKey:@"_id"]];
    [patch setClientPatchId:clientPatchId];
    [patch setTaskId:[patchDict objectForKey:@"taskId"]];
    [patch setState:kIAAPatchStateDownloaded];
    [patch setOperation:[IAAPatch operationForString:[patchDict objectForKey:@"operation"]]];
    
    [patch setBody:[NSKeyedArchiver archivedDataWithRootObject:[patchDict objectForKey:@"body"]]];
}

- (void)merge
{
    NSArray *patches = [_dataAccess findDownloadedPatches];
    
    for (IAAPatch *patch in patches) {
        if (patch.operation == kIAAPatchOperationAdd)
            [self insertTask:patch];
    }
    
    NSMutableArray *removedIds = [NSMutableArray array];
    
    for (IAAPatch *patch in patches) {
        if (patch.operation == kIAAPatchOperationRemove) {
            [self removeTask:patch];
            [removedIds addObject:patch.taskId];
        }
    }
    
    NSMutableDictionary *taskMap = [NSMutableDictionary dictionary];
    NSMutableArray *fullMergeTasks = [NSMutableArray array];
    NSMutableDictionary *taskPatchesMap = [NSMutableDictionary dictionary];
    
    for (IAAPatch *patch in patches) {
        if (patch.operation == kIAAPatchOperationEdit && ![removedIds containsObject:patch.taskId]) {
            IAATask *task = [taskMap objectForKey:patch.taskId];
            task = task ? : [_dataAccess getTaskWithId:patch.taskId];
            if (task == nil)
                continue;
            
            [taskMap setObject:task forKey:patch.taskId];
            [taskPatchesMap setObject:[NSMutableArray array] forKey:patch.taskId];
        }
    }
    
    for (IAAPatch *patch in patches) {
        if (patch.operation == kIAAPatchOperationEdit) {
            IAATask *task = [taskMap objectForKey:patch.taskId];
            if (task == nil)
                continue;
            
            NSComparisonResult order = [task.lastClientPatchId compare:patch.clientPatchId];
            
            if (task.lastClientPatchId != nil && (order == NSOrderedSame || order == NSOrderedDescending)) {
                [fullMergeTasks addObject:task];
                [taskMap removeObjectForKey:patch.taskId];
                [taskPatchesMap removeObjectForKey:patch.taskId];
            }
            else {
                NSMutableArray *taskPatches = [taskPatchesMap objectForKey:patch.taskId];
                [taskPatches addObject:patch];
            }
        }
    }
    
    for (NSString *taskId in [taskPatchesMap allKeys])
    {
        IAATask *taskToMerge = [taskMap objectForKey:taskId];
        NSArray *taskPatches = [taskPatchesMap objectForKey:taskId];
        
        [self simpleMerge:taskToMerge patches:taskPatches];
    }
    
    for (IAATask *task in fullMergeTasks)
        [self fullMerge:task];
    
    for (IAAPatch *patch in patches)
        [patch setState:kIAAPatchStateServer];
}

- (void)insertTask:(IAAPatch *)patch
{
    IAATask *task = [_dataAccess getTaskWithId:patch.taskId];
    if (task == nil)
        task = [_dataAccess createObject:[IAATask class]];
    
    [task setId:patch.taskId];
    [task setLastClientPatchId:patch.clientPatchId];
    
    NSDictionary *body = [NSKeyedUnarchiver unarchiveObjectWithData:patch.body];
    
    NSString *name = [body objectForKey:@"name"];
    if (![IAAUtils isNilOrNull:name])
        [task setName:name];
    
    NSString *notes = [body objectForKey:@"notes"];
    if (![IAAUtils isNilOrNull:notes])
        [task setNotes:notes];
    
    NSDictionary *reminder = [body objectForKey:@"reminder"];
    if (reminder != nil) {
        [task setReminderImportant:[[reminder objectForKey:@"important"] boolValue]];
        NSTimeInterval date = [[reminder objectForKey:@"time"] doubleValue] / 1000;
        [task setReminderDate:[NSDate dateWithTimeIntervalSince1970:date]];
        
    }
    
    NSArray *categories = [body objectForKey:@"categories"];
    if (categories != nil) {
        for (NSString *categoryName in categories) {
            IAACategory *category = [_dataAccess getCategoryWithName:categoryName];
            if (category == nil)
                category = [self addCategory:categoryName];
            
            [task addCategoriesObject:category];
        }
    }
}

- (void)removeTask:(IAAPatch *)patch
{
    IAATask *task = [_dataAccess getTaskWithId:patch.taskId];
    if (task == nil)
        return;
    
    [_dataAccess deleteObject:task];
}

- (void)updateTask:(IAATask *)task withPatch:(IAAPatch *)patch
{
    NSDictionary *body = [NSKeyedUnarchiver unarchiveObjectWithData:patch.body];
    
    NSDictionary *name = [body objectForKey:@"name"];
    if (name != nil) {
        NSString *oldName = [[name objectForKey:@"old"] iaa_nilIfNull];
        NSString *newName = [[name objectForKey:@"new"] iaa_nilIfNull];
        
        [task setName:[IAATextMerge merge:oldName current:task.name new:newName]];
    }
    
    NSDictionary *notes = [body objectForKey:@"notes"];
    if (notes != nil) {
        NSString *oldNotes = [[notes objectForKey:@"old"] iaa_nilIfNull];
        NSString *newNotes = [[notes objectForKey:@"new"] iaa_nilIfNull];
        
        [task setNotes:[IAATextMerge merge:oldNotes current:task.notes new:newNotes]];
    }
    
    NSDictionary *reminder = [body objectForKey:@"reminder"];
    if (reminder != nil) {
        
        NSNumber *time = [reminder objectForKey:@"time"];
        if ([time isEqual:[NSNull null]]) {
            [task setReminderDate:nil];
            [task setReminderImportant:NO];
        }
        else {
            if (time != nil) {
                NSTimeInterval timeInterval = [time doubleValue] / 1000;
                [task setReminderDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
            }
            
            NSNumber *important = [reminder objectForKey:@"important"];
            if (important != nil)
                [task setReminderImportant:[important boolValue]];
        }
    }
    
    NSDictionary *categories = [body objectForKey:@"categories"];
    if (categories != nil) {
        NSArray *added = [categories objectForKey:@"add"];
        if (added != nil) {
            for (NSString *categoryName in added) {
                IAACategory *category = [_dataAccess getCategoryWithName:categoryName];
                if (category == nil)
                    category = [self addCategory:categoryName];
                
                [task addCategoriesObject:category];
            }
        }
        
        NSArray *removed = [categories objectForKey:@"remove"];
        if (removed != nil) {
            for (NSString *categoryName in removed) {
                IAACategory *category = [_dataAccess getCategoryWithName:categoryName];
                if (category == nil)
                    continue;
                
                [task removeCategoriesObject:category];
            }
        }
    }
}

- (IAACategory *)addCategory:(NSString *)categoryName
{
    IAACategory *category = [_dataAccess createObject:[IAACategory class]];
    
    category.name = categoryName;
    category.order = 0;
    
    // todo: maybe renumber all the categories at this point ?
    
    return category;
}


- (void)simpleMerge:(IAATask *)task patches:(NSArray *)patches
{
    if ([patches count] == 0)
        return;
    
    for (IAAPatch *patch in patches)
        [self updateTask:task withPatch:patch];
}

- (void)fullMerge:(IAATask *)task
{
    NSMutableArray *patches = [[_dataAccess findPatchesWithTaskId:task.id] mutableCopy];
    if ([patches count] == 0)
        return;
    
    IAAPatch *firstPatch = [patches objectAtIndex:0];
    
    if (firstPatch.operation != kIAAPatchOperationAdd) {
        NSLog(@"Inconsistent history of a task.");
        return;
    }
    
    // clear properties - to avoid reinsert
    [task setName:nil];
    [task setNotes:nil];
    [task setReminderDate:nil];
    [task setReminderImportant:NO];
    [task setLastClientPatchId:nil];
    [task setCategories:[NSSet set]];
    
    [self insertTask:firstPatch];
    [patches removeObjectAtIndex:0];
    
    [self simpleMerge:task patches:patches];
}



@end
