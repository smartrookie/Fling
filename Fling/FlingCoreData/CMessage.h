//
//  CMessage.h
//  Fling
//
//  Created by smartrookie on 14/11/15.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CFling;

@interface CMessage : NSManagedObject

@property (nonatomic, retain) NSString * mesId;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * video;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) CFling *cFling;

@end
