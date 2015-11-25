//
//  YDBaseViewController.m
//  LZHOA
//
//  Created by 224 on 15/7/9.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDBaseViewController.h"

@interface YDBaseViewController ()

@end

@implementation YDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.currentIsSale = YES;
    [self customTableViews];
}

- (void)customTableViews
{
//    UIImageView *imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
//    imageView.image=[UIImage imageNamed:@"welcome.png"];
//    [self.view addSubview:imageView];
    
    self.leftTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kLeftWidth,self.view.frame.size.height-120)style:UITableViewStylePlain];
    self.leftTable.showsVerticalScrollIndicator = NO;
    [self.leftTable setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.leftTable];
    
    self.rightTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kHeadNameCount*kWidth, self.view.frame.size.height-120)style:UITableViewStylePlain];
    [self.rightTable setSeparatorInset:UIEdgeInsetsZero];
    
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(kLeftWidth, 0, self.view.frame.size.width - kLeftWidth, self.view.frame.size.height-120)];
    self.scroll.contentSize = CGSizeMake(kHeadNameCount*kWidth, 0);
    self.scroll.backgroundColor = [UIColor clearColor];
    self.scroll.bounces = NO;
    [self.scroll addSubview:self.rightTable];
    
    [self.view addSubview:self.scroll];
    
    self.leftTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    self.rightTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    self.leftTable.contentOffset = self.rightTable.contentOffset;
    
}

- (void)customButtons:(NSArray *)buttons {
    
    float margin=(self.view.frame.size.width-80*buttons.count) / (buttons.count+1);
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 120)];
    [self.view addSubview:tabView];
    tabView.backgroundColor = UIColorFromRGB(0x3da8e5);
    
    for (int i = 0; i < buttons.count; i++) {
        YDTabButton *tab = buttons[i];
        YDImageButton *btn = [YDImageButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((i+1)*margin+80*i, 0, 80, 48)];
        [btn setImage:[UIImage imageNamed:tab.imageName] forState:UIControlStateNormal];
        if (tab.selectImageName != nil) {
            [btn setImage:[UIImage imageNamed:tab.selectImageName] forState:UIControlStateSelected];
        }
        [btn setTitle:tab.buttonName forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn addTarget:self action:tab.selName forControlEvents:UIControlEventTouchUpInside];
//        [btn setHighlighted:YES];
        [tabView addSubview:btn];
    }
}


@end
