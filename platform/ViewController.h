//
//  ViewController.h
//  platform
//
//  Created by apple on 13-9-3.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMD5.h"
#import "Reachability.h"
#import "commonUtil.h"
#import "SoapXmlParseHelper.h"
#import "MainViewController.h"
#import "AppDelegate.h"


@interface ViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>

@property(strong, nonatomic) NSString *serverHost;
@property(strong, nonatomic) NSString *serverAddress;


@end
