//
//  YDSettingViewController.h
//  HNOA
//
//  Created by 224 on 14-8-5.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface YDSettingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UINavigationBar *navbar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (strong, nonatomic) CLLocationManager *localManager;
@end
