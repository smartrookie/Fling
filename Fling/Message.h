//
//  Message.h
//  Fling
//
//  Created by Ryo.x on 14/11/7.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MessageTypeMe,          //  自己发的
    MessageTypeOther,       //  别人发的
} MessageType;

@interface Message : NSObject

@property (assign, nonatomic) MessageType type;
@property (copy, nonatomic) NSString *text;

@end
