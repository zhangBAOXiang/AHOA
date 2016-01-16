//
//  YDRebindViewController.m
//  HNOA
//
//  Created by 224 on 14-8-8.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDRebindViewController.h"
#import "YDMainViewController.h"
#import "YDSoapAndXmlParseUtil.h"
#import "YDAppDelegate.h"

static dispatch_queue_t queue;
static NSTimer *timer;

@interface YDRebindViewController () <UITextFieldDelegate>

@property (copy, nonatomic) NSString *returnString;

@end

@implementation YDRebindViewController

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
    
    [self.navbar setBarTintColor: UIColorFromRGB(0x3DA8E5)];
    
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navbarItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 63)];
    imageview.image=[UIImage imageNamed:@"head_set.png"];
    self.navbarItem.titleView=imageview;
    
    UIButton *btn1=[[UIButton alloc] init];
    [btn1 setImage:[UIImage imageNamed:@"firstpage.png"] forState:UIControlStateNormal];
    btn1.contentMode=UIViewContentModeCenter;
    [btn1 setFrame:CGRectMake(0, 0, 50, 63)];
    [btn1 addTarget:self action:@selector(handleRight) forControlEvents:UIControlEventTouchUpInside];
    self.navbarItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn1];

    
    self.username.delegate=self;
    self.password.delegate=self;
    self.username.layer.masksToBounds=YES;
    [self.username.layer setCornerRadius:5.f];
    self.password.layer.masksToBounds=YES;
    [self.password.layer setCornerRadius:5.f];
    
    self.btn.layer.masksToBounds=YES;
    [self.btn.layer setCornerRadius:5.f];
}

- (void)handleLeft
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleRight
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)cleanUserDefaults
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:[defaults valueForKey:@"userName"] forKey:@"oldUser"];
    [defaults removeObjectForKey:@"userName"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"version"];
    [defaults removeObjectForKey:@"personid"];
    [defaults removeObjectForKey:@"personnames"];
    [defaults removeObjectForKey:@"channelid"];
    [defaults removeObjectForKey:@"userid"];
    [defaults removeObjectForKey:@"personName"];
    [defaults removeObjectForKey:@"busPersoninfo"];
    [defaults removeObjectForKey:@"responseString"];
    [defaults removeObjectForKey:@"menuString"];
    [defaults synchronize];
    
}

- (IBAction)rebind:(id)sender {
    if ([self.username.text isEqualToString:@""] || self.username.text==nil) {
        [self.username becomeFirstResponder];
    }
    else if ([self.password.text isEqualToString:@""] || self.password.text==nil) {
        [self.password becomeFirstResponder];
    }else{
        [self.password resignFirstResponder];
        self.btn.enabled=NO;
        self.btn.alpha=0.5f;
        [self.indicator startAnimating];
        
        [self cleanUserDefaults];
        
        
        Reachability *r=[Reachability reachabilityWithHostName:@"www.baidu.com"];
        if ([r currentReachabilityStatus]==NotReachable) {
            //网络连接不可用
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"消息" message:@"对不起，您当前无网络连接，请先连接网络!!"
                                                         delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self stopRequestAndAnimate];
        }
        else{
            //存在网络连接，开始绑定
            __block NSError *err=nil;
            __block NSData *data;
            __block NSMutableDictionary *dict;
            
            timer=[NSTimer scheduledTimerWithTimeInterval:15 target:self
                                                 selector:@selector(handleTimer) userInfo:nil repeats:NO];
            
            queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                dict=[YDSoapAndXmlParseUtil requestToWsdl:kUserBind
                                                loginCode:self.username.text
                                            loginPassword:[MyMD5 md5:self.password.text]];
                
                if (dict) {
                    err=[dict valueForKey:@"errorMsg"];
                    data=[dict valueForKey:@"data"];
                    if (err) {
                        NSLog(@"请求绑定失败！！！错误信息:%@",err);
                        return;
                    }
                    self.returnString=[YDSoapAndXmlParseUtil responseXML:data methodName:@"userBind"];
                    
                    NSMutableDictionary *bindDict=[YDSoapAndXmlParseUtil XmlToDictionary:self.returnString];
                    if (![[bindDict objectForKey:@"returnValue"] isEqualToString:@"1"]) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self stopRequestAndAnimate];
                            [timer invalidate];//关闭定时器
                            queue=nil;
                            
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"登陆信息"
                                                                          message:@"对不起，您的用户名或密码错误，绑定失败!"
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                            [alert show];
                        });                        
                        
                    }
                    else{
                        
                        //绑定成功,保存登陆信息
                        dict=[YDSoapAndXmlParseUtil requestToWsdl:kUserLogin loginCode:self.username.text
                                                    loginPassword:[MyMD5 md5:self.password.text]];
                        if (dict) {
                            err=[dict valueForKey:@"errorMsg"];
                            data=[dict valueForKey:@"data"];
                            if (err) {
                                NSLog(@"请求登陆失败！！！错误信息:%@",err);
                                return;
                            }
                            self.returnString=[YDSoapAndXmlParseUtil responseXML:data methodName:@"userLogin"];
                            NSMutableDictionary *loginDict =[YDSoapAndXmlParseUtil XmlToDictionary:self.returnString];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"绑定信息"
                                                                              message:@"绑定成功!"
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                                [alert show];
                                
                                //登陆成功，设置手势密码，保存信息
                                YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
                                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                                
                                [defaults setValue:self.username.text forKey:@"userName"];
                                [defaults setValue:[MyMD5 md5:self.password.text] forKey:@"password"];
                                [defaults setValue:delegate.channelid forKey:@"channelid"];
                                [defaults setValue:delegate.userid forKey:@"userid"];
                                [defaults setValue:[loginDict valueForKey:@"personid"] forKey:@"personid"];
                                [defaults setValue:[loginDict valueForKey:@"personname"] forKey:@"personName"];
                                
                                
                                if ([defaults integerForKey:@"versionNotUpdate"]) {
                                    //小版本不升级的不更改版本号
                                } else {
                                    [defaults setValue:[loginDict valueForKey:@"version"] forKey:@"version"];
                                }

                                
                                
                                [defaults synchronize];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"nameChanged"
                                                                                    object:[defaults valueForKey:@"personName"]];
                                
                                [self stopRequestAndAnimate];
                                
                                [timer invalidate];//关闭定时器
                                self.password.text=@"";
                                self.username.text=@"";
                                queue=nil;
                                
                                [self dismissViewControllerAnimated:YES completion:nil];
                            });
                        }
                    }
                }
            });
            
        }

    }

}

- (void)handleTimer
{
    if (queue != nil) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"网络信息"
                                                      message:@"连接超时!"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        
        [self.username becomeFirstResponder];
        
        queue=nil;
        [self stopRequestAndAnimate];
    }
    
    
}

- (void)stopRequestAndAnimate
{
    self.btn.enabled=YES;
    self.btn.alpha=1.0f;
    [self.password resignFirstResponder];
    [self.indicator stopAnimating];
}

#pragma mark - TextField Delegate Method
//处理键盘响应
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL returnValue=NO;
    if (textField==self.username) {
        [self.password becomeFirstResponder];
        self.password.placeholder=@"";
        returnValue=NO;
    }else{
        [self.password resignFirstResponder];
    }
    //返回值为NO，即 忽略 按下此键；若返回为YES则 认为 用户按下了此键，并去调用TextFieldDoneEditint方法，在此方法中，你可以继续 写下 你想做的事
    return returnValue;
}

@end
