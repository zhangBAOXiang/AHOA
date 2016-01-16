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

- (void)loadView
{
    CGRect appFrame=[[UIScreen mainScreen] applicationFrame];
    UIView *view=[[UIView alloc] initWithFrame:appFrame];
    view.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view=view;
    
    self.splashImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcome.jpg"]];
    
    [self.view addSubview:self.splashImageView];
    
    self.splashImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.splashImageView
                              attribute:NSLayoutAttributeLeading
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeLeading
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.splashImageView
                              attribute:NSLayoutAttributeTrailing
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeTrailing
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.splashImageView
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeTop
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.splashImageView
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeBottom
                              multiplier:1
                              constant:0]];
    
    UILabel *topLabel=[[UILabel alloc] init];
    topLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:20];
    topLabel.text=@"安徽中烟客服系统";
    [topLabel setTag:101];
    [self.view addSubview:topLabel];
    
    topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:topLabel
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:topLabel
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1
                              constant:0]];
    
    UIImageView *topView=[[UIImageView alloc] init];
    topView.image=[UIImage imageNamed:@"welcome_top.png"];
    [topView setTag:100];
    [self.view addSubview:topView];
    
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:topView
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:topView
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:topLabel
                              attribute:NSLayoutAttributeTop
                              multiplier:1
                              constant:-50]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:topView
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeWidth
                              multiplier:1
                              constant:106]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:topView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeHeight
                              multiplier:1
                              constant:106]];
    
    //设置版本号
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"version"]) {
        
        self.label1 = [[UILabel alloc] init];
        self.label1.font=[UIFont fontWithName:@"Helvetica-Oblique" size:19];
        self.label1.text = [NSString stringWithFormat:@"version:%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"version"]];
        self.label1.textColor = [UIColor blackColor];
        [self.view addSubview:self.label1];
        
        self.label1.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:self.label1
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                  constant:0]];
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:self.label1
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:topLabel
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1
                                  constant:50]];

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
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LockAndLogin" bundle:nil];
    if ([defaults valueForKey:@"gesturePassword"]) {
        self.view.alpha=1.0;

        self.lockViewController = [storyBoard instantiateViewControllerWithIdentifier:@"YDLockViewController"];

        [self.view addSubview:self.lockViewController.view];
        

    }else{
        self.view.alpha=1.0;
        self.viewController = [storyBoard instantiateViewControllerWithIdentifier:@"YDLoginViewController"];
            [self.view addSubview:self.viewController.view];
    }
    
    [UIView commitAnimations];
    [self.splashImageView removeFromSuperview];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"version"]) {
        [self.label1 removeFromSuperview];
        [[self.view viewWithTag:100] removeFromSuperview];
        [[self.view viewWithTag:101] removeFromSuperview];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}


@end
