//
//  YDViewController.h
//  hnOA
//
//  Created by 224 on 14-6-24.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDSoapAndXmlParseUtil.h"
#import "YDAppDelegate.h"
#import "YDLockViewController.h"
#import "YDSqliteUtil.h"

@interface YDLoginViewController : UIViewController <UITextFieldDelegate>

//fields
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *returnString;
@property (strong ,nonatomic) NSMutableData *data;

- (IBAction)userLogin:(id)sender;

@end
