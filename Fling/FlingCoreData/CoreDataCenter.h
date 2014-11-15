//
//  CoreDataCenter.h
//  Fling
//
//  Created by jhbjserver on 14/11/10.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CFling.h"
#import "CMessage.h"

typedef enum : NSUInteger {
    MessageTypeMe,
    MessageTypeOther,
} MessageType;

@interface CoreDataCenter : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)shareInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (CFling *)newCFling;
- (CMessage *)newCMessage;

- (CFling *)storeCFlingByDictionary:(NSDictionary *)dictionay;



- (NSFetchedResultsController *)fetchedResultsControllerAllFling;


@end
