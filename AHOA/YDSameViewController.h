//
//  YDSameViewController.h
//  HNOA
//
//  Created by 224 on 14-8-6.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDSameViewController : UITableViewController <UISearchBarDelegate,
                                                         UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *contactSearchBar;

@property (weak, nonatomic) IBOutlet UIImageView *selectView;
@property (weak, nonatomic) IBOutlet UILabel *departLabel;

@end
