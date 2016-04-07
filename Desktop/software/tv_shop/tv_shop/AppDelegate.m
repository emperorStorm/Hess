//
//  AppDelegate.m
//  tv_shop
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 peraytech. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "WXApi.h"
@interface AppDelegate ()
@property (strong,nonatomic) UIView *splashView;
@end

@implementation AppDelegate
@synthesize splashView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]];
    [UMSocialData setAppKey:UMKEY];
    //隐藏状态栏，info.plist中Status bar is initially hidden设置为yes确保loading页页隐藏，View controller-based status bar appearance设置为NO确保不使用默认的状态栏显示模式
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    sleep(3.0);//延长3秒

    //设置微信AppId、appSecret
    //三方登陆
    [UMSocialWechatHandler setWXAppId:@"wx3b21a5ea2aa7222e" appSecret:@"e802579a22f3447d1f3a37555e96700e" url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setQQWithAppId:@"1105009253" appKey:@"3N2I2sp9EnlPNntW" url:@"http://www.umeng.com/social"];
    //QQ授权
    TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:@"1105009253" andDelegate:self];
    //注册微信app
    [WXApi registerApp:@"wx3b21a5ea2aa7222e"];
    return YES;
}

#pragma  mark -- qq登陆重写的方法
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
        result = [TencentOAuth HandleOpenURL:url];
    }
    return result;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
