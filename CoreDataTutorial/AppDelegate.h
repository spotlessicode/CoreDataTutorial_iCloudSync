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

@property (readonly, nonatomic) NSPersistentStore *store;
@property (readonly, nonatomic) NSPersistentStore *iCloudStore;

- (BOOL)reloadStore;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(NSArray*)getAllUserRecords;
- (BOOL)iCloudAccountIsSignedIn;
@end

