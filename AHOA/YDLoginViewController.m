//
//  YDViewController.m
//  hnOA
//
//  Created by 224 on 14-6-24.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDLoginViewController.h"
#import "YDLoginViewController+Contacts.h"

static dispatch_queue_t queue;
static NSTimer *timer;

@interface YDLoginViewController ()

@end

@implementation YDLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.usernameField.delegate=self;
    self.passwordField.delegate=self;
    self.usernameField.layer.masksToBounds=YES;
    [self.usernameField.layer setCornerRadius:5.f];
    self.passwordField.layer.masksToBounds=YES;
    [self.passwordField.layer setCornerRadius:5.f];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyBoard)];
    gesture.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:gesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userLogin:(id)sender {
    
    self.username=self.usernameField.text;
    self.password=[MyMD5 md5:self.passwordField.text];
    
    if ([self.usernameField isFirstResponder]) {
        self.usernameField.placeholder=@"";
    }
    
    if ([self.username isEqualToString:@""] || self.username==nil) {
        self.usernameField.placeholder=@"用户名不能为空";
        [self.usernameField becomeFirstResponder];
    }
    else if ([self.passwordField.text isEqualToString:@""] || self.password==nil) {
        self.passwordField.placeholder=@"密码不能为空";
        [self.passwordField becomeFirstResponder];
    }
    else{
        self.usernameField.placeholder=@"";
        self.loginButton.enabled=NO;
        self.loginButton.alpha=0.5f;
        [self.spinner startAnimating];
        
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
            
            timer=[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(handleTimer) userInfo:nil repeats:NO];
            
            queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                dict=[YDSoapAndXmlParseUtil requestToWsdl:kUserBind
                                                loginCode:self.username
                                            loginPassword:self.password];
                
            
                if (dict) {
//                    err=[dict valueForKey:@"errorMsg"];
                    data=[dict valueForKey:@"data"];
//                    if (err) {
//                        NSLog(@"请求绑定失败！！！错误信息:%@",err);
//                        return;
//                    }
                    self.returnString=[YDSoapAndXmlParseUtil responseXML:data methodName:@"userBind"];
                    NSLog(@"dict=%@",self.returnString);
                
                    NSMutableDictionary *bindDict=[YDSoapAndXmlParseUtil XmlToDictionary:self.returnString];
                    
                    if (![[bindDict objectForKey:@"returnValue"] isEqualToString:@"1"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self stopRequestAndAnimate];
                            [timer invalidate];//关闭定时器
                            queue=nil;
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示"
                                                                          message:@"用户名或密码错误或请检查您的网络"
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                            [alert show];
                        });
                    
                    }
                    else{
                        //绑定成功,登陆信息
                        dict=[YDSoapAndXmlParseUtil requestToWsdl:kUserLogin loginCode:self.username loginPassword:self.password];
                        
                        if (dict) {
                            err=[dict valueForKey:@"errorMsg"];
                            data=[dict valueForKey:@"data"];
                            if (err) {
                                NSLog(@"请求登陆失败！！！错误信息:%@",err);
                                return;
                            }
                            
                            self.returnString=[YDSoapAndXmlParseUtil responseXML:data methodName:@"userLogin"];
                            NSDictionary *loginDict =[YDSoapAndXmlParseUtil XmlToDictionary:self.returnString];
                            
                            //登陆成功，创建数据库
                            [YDSqliteUtil initializeDatabase];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                
                                //登陆成功，设置手势密码，保存信息
                                YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
                                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                                
                                
                                //读取用户配置信息
                                NSString *oldUser = [defaults valueForKey:@"oldUser"];
                                if ([self.username isEqualToString:oldUser]) {
                                   //相同用户，保存配置不变
                                }else {
                                    //不是相同用户，删除配置信息
                                    [defaults removeObjectForKey:@"selectIndex"];
                                    [defaults removeObjectForKey:@"theSelectedMenu"];
                                    [defaults synchronize];
                                }
                                
                                [defaults setValue:self.username forKey:@"userName"];
                                [defaults setValue:self.password forKey:@"password"];
//                                [defaults setValue:delegate.channelid forKey:@"channelid"];
//                                [defaults setValue:delegate.userid forKey:@"userid"];
                                [defaults setValue:[loginDict valueForKey:@"personid"] forKey:@"personid"];
                                [defaults setValue:[loginDict valueForKey:@"personname"] forKey:@"personName"];
                                
                                
                                
                                if ([defaults integerForKey:@"versionNotUpdate"]) {
                                    //小版本不升级的不更改版本号
                                } else {
                                    [defaults setValue:[loginDict valueForKey:@"version"] forKey:@"version"];
                                }
                                
                                [defaults synchronize];
                                
                                
                               
                                [self busPersonInfo];
                                [NSThread sleepForTimeInterval:1];
                                
                                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LockAndLogin" bundle:nil];
                                
                                YDLockViewController *lockViewController = [storyBoard instantiateViewControllerWithIdentifier:@"YDLockViewController"];
                                lockViewController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
                                delegate.window.rootViewController=lockViewController;
                                
                                [self stopRequestAndAnimate];
                                self.usernameField.text=@"";
                                self.passwordField.text=@"";
                                queue=nil;
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
        [self stopRequestAndAnimate];
        
        queue=nil;
    }
    
    
}

- (void)stopRequestAndAnimate
{
    self.loginButton.enabled=YES;
    self.loginButton.alpha=1.0f;
    [self.spinner stopAnimating];
}

- (void)hidenKeyBoard{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - TextField Delegate Method
//处理键盘响应
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL returnValue=NO;
    if (textField==self.usernameField) {
        [self.passwordField becomeFirstResponder];
        self.passwordField.placeholder=@"";
        returnValue=NO;
    }else{
        [self.passwordField resignFirstResponder];
    }
    //返回值为NO，即 忽略 按下此键；若返回为YES则 认为 用户按下了此键，并去调用TextFieldDoneEditint方法，在此方法中，你可以继续 写下 你想做的事
    return returnValue;
}



@end
