//
//  YDBaseViewController.h
//  LZHOA
//
//  Created by 224 on 15/7/9.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDTabButton.h"
#import "YDImageButton.h"

@interface YDBaseViewController : UIViewController

@property (strong, nonatomic) UITableView *leftTable;
@property (strong, nonatomic) UITableView *rightTable;
@property (strong, nonatomic) UIScrollView *scroll;
@property (strong, nonatomic) NSArray *leftSource;
@property (strong, nonatomic) NSArray *rightSource;

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (copy, nonatomic) NSString *yorm;
@property (assign, nonatomic) BOOL currentIsSale;//判定当前是销量页面还是销售额页面.默认位销量页面
@property (copy, nonatomic) NSString *timeStamp;

- (void)customButtons:(NSArray *)buttons;
- (void)customTableViews;

@end
