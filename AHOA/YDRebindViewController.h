//
//  YDRebindViewController.h
//  HNOA
//
//  Created by 224 on 14-8-8.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDRebindViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationBar *navbar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navbarItem;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *btn;
- (IBAction)rebind:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@end
