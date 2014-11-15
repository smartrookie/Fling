//
//  SettingsViewController.m
//  Fling
//
//  Created by Ryo.x on 14/11/11.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "SettingsViewController.h"
#import "VPImageCropperViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface SettingsViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate> {
    UIButton *avatarButton;
    
    UIButton *ageButton;
    NSArray *ageArray;
    UIPickerView *agePickerView;
}

@end

#define ORIGINAL_MAX_WIDTH 640.0f

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    ageArray = @[@"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35"];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    topView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:topView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 17, 44, 44);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissCurrentVC) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:closeButton];
    
    avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    avatarButton.frame = CGRectMake(SCREEN_WIDTH / 2.0f - 50.0f, topView.frame.origin.y + topView.bounds.size.height + 40.0f, 100.0f, 100.0f);
    avatarButton.backgroundColor = [UIColor whiteColor];
    avatarButton.layer.cornerRadius = avatarButton.frame.size.width / 2.0f;
    avatarButton.layer.masksToBounds = YES;
    [avatarButton addTarget:self action:@selector(modifyAvatar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:avatarButton];
    
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0f - 100.0f, avatarButton.frame.origin.y + avatarButton.bounds.size.height + 22.0f, 200.0f, 25.0f)];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.text = @"Ryo.x";
    nameTextField.textColor = [UIColor whiteColor];
    nameTextField.textAlignment = NSTextAlignmentCenter;
    nameTextField.font = [UIFont boldSystemFontOfSize:16.0f];
    nameTextField.tintColor = [UIColor whiteColor];
    nameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.delegate = self;
    [self.view addSubview:nameTextField];
    
    UIView *underlineView_Name = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0f - 100.0f, avatarButton.frame.origin.y + avatarButton.bounds.size.height + 55.0f, 200.0f, 0.5f)];
    underlineView_Name.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:underlineView_Name];
    
    ageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ageButton.backgroundColor = [UIColor clearColor];
    ageButton.frame = CGRectMake(SCREEN_WIDTH / 2.0f - 100.0f, underlineView_Name.frame.origin.y + 8.0f, 200.0f, 25.0f);
    ageButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [ageButton setTitle:@"请选择年龄" forState:UIControlStateNormal];
    [ageButton addTarget:self action:@selector(displayAgePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ageButton];
    
    UIView *underlineView_Age = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0f - 100.0f, underlineView_Name.frame.origin.y + 40.0f, 200.0f, 0.5f)];
    underlineView_Age.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:underlineView_Age];
    
    agePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 167.0f, SCREEN_WIDTH - 20.0f, 162.0f)];
    agePickerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9f];
    agePickerView.layer.cornerRadius = 2.0f;
    agePickerView.layer.masksToBounds = YES;
    agePickerView.dataSource = self;
    agePickerView.delegate = self;
    agePickerView.alpha = 0;
    [self.view addSubview:agePickerView];
    
    UISegmentedControl *typeSegmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"男", @"女", @"随机", nil]];
    typeSegmentControl.frame = CGRectMake(SCREEN_WIDTH / 2.0f - 100.0f, underlineView_Age.frame.origin.y + 40.0f, 200.0f, 28.0f);
    typeSegmentControl.backgroundColor = [UIColor whiteColor];
    typeSegmentControl.layer.cornerRadius = 3.0f;
    typeSegmentControl.layer.masksToBounds = YES;
    typeSegmentControl.tintColor = [UIColor orangeColor];
    typeSegmentControl.selectedSegmentIndex = 0;
    [typeSegmentControl addTarget:self action:@selector(selectReceiveGroup:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:typeSegmentControl];
    
    UISlider *sendCountSlider = [[UISlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0f - 100.0f, typeSegmentControl.frame.origin.y + 80, 200.0f, 20.0f)];
    sendCountSlider.tintColor = [UIColor orangeColor];
    sendCountSlider.minimumValue = 5;
    sendCountSlider.maximumValue = 50;
    sendCountSlider.value = 20;
    [self.view addSubview:sendCountSlider];
}

- (void)dismissCurrentVC {
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         agePickerView.alpha = 0;
                     }];
}

- (void)selectReceiveGroup:(UISegmentedControl *)segmentedControl {
    
}

#pragma mark 设置年龄
- (void)displayAgePicker {
    CGFloat alpha = 0;
    
    if (agePickerView.alpha == 0) {
        alpha = 1.0f;
    } else {
        alpha = 0;
    }
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         agePickerView.alpha = alpha;
                     }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return ageArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [ageArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [ageButton setTitle:[ageArray objectAtIndex:row] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         agePickerView.alpha = 0;
                     }];
}

#pragma mark 设置姓名
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark 设置头像
- (void)modifyAvatar {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            if ([self isFrontCameraAvailable]) {
                imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            
            NSMutableArray *mediaTypes = [NSMutableArray array];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            
            imagePickerController.mediaTypes = mediaTypes;
            imagePickerController.allowsEditing = NO;
            imagePickerController.delegate = self;
            
            [self presentViewController:imagePickerController animated:YES completion:NULL];
        }
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            NSMutableArray *mediaTypes = [NSMutableArray array];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            
            imagePickerController.mediaTypes = mediaTypes;
            imagePickerController.delegate = self;
            
            [self presentViewController:imagePickerController animated:YES completion:NULL];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *avatarImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        avatarImage = [self imageByScalingToMaxSize:avatarImage];
        
        VPImageCropperViewController *imageCropperVC = [[VPImageCropperViewController alloc] initWithImage:avatarImage cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width)
                                                                                        limitScaleRatio:3.0];
        imageCropperVC.delegate = self;
        [self presentViewController:imageCropperVC animated:YES completion:NULL];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        [avatarButton setBackgroundImage:editedImage forState:UIControlStateNormal];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [cropperViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
                          sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) canUserPickVideosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie
                          sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) canUserPickPhotosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
                          sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    
    if ([paramMediaType length] == 0) {
        return NO;
    }
    
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    
    return result;
}

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
