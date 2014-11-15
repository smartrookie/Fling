//
//  PhotoMarkView.m
//  FlingSendDemo
//
//  Created by Ryo.x on 14/10/28.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "PhotoMarkView.h"
#import "NoteView.h"
#import "ReceiverMapViewController.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"
#import <MapKit/MapKit.h>

@interface PhotoMarkView() {
    UIImageView *photoImageView;
    NoteView *noteView;
    UIButton *saveButton;
}

@end

#define URL_BASE @"http://182.92.228.182:8888"
#define URL_FLING [NSString stringWithFormat:@"%@/fling",URL_BASE]
//#define URL_UPLOAD [NSString stringWithFormat:@"%@/upload_file",URL_BASE]

@implementation PhotoMarkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        photoImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        photoImageView.backgroundColor = [UIColor blackColor];
        photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        photoImageView.userInteractionEnabled = YES;
        [self addSubview:photoImageView];
        
        noteView = [[NoteView alloc] init];
        noteView.hidden = YES;
        [photoImageView addSubview:noteView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(3, 17, 44, 44);
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelPhotoMark) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        UIButton *noteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        noteButton.frame = CGRectMake(SCREEN_WIDTH - 20 - 30, 40, 30, 30);
        noteButton.backgroundColor = [UIColor yellowColor];
        noteButton.titleLabel.font = [UIFont boldSystemFontOfSize:25.0f];
        [noteButton setTitle:@"T" forState:UIControlStateNormal];
        [noteButton addTarget:self action:@selector(displayNote) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:noteButton];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = CGRectMake(SCREEN_WIDTH - 10 - 40, SCREEN_HEIGHT - 10 - 40, 40, 40);
        [saveButton setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
        
        UIButton *flingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        flingButton.frame = CGRectMake(0, 0, 42, 42);
        flingButton.center = CGPointMake(SCREEN_WIDTH / 2.0f, SCREEN_HEIGHT - 44.0f);
        [flingButton setBackgroundImage:[UIImage imageNamed:@"fling"] forState:UIControlStateNormal];
        [flingButton addTarget:self action:@selector(fling) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:flingButton];
        
    }
    
    return self;
}

- (void)setPhoto4Fling:(UIImage *)photo4Fling {
    _photo4Fling = photo4Fling;
    
    [photoImageView setImage:_photo4Fling];
}

- (void)fling {
    NSString *noteText = [noteView noteText];
    
    CGPoint originPoint = CGPointZero;
    
    if (noteText && noteText.length > 0) {
        originPoint = noteView.frame.origin;
    } else {
        noteText = nil;
    }
    
    int sendCount = [(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"SendCount"] intValue];
    
    [self flingPicture:_photo4Fling note:noteText origin:originPoint sendCount:sendCount];
    [self startFlingAnimation];
}

    /**
     *      为了第一时间获得接收用户坐标，所以图片的发送被拆成两步完成
     *
     *      1、发送除图片以外的其他信息到服务器，服务器返回接收用户坐标和一个flingID，该flingID有效时长为30分钟
     *      2、根据flingID进行图片的后台上传 （flingID需要拼接到URL中）
     */

- (void)flingPicture:(UIImage *)pictureImage        //  需要发送的图片
                note:(NSString *)noteText           //  图片上添加的文字内容
              origin:(CGPoint)originPoint           //  文字内容显示位置
           sendCount:(int)sendCount {               //  发送数量
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MobileUDID"]
                     forHTTPHeaderField:@"TOKEN"];
    
    NSMutableDictionary *parametersMDic = [NSMutableDictionary dictionary];
    
    [parametersMDic setObject:@"picture" forKey:@"type"];
    
    if (noteText) {
        [parametersMDic setObject:noteText forKey:@"text"];
        [parametersMDic setObject:[NSNumber numberWithInt:originPoint.x] forKey:@"x"];
        [parametersMDic setObject:[NSNumber numberWithInt:originPoint.y] forKey:@"y"];
    }
    
    NSLog(@"%@", parametersMDic);
    
    [manager POST:URL_FLING
       parameters:parametersMDic
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              __weak ReceiverMapViewController *rmVC = [ReceiverMapViewController shareInstance];
              __weak PhotoMarkView *photoMarkView = self;
              
              rmVC.coordinateArray = [photoMarkView extractCoordinate:responseObject];
              
              NSLog(@"%@", responseObject);
              
              int flingID = [[responseObject objectForKey:@"fling_id"] intValue];
              
              [photoMarkView uploadPicture:pictureImage flingID:flingID];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"fling failed, error = %@", error.description);
          }];
}

//  上传图片
- (void)uploadPicture:(UIImage *)picture flingID:(int)flingID {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MobileUDID"]
                     forHTTPHeaderField:@"TOKEN"];
    
    NSMutableDictionary *parametersMDic = [NSMutableDictionary dictionary];
    
    //  flingID需要拼接到URL中，不能以属性的形式添加到parameters中
    NSString *url_upload = [NSString stringWithFormat:@"%@/upload_file/%d", URL_BASE, flingID];
    
    [manager POST:url_upload
        parameters:parametersMDic.count > 0 ? parametersMDic : nil
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(picture, 1.0f)
                                        name:@"picture"
                                    fileName:@"xxx"
                                    mimeType:@"image/jpeg"];
        }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"upload successed");
              NSLog(@"upload response ＝ %@", responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"diffuse failed, error = %@", error.description);
          }];
}

//  执行发送动画
- (void)startFlingAnimation {
    [UIView animateWithDuration:1.0f
                     animations:^{
                         self.alpha = 0;
                         
                         CATransform3D transform3d = CATransform3DIdentity;
                         
                         transform3d.m34 = 0.008f;
                         
                         transform3d = CATransform3DScale(transform3d, 0.35f, 0.35f, 0.35f);
                         transform3d = CATransform3DRotate(transform3d, M_PI_4 / 4.0f, 0.01f, -1.0f, -1.0f);
                         transform3d = CATransform3DTranslate(transform3d, -100, 0, 0);
                         
                         self.layer.transform = transform3d;
                     }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(photoFlingAnimationDidFinished:)]) {
                             [self.delegate photoFlingAnimationDidFinished:self];
                         }
                     }];
}

- (void)cancelPhotoMark {
    if ([self.delegate respondsToSelector:@selector(photoMarkDidCanceled:)]) {
        [self.delegate photoMarkDidCanceled:self];
    }
    
    [self resetDefaultLayout];
}

//  重置界面布局
- (void)resetDefaultLayout {
    if (self) {
        [noteView resetDefaultLayout];
        
        self.layer.transform = CATransform3DIdentity;
        self.alpha = 1.0f;
    }
}

- (void)displayNote {
    noteView.hidden = NO;
}

//  将当前照片保存到手机相册中
- (void)savePhoto {
    UIImageWriteToSavedPhotosAlbum(_photo4Fling, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = nil ;
    
    if (error != NULL) {
        message = @"保存图片失败" ;
    } else {
        message = @"保存图片成功" ;
        
        [saveButton setEnabled:NO];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//  从返回的接收用户信息中提取出坐标信息
- (NSArray *)extractCoordinate:(id)responseObject {
    NSArray *receiverArray = [responseObject objectForKey:@"receiver_list"];
    
    NSMutableArray *coordinateMArray = [NSMutableArray array];
    
    for (NSDictionary *receiverDic in receiverArray) {
        NSString *latitude = [receiverDic objectForKey:@"latitude"];
        NSString *longitude = [receiverDic objectForKey:@"longitude"];
        
        if ([latitude isEqual:[NSNull null]] || [longitude isEqual:[NSNull null]]) {
            continue;
        }
        
        CLLocationCoordinate2D receiverCoordinate = CLLocationCoordinate2DMake([[receiverDic objectForKey:@"latitude"] floatValue], [[receiverDic objectForKey:@"longitude"] floatValue]);
        
        [coordinateMArray addObject:[NSValue valueWithMKCoordinate:receiverCoordinate]];
    }
    
    return coordinateMArray;
}

- (void)dealloc {
    NSLog(@"photo mark view dealloc");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
