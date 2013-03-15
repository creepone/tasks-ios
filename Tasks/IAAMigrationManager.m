#import "IAAMigrationManager.h"
#import "IAADefaultsManager.h"
#import "IAAUtils.h"
#import "IAACoreDataStack.h"
#import "IAADataAccess.h"

#define kCurrentDataStoreVersion 1

@interface IAAMigrationManager()

+ (BOOL)createDefaultObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (BOOL)migrateFromVersion:(NSInteger)version error:(NSError **)error;
+ (BOOL)postMigrationVersion:(NSInteger)version inContext:(NSManagedObjectContext *)context error:(NSError **)error;

@end

@implementation IAAMigrationManager

+ (IAACoreDataStack *)coreDataStack:(NSError **)error
{
    int lastInstalledVersion = [IAADefaultsManager dataStoreVersion];
    IAACoreDataStack *result;
    
    if(lastInstalledVersion == kCurrentDataStoreVersion) {
        return [self coreDataStackForModelVersion:kCurrentDataStoreVersion error:error];
    }
    else if(lastInstalledVersion == 0) {
        result = [self coreDataStackForModelVersion:kCurrentDataStoreVersion error:error];
        
        if(*error != nil)
            return nil;
        
        [self createDefaultObjectsInContext:result.managedObjectContext error:error];
        
        if(*error != nil)
            return nil;
    }
    else {
        [self migrateFromVersion:lastInstalledVersion error:error];
        
        if(*error != nil)
            return nil;
        
        result = [self coreDataStackForModelVersion:kCurrentDataStoreVersion error:error];
        
        if(*error != nil)
            return nil;
        
        [self postMigrationVersion:lastInstalledVersion inContext:result.managedObjectContext error:error];
        
        if(*error != nil)
            return nil;
    }

    [IAADefaultsManager setDataStoreVersion:kCurrentDataStoreVersion];
    return result;
}

+ (IAACoreDataStack *)coreDataStackForModelVersion:(NSInteger)version error:(NSError **)error
{
    NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePathVersion:version]];    
    return [IAACoreDataStack coreDataStackWithStoreURL:storeURL andModel:[self modelVersion:version] error:error];
}

+ (NSManagedObjectModel *)currentModel
{
    NSString *momdPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
    NSURL *momdURL = [NSURL fileURLWithPath:momdPath];
    
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:momdURL];
}

+ (NSManagedObjectModel *)modelVersion:(NSInteger)version
{
    if(version == kCurrentDataStoreVersion) {
        return [self currentModel];
    }
    else {
        NSString *momdPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
        NSString *resourceSubpath = [momdPath lastPathComponent];
        
        NSString *momName = version == 1 ? @"Model" : [NSString stringWithFormat:@"Model %d", version];
        NSString *momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"mom" inDirectory:resourceSubpath];
        NSURL *momURL = [NSURL fileURLWithPath:momPath];
        
        return [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    }
}

+ (NSString *)dataStorePathVersion:(NSInteger)version
{
    NSString *sqliteName = [self dataStoreNameVersion:version];
    return [[IAAUtils documentDirectoryPath] stringByAppendingPathComponent:sqliteName];
}

+ (NSString *)dataStoreNameVersion:(NSInteger)version
{
    return [NSString stringWithFormat:@".Tasks%d.sqlite", version];
}


+ (BOOL)createDefaultObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    IAACategory *categoryHigh = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([IAACategory class]) inManagedObjectContext:context];
    categoryHigh.name = @"High";
    categoryHigh.order = 0;
    
    IAACategory *categoryMedium = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([IAACategory class]) inManagedObjectContext:context];
    categoryMedium.name = @"Medium";
    categoryMedium.order = 1;
    
    IAACategory *categoryLow = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([IAACategory class]) inManagedObjectContext:context];
    categoryLow.name = @"Low";
    categoryLow.order = 2;
    
    return [context save:error];
}

+ (BOOL)migrateFromVersion:(NSInteger)version error:(NSError **)error
{
    NSURL *sourceStoreURL = [NSURL fileURLWithPath:[self dataStorePathVersion:version]];
    NSURL *targetStoreURL = [NSURL fileURLWithPath:[self dataStorePathVersion:kCurrentDataStoreVersion]];
	
    NSManagedObjectModel *sourceModel = [self modelVersion:version];
    NSManagedObjectModel *targetModel = [self modelVersion:kCurrentDataStoreVersion];
    
    NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:targetModel];
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:targetModel];
    
	if(mappingModel == nil) {
        return NO;
    }
    
    [migrationManager migrateStoreFromURL:sourceStoreURL
                                               type:NSSQLiteStoreType
                                            options:nil
                                   withMappingModel:mappingModel
                                   toDestinationURL:targetStoreURL
                                    destinationType:NSSQLiteStoreType
                                 destinationOptions:nil
                                              error:error];
    if(*error != nil) 
        return NO;
    
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	[fileManager removeItemAtPath:[self dataStorePathVersion:version] error:error];
    
    if(*error != nil)
        return NO;
    
    return YES;
}

+ (BOOL)postMigrationVersion:(NSInteger)version inContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    return [context save:error];
}


@end
