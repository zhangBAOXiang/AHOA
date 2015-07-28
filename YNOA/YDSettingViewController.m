//
//  YDSettingViewController.m
//  HNOA
//
//  Created by 224 on 14-8-5.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSettingViewController.h"
#import "YDAppDelegate.h"
#import "YDLockViewController.h"
#import "YDLoginViewController.h"
#import "YDRebindViewController.h"
#import "YDMenuSetController.h"

@interface YDSettingViewController ()<CLLocationManagerDelegate>

@property (assign, nonatomic) BOOL isOpen;
@property (copy, nonatomic) NSString *currentVersion;

@end

@implementation YDSettingViewController

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
    
    self.isOpen=NO;
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.navbar setBarTintColor: UIColorFromRGB(0x3DA8E5)];
    
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 63)];
    imageview.image=[UIImage imageNamed:@"head_set.png"];
    self.navItem.titleView=imageview;
    
    UIButton *btn1=[[UIButton alloc] init];
    [btn1 setImage:[UIImage imageNamed:@"firstpage.png"] forState:UIControlStateNormal];
    btn1.contentMode=UIViewContentModeCenter;
    [btn1 setFrame:CGRectMake(0, 0, 50, 63)];
    [btn1 addTarget:self action:@selector(handleRight) forControlEvents:UIControlEventTouchUpInside];
    self.navItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn1];
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)handleLeft
{
    self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleRight
{
    self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 8;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"settingIdentifier"];
    CGRect bounds = CGRectInset(cell.bounds, 10, 0);
    if (cell == nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingIdentifier"];
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.imageView.image=[UIImage imageNamed:@"icon_rebind"];
                cell.textLabel.text=@"重新绑定";
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 1:
                cell.imageView.image=[UIImage imageNamed:@"about_info.png"];
                cell.textLabel.text=@"关于移动助手";
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 2:
                cell.imageView.image=[UIImage imageNamed:@"icon_gesture.png"];
                cell.textLabel.text=@"修改手势密码";
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 3:{
                cell.imageView.image=[UIImage imageNamed:@"icon_push.png"];
                cell.textLabel.text=@"接收推送通知";
                UISwitch* myswitch = [[ UISwitch alloc] initWithFrame:CGRectMake(200.0,10.0,0.0,0.0)];
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                if ([defaults valueForKey:@"switch"]) {
                    NSString *switchStatus=[defaults valueForKey:@"switch"];
                    if ([switchStatus isEqualToString:@"yes"]) {
                        [myswitch setOn:YES];
                    }else{
                        [myswitch setOn:NO];
                    }
                }else{
                    //默认为开
                    [myswitch setOn:YES];
                }

                [myswitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView=myswitch;
                break;
            }
        
            case 4:
                cell.imageView.image=[UIImage imageNamed:@"icon_update.png"];
                cell.textLabel.text=@"检查版本更新";
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 5:
                cell.imageView.image=[UIImage imageNamed:@"icon_headset.png"];
                cell.textLabel.text=@"首页设置";
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 6:
                cell.imageView.image=[UIImage imageNamed:@"icon_remove.png"];
                cell.textLabel.text=@"清理缓存";
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                break;
            
            case 7:
                cell.imageView.image=[UIImage imageNamed:@"icon_update.png"];
                cell.textLabel.text=@"地理位置";
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            default:
            break;
        }
        
    }else if(indexPath.section == 1){
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        [button setTitle:@"退出登录" forState:UIControlStateNormal];
        [button setFrame:cell.frame];
        button.layer.masksToBounds=YES;
        [button.layer setCornerRadius:5.f];
        [button addTarget:self action:@selector(backToLogin) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:bounds];
        [cell.contentView addSubview:button];
    }

    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        return 15;
    }else{
        return 40;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [view setFrame:CGRectMake(0, 0, 320, 15)];
    }else{
        [view setFrame:CGRectMake(0, 0, 320, 40)];
    }
    
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Contacts" bundle:nil];
            [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"rebindView"]
                               animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            NSString *info=[[NSString alloc] initWithFormat:@"版本号:%@",[defaults valueForKey:@"version"]];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"信息" message:info delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        if (indexPath.row == 2) {
            //修改手势密码
            YDLockViewController *lockViewController;
            
            if ([[UIScreen mainScreen] bounds].size.height == 568) {
                lockViewController=[[YDLockViewController alloc] initWithNibName:@"YDLockViewController"  bundle:[NSBundle mainBundle]];
            }else{
                lockViewController=[[YDLockViewController alloc] initWithNibName:@"YDLockViewController4" bundle:[NSBundle mainBundle]];
            }

            YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults setValue:@"1" forKey:@"updatePassword"];
            [defaults synchronize];
            delegate.window.rootViewController=lockViewController;
        }
        if (indexPath.row == 4) {
            //比较版本号
            
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            NSError *err;
            NSData *data;
            NSString *returnString;
            NSDictionary *dict=[YDSoapAndXmlParseUtil requestToWsdl:kUserLogin
                                                          loginCode:[defaults valueForKey:@"userName"]
                                                      loginPassword:[defaults valueForKey:@"password"]];
            if (dict) {
                err=[dict valueForKey:@"errorMsg"];
                data=[dict valueForKey:@"data"];
                if (err) {
                    NSLog(@"请求登陆失败！！！错误信息:%@",err);
                }
                
                returnString=[YDSoapAndXmlParseUtil responseXML:data methodName:@"userLogin"];
                NSMutableDictionary *loginDict =[YDSoapAndXmlParseUtil XmlToDictionary:returnString];
                NSString *version=[loginDict valueForKey:@"version"];
                self.currentVersion = version;
                NSString *oldVersion=[defaults valueForKey:@"version"];
                if (![version isEqualToString:oldVersion]) {
                    //版本号不一致，更新提示
                    //大小版本，大版本必须升级
                    //判断版本号第一个字符
                    if (![[oldVersion substringWithRange:NSMakeRange(0, 1)] isEqualToString:[version substringWithRange:NSMakeRange(0, 1)]]) {
                        //必须升级
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"必须更新" message:@"检测到新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                    //小版本，建议更新
                    }else{
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"建议更新" message:@"检测到新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    
                }else{
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"已经是最新版本" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }
        
        if (indexPath.row == 5) {
            //菜单首页设置
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            YDMenuSetController *menuSetController=[storyBoard instantiateViewControllerWithIdentifier:@"menuset"];
            [self presentViewController:menuSetController animated:YES completion:nil];
        }
        
        if (indexPath.row == 6) {
            //清理缓存
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
               
               NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
               NSLog(@"files :%d",[files count]);
               for (NSString *p in files) {
                   NSError *error;
                   NSString *path = [cachPath stringByAppendingPathComponent:p];
                   if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                       [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                   }
               }
                NSHTTPCookie *cookie;
                NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                for (cookie in [storage cookies])
                {
                    [storage deleteCookie:cookie];
                }
                [[NSURLCache sharedURLCache] removeAllCachedResponses];
               [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil
                                   waitUntilDone:YES];
            });
        }
        
        if (indexPath.row == 7) {
            //开启地理位置
            self.localManager=[[CLLocationManager alloc] init];
            _localManager.delegate=self;
            _localManager.desiredAccuracy=kCLLocationAccuracyBest;
            [_localManager startUpdatingLocation];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)clearCacheSuccess
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"清理成功" delegate:nil
                                       cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.section == 0) {
        if ([cell respondsToSelector:@selector(tintColor)]) {
            
            if (tableView == self.tableview) {
                
                CGFloat cornerRadius = 5.f;
                
                cell.backgroundColor = UIColor.clearColor;
                
                CAShapeLayer *layer = [[CAShapeLayer alloc] init];
                
                CGMutablePathRef pathRef = CGPathCreateMutable();
                
                CGRect bounds = CGRectInset(cell.bounds, 10, 0);
                
                BOOL addLine = NO;
                
                if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                    
                    CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
                    
                } else if (indexPath.row == 0) {
                    
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                    
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                    
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                    
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                    
                    addLine = YES;
                    
                } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                    
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                    
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                    
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                    
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
                    
                } else {
                    
                    CGPathAddRect(pathRef, nil, bounds);
                    
                    addLine = YES;
                    
                }
                
                layer.path = pathRef;
                
                CFRelease(pathRef);
                
                layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
                
                
                
                if (addLine == YES) {
                    
                    CALayer *lineLayer = [[CALayer alloc] init];
                    
                    CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                    
                    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                    
                    lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                    
                    [layer addSublayer:lineLayer];
                    
                }
                
                UIView *testView = [[UIView alloc] initWithFrame:bounds];
                
                [testView.layer insertSublayer:layer atIndex:0];
                
                testView.backgroundColor = UIColor.clearColor;
                
                cell.backgroundView = testView;
                
            }
            
        }
    }
    
}

-(void)switchValueChanged:(id)sender
{
    UISwitch *control=(UISwitch *)sender;
    BOOL switchStatus=control.on;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //开关打开
    if (!switchStatus) {
        [defaults setValue:@"no" forKey:@"switch"];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }else {
        [defaults setValue:@"yes" forKey:@"switch"];
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert
                                                                                | UIRemoteNotificationTypeBadge
                                                                                | UIRemoteNotificationTypeSound];
    }
    [defaults synchronize];
}

#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (buttonIndex == 0) {
        
        //更新版本号
        [defaults setValue:self.currentVersion forKey:@"version"];
        [defaults synchronize];
        
        //在线下载安装ipa
        NSURL *url=[NSURL URLWithString:@"itms-services://?action=download-manifest&url="
                    "https://git.oschina.net/zoomlgd/zoomlgd/raw/master/ynzy-sale.plist"];

        [[UIApplication sharedApplication] openURL:url];
        [self exitApplication];
    }
}

- (void)exitApplication {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"versionNotUpdate"];
    [defaults synchronize];
    
    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    
    [UIView beginAnimations:@"exitApplication" context:nil];
    
    [UIView setAnimationDuration:0.5];
    
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:delegate.window cache:NO];
    
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    
    delegate.window.bounds = CGRectMake(0, 0, 0, 0);
    
    [UIView commitAnimations];
    
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if ([animationID compare:@"exitApplication"] == 0) {
        
        exit(0);
        
    }
    
}


//退出登陆
- (void)backToLogin
{
    [YDTool cleanUserDefaults];
    
    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    YDLoginViewController *loginViewController=[[YDLoginViewController alloc] initWithNibName:@"YDLoginViewController"
                                                                                       bundle:[NSBundle mainBundle]];
    delegate.window.rootViewController=loginViewController;
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation=[locations lastObject];
    NSLog(@"纬度:%f",newLocation.coordinate.latitude);
    NSLog(@"经度:%f",newLocation.coordinate.longitude);
    [_localManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorType=(error.code == kCLErrorDenied)?@"Access Denied":@"Unknown Error";
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误信息" message:errorType delegate:nil
                                        cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
