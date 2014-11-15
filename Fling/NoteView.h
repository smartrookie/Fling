//
//  NoteView.h
//  Fling_NoteView
//
//  Created by Ryo.x on 14/10/19.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteView : UIView

@property (strong, nonatomic) UITextField *noteTextField;

- (NSString *)noteText;
- (void)resetDefaultLayout;

@end

