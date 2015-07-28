//
//  YDBaseViewController+ConfigureCell.h
//  YNOA
//
//  Created by 224 on 15/7/19.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDBaseViewController.h"
#import "YDSaleAnaylse.h"

@interface YDBaseViewController (ConfigureCell)

- (void)configureCell:(UITableViewCell *)cell withSale:(YDSaleAnaylse *)sale;
- (void)customTitleView:(NSString *)titleString withDateString:(NSString *)dateString;
- (void)customTitleView:(NSString *)titleString withDateString2:(NSString *)dateString;

@end
