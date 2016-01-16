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
    
    return YES;
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
