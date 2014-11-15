//
//  CMessage.h
//  Fling
//
//  Created by jhbjserver on 11/15/14.
//  Copyright (c) 2014 Ryo.x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CFling;

@interface CMessage : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * mesId;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * video;
@property (nonatomic, retain) CFling *cFling;

@end
