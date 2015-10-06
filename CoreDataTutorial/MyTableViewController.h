//
//  MyTableViewController.h
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 11. 16..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"


@interface MyTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSMutableArray *myArray;
@property (strong, nonatomic) User *selecteduser;
- (UIView *)customSnapshotFromView:(UIView *)inputView;

@end
