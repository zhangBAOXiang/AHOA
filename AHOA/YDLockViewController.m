//
//  YDLockViewController.m
//  hnOA
//
//  Created by 224 on 14-7-2.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDLockViewController.h"
#import "YDLoginViewController.h"
#import "YDAppDelegate.h"
#import "YDMenuStore.h"
#import "YDSaleStore.h"
#import "YDLockViewController+DetectUpdate.h"
#import "YDLockViewController+Menu.h"

static int count=0;

@interface YDLockViewController ()

@property (assign, nonatomic)ePasswordState state;
@property (copy, nonatomic) NSString *password;
@property (strong, nonatomic) UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockBottomConstraint;

@end

@implementation YDLockViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
//    self.view.backgroundColor=UIColorFromRGB(0x48ADE8);
    
    if (self.view.bounds.size.height > 568) {
        self.lockBottomConstraint.constant = 50;
        [self.view setNeedsUpdateConstraints];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [self detectUpdate];
    self.password=@"";
    
  
    if ([defaults valueForKey:@"gesturePassword"]) {
        
        if ([defaults valueForKey:@"updatePassword"]) {
            self.state=ePasswordOld;
        }else{
            self.state=ePasswordLogin;
        }
    }else {
        self.state=ePasswordUnset;
    }
    
    //提示信息
    self.infoLabel=[[UILabel alloc] init];
    
    self.infoLabel.backgroundColor=[UIColor clearColor];
    self.infoLabel.textAlignment=NSTextAlignmentCenter;
    self.infoLabel.textColor=[UIColor redColor];
    self.infoLabel.font = [UIFont fontWithName:@"Helvetica" size:19];
    [self.view addSubview:self.infoLabel];
    
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.infoLabel
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.lockView
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.infoLabel
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.lockView
                              attribute:NSLayoutAttributeTop
                              multiplier:1
                              constant:-15]];
    
    //人员姓名
    if ([defaults valueForKey:@"personName"]) {
        UILabel *label=[[UILabel alloc] init];
        
        label.backgroundColor=[UIColor clearColor];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor blackColor];
        label.text=[defaults valueForKey:@"personName"];
        label.font = [UIFont fontWithName:@"Helvetica" size:19];
        [self.view addSubview:label];
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:label
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.infoLabel
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                  constant:0]];
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:label
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.infoLabel
                                  attribute:NSLayoutAttributeTop
                                  multiplier:1
                                  constant:-10]];
    }
    
    //圆形头像
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [imageView.layer setCornerRadius:CGRectGetHeight([imageView bounds])/2];
    imageView.layer.masksToBounds=YES;
    imageView.layer.borderColor=[[UIColor whiteColor] CGColor];
    imageView.layer.contents=(id)[[UIImage imageNamed:@"head.png"] CGImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.infoLabel
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.infoLabel
                              attribute:NSLayoutAttributeTop
                              multiplier:1
                              constant:-40]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeWidth
                              multiplier:1
                              constant:70]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeHeight
                              multiplier:1
                              constant:70]];

    
    self.lockView.delegate=self;
    
    [self updateInfoLabel];
}

- (void)updateInfoLabel
{
    NSString *infoText;
    switch (self.state) {
        case ePasswordUnset:
            infoText=@"请设置手势密码";
            break;
            
        case ePasswordRepeat:
            infoText=@"请确认手势密码";
            break;
            
        case ePasswordExist:
            infoText=@"密码设置成功";
            break;
            
        case ePasswordLogin:
            if (count==0) {
                infoText=@"请输入密码:";
            }else{
                infoText=[[NSString alloc] initWithFormat:@"密码错误,您还可以再输入%d次",3-count];
            }
            break;
            
        case ePasswordOld:
            infoText=@"请输入原始密码:";
            break;
            
        default:
            break;
    }
    
    self.infoLabel.text=infoText;
}

#pragma mark - Lock View Delegate Method

- (void)LockViewDidClick:(YDGestureLockView *)lockView andPassword:(NSString *)pwd
{
    switch (self.state) {
        case ePasswordUnset:
            self.password=pwd;
            if ([self.password length]>=3) {
                self.state=ePasswordRepeat;
            }else{

            }
            break;
            
        case ePasswordOld:{
            self.password=pwd;
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            if ([pwd isEqualToString:[defaults valueForKey:@"gesturePassword"]]) {
                [defaults removeObjectForKey:@"gesturePassword"];
//                [defaults removeObjectForKey:@"updatePassword"];
//                [defaults synchronize];
                self.state=ePasswordUnset;
            }else{
                count++;
                if (count != 3) {

                }else{
                    [YDTool cleanUserDefaults];
                    
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LockAndLogin" bundle:nil];
                    YDLoginViewController *viewController=[storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    viewController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
                    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
                    delegate.window.rootViewController=viewController;
                }
            }
            break;
        }
        case ePasswordRepeat:
            if ([pwd isEqualToString:self.password]) {
                self.state=ePasswordExist;
                
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                [defaults setValue:pwd forKey:@"gesturePassword"];
                [defaults synchronize];
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(finishAnimating)];
//                self.view.alpha=0.0;
                [UIView commitAnimations];

            }
            break;
            
        case ePasswordExist: {

            self.state=ePasswordLogin;
        }
            break;
            
        case ePasswordLogin:{
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            if ([pwd isEqualToString:[defaults valueForKey:@"gesturePassword"]])
            {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(finishAnimating)];
                [UIView commitAnimations];
                
                
            }else{
                count++;
                if (count!=3) {
                    
                }else{
                    [YDTool cleanUserDefaults];
                    
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LockAndLogin" bundle:nil];
                    YDLoginViewController *viewController=[storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    viewController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
                    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
                    delegate.window.rootViewController=viewController;
                    
                }
                
            }
        }
            break;
            
        default:
            break;
    }
    
    [self updateInfoLabel];
}

- (void)finishAnimating
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    self.HUD.labelText=@"加载界面..";
    self.HUD.dimBackground=NO;
    
    if ([defaults valueForKey:@"updatePassword"]) {
        [defaults removeObjectForKey:@"updatePassword"];
        [defaults synchronize];
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
        [UIView transitionWithView:self.view
                          duration:1.0f
                           options:UIViewAnimationOptionTransitionCurlDown
                        animations:^{
                            delegate.window.rootViewController=[storyBoard instantiateInitialViewController];
                        }
                        completion:nil];
    }
    
    
    BOOL menuExists = [defaults boolForKey:@"menuExists"];
    if (!menuExists) {
        [self.HUD show:YES];
        [self busGetMenuList];
        
    }else{
        [self.HUD show:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
            delegate.window.rootViewController=[storyBoard instantiateInitialViewController];
        });
        
        
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)forgetGesture:(id)sender {
    [YDTool cleanUserDefaults];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LockAndLogin" bundle:nil];
    YDLoginViewController *viewController=[storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    viewController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController=viewController;

}

- (IBAction)reLogin:(id)sender {
    [YDTool cleanUserDefaults];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LockAndLogin" bundle:nil];
    YDLoginViewController *viewController=[storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    viewController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController=viewController;

}

@end
