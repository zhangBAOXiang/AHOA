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

@end

@implementation YDLockViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    self.view.backgroundColor=UIColorFromRGB(0x48ADE8);
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [self detectUpdate];
    
    self.backGroundView.frame=self.view.frame;
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
    
    //圆形头像
    UIImageView *imageView;
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        imageView=[[UIImageView alloc] initWithFrame:CGRectMake(125, 30, 70, 70)];
    }else{
        imageView=[[UIImageView alloc] initWithFrame:CGRectMake(135, 30, 50, 50)];
    }
    
    [imageView.layer setCornerRadius:CGRectGetHeight([imageView bounds])/2];
    imageView.layer.masksToBounds=YES;
//    imageView.layer.borderWidth=2;
    imageView.layer.borderColor=[[UIColor whiteColor] CGColor];
    imageView.layer.contents=(id)[[UIImage imageNamed:@"head.png"] CGImage];
    [self.view addSubview:imageView];
    
    //人员姓名
    if ([defaults valueForKey:@"personName"]) {
        UILabel *label;
        if ([[UIScreen mainScreen] bounds].size.height == 568){
            label=[[UILabel alloc] initWithFrame:CGRectMake(13, 97, 300, 30)];
        }else{
            label=[[UILabel alloc] initWithFrame:CGRectMake(13, 77, 300, 30)];
        }
        
        label.backgroundColor=[UIColor clearColor];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor blackColor];
        label.text=[defaults valueForKey:@"personName"];
        [self.view addSubview:label];
    }
    
    //提示信息
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        self.infoLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 127, 300, 30)];
    }else{
        //320*480
        self.infoLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 97, 300, 30)];
        self.lockView.frame=CGRectMake(0, 130, 320, 300);
    }
    
    self.infoLabel.backgroundColor=[UIColor clearColor];
    self.infoLabel.textAlignment=NSTextAlignmentCenter;
    self.infoLabel.textColor=[UIColor redColor];
    [self.view addSubview:self.infoLabel];
    
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
                    
                    YDLoginViewController *viewController=[[YDLoginViewController alloc] initWithNibName:@"YDLoginViewController" bundle:[NSBundle mainBundle]];
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
                    
                    YDLoginViewController *viewController=[[YDLoginViewController alloc] initWithNibName:@"YDLoginViewController" bundle:[NSBundle mainBundle]];
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
    
    Reachability *r=[Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    if ([r currentReachabilityStatus]==NotReachable) {
        //网络连接不可用
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"消息" message:@"对不起，您当前无网络连接，请先连接网络!!"
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    else{
        [YDSaleStore removePath];
        if (![defaults valueForKey:@"updatePassword"]) {
            self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.HUD];
            self.HUD.labelText=@"加载界面..";
            self.HUD.dimBackground=NO;
            [self.HUD show:YES];
            [self busGetMenuList];
            
        }else{
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

    }
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

- (IBAction)forgetGesture:(id)sender {
    [YDTool cleanUserDefaults];
    
    YDLoginViewController *viewController=[[YDLoginViewController alloc] initWithNibName:@"YDLoginViewController" bundle:[NSBundle mainBundle]];
    viewController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController=viewController;

}

- (IBAction)reLogin:(id)sender {
    [YDTool cleanUserDefaults];
    
    YDLoginViewController *viewController=[[YDLoginViewController alloc] initWithNibName:@"YDLoginViewController" bundle:[NSBundle mainBundle]];
    viewController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController=viewController;

}

@end
