//
//  NoteView.m
//  Fling_NoteView
//
//  Created by Ryo.x on 14/10/19.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "NoteView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define BG_HEIGHT 50
#define NOTE_MAX_LENGTH 20

@interface NoteView ()<UITextFieldDelegate>
{
    CGFloat originalY;
}

@end

@implementation NoteView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, (SCREEN_HEIGHT - BG_HEIGHT) / 2.0f, SCREEN_WIDTH, BG_HEIGHT);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
        
        [self registerForKeyboardNotifications];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(adjustPosition:)];
        
        _noteTextField = [[UITextField alloc] initWithFrame:self.bounds];
        _noteTextField.text = @"";
        _noteTextField.textColor = [UIColor whiteColor];
        _noteTextField.font = [UIFont systemFontOfSize:16.0f];
        _noteTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.bounds.size.height)];
        _noteTextField.leftViewMode = UITextFieldViewModeAlways;
        _noteTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _noteTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _noteTextField.returnKeyType = UIReturnKeyDone;
        _noteTextField.delegate = self;
        [_noteTextField addGestureRecognizer:panGesture];
        [self addSubview:_noteTextField];
    }
    
    return self;
}

- (void)adjustPosition:(UIPanGestureRecognizer *)recognizer {
    if (!_noteTextField.isEditing) {
        if (recognizer.state == UIGestureRecognizerStateChanged || recognizer.state == UIGestureRecognizerStateEnded) {
            CGPoint offset = [recognizer translationInView:self.superview];
            
            self.center = CGPointMake(self.center.x, self.center.y + offset.y);
            
            [recognizer setTranslation:CGPointMake(0, 0) inView:self];
        }
    }
}

- (void)resetDefaultLayout {
    if (self) {
        if ([_noteTextField isFirstResponder]) {
            [_noteTextField resignFirstResponder];
        }
        
        self.hidden = YES;
        self.frame = CGRectMake(0, (SCREEN_HEIGHT - BG_HEIGHT) / 2.0f, SCREEN_WIDTH, BG_HEIGHT);
        _noteTextField.text = @"";
    }
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSLog(@"%.1f, %.1f", keyboardSize.width, keyboardSize.height);
    
    self.frame = CGRectMake(self.frame.origin.x,
                            SCREEN_HEIGHT - keyboardSize.height - BG_HEIGHT,
                            self.bounds.size.width,
                            self.bounds.size.height);
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    if (!_noteTextField || _noteTextField.text.length == 0) {
        self.hidden = YES;
        self.frame = CGRectMake(0, (SCREEN_HEIGHT - BG_HEIGHT) / 2.0f, SCREEN_WIDTH, BG_HEIGHT);
    } else {
        _noteTextField.leftViewMode = UITextFieldViewModeNever;
        _noteTextField.textAlignment = NSTextAlignmentCenter;
        
        [UIView animateWithDuration:0.75f
                              delay:0
             usingSpringWithDamping:0.75f
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x,
                                                     originalY,
                                                     self.bounds.size.width,
                                                     self.bounds.size.height);
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

- (NSString *)noteText {
    return _noteTextField.text;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (!hidden) {
        [_noteTextField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.textAlignment = NSTextAlignmentLeft;
    
    originalY = self.frame.origin.y;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location >= NOTE_MAX_LENGTH) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (void)dealloc {
    NSLog(@"dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
