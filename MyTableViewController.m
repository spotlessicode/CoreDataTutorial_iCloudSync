//
//  MyTableViewController.m
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 11. 16..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import "MyTableViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "Type.h"
#import "ViewController.h"
#import "Hobby.h"

@interface MyTableViewController ()

@property (strong, nonatomic) NSMutableArray *userchangeArray;
@end

@implementation MyTableViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize myArray, selecteduser;

- (NSMutableArray *)userchangeArray {
    if (! _userchangeArray) {
        
        
        _userchangeArray = [_fetchedResultsController.fetchedObjects mutableCopy];
        
    }
    return _userchangeArray;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    //do fetchrequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"User" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //set SortDescriptor
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"displayOrder" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    //create FetchedResultsController with context, sectionNameKeyPath, and you can cache here, so the next work if the same you can use your cash file.
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    
    // Perform Fetch
    NSError *error = nil;
    [_fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
     [self.tableView reloadData];
    return _fetchedResultsController;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    //self.myArray =[[appDelegate getAllUserRecords]mutableCopy];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    
    [_fetchedResultsController performFetch:nil];
    self.myArray =[_fetchedResultsController.fetchedObjects mutableCopy];

    
    [self.tableView reloadData];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.scrollEnabled = YES;
    [self.tableView setEditing:NO];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.2; //seconds
    longPress.delegate = self;
    [self.tableView addGestureRecognizer:longPress];
    

    


    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    //return myArray.count;
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    NSString *attributeName = @"userName";
    NSString *attributeValue = @"user";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attributeName, attributeValue];
    [myArray filteredArrayUsingPredicate:predicate];



     User *user1 = [_fetchedResultsController.fetchedObjects  objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user1.displayOrder, user1.userName];
    
    NSArray *hobbiesArray = [user1.hobbiesofuser allObjects];
    
    Hobby *hobby1 = [hobbiesArray firstObject];

    
    // detect typeName with "typeofuser" relationship
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", user1.typeofuser.typeName, hobby1.hobbyName];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selecteduser = [_fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"selectuser" sender:self];
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"selectuser"]) {
        
        ViewController * detailViewController = (ViewController *)segue.destinationViewController;
        detailViewController.selecteduser = selecteduser;
    }
    

}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.tableView beginUpdates];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        _managedObjectContext = [appDelegate managedObjectContext];
        
        // delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //delete data from database
        
        [self.managedObjectContext deleteObject:[_fetchedResultsController.fetchedObjects  objectAtIndex:indexPath.row]];
        
        NSError *error;
        
        if (![self.managedObjectContext save:&error]) {
            
            NSLog(@"Whoops, couldn't save:%@", [error localizedDescription]);
        }
        self.myArray = [_fetchedResultsController.fetchedObjects mutableCopy];
        
        [self.tableView endUpdates];
        
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

/*

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)controllerWillChangeContent:
(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - Gestures


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    
    UIGestureRecognizerState state = longPressRecognizer.state;
    
    CGPoint location = [longPressRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                [self.tableView setScrollEnabled:NO];
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            
            
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            _userchangeArray = [_fetchedResultsController.fetchedObjects mutableCopy];

            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                
                // ... update data source.
                [_userchangeArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            
            int i = 0;
            for (NSManagedObject *savechange in self.userchangeArray)
            {
                [savechange setValue:[NSNumber numberWithInt:i++] forKey:@"displayOrder"];
            }
            
            self.userchangeArray= nil;
            
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            
            break;
        }
            
        default: {
            // Clean up.
            [self.tableView setScrollEnabled:YES];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0;
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                [snapshot removeFromSuperview];
                snapshot = nil;
                cell.hidden = NO;
            }];
            sourceIndexPath = nil;
            
            break;
        }
    }
}
#pragma mark - Helper methods


- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    
    // make an image from the pressed tableview cell
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // create and image view that we will drag around the screen
    UIView *snapshot = [[UIImageView alloc] initWithImage:cellImage];
    return snapshot;
}


@end
