//
//  AppDelegate.h
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 11. 16..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSPersistentStore *store;
@property (nonatomic, readonly) NSPersistentStore *iCloudStore;

- (NSURL *)applicationStoresDirectory;
- (void)setupCoreData;
- (void)saveContext;
- (BOOL)reloadStore;
- (NSURL *)applicationDocumentsDirectory;
-(NSArray*)getAllUserRecords;
- (BOOL)iCloudAccountIsSignedIn;

@end

