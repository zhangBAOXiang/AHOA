//
//  YDContactViewController.h
//  HNOANew
//
//  Created by 224 on 14-7-17.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

/**
 *通讯录和人员查询界面
**/

#import <UIKit/UIKit.h>

@interface YDContactViewController : UITableViewController <UISearchBarDelegate,
                                                            UISearchDisplayDelegate,
                                                            UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *contactSearchBar;

@property (weak, nonatomic) IBOutlet UIImageView *selectView;
@property (weak, nonatomic) IBOutlet UILabel *departLabel;

@end
