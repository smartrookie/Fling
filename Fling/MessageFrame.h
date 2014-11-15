//
//  MessageFrame.h
//  Fling
//
//  Created by Ryo.x on 14/11/8.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageFrame : NSObject

@property (strong, nonatomic) Message *message;
@property (assign, nonatomic) CGFloat cellHeight;

@end
