//
//  MainViewController.h
//  platform
//s
//  Created by apple on 13-9-3.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "commonUtil.h"
#import "MarsLocation.h"
#import "Reachability.h"
#import "SoapXmlParseHelper.h"
#import <sqlite3.h>
#import "SSZipArchive.h"
#import <CoreLocation/CoreLocation.h>
#import "PCStackMenu.h"
#import "AreaStruct.h"
#import "MTMagnifyView.h"

@interface MainViewController : UIViewController<UIScrollViewDelegate, UIWebViewDelegate, CLLocationManagerDelegate>

@property(strong, nonatomic) AppDelegate *delegate;

@end
