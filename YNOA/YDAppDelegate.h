//
//  YDAppDelegate.h
//  HNOA
//
//  Created by 224 on 14-8-5.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YDSplashViewController;
@interface YDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) YDSplashViewController *viewController;

//保存从百度云获取的channelid和userid,用于绑定
@property (copy, nonatomic) NSString *channelid;
@property (copy, nonatomic) NSString *userid;

+ (NSMutableArray *)sharedDepartments;
+ (NSMutableDictionary *)sharedMobileCodes;
+ (NSMutableData *)sharedPersonInfo;

@end
