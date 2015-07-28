//
//  YDTool.m
//  YNOA
//
//  Created by 224 on 14-11-14.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDTool.h"

@implementation YDTool

+ (void)cleanUserDefaults
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:[defaults valueForKey:@"userName"] forKey:@"oldUser"];
    [defaults removeObjectForKey:@"userName"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"version"];
    [defaults removeObjectForKey:@"personid"];
    [defaults removeObjectForKey:@"personnames"];
    [defaults removeObjectForKey:@"channelid"];
    [defaults removeObjectForKey:@"userid"];
    [defaults removeObjectForKey:@"personName"];
    [defaults removeObjectForKey:@"gesturePassword"];
    [defaults removeObjectForKey:@"busPersoninfo"];
    [defaults removeObjectForKey:@"responseString"];
    [defaults removeObjectForKey:@"menuString"];
    [defaults synchronize];
 
}

@end
