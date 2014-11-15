//
//  CFling.h
//  Fling
//
//  Created by jhbjserver on 11/15/14.
//  Copyright (c) 2014 Ryo.x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMessage;

@interface CFling : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * distance;
@property (nonatomic, retain) NSString * flingID;
@property (nonatomic, retain) NSNumber * isMeSender;
@property (nonatomic, retain) NSString * lastReply;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * video;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * unReadReplyCount;
@property (nonatomic, retain) NSNumber * isNewFling;
@property (nonatomic, retain) NSSet *messageHistory;
@end

@interface CFling (CoreDataGeneratedAccessors)

- (void)addMessageHistoryObject:(CMessage *)value;
- (void)removeMessageHistoryObject:(CMessage *)value;
- (void)addMessageHistory:(NSSet *)values;
- (void)removeMessageHistory:(NSSet *)values;

@end
