//
//  AppDelegate.h
//  platform
//
//  Created by apple on 13-9-3.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPush.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString* gSessionId;
    NSString* gLoginMessage;
    NSString* gPersonName;
    NSString* gLoginName;
    NSString* gPersonId;
    BOOL bLogin;
    NSString* gServerHost;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;


@property(strong, nonatomic) NSString* gSessionId;
@property(strong, nonatomic) NSString* gLoginMessage;
@property(strong, nonatomic) NSString* gPersonName;
@property(strong, nonatomic) NSString* gPersonId;
@property(strong, nonatomic) NSString* gLoginName;
@property(assign, nonatomic) BOOL bLogin;
@property(strong, nonatomic) NSString* gServerHost;
@property(strong, nonatomic) NSString* gServerAddress;


@end
