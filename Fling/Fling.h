//
//  Fling.h
//  Fling
//
//  Created by Ryo.x on 14/11/7.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Fling : NSObject

@property (copy, nonatomic) NSString *age;
@property (copy, nonatomic) NSString *avatar;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *distance;
@property (copy, nonatomic) NSString *flingID;
@property (assign, nonatomic) BOOL isMeSender;
@property (assign, nonatomic) BOOL isNewFling;
@property (copy, nonatomic) NSString *lastReply;
@property (assign, nonatomic) CGFloat latitude;
@property (assign, nonatomic) CGFloat longitude;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *note;
@property (copy, nonatomic) NSString *picture;
@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *time;
@property (copy, nonatomic) NSString *video;
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;







@end
