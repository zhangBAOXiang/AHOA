//
//  YDSplashViewController.m
//  hnOA
//
//  Created by 224 on 14-6-30.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSplashViewController.h"

@interface YDSplashViewController ()

@end

@implementation YDSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    CGRect appFrame=[[UIScreen mainScreen] applicationFrame];
    UIView *view=[[UIView alloc] initWithFrame:appFrame];
    view.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view=view;
    
    self.splashImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcome.jpg"]];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        self.splashImageView.frame=CGRectMake(0, 0, 320, 480);
    }else{
        self.splashImageView.frame=CGRectMake(0, 0, 320, 568);
    }
    
    [self.view addSubview:self.splashImageView];
    
    UIImageView *topView=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-65, 100, 106, 103)];
    topView.image=[UIImage imageNamed:@"welcome_top.png"];
    [topView setTag:100];
    [self.view addSubview:topView];
    
    UILabel *topLabel=[[UILabel alloc] initWithFrame:CGRectMake(70, 208, 180, 50)];
    topLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:21];
    topLabel.text=@"云南中烟营销系统";
    [topLabel setTag:101];
    [self.view addSubview:topLabel];
    
    //设置版本号
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"version"]) {
        self.label1=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-65, self.view.frame.size.height/2, 70, 50)];
        self.label1.font=[UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
        self.label1.text =@"version:";
        self.label1.textColor=[UIColor blackColor];
        [self.view addSubview:self.label1];
        
        self.label2=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2+5, self.view.frame.size.height/2, 100, 50)];
        self.label2.font=[UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
        self.label2.text =[[NSUserDefaults standardUserDefaults] valueForKey:@"version"];
        self.label2.textColor=[UIColor blackColor];
        [self.view addSubview:self.label2];

    }
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];
    
}

- (void)fadeScreen
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishedFading)];
    self.view.alpha=0.0;
    [UIView commitAnimations];
}

- (void) finishedFading
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"gesturePassword"]) {
        self.view.alpha=1.0;
//        [self.viewController.view removeFromSuperview];
//        self.lockViewController.view.alpha=1.0;
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            self.lockViewController=[[YDLockViewController alloc] initWithNibName:@"YDLockViewController"  bundle:[NSBundle mainBundle]];
        }else{
            self.lockViewController=[[YDLockViewController alloc] initWithNibName:@"YDLockViewController4" bundle:[NSBundle mainBundle]];
        }

        [self.view addSubview:self.lockViewController.view];
        

    }else{
        self.view.alpha=1.0;
//        [self.lockViewController.view removeFromSuperview];
//        self.viewController.view.alpha=1.0;
            self.viewController=[[YDLoginViewController alloc] initWithNibName:@"YDLoginViewController"
                                                                        bundle:[NSBundle mainBundle]];
            [self.view addSubview:self.viewController.view];
    }
    
//    self.viewController.view.alpha=1.0;
    [UIView commitAnimations];
    [self.splashImageView removeFromSuperview];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"version"]) {
        [self.label1 removeFromSuperview];
        [self.label2 removeFromSuperview];
        [[self.view viewWithTag:100] removeFromSuperview];
        [[self.view viewWithTag:101] removeFromSuperview];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}


@end
