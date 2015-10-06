//
//  ViewController.h
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 11. 16..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) IBOutlet UITextField *TextField1;
@property (strong, nonatomic) IBOutlet UITextField *TextField2;
@property (strong, nonatomic) IBOutlet UIButton *myButton;
@property (strong, nonatomic) User *selecteduser;
@property (strong, nonatomic) NSArray *myArray;
@property (strong, nonatomic) NSString *samestring;
@property (strong, nonatomic) IBOutlet UITextField *TextField3;


@end

