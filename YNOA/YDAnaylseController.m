//
//  YDAnaylseController.m
//  YNOA
//
//  Created by 224 on 14-9-22.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDAnaylseController.h"

@interface YDAnaylseController ()

@end

@implementation YDAnaylseController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIView *rightView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 63)];
    UIImageView *rightImage=[[UIImageView alloc] init];
    rightImage.image=[UIImage imageNamed:@"about_info.png"];
    rightImage.frame=CGRectMake(0, 0, 48, 60);
    [rightView addSubview:rightImage];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightView];

}

- (void)handleLeft
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
