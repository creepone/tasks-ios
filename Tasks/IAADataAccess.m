#import "IAADataAccess.h"
#import "IAACoreDataStack.h"
#import "IAAAppDelegate.h"
#import "IAADefaultsManager.h"
#import "IAAErrorManager.h"

@interface IAADataAccess() {
    NSManagedObjectContext *_context;
}

@end

@implementation IAADataAccess

- (id)init
{
    return [self initWithNewContext:NO];
}

- (id)initWithNewContext:(BOOL)useNewContext
{    
    IAAAppDelegate *appDelegate = (IAAAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = useNewContext ? [appDelegate.coreDataStack newContext] : nil;
    return [self initWithContext:context];
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesIntoContext:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}


+ (IAADataAccess *)sharedDataAccess
{
    static dispatch_once_t once;
    static IAADataAccess *sharedDataAccess;
    dispatch_once(&once, ^ { sharedDataAccess = [[self alloc] init]; });
    return sharedDataAccess;
}

- (NSManagedObjectContext *)context
{
    if(_context == nil) {
        IAAAppDelegate *appDelegate = (IAAAppDelegate *)[[UIApplication sharedApplication] delegate];
        return appDelegate.coreDataStack.managedObjectContext;
    }
    else 
        return _context;
}

- (void)mergeChangesIntoContext:(NSNotification *)notification
{
    // only merge into the main context and if it's not the one notifying
    if (_context == nil && notification.object != self.context) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.context mergeChangesFromContextDidSaveNotification:notification];
        });
    }
}


- (void)deleteObject:(NSManagedObject *)object
{
    [self.context deleteObject:object];
}

- (BOOL)deleteObject:(NSManagedObject *)object error:(NSError **)error
{
    [self.context deleteObject:object];
    return [self saveChanges:error];
}

- (BOOL)saveChanges:(NSError **)error
{
	return [self.context save:error];
}

- (void)rollbackChanges
{
    [self.context rollback];
}

- (void)processChanges
{
    [self.context processPendingChanges];
}


- (id)createObject:(Class)class
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(class) inManagedObjectContext:self.context];
}

- (NSFetchedResultsController *)fetchedResultsControllerForAllCategories
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAACategory class]) inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTasksOfCategory:(IAACategory *)category
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAATask class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate;
    
    if (category == nil)
        predicate = [NSPredicate predicateWithFormat:@"categories.@count == 0"];
    else
        predicate = [NSPredicate predicateWithFormat:@"categories CONTAINS %@", category];
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *reminderSD = [[NSSortDescriptor alloc] initWithKey:@"reminderDate" ascending:YES];
    NSSortDescriptor *timestampSD = [[NSSortDescriptor alloc] initWithKey:@"lastClientPatchId" ascending:YES];
    [fetchRequest setSortDescriptors:@[reminderSD, timestampSD]];
    
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForDueTasks
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAATask class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reminderDate = nil OR reminderDate < %@", [NSDate date]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *reminderSD = [[NSSortDescriptor alloc] initWithKey:@"reminderDate" ascending:YES];
    NSSortDescriptor *timestampSD = [[NSSortDescriptor alloc] initWithKey:@"lastClientPatchId" ascending:YES];
    [fetchRequest setSortDescriptors:@[reminderSD, timestampSD]];
    
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTasksDueBetween:(NSDate *)startDate and:(NSDate *)endDate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAATask class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reminderDate != nil AND reminderDate >= %@ AND reminderDate < %@", startDate, endDate];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *reminderSD = [[NSSortDescriptor alloc] initWithKey:@"reminderDate" ascending:YES];
    NSSortDescriptor *timestampSD = [[NSSortDescriptor alloc] initWithKey:@"lastClientPatchId" ascending:YES];
    [fetchRequest setSortDescriptors:@[reminderSD, timestampSD]];
    
	return [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.context
            sectionNameKeyPath:nil
            cacheName:nil];
}

- (NSInteger)countOfTasksInCategory:(IAACategory *)category
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAATask class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate;
    
    if (category == nil)
        predicate = [NSPredicate predicateWithFormat:@"categories.@count == 0"];
    else
        predicate = [NSPredicate predicateWithFormat:@"categories CONTAINS %@", category];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSInteger result = [self.context countForFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    return result;
}

- (NSInteger)countOfDueTasks
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAATask class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reminderDate = nil OR reminderDate < %@", [NSDate date]];
    [fetchRequest setPredicate:predicate];

    NSError *error;
    NSInteger result = [self.context countForFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    return result;
}

- (NSInteger)countOfTasksDueBetween:(NSDate *)startDate and:(NSDate *)endDate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAATask class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reminderDate != nil AND reminderDate >= %@ AND reminderDate < %@", startDate, endDate];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSInteger result = [self.context countForFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    return result;
}

- (NSString *)lastAvailablePatchId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAAPatch class]) inManagedObjectContext:self.context]];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"clientPatchId"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxValue"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSStringAttributeType];
    
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    if (error != nil || [result count] != 1) {
        return nil;
    }
    else {
        NSDictionary *map = [result lastObject];
        return [map valueForKey:@"maxValue"];
    }
}

- (IAAPatch *)getPatchWithClientId:(NSString *)clientPatchId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAAPatch class]) inManagedObjectContext:self.context]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientPatchId = %@", clientPatchId];
    [fetchRequest setPredicate:predicate];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    if (error != nil || [result count] != 1)
        return nil;
    return [result lastObject];
}

- (IAATask *)getTaskWithId:(NSString *)taskId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAATask class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", taskId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    if (error != nil || [result count] != 1)
        return nil;
    return [result lastObject];
}

- (IAACategory *)getCategoryWithName:(NSString *)name
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAACategory class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    if (error != nil || [result count] != 1)
        return nil;
    return [result lastObject];
}

- (NSArray *)findDownloadedPatches
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAAPatch class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state = %@", @(kIAAPatchStateDownloaded)];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clientPatchId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
	NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    return result;
}

- (NSArray *)findPatchesWithTaskId:(NSString *)taskId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAAPatch class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId = %@", taskId];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clientPatchId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
	NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
    [IAAErrorManager checkError:error];
    
    return result;
}


- (void)performForEachSchedulableTask:(void (^)(IAATask *task))block
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAATask class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reminderDate != nil"];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:50];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"reminderDate" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    BOOL rowsLeft = YES;
    NSInteger fetchOffset = 0;
    
    while (rowsLeft)
    {
        [fetchRequest setFetchOffset:fetchOffset];
        
        NSArray *results = [self.context executeFetchRequest:fetchRequest error:&error];
        if (![IAAErrorManager checkError:error])
            break;
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            IAATask *task = (IAATask *)obj;
            block(task);
        }];
        
        rowsLeft = [results count] == 50;
        fetchOffset += 50;
    }
}

- (void)performForEachPatchToSync:(void (^)(IAAPatch *patch))block
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([IAAPatch class]) inManagedObjectContext:self.context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state = %@", @(kIAAPatchStateLocal)];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:50];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clientPatchId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    BOOL rowsLeft = YES;
    NSInteger fetchOffset = 0;
    
    while (rowsLeft)
    {
        [fetchRequest setFetchOffset:fetchOffset];
        
        NSArray *results = [self.context executeFetchRequest:fetchRequest error:&error];
        if (![IAAErrorManager checkError:error])
            break;
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            IAAPatch *patch = (IAAPatch *)obj;
            block(patch);
        }];
        
        rowsLeft = [results count] == 50;
        fetchOffset += 50;
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
