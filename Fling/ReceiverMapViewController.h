//
//  ReceiverMapViewController.h
//  FlingMapDemo
//
//  Created by Ryo.x on 14/10/25.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiverMapViewController : UIViewController

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSArray *coordinateArray;

+ (id)shareInstance;

@end
