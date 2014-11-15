//
//  InboxViewController.m
//  DiffuseDemo
//
//  Created by Gueie on 14-10-11.
//  Copyright (c) 2014年 Gueie. All rights reserved.
//

#import "InboxViewController.h"
#import "MessageViewController.h"
#import "InboxCell.h"
#import "CFling.h"
#import "SettingsViewController.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"
#import "CoreDataCenter.h"

@interface InboxViewController ()<UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate> {
    UITableView *inboxTableView;
}

@property (strong, nonatomic) NSFetchedResultsController *flingFetchedResultsController;

@end

#define URL_BASE @"http://182.92.228.182:8888"
#define URL_FLING_LIST [NSString stringWithFormat:@"%@/fling_list",URL_BASE]

@implementation InboxViewController

+ (id)shareInstance {
    static InboxViewController *shareVC = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareVC = [[InboxViewController alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:shareVC
                                                 selector:@selector(checkFlingListIfNeedRequest)
                                                     name:@"REQUEST_FLING_LIST"
                                                   object:nil];
    });
    
    return shareVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Fling";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                                              forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //  隐藏返回按钮的title   只显示左箭头
    //  将返回按钮的文字position设置不在屏幕上显示
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *settingBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(checkUserSettings)];
    self.navigationItem.rightBarButtonItem = settingBarButtonItem;
    
    self.flingFetchedResultsController = [[CoreDataCenter shareInstance] fetchedResultsControllerAllFling];
    [self.flingFetchedResultsController setDelegate:self];
    
    inboxTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                          style:UITableViewStylePlain];
    inboxTableView.dataSource = self;
    inboxTableView.delegate = self;
    inboxTableView.rowHeight = 110.0f;
    inboxTableView.separatorInset = UIEdgeInsetsMake(0, 110, 0, 0);
    inboxTableView.delaysContentTouches = NO;
    [self.view addSubview:inboxTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkFlingListIfNeedRequest];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.flingFetchedResultsController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[InboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        for (id obj in cell.subviews) {
            if ([NSStringFromClass([obj class]) isEqualToString:@"UITableViewCellScrollView"]) {
                UIScrollView *scrollView = (UIScrollView *) obj;
                scrollView.delaysContentTouches = NO;
                
                break;
            }
        }
    }
    
    cell.fling = [self.flingFetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CFling *fling = [self.flingFetchedResultsController objectAtIndexPath:indexPath];
    
    MessageViewController *messageVC = [[MessageViewController alloc] init];
    messageVC.fling = fling;
    
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[CoreDataCenter shareInstance].managedObjectContext deleteObject:[self.flingFetchedResultsController objectAtIndexPath:indexPath]];
    }
}

- (void)checkFlingListIfNeedRequest {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *result = [userDefaults objectForKey:@"FlingListNeedRequest"];
    
    NSLog(@"FlingListNeedRequest = %@", result);
    
    if ([result isEqualToString:@"Yes"]) {
        [self requestFlingList];
    }
}

- (void)requestFlingList {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"MobileUDID"]
//                     forHTTPHeaderField:@"TOKEN"];
    [manager.requestSerializer setValue:@"0c117698385eb6d03191dbf9907da733e675c863"
                     forHTTPHeaderField:@"TOKEN"];
    
    NSLog(@"Start Request Fling List");
    
    [manager GET:URL_FLING_LIST
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"%@", responseObject);
             
             __weak InboxViewController *inboxVC = self;
             [inboxVC updateInboxList:[responseObject objectForKey:@"flings"]];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", error);
         }];
}

- (void)updateInboxList:(NSArray *)infoArray {
    for (NSDictionary *flingDictionay in infoArray) {
        /**
         * 封装存储过程
         */
        [[CoreDataCenter shareInstance] storeCFlingByDictionary:flingDictionay];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"No" forKey:@"FlingListNeedRequest"];
    [userDefaults synchronize];
    
    NSLog(@"Finish Request Fling List");
}

- (void)checkUserSettings {
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self presentViewController:settingsVC animated:YES completion:NULL];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [inboxTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [inboxTableView insertSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [inboxTableView deleteSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = inboxTableView;
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:indexPath.section];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            InboxCell *cell = (InboxCell *)[tableView cellForRowAtIndexPath:indexPath];
             cell.fling = [self.flingFetchedResultsController objectAtIndexPath:indexPath];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [inboxTableView endUpdates];
}


@end
