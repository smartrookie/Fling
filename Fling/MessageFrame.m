//
//  MessageFrame.m
//  Fling
//
//  Created by Ryo.x on 14/11/8.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "MessageFrame.h"

#define MARGIN 10

@implementation MessageFrame

- (void)setMessage:(Message *)message {
    _message = message;
    
    CGSize contentSize = [_message.text sizeWithFont:[UIFont systemFontOfSize:22.0f]
                                   constrainedToSize:CGSizeMake(SCREEN_WIDTH - MARGIN * 2.0f, CGFLOAT_MAX)];
    
    _cellHeight = contentSize.height + MARGIN * 4.0f;
}

@end
