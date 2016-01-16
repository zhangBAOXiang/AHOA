//
//  YDAppDelegate.m
//  hnOA
//
//  Created by 224 on 14-6-24.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDAppDelegate.h"
#import "YDSplashViewController.h"
#import "YDSaleStore.h"
#import "YDIndSaleStore.h"
#import "YDSaleStockStore.h"

static NSMutableDictionary *mobilecodes=nil;
static NSMutableArray *departments=nil;
static NSMutableData *data=nil;

@interface YDAppDelegate ()<NSURLConnectionDataDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) NSMutableData *data;
@property (assign, nonatomic) NSInteger type;

@end

@implementation YDAppDelegate

- (void)uniqueToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceUUID = [defaults valueForKey:@"deviceUUID"];
    if (deviceUUID != nil && deviceUUID.length > 0) {
        
    }else {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        [defaults setValue:result forKey:@"deviceUUID"];
        [defaults synchronize];
    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.viewController=[[YDSplashViewController alloc] init];
    self.window.rootViewController=self.viewController;
    
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    
    [self uniqueToken];
    
    //百度云推送设置
    //必须
    [BPush setupChannel:launchOptions];
    //必须。参数对象必须实现(void)onMethod:(NSString *)method....方法
    [BPush setDelegate:self];
    
    //三个参数分别代表消息（横幅或提醒，由用户Setting决定，程序不可更改）、数字标记、声音。
    //支持ios8
    #if _IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge
                                        |UIRemoteNotificationTypeAlert
                                        |UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    }
    #endif
    
    [application registerForRemoteNotificationTypes:
                    UIRemoteNotificationTypeAlert
                    | UIRemoteNotificationTypeBadge
                    | UIRemoteNotificationTypeSound];
    
    application.applicationIconBadgeNumber=0;
    
    return YES;
}

//iPhone 从APNs服务器获取deviceToken后回调此方法
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //注册device token
    //必须
    [BPush registerDeviceToken:deviceToken];
    //必须。可以在其他时机调用，只有在该方法返回(通过 onMethod:response:
    //回调)绑定成功时,app 才能接收到 Push 消息。一个 app 绑定成功至少一次即可(如 果 access token 变更请重新绑定).
    
    NSString* dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSLog(@"deviceToken is:%@", dt);
    [BPush bindChannel];
}

// 必须,如果正确调用了 setDelegate,在 bindChannel 之后,结果在这个回调中返回。 若绑定失败,请进行重新绑定,确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data {
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
        self.channelid=[res valueForKey:BPushRequestChannelIdKey];
        self.userid=[res valueForKey:BPushRequestUserIdKey];
        int returnCode=[[res valueForKey:BPushRequestErrorCodeKey] intValue];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setInteger:returnCode forKey:@"bpushCode"];
        [defaults synchronize];
    }
}

//支持ios8
#if _IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //可选
    //处理接收到的push消息
    [application setApplicationIconBadgeNumber:0];
    [BPush handleNotification:userInfo];
}

//注册push功能失败 后 返回错误信息，执行相应的处理
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Push Register Error:%@", error.description);
}

//应用程序从后台激活时
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [YDIndSaleStore removePath];
    [YDSaleStockStore removePath];
    [YDSaleStore removePath];
}

//
///**全局变量单例模式，说实话这个很重要，否则即使定义了全局变量
// *但是在其他的类中使用时，遇到很多问题，根本无法使用
// *单例模式确保每次调用的都是同一个变量
// **/
+(NSMutableDictionary *)sharedMobileCodes
{
    if (mobilecodes == nil) {
        mobilecodes=[NSMutableDictionary dictionary];
    }

    return mobilecodes;
}

+(NSMutableArray *)sharedDepartments
{
    if (departments == nil) {
        departments=[NSMutableArray array];
    }

    return departments;
}

+ (NSMutableData *)sharedPersonInfo
{
    if (data == nil) {
        data=[NSMutableData data];
    }

    return data;
}

@end
