//
//  MessageViewController.m
//  Fling
//
//  Created by Ryo.x on 14/11/7.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "MessageViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"
#import "MessageCell.h"
#import "MessageFrame.h"
#import "MessageInputView.h"
#import "CoreDataCenter.h"

@interface MessageViewController ()<UITableViewDataSource, UITableViewDelegate, MessageInputViewDelegate> {
    UIView *clearBgView;
    UILabel *noteLabel;
    UIImageView *pictureImageView;
    
    NSMutableArray *messageFrameMArray;
    UITableView *messageTableView;
    MessageInputView *messageInputView;
}

@end

#define URL_BASE @"http://182.92.228.182:8888"
#define URL_FLING_LIST [NSString stringWithFormat:@"%@/fling_list",URL_BASE]

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    messageFrameMArray = [NSMutableArray array];
    
    pictureImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    pictureImageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:pictureImageView];
    
    clearBgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    clearBgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:clearBgView];
    
    messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 90)
                                                    style:UITableViewStylePlain];
    messageTableView.backgroundColor = [UIColor clearColor];
    messageTableView.dataSource = self;
    messageTableView.delegate = self;
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [clearBgView addSubview:messageTableView];
    
    noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    noteLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
    noteLabel.alpha = 0;
    noteLabel.textColor = [UIColor whiteColor];
    noteLabel.textAlignment = NSTextAlignmentCenter;
    noteLabel.font = [UIFont systemFontOfSize:16.0f];
    [clearBgView addSubview:noteLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor colorWithRed:255 / 255.0f green:182 / 255.0f blue:0 / 255.0f alpha:1.0f];
    backButton.frame = CGRectMake(20, SCREEN_HEIGHT - 70, 50, 50);
    backButton.layer.cornerRadius = 25.0f;
    backButton.layer.masksToBounds = YES;
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [clearBgView addSubview:backButton];
    
    UIButton *writeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    writeButton.backgroundColor = [UIColor colorWithRed:0 / 255.0f green:175 / 255.0f blue:245 / 255.0f alpha:1.0f];
    writeButton.frame = CGRectMake(0, SCREEN_HEIGHT - 70, 50, 50);
    writeButton.center = CGPointMake(SCREEN_WIDTH / 2.0f, writeButton.center.y);
    writeButton.layer.cornerRadius = 25.0f;
    writeButton.layer.masksToBounds = YES;
    [writeButton setImage:[UIImage imageNamed:@"write"] forState:UIControlStateNormal];
    [writeButton addTarget:self action:@selector(writeMessage) forControlEvents:UIControlEventTouchUpInside];
    [clearBgView addSubview:writeButton];
    
    UIButton *eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.backgroundColor = [UIColor colorWithRed:0 / 255.0f green:236 / 255.0f blue:0 / 255.0f alpha:1.0f];
    eyeButton.frame = CGRectMake(SCREEN_WIDTH - 20 - 50, SCREEN_HEIGHT - 70, 50, 50);
    eyeButton.layer.cornerRadius = 25.0f;
    eyeButton.layer.masksToBounds = YES;
    [eyeButton setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    [eyeButton addTarget:self action:@selector(uncoverPicture) forControlEvents:UIControlEventTouchDown];
    [eyeButton addTarget:self action:@selector(coverPicture) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [clearBgView addSubview:eyeButton];
    
    messageInputView = [[MessageInputView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    messageInputView.alpha = 0;
    messageInputView.delegate = self;
    [self.view addSubview:messageInputView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    
    if (_fling) {
        [pictureImageView sd_setImageWithURL:[NSURL URLWithString:_fling.picture]
                            placeholderImage:nil
                                     options:SDWebImageProgressiveDownload
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       if (_fling.note && _fling.note.length > 0) {
                                           noteLabel.alpha = 1.0f;
                                           noteLabel.text = _fling.note;
                                           
                                           noteLabel.frame = CGRectMake(0, _fling.y.floatValue, noteLabel.bounds.size.width, noteLabel.bounds.size.height);
                                       }
                                   }];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
}

- (void)requestChatHistory:(NSString *)flingID {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MobileUDID"]
                     forHTTPHeaderField:@"TOKEN"];
    
    [manager GET:[NSString stringWithFormat:@"%@/conversation/%@", URL_BASE, flingID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"chat history = %@", responseObject);
             
             __weak CFling *cfling = _fling;
             NSArray *conversation = responseObject[@"conversation"];
             [conversation enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                 CMessage *messgae = [[CoreDataCenter shareInstance] newCMessage];
                 messgae.mesId   = obj[@"id"];
                 messgae.picture = obj[@"picture"];
                 messgae.text    = obj[@"text"];
                 messgae.time    = obj[@"time"];
                 messgae.video   = obj[@"video"];
                 [cfling addMessageHistoryObject:messgae];
             }];
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", error);
         }];
}

- (void)sendMessage:(NSString *)messageText {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MobileUDID"]
                     forHTTPHeaderField:@"TOKEN"];
    
    NSMutableDictionary *parametersMDic = [NSMutableDictionary dictionary];
    
    [parametersMDic setObject:messageText forKey:@"text"];
    
    NSLog(@"%@", parametersMDic);
    
    [manager POST:[NSString stringWithFormat:@"%@/chat/%@", URL_BASE, _fling.flingID]
       parameters:parametersMDic
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"%@", responseObject);
              
              __weak MessageViewController *messageVC = self;
              [messageVC requestChatHistory:_fling.flingID];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"fling failed, error = %@", error.description);
          }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messageFrameMArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    MessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (messageCell == nil) {
        messageCell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:identifier];
        
        messageCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    messageCell.messageFrame = [messageFrameMArray objectAtIndex:indexPath.row];
    
    return messageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[messageFrameMArray objectAtIndex:indexPath.row] cellHeight];
}

- (void)uncoverPicture {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         clearBgView.alpha = 0;
                     }];
}

- (void)coverPicture {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         clearBgView.alpha = 1.0f;
                     }];
}

- (void)writeMessage {
    messageInputView.alpha = 1.0f;
}

- (void)messageInputViewDidDisplay:(CGFloat)alpha messageBgViewFrame:(CGRect)rect {
    if (alpha > 0) {
        messageTableView.frame = CGRectMake(messageTableView.frame.origin.x,
                                            rect.origin.y - messageTableView.bounds.size.height,
                                            messageTableView.bounds.size.width,
                                            messageTableView.bounds.size.height);
        
        NSLog(@"%.1f", messageTableView.frame.origin.y);
    } else {
        messageTableView.frame = CGRectMake(messageTableView.frame.origin.x,
                                            0,
                                            messageTableView.bounds.size.width,
                                            messageTableView.bounds.size.height);
    }
}

- (void)messageInputViewDidSendMessage:(NSString *)messageText {
    if (messageFrameMArray.count == 0 && _fling.note.length > 0) {
        noteLabel.alpha = 0;
        
        [self addMessage:_fling.note type:MessageTypeMe];
    }
    
    [self sendMessage:messageText];
}

- (void)addMessage:(NSString *)messageText type:(MessageType)messageType {
    CMessage *message = [[CMessage alloc] init];
    message.text = messageText;
    message.type = @(messageType);
    
    MessageFrame *messageFrame = [[MessageFrame alloc] init];
    messageFrame.message = message;
    
    [messageFrameMArray addObject:messageFrame];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageFrameMArray.count - 1
                                                inSection:0];
    
    [messageTableView insertRowsAtIndexPaths:@[indexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
    
    [messageTableView scrollToRowAtIndexPath:indexPath
                            atScrollPosition:UITableViewScrollPositionBottom
                                    animated:YES];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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
