//
//  AppDelegate.m
//  LUDE
//
//  Created by 胡祥清 on 15/10/7.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "AppDelegate.h"
#import "NTAccount.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "GuideViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "PressureDataModel.h"
#import "APService.h"

#define SHARESDKAPPKEY @"ba0360de3ea3"
#define WXAPPID @"wxe5f0388ff5ae4602"
#define WXAPPSECRET @"d4624c36b6795d1d99dcf0547af5443d"
#define WBAPPID @"35451006"
#define WBAPPSECRET @"74d9dbaa39092daf37989afb18e1ca8e"

#define REDIRECTURL @"http://www.sharesdk.cn"
#import "NavRootViewController.h"
#import "MobClick.h"
@interface AppDelegate ()

@end

static AppDelegate *_appDelegate;

@implementation AppDelegate
#define UMAppKey @"5694771fe0f55a251b001d4f"
+ (AppDelegate *) app
{
    return _appDelegate;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _appDelegate = self;
    
    [MobClick startWithAppkey:UMAppKey reportPolicy:BATCH channelId:nil];
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"isFirst"])
    {//第一次登陆
        GuideViewController *guideView = [[GuideViewController alloc] initWithStoryboardID:@"GuideViewController"];
        self.window.rootViewController = [[NavRootViewController alloc]initWithRootViewController:guideView];
    }
    else
    {//不是第一次登陆
        NSDictionary *dict = [DEFAULTS objectForKey:@"User"];
        NSString * userIdStr =[[dict objectForKey:@"data"]objectForKey:@"userId"];
        
        if (userIdStr) {
            MainViewController *MainView = [[MainViewController alloc] initWithStoryboardID:@"MainViewController"];
            self.window.rootViewController = [[NavRootViewController alloc]initWithRootViewController:MainView];
        }
        else
        {
            /**
             *	@brief	弹出登陆界面
             */
            LoginViewController *loginView = [[LoginViewController alloc] initWithStoryboardID:@"LoginViewController"];
            UINavigationController *loginNav = [[NavRootViewController alloc]initWithRootViewController:loginView];
            self.window.rootViewController = loginNav;
        }
    }
    [[NSUserDefaults standardUserDefaults]setObject:@"second" forKey:@"isFirst"];
 
    //ShareSDK
    [self registerShareSDK];
    //监听通知事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(obtainUserId:)
                                                 name:@"obtainUserId"
                                               object:nil];
    //JPush
    [self registerJPushWithOptions:launchOptions];
   
    return YES;
}

-(void)saveMessageContend:(NSDictionary *)userInfo
{
    NSString *pushType = [userInfo valueForKey:@"pushType"];
    if (![pushType isEqualToString:@"2"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"apns" object:userInfo];
        NSMutableArray  *messages;
        if ([[NTAccount shareAccount] Messages]) {
            messages = [[NSMutableArray alloc] initWithArray:[[NTAccount shareAccount] Messages]];
        }
        else
        {
            messages = [[NSMutableArray alloc] init];
        }
//        LUDEMessage *message = [[LUDEMessage alloc] init];
//        message.read = [NSNumber numberWithBool:NO];
//        message.PushType = pushType;
//        [messages insertObject:message atIndex:0];\
        
        if(![messages containsObject:pushType])
        {
            [messages addObject:pushType];
        }
        
        [[NTAccount shareAccount] setMessages:messages];
    }
}
//为用户设置通知的tag值
-(void)obtainUserId:(NSNotification *)info
{
    NSDictionary *_dic = [info userInfo];
    [APService setTags:[NSSet setWithObject:@"sysMessage"] alias:[_dic objectForKey:@"userId"] callbackSelector:nil object:nil];
}

//apns
-(void)registerJPushWithOptions:(NSDictionary *)launchOptions
{
    // Required
    //可以添加自定义categories
    [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                   UIUserNotificationTypeSound |
                                                   UIUserNotificationTypeAlert)
                                       categories:nil];
        
    // Required
    [APService setupWithOption:launchOptions];
    
    // apn 内容获取：
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        [self saveMessageContend:remoteNotification];
    }
}

//shareSDK
-(void)registerShareSDK
{
    [ShareSDK registerApp:SHARESDKAPPKEY
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformSubTypeWechatSession),
                            @(SSDKPlatformSubTypeWechatTimeline),
                            ]
                 onImport:^(SSDKPlatformType platformType) {
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         default:
                             break;
                     }
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupSinaWeiboByAppKey:WBAPPID appSecret:WBAPPSECRET redirectUri:REDIRECTURL authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:WXAPPID
                                            appSecret:WXAPPSECRET];
                      break;
                  default:
                      break;
              }
          }];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [APService registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [APService handleRemoteNotification:userInfo];
     [self saveMessageContend:userInfo];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [APService setBadge:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {

}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
     [self saveMessageContend:userInfo];
}
#endif
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [APService handleRemoteNotification:userInfo];
     [self saveMessageContend:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [APService showLocalNotificationAtFront:notification identifierKey:nil];
}



@end
