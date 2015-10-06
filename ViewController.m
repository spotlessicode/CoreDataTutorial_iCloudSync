//
//  ViewController.m
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 11. 16..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MyTableViewController.h"
#import "User.h"
#import "Type.h"
#import "Hobby.h"
#import "MappingHobby.h"
#import "MappingHobby2.h"
#import "Hobby.h"




@interface ViewController ()

@end

@implementation ViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize TextField2, TextField1, myButton, selecteduser, myArray, samestring, TextField3;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.TextField1.placeholder = @"I am userName";
    self.TextField2.placeholder = @"I am typeName";
    self.TextField3.placeholder = @"I am hobbyName";
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];

    /*
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:@"MappingHobby2"];
    [request setFetchLimit:50];
    NSError *error = nil;
    NSArray *fetchedObjects =
    [_managedObjectContext executeFetchRequest:request error:&error];
    if (error) {NSLog(@"%@", error);} else {
        for (MappingHobby2 *hobby in fetchedObjects) { NSLog(@"Fetched MappingHobby2 Object = %@", hobby.hmName);
        } }
    
    NSFetchRequest *request2 =
    [NSFetchRequest fetchRequestWithEntityName:@"Hobby"];
    [request2 setFetchLimit:50];
    NSArray *fetchedObjects2 =
    [_managedObjectContext executeFetchRequest:request2 error:&error];
    if (error) {NSLog(@"%@", error);} else {
        for (Hobby *hobby in fetchedObjects2) { NSLog(@"Fetched Hobby Object = %@", hobby.hobbyName);
        } }
    */



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    // When start to edit the placeholder will disappear
    self.TextField1.placeholder = @"";
    self.TextField2.placeholder = @"";
    self.TextField3.placeholder = @"";

    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    //When editing end which text show in the TexField placeholder
    if (self.TextField1.text.length == 0) {
        self.TextField1.text = self.TextField1.placeholder;
    }
    self.TextField1.placeholder = self.TextField1.text;
    
    if (self.TextField2.text.length == 0) {
        self.TextField2.text = self.TextField2.placeholder;
    }
    self.TextField2.placeholder = self.TextField2.text;
    if (self.TextField3.text.length == 0) {
        self.TextField3.text = self.TextField3.placeholder;
    }
    self.TextField3.placeholder = self.TextField3.text;

    
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //Keyboard Return button - end editing, dismiss keyboard
    [textField resignFirstResponder];
    
    return YES;
    
}

-(void) touchesBegan :(NSSet *) touches withEvent:(UIEvent *)event

{
    // If you touch otside of TextField your editing will stop adn keyboard dismiss
    [self.TextField1 resignFirstResponder];
    [self.TextField2 resignFirstResponder];
    [self.TextField3 resignFirstResponder];
    
    
    [super touchesBegan:touches withEvent:event ];
    
    return;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"ListUsersSegue"]) {
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        _managedObjectContext = [appDelegate managedObjectContext];
        
        self.myArray = [appDelegate getAllUserRecords];
        
        if ([samestring isEqualToString:@"same"]) {
            
            [selecteduser setUserName: self.TextField1.text];
            [selecteduser.typeofuser setTypeName:self.TextField2.text];
            
        }
        
    
        User *user1 = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
        user1.userName = self.TextField1.text;
    
        Type *type1 = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:self.managedObjectContext];
        type1.typeName = self.TextField2.text;
        
        Hobby *hobby1 = [NSEntityDescription insertNewObjectForEntityForName:@"Hobby" inManagedObjectContext:self.managedObjectContext];
        hobby1.hobbyName = self.TextField3.text;
        
        [user1 addHobbiesofuserObject:hobby1];
        [type1 addUsersoftypeObject:user1];
        
        //set the user "displayOrder" attribute
        int num =(int)myArray.count;
        
        [user1 setValue:[NSNumber numberWithInt:num] forKey:@"displayOrder"];


    
        NSError *error;
    
        if (![self.managedObjectContext save:&error]) {
        
            NSLog(@"Couldn't save:%@", [error localizedDescription]);
        }
        NSLog(@"Save");
    
        self.TextField1.text = NULL;
        self.TextField2.text = NULL;
        self.TextField3.text = NULL;

    
        [self.view endEditing:YES];
        
        }
}

-(IBAction)unwindFromSegue:(UIStoryboardSegue*)segue{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    self.myArray = [appDelegate getAllUserRecords];
    
    self.TextField1.text = selecteduser.userName;
    self.TextField2.text = selecteduser.typeofuser.typeName;
    self.samestring = @"same";
    
}






@end
