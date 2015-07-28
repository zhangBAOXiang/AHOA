//
//  YDTabController.m
//  HNOANew
//
//  Created by 224 on 14-7-17.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDTabController.h"
#import "YDPerson.h"
#import "YDAppDelegate.h"
#import "YDSqliteUtil.h"

@interface YDTabController () <UITabBarDelegate>{
    YDAppDelegate *appDelegate;
}

@property (strong ,nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) MFMessageComposeViewController *picker;
@property (strong, nonatomic) NSMutableArray *selecedMobileCodes;
@property (copy, nonatomic) NSString *path;

@end

@implementation YDTabController

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
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    //设置navigationbar的背景颜色
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x3DA8E5);
    self.tabBar.barTintColor=[UIColor whiteColor];
    
    //导航栏按钮
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"firstpage.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.navigationItem setTitle:@"云南中烟"];
    
    self.navigationController.navigationBar.translucent=NO;
    // Do any additional setup after loading the view.
}

- (void)home
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarControl Delegate Mehtod

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 1) {
        BOOL canSendSMS=[MFMessageComposeViewController canSendText];
        
        if (canSendSMS) {
            self.picker=[[MFMessageComposeViewController alloc] init];
            self.picker.messageComposeDelegate=self;
            self.picker.navigationBar.tintColor=[UIColor blackColor];
            self.picker.body=@"";
            // 默认收件人(可多个)
            
            NSMutableArray *mobilecodes=[NSMutableArray array];
            for (NSString *departName in [YDAppDelegate sharedDepartments]) {
                NSMutableArray *array=[[YDAppDelegate sharedMobileCodes] valueForKey:departName];
//                NSLog(@"array=%@",array);
                for (int i=0; i<[array count]; i++) {
                    YDPerson *person=array[i];
//                    NSLog(@"selected=%@",person.selected?@"yes":@"no");
                    if (person.selected) {
                        [mobilecodes addObject:person.mobilecode];
                    }
                }
            }
            
            if ([mobilecodes count] != 0) {
                self.picker.recipients=mobilecodes;
                [self presentViewController:self.picker animated:YES completion:nil];
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择联系人" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
}

#pragma mark - MFMessageComposeViewController Delegate Methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Result: Canceled");
            break;
            
        case MessageComposeResultSent:
            NSLog(@"Result: Sent");
            break;
            
        case MessageComposeResultFailed:
            NSLog(@"Result: Failed");
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
