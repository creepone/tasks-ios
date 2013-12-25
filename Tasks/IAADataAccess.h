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
- (NSFetchedResultsController *)fetchedResultsControllerForTasksDueUntil:(NSDate *)date;

- (NSInteger)countOfTasksInCategory:(IAACategory *)category;
- (NSInteger)countOfTasksDueUntil:(NSDate *)date;

- (void)performForEachSchedulableTask:(void (^)(IAATask *task))block;
- (void)performForEachPatchToSync:(void (^)(IAAPatch *patch))block;

@end
