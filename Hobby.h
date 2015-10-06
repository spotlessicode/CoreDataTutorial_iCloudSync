//
//  Hobby.h
//  CoreDataTutorial
//
//  Created by Eva Puskas on 2014. 11. 27..
//  Copyright (c) 2014. Pepzen Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Hobby : NSManagedObject

@property (nonatomic, retain) NSString * hobbyName;
@property (nonatomic, retain) User *userofhobby;

@end
