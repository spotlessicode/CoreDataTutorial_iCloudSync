//
//  AppDelegate.m
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 11. 16..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

NSString *storeFilename = @"CoreDataTutorial.sqlite";
NSString *iCloudStoreFilename = @"iCloud.sqlite";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self iCloudAccountIsSignedIn];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self setupCoreData];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory  {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "pepzen.CoreDataTutorial" in the application's documents directory.
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
}

- (NSURL *)applicationStoresDirectory {
    
    NSURL *storesDirectory =
    [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            
            NSLog(@"Successfully created application Stores directory");}
        
        else {NSLog(@"Failed to create application Stores directory: %@", error);}
    }
    return storesDirectory;
}

- (NSURL *)storeURL {
    
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

- (NSURL *)iCloudStoreURL {
    
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:iCloudStoreFilename];
}

- (id)init {

    self = [super init];
    if (!self) {return nil;}

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataTutorial" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    [self listenForStoreChanges];
    

    return self;
}

- (void)setupCoreData {
 
    if (self.iCloudAccountIsSignedIn == YES) {
        
        NSLog(@"----Load the iCloud Store----");
        
        if ([self loadiCloudStore]) {
            return;
        }
    }else{
        
        NSLog(@"----Load the Local, Non-iCloud Store----");
        
        [self loadStore];
    }

}

- (void)loadStore {
    
    if (_store) {return;} // Don’t load store if it’s already loaded!!
    
    BOOL useMigrationManager = NO;
    if (useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    
    } else {
        NSDictionary *options =@{ NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@YES
          //,NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"} // Uncomment to disable WAL journal mode
                                  };
        NSError *error = nil;
        _store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:[self storeURL]
                                                                 options:options
                                                                   error:&error];
        if (!_store) {
            NSLog(@"Failed to add store!! Error: %@", error);abort();
        }
        
        else{
            NSLog(@"Successfully added store: %@", _store);
        }
    }
    
}
#pragma mark - Core Data Migration Support

//check if migration needs

- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        
        NSLog(@"SKIPPED MIGRATION: Source database is missing.");
        
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeUrl
                                                                                          options:nil
                                                                                            error:&error ];
    
    NSManagedObjectModel *destinationModel = _persistentStoreCoordinator.managedObjectModel;
    
    if ([destinationModel isConfiguration:nil
              compatibleWithStoreMetadata:sourceMetadata]) {
        
        NSLog(@"SKIPPED MIGRATION: Source database is already compatible");
        
        return NO;
    }
    
    return YES;
}

- (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL {
    
    
    // Perform migration in the background.

    dispatch_async(
                   dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                       BOOL done = [self migrateStore:storeURL];
                       if(done) {
                           
                           // When migration finishes, add the newly migrated store
                           dispatch_async(dispatch_get_main_queue(), ^{
                               NSError *error = nil;
                               _store =
                               [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                         configuration:nil
                                                                                   URL:[self storeURL]
                                                                               options:nil
                                                                                 error:&error];
                               if (!_store) {
                                   NSLog(@"Failed to add a migrated store. Error: %@",
                                         error);abort();}
                               else {
                                   NSLog(@"Successfully added a migrated store: %@",
                                         _store);}

                           });
                       }
                   });
}

- (BOOL)migrateStore:(NSURL*)sourceStore {
    
    BOOL success = NO;
    NSError *error = nil;
    
    // STEP 1: Collect the Source, Destination and Mapping Model
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:sourceStore
                                                                                          options:nil
                                                                                            error:&error];
    
    
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil
                                                                    forStoreMetadata:sourceMetadata];
    
    NSManagedObjectModel *destinModel = _managedObjectModel;
    
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                            forSourceModel:sourceModel
                                                          destinationModel:destinModel];
    
    // STEP 2: Perform migration
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager =
        [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                       destinationModel:destinModel];
        
        [migrationManager addObserver:self
                           forKeyPath:@"migrationProgress"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
        
        NSURL *destinStore = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success =[migrationManager migrateStoreFromURL:sourceStore
                                                  type:NSSQLiteStoreType options:nil
                                      withMappingModel:mappingModel
                                      toDestinationURL:destinStore
                                       destinationType:NSSQLiteStoreType
                                    destinationOptions:nil
                                                 error:&error];
        if (success) {
            // STEP 3: Replace the old store with the new migrated one
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                
                NSLog(@"SUCCESSFULLY MIGRATED %@ to the Current Model",sourceStore.path);
                
                [migrationManager removeObserver:self
                                      forKeyPath:@"migrationProgress"];
            }
        }
        else {
            
            NSLog(@"FAILED MIGRATION: %@",error);
        }
    }
    else {
       
        NSLog(@"FAILED MIGRATION: Mapping Model is null");
    }
    
    return YES; // indicates migration has finished
}

- (BOOL)replaceStore:(NSURL*)old withStore:(NSURL*)new {
    
    BOOL success = NO;
    NSError *Error = nil;
    
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&Error]) {
        
        Error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&Error]) {
            
            success = YES;
        }
        else {
            
            NSLog(@"FAILED to relocate new store %@", Error);
        }
    }
    else {
        
        NSLog(@"FAILED to remove old store %@: Error:%@", old, Error);
    
    }
    return success;
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


-(NSArray*)getAllUserRecords{
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc]initWithKey:@"userName" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(hobbiesofuser.@count !=0)"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedRecords;
    

    
}

#pragma mark - iCloud
- (BOOL)iCloudAccountIsSignedIn {
    
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (token) {
        NSLog(@"----iCloud is Logged In with token '%@' ----", token);
        return YES;
    }
    NSLog(@"---- iCloud is NOT Logged In ----");
    NSLog(@"Check these: Is iCloud Documents and Data enabled??? (Mac, IOS Device)--- iCloud Capability -App Target, ---- Code Sign Entitlements Error??");
    
    return NO;
}

- (BOOL)loadiCloudStore {
    
    if (_iCloudStore) {
        return YES;
    } // Don't load iCloud store if it's already loaded
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption:@YES,
                              NSInferMappingModelAutomaticallyOption:@NO,
                              NSPersistentStoreUbiquitousContentNameKey:@"Purp",
                              //,NSPersistentStoreUbiquitousContentURLKey:@"ChangeLogs" // Optional since iOS7
                              };
    NSError *error;
    _iCloudStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:[self iCloudStoreURL]
                                                    options:options
                                                      error:&error];
    if (_iCloudStore) {
        NSLog(@"** The iCloud Store has been successfully configured at '%@' **", _iCloudStore.URL.path);
        return YES;
    }
    
    NSLog(@"** FAILED to configure the iCloud Store : %@ **", error);
    return NO;
}

- (void)listenForStoreChanges {
    
    //indicate that the store is about to change

    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(storesWillChange:)
               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
             object:_persistentStoreCoordinator];
    [dc addObserver:self
           selector:@selector(storesDidChange:)
               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
             object:_persistentStoreCoordinator];
    [dc addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitiousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:_persistentStoreCoordinator];
}

- (void)storesWillChange:(NSNotification *)n {
    
    //react to the store change notifications

    [_managedObjectContext performBlockAndWait:^{
        [_managedObjectContext save:nil];
        [self resetContext:_managedObjectContext]; }];

    // Refresh UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                        object:nil
                                                      userInfo:nil];
}
- (void)storesDidChange:(NSNotification *)n {
    
    //store has changed
    // Refresh UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                        object:nil
                                                      userInfo:nil];
}

- (void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification*)n {
    
    //update the context of the user interface
    [_managedObjectContext performBlock:^{
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:n];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    }];
}
- (void)somethingChanged {
    
    // Notification: refresh data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
}

- (void)resetContext:(NSManagedObjectContext*)moc {
    [moc performBlockAndWait:^{
        [moc reset];
    }];
}

- (BOOL)reloadStore {
    BOOL success = NO;
    NSError *error = nil;
    if (![_persistentStoreCoordinator removePersistentStore:_store error:&error]) {
        NSLog(@"Unable to remove persistent store : %@", error);
    }
    [self resetContext:_managedObjectContext];
    
    _store = nil;
    [self setupCoreData];
    [self somethingChanged];
    if (_store) {success = YES;}
    return success;
}

@end
