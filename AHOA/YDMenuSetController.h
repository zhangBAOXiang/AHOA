//
//  YDMenuSetController.h
//  YNOA
//
//  Created by 224 on 14-9-15.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDMenu.h"

@interface YDMenuSetController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
