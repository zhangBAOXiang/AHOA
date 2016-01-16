//
//  YDLockViewController.h
//  hnOA
//
//  Created by 224 on 14-7-2.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDGestureLockView.h"
#import "YDMainViewController.h"
#import "YDLoginViewController.h"
#import "YDAppDelegate.h"

@interface YDLockViewController : UIViewController <YDGestureLockViewDelegate>

@property (strong, nonatomic)  IBOutlet YDGestureLockView *lockView;

@property (copy, nonatomic) NSString *currentVersion;
@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) MBProgressHUD *HUD;

- (IBAction)forgetGesture:(id)sender;
- (IBAction)reLogin:(id)sender;
@end
