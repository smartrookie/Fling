//
//  MessageInputView.m
//  TableViewInputDemo
//
//  Created by Ryo.x on 14/11/8.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "MessageInputView.h"

@interface MessageInputView()<UITextViewDelegate> {
    UIView *messageBgView;
    UITextView *messageTextView;
    
    BOOL needAnaylseKeyboardHeight;
    CGSize keyboardSize;
    CGFloat singleLineHeight;

}

@end

#define MARGIN 10.0f
#define MESSAGE_FONT_SIZE 22.0f

@implementation MessageInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        needAnaylseKeyboardHeight = YES;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(cancelMessageInput:)];
        
        [self addGestureRecognizer:tapGesture];
        
        messageBgView = [[UIView alloc] initWithFrame:CGRectZero];
        messageBgView.backgroundColor = [UIColor greenColor];
        [self addSubview:messageBgView];
        
        messageTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        messageTextView.backgroundColor = [UIColor clearColor];
        messageTextView.textColor = [UIColor whiteColor];
        messageTextView.textAlignment = NSTextAlignmentCenter;
        messageTextView.font = [UIFont systemFontOfSize:MESSAGE_FONT_SIZE];
        messageTextView.returnKeyType = UIReturnKeySend;
        messageTextView.keyboardAppearance = UIKeyboardAppearanceDark;
        messageTextView.tintColor = [UIColor whiteColor];
        messageTextView.delegate = self;
        [messageBgView addSubview:messageTextView];
    }
    
    return self;
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    
    if (alpha > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShown:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [messageTextView becomeFirstResponder];
        
        if ([self.delegate respondsToSelector:@selector(messageInputViewDidDisplay:messageBgViewFrame:)]) {
            [self.delegate messageInputViewDidDisplay:alpha messageBgViewFrame:messageBgView.frame];
        }
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [messageTextView resignFirstResponder];
        
        if ([self.delegate respondsToSelector:@selector(messageInputViewDidDisplay:messageBgViewFrame:)]) {
            [self.delegate messageInputViewDidDisplay:alpha messageBgViewFrame:messageBgView.frame];
        }
    }
}

- (void)keyboardWillShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    
    keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSLog(@"%.1f, %.1f", keyboardSize.width, keyboardSize.height);

    if (needAnaylseKeyboardHeight) {
        NSString *tempString = @"string4Anaylse";
        
        singleLineHeight = [tempString sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE]
                                  constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - MARGIN * 2.0f, CGFLOAT_MAX)].height;
        
        messageBgView.frame = CGRectMake(0,
                                         [UIScreen mainScreen].bounds.size.height - keyboardSize.height - singleLineHeight - MARGIN * 4.0f,
                                         [UIScreen mainScreen].bounds.size.width,
                                         singleLineHeight + MARGIN * 4.0f);
        
        messageTextView.frame = CGRectMake(MARGIN,
                                           MARGIN * 2.0f,
                                           [UIScreen mainScreen].bounds.size.width - MARGIN * 2.0f,
                                           singleLineHeight);
        
        needAnaylseKeyboardHeight = NO;
    } else {
        messageBgView.frame = CGRectMake(messageBgView.frame.origin.x,
                                         [UIScreen mainScreen].bounds.size.height - keyboardSize.height - messageBgView.bounds.size.height,
                                         messageBgView.bounds.size.width,
                                         messageBgView.bounds.size.height);
    }
    
    
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        CGSize contentSize = [textView.text sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE]
                                       constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - MARGIN * 2.0f, CGFLOAT_MAX)];
        
        if (contentSize.height <= singleLineHeight * 2.0f) {
            if (messageTextView.bounds.size.height != contentSize.height) {
                NSLog(@"xxxxxxxxxxxxxxxxx");
                
                messageTextView.frame = CGRectMake(messageTextView.frame.origin.x,
                                                   messageTextView.frame.origin.y,
                                                   messageTextView.bounds.size.width,
                                                   contentSize.height);
                
                messageBgView.frame = CGRectMake(messageBgView.frame.origin.x,
                                                 [UIScreen mainScreen].bounds.size.height - keyboardSize.height - messageTextView.bounds.size.height - MARGIN * 4.0f,
                                                 messageBgView.bounds.size.width,
                                                 messageTextView.bounds.size.height + MARGIN * 4.0f);
                
                if ([self.delegate respondsToSelector:@selector(messageInputViewDidDisplay:messageBgViewFrame:)]) {
                    [self.delegate messageInputViewDidDisplay:1.0f messageBgViewFrame:messageBgView.frame];
                }
            }
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        self.alpha = 0;
        
        if (textView.text.length > 0) {
            if ([self.delegate respondsToSelector:@selector(messageInputViewDidSendMessage:)]) {
                [self.delegate messageInputViewDidSendMessage:textView.text];
                
                [self resetDefaultLayout];
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (void)resetDefaultLayout {
    messageTextView.text = @"";
    needAnaylseKeyboardHeight = YES;
}

- (void)cancelMessageInput:(UITapGestureRecognizer *)recognizer {
    self.alpha = 0;
}

- (void)dealloc {
    NSLog(@"dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
