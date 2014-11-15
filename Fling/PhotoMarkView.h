//
//  PhotoMarkView.h
//  FlingSendDemo
//
//  Created by Ryo.x on 14/10/28.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoMarkViewDelegate;

@interface PhotoMarkView : UIView

@property (strong, nonatomic) UIImage *photo4Fling;
@property (assign, nonatomic) id<PhotoMarkViewDelegate> delegate;

- (void)resetDefaultLayout;

@end

@protocol PhotoMarkViewDelegate <NSObject>

- (void)photoMarkDidCanceled:(PhotoMarkView *)photoMarkView;
- (void)photoFlingAnimationDidFinished:(PhotoMarkView *)photoMarkView;

@end
