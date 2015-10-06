//
//  User.h
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 12. 17..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hobby, Type;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * userBirthDate;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * userPhone;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSSet *hobbiesofuser;
@property (nonatomic, retain) Type *typeofuser;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addHobbiesofuserObject:(Hobby *)value;
- (void)removeHobbiesofuserObject:(Hobby *)value;
- (void)addHobbiesofuser:(NSSet *)values;
- (void)removeHobbiesofuser:(NSSet *)values;

@end
