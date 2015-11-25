//
//  YDPersonListController.h
//  HNOANew
//
//  Created by 224 on 14-7-24.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

/**
 *人员列表界面
**/

#import <UIKit/UIKit.h>
#import "YDDepartment.h"

@protocol PersonListDelegate <NSObject>

- (void)setSelection:(NSMutableDictionary *)dict;

@end

typedef void (^ReturnBolck)(NSMutableDictionary *dict);//声明block

@interface YDPersonListController : UITableViewController <UISearchBarDelegate,
                                                            UISearchDisplayDelegate>

@property (strong, nonatomic) YDDepartment *department;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<PersonListDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISearchBar *contactSearchBar;

//定义block属性
@property (strong, nonatomic)ReturnBolck returnBlock;

- (void)returnText:(ReturnBolck)block;//第一个界面传进来的block语句快的函数

@end
