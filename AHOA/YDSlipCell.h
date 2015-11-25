//
//  YDSlipCell.h
//  YNOA
//
//  Created by 224 on 14-9-5.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

/**
 *滑动模块cell
**/

#import <UIKit/UIKit.h>
#import "YDImageButton.h"
#define RColCount 4
#define RRowForCell 2

@class YDSlipCell;
@protocol YDSlipCellDelegate <NSObject>

@optional

- (void)productCell:(YDSlipCell *)cell actionWithFlag:(NSInteger)flag;

@end

@interface YDSlipCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableview;
@property (strong, nonatomic) UITableView *anotherTableView;
@property (copy, nonatomic) NSString *selectedURL;
@property (strong, nonatomic) NSArray *menuArray;
@property (weak, nonatomic) id<YDSlipCellDelegate> cellDelegate;

@end
