//
//  CameraViewController.m
//  Fling
//
//  Created by Ryo.x on 14/10/30.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "CameraViewController.h"
#import "ReceiverMapViewController.h"
#import "InboxViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIButton *shutterButton;
    UIButton *cameraButton;
    UIButton *flashButton;
    
    AVCaptureFlashMode currentFlashMode;
    
}

//  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession *session;

//  AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;

//  照片输出流对象，当然我的照相机只有拍照功能，所以只需要这个对象就够了
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

//  预览图层，来显示照相机拍摄到的画面
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation CameraViewController

+ (id)shareInstance {
    static CameraViewController *shareVC = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareVC = [[CameraViewController alloc] init];
    });
    
    return shareVC;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initialSession];
        [self setUpCameraLayer];
        [self setUpControlView];
    }
    
    return self;
}

- (void)initialSession {
    //这个方法的执行我放在init方法里了
    self.session = [[AVCaptureSession alloc] init];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera]
                                                             error:nil];

    //[self fronCamera]方法会返回一个AVCaptureDevice对象，因为我初始化时是采用前摄像头，所以这么写，具体的实现方法后面会介绍
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    NSLog(@"initialSession");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    if (self.session) {
        [self.session stopRunning];
    }
}

- (void)setUpCameraLayer {
    if ([[AVCaptureDevice devices] count] == 0) {
        return;
    }
    
    if (!self.previewLayer) {
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.frame = self.view.bounds;
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:self.previewLayer];
    }
}

- (void)setUpControlView {
//    shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    shutterButton.frame = CGRectMake((SCREEN_WIDTH - 70) / 2.0f, SCREEN_HEIGHT - 70.0f - 22.0f, 70.0f, 70.0f);
//    shutterButton.backgroundColor = [UIColor whiteColor];
//    shutterButton.layer.cornerRadius = 70.0f / 2.0f;
//    shutterButton.layer.masksToBounds = YES;
//    shutterButton.layer.borderWidth = 3.0f;
//    shutterButton.layer.borderColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.25f] CGColor];
//    [shutterButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:shutterButton];
    
    //  闪光灯按钮
//    flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    flashButton.frame = CGRectMake(24.0f, shutterButton.center.y - 12.0f, 50.0f, 24.0f);
//    flashButton.backgroundColor = [UIColor whiteColor];
//    flashButton.layer.cornerRadius = 24.0f / 2.0f;
//    flashButton.layer.masksToBounds = YES;
//    flashButton.layer.borderWidth = 2.0f;
//    flashButton.layer.borderColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.25f] CGColor];
//    flashButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
//    [flashButton setTitle:@"Auto" forState:UIControlStateNormal];
//    [flashButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    [flashButton addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:flashButton];
    
    currentFlashMode = AVCaptureFlashModeOff;
    
    //  切换镜头按钮
//    cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    cameraButton.frame = CGRectMake(SCREEN_WIDTH - 50.0f - 24.0f, shutterButton.center.y - 12.0f, 50.0f, 24.0f);
//    cameraButton.backgroundColor = [UIColor whiteColor];
//    cameraButton.layer.cornerRadius = 24.0f / 2.0f;
//    cameraButton.layer.masksToBounds = YES;
//    cameraButton.layer.borderWidth = 2.0f;
//    cameraButton.layer.borderColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.25f] CGColor];
//    cameraButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
//    [cameraButton setTitle:@"Font" forState:UIControlStateNormal];
//    [cameraButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    [cameraButton addTarget:self action:@selector(toggleCamera) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:cameraButton];
    
    shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shutterButton.frame = CGRectMake((SCREEN_WIDTH - 60) / 2.0f, SCREEN_HEIGHT - 60.0f - 10.0f, 60.0f, 60.0f);
    [shutterButton setImage:[UIImage imageNamed:@"shutter"] forState:UIControlStateNormal];
    [shutterButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shutterButton];
    
    cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(18.0f, shutterButton.center.y - 13.0f, 33.0f, 25.0f);
    cameraButton.center = CGPointMake(34.0f, shutterButton.center.y);
    [cameraButton setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(toggleCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    
    UIButton *pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pictureButton.frame = CGRectMake(SCREEN_WIDTH - 32.0f - 18.0f, shutterButton.center.y - 10.0f, 32.0f, 27.0f);
    pictureButton.center = CGPointMake(SCREEN_WIDTH - 18.0f - 16.0f, shutterButton.center.y);
    [pictureButton setBackgroundImage:[UIImage imageNamed:@"picture"] forState:UIControlStateNormal];
    [pictureButton addTarget:self action:@selector(selectPicture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pictureButton];
    
    UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    listButton.frame = CGRectMake(SCREEN_WIDTH - 40.0f - 15.0f, 25.0f, 40.0f, 44.0f);
    [listButton setBackgroundImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
    [listButton addTarget:self action:@selector(checkReceiveList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:listButton];
}

- (void)checkReceiveList {
    InboxViewController *inboxVC = [InboxViewController shareInstance];
    
    [self.navigationController pushViewController:inboxVC animated:YES];
}

- (void)shutterCamera {
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [CameraViewController setFlashMode:currentFlashMode
                             forDevice:self.videoInput.device];
    
    __weak CameraViewController *cVC = self;
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           if (imageDataSampleBuffer == NULL) {
                                                               return;
                                                           }
                                                           
                                                           NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                           UIImage *image = [UIImage imageWithData:imageData];
                                                           
                                                           [cVC displayPhoto:image
                                                                    position:[[_videoInput device] position]];
                                                           
                                                           NSLog(@"image size = %@",NSStringFromCGSize(image.size));
                                                       }];
}

- (void)displayPhoto:(UIImage *)image position:(AVCaptureDevicePosition) position {
    //  如果是前置摄像头拍摄的照片，则进行水平翻转，以保证与拍照前取景框内图像方向一致
    if (position == AVCaptureDevicePositionFront) {
        image = [UIImage imageWithCGImage:image.CGImage
                                    scale:1.0f
                              orientation:UIImageOrientationLeftMirrored];
    }

    ReceiverMapViewController *rmVC = [ReceiverMapViewController shareInstance];
    rmVC.photo = image;
    
    [self presentViewController:rmVC animated:NO completion:NULL];
}

- (void)toggleFlash {
    NSString *flashModeTitle = @"";
    
    switch (currentFlashMode) {
        case AVCaptureFlashModeOff:
            currentFlashMode = AVCaptureFlashModeOn;
            flashModeTitle = @"On";
            
            break;
            
        case AVCaptureFlashModeOn:
            currentFlashMode = AVCaptureFlashModeAuto;
            flashModeTitle = @"Auto";
            
            break;
            
        case AVCaptureFlashModeAuto:
            currentFlashMode = AVCaptureFlashModeOff;
            flashModeTitle = @"No";
            
            break;
            
        default:
            break;
    }
    
    [flashButton setTitle:flashModeTitle forState:UIControlStateNormal];
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
        NSError *error = nil;
        
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@", error);
        }
    }
}

- (void)toggleCamera {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    
    if (cameraCount > 1) {
        NSError *error;
        
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
            
            [cameraButton setTitle:@"Front" forState:UIControlStateNormal];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
            
            [cameraButton setTitle:@"Back" forState:UIControlStateNormal];
        } else {
            return;
        }
        
        if (newVideoInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [self.session addInput:self.videoInput];
            }
            
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    
    return nil;
}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (void)selectPicture {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        NSMutableArray *mediaTypes = [NSMutableArray array];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        
        imagePickerController.mediaTypes = mediaTypes;
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO
                               completion:^() {
                                   UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
                                   
                                   ReceiverMapViewController *rmVC = [ReceiverMapViewController shareInstance];
                                   rmVC.photo = originalImage;
                                   
                                   [self presentViewController:rmVC animated:NO completion:NULL];
                               }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
