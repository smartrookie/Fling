//
//  AppDelegate.m
//  Fling
//
//  Created by Ryo.x on 14/10/20.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "CameraViewController.h"
#import "OpenUDID.h"
#import "APService.h"
#import "CoreDataCenter.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Mobile UDID = %@", [userDefaults objectForKey:@"MobileUDID"]);
    
    if (![userDefaults objectForKey:@"MobileUDID"]) {
        [userDefaults setObject:[OpenUDID value] forKey:@"MobileUDID"];
        [userDefaults synchronize];
    } else {
        NSLog(@"Mobile UDID = %@", [userDefaults objectForKey:@"MobileUDID"]);
    }
    
    NSLog(@"Mobile UDID = %@", [userDefaults objectForKey:@"MobileUDID"]);
    
    if (![userDefaults objectForKey:@"MobileAlias"]) {
        [APService setAlias:[OpenUDID value]
           callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                     object:self];
    } else {
        NSLog(@"Mobile Alias = %@", [userDefaults objectForKey:@"MobileAlias"]);
    }
    
    if (![userDefaults objectForKey:@"SendCount"]) {
        [userDefaults setObject:@"20" forKey:@"SendCount"];
        [userDefaults synchronize];
    } else {
        NSLog(@"Send Count = %@", [userDefaults objectForKey:@"SendCount"]);
    }
    
    if (![userDefaults objectForKey:@"FlingListNeedRequest"]) {
        [userDefaults setObject:@"Yes" forKey:@"FlingListNeedRequest"];
        [userDefaults synchronize];
    } else {
        NSLog(@"FlingListNeedRequest = %@", [userDefaults objectForKey:@"FlingListNeedRequest"]);
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    CameraViewController *cameraVC = [CameraViewController shareInstance];
    
    UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:cameraVC];
    
    self.window.rootViewController = rootNC;
    
    [self.window makeKeyAndVisible];
    
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
    
    return YES;
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet *)tags alias:(NSString *)alias {
//    NSString *callbackString = [NSString stringWithFormat:@"%d, \ntags: %@, \nalias: %@\n", iResCode, [self logSet:tags], alias];
//    
//    NSLog(@"TagsAlias回调:%@", callbackString);
    if (iResCode == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:alias forKey:@"MobileAlias"];
    }
}

- (NSString *)logSet:(NSSet *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    
    NSString *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"FlingListNeedRequest"];
    
    if ([result isEqualToString:@"Yes"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REQUEST_FLING_LIST" object:nil];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:@"Yes" forKey:@"FlingListNeedRequest"];
//    [userDefaults synchronize];
    
    [[CoreDataCenter shareInstance] saveContext];
}

//- (void)applicationWillResignActive:(UIApplication *)application {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:@"Yes" forKey:@"FlingListNeedRequest"];
//    [userDefaults synchronize];
//}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"Yes" forKey:@"FlingListNeedRequest"];
    [userDefaults synchronize];
    
    [[CoreDataCenter shareInstance] saveContext];
}

//- (void)checkAliasCallback:(int)resultCode alias:(NSString *)alias {
//    NSLog(@"%d", resultCode);
//    
//    if (resultCode == 0) {
//        [[NSUserDefaults standardUserDefaults] setObject:alias forKey:@"MobileAlias"];
//    } else {
//        NSLog(@"%d", resultCode);
//    }
//}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    
    NSLog(@"123123");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"Yes" forKey:@"FlingListNeedRequest"];
    [userDefaults synchronize];
    
    if (application.applicationState == UIApplicationStateActive) {
        AudioServicesPlaySystemSound(1002);
        
        NSLog(@"%@", userInfo);
        NSLog(@"%@", [userDefaults objectForKey:@"FlingListNeedRequest"]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REQUEST_FLING_LIST" object:nil];
    } else {
        
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
