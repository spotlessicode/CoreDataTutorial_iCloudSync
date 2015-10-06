//
//  Type.h
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 11. 27..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Type : NSManagedObject

@property (nonatomic, retain) NSString * typeName;
@property (nonatomic, retain) NSSet *usersoftype;
@end

@interface Type (CoreDataGeneratedAccessors)

- (void)addUsersoftypeObject:(User *)value;
- (void)removeUsersoftypeObject:(User *)value;
- (void)addUsersoftype:(NSSet *)values;
- (void)removeUsersoftype:(NSSet *)values;

@end
