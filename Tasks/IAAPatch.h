//
//  IAAPatch.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
	kIAAPatchOperationAdd = 1,
    kIAAPatchOperationEdit = 2,
    kIAAPatchOperationRemove = 3
} IAAPatchOperation;

typedef enum {
	kIAAPatchStateLocal = 1,
    kIAAPatchStateDownloaded = 2,
    kIAAPatchStateServer = 3
} IAAPatchState;

@class IAATask, IAATaskChanges;

@interface IAAPatch : NSManagedObject

@property (nonatomic, retain) NSData * body;
@property (nonatomic, retain) NSString * id;
@property (nonatomic) int16_t operation;
@property (nonatomic) int16_t state;
@property (nonatomic, retain) NSString * taskId;
@property (nonatomic, retain) NSString * clientPatchId;

+ (IAAPatch *)generateInsertPatch:(IAATaskChanges *)taskChanges id:(NSString *)uuid;
+ (IAAPatch *)generateUpdatePatch:(IAATaskChanges *)taskChanges forTask:(IAATask *)task;
+ (IAAPatch *)generateRemovePatch:(IAATask *)task;

- (NSString *)JSONRepresentation;
- (NSDictionary *)dictionaryRepresentation;

+ (IAAPatchOperation)operationForString:(NSString *)operation;

@end
