#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "IAATask.h"
#import "IAAPatch.h"
#import "IAACategory.h"

@interface IAADataAccess : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *context;

/**
 Initializes a new instance of the data access. If "useNewContext" flag is set, a new managed object context will be 
 created and used for all the queries operations etc. If the flag is not set, the global context for the application
 will be reused.
 */
- (id)initWithNewContext:(BOOL)useNewContext;

/**
 Initializes a new instance of the data access using the given managed object context.
 */
- (id)initWithContext:(NSManagedObjectContext *)context;

/**
 Shared data access instance that uses the global managed object context for its operations.
 */
+ (IAADataAccess *)sharedDataAccess;

- (void)deleteObject:(NSManagedObject *)object;
- (BOOL)deleteObject:(NSManagedObject *)object error:(NSError **)error;
- (BOOL)saveChanges:(NSError **)error;
- (void)rollbackChanges;
- (void)processChanges;

- (id)createObject:(Class)class;

- (NSFetchedResultsController *)fetchedResultsControllerForAllCategories;
- (NSFetchedResultsController *)fetchedResultsControllerForTasksOfCategory:(IAACategory *)category;
- (NSFetchedResultsController *)fetchedResultsControllerForDueTasks;
- (NSFetchedResultsController *)fetchedResultsControllerForTasksDueBetween:(NSDate *)startDate and:(NSDate *)endDate;

- (NSInteger)countOfTasksInCategory:(IAACategory *)category;
- (NSInteger)countOfDueTasks;
- (NSInteger)countOfTasksDueBetween:(NSDate *)startDate and:(NSDate *)endDate;

- (NSString *)lastAvailablePatchId;

- (IAAPatch *)getPatchWithClientId:(NSString *)clientPatchId;
- (IAATask *)getTaskWithId:(NSString *)taskId;
- (IAACategory *)getCategoryWithName:(NSString *)name;

- (NSArray *)findDownloadedPatches;
- (NSArray *)findPatchesWithTaskId:(NSString *)taskId;

- (void)performForEachSchedulableTask:(void (^)(IAATask *task))block;
- (void)performForEachPatchToSync:(void (^)(IAAPatch *patch))block;

@end
