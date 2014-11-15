//
//  MessageInputView.h
//  TableViewInputDemo
//
//  Created by Ryo.x on 14/11/8.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageInputViewDelegate;

@interface MessageInputView : UIView

@property (assign, nonatomic) id<MessageInputViewDelegate> delegate;

@end

@protocol MessageInputViewDelegate <NSObject>

- (void)messageInputViewDidDisplay:(CGFloat)alpha messageBgViewFrame:(CGRect)rect;
- (void)messageInputViewDidSendMessage:(NSString *)messageText;

@end