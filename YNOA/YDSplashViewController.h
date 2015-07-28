//
//  YDSplashViewController.h
//  hnOA
//
//  Created by 224 on 14-6-30.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

/**
 *启动界面
**/

#import <UIKit/UIKit.h>
#import "YDLoginViewController.h"
#import "YDLockViewController.h"

@interface YDSplashViewController : UIViewController

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIImageView *splashImageView;
@property (strong, nonatomic) UILabel *label1;
@property (strong, nonatomic) UILabel *label2;

@property (strong, nonatomic) YDLoginViewController *viewController;
@property (strong, nonatomic) YDLockViewController *lockViewController;

@end
