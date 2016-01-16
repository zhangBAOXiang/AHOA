//
//  YDFunctionMenuCell.h
//  AHOA
//
//  Created by Zhang-mac on 15/12/8.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ColCount 4

@class YDFunctionMenuCell;
@protocol YDFunctionMenuCellDelegate <NSObject>

@optional

- (void)productCell:(YDFunctionMenuCell *)cell actionWithFlag:(NSInteger)flag;

@end



@interface YDFunctionMenuCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) UITableView *tableview;
@property (strong, nonatomic) UITableView *anotherTableView;
@property (strong, nonatomic) NSArray *menuArray;
@property (strong, nonatomic) NSArray *menuAllArray;
@property (strong, nonatomic) NSArray *menuNameArray;
@property (strong, nonatomic) NSArray *menuCodeArray;
@property (copy, nonatomic) NSString *selectedURL;
@property (weak, nonatomic) id<YDFunctionMenuCellDelegate> cellDelegate;

@end
