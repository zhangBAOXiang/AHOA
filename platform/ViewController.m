//
//  ViewController.m
//  platform
//
//  Created by apple on 13-9-3.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *userPasswd;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

- (IBAction)onLogin:(id)sender;


@end

@implementation ViewController

@synthesize serverHost;
@synthesize serverAddress;


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //读取本地conf.plist文件
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[commonUtil dictionaryFromSystemPListFile:@"conf"]];
    [self setServerHost:[dict objectForKey:@"serverHost"]];
    [self setServerAddress:[dict objectForKey:@"serverAddress"]];
    NSLog(@"%@",self.serverHost);

    [self drawLoginButtons];
}

- (void)drawLoginButtons
{
    //声明输入框
    self.userName = [[UITextField alloc]initWithFrame:CGRectMake(618, 296, 173, 30)];
    [self.userName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.userName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.userName setReturnKeyType:UIReturnKeyNext];
    self.userPasswd = [[UITextField alloc]initWithFrame:CGRectMake(618, 342, 173, 30)];
    [self.userPasswd setSecureTextEntry:YES];
    [self.userPasswd setReturnKeyType:UIReturnKeyDone];
    
    SEL loginHandler = @selector(onLogin:);

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(618, 393, 75, 27)];
    [btn setTag:10001];//设置tag值，方便以后找到这个按钮
    [btn addTarget:self action:loginHandler forControlEvents:UIControlEventTouchUpInside];
    int w=32, h=32;
    CGRect frame = [btn frame];
    _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((frame.size.width-w)/2, (frame.size.height-h)/2, w, h)];
    [_indicator setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [btn addSubview:_indicator];
    
    
    [self.view addSubview:self.userName];
    [self.view addSubview:self.userPasswd];
    [self.view addSubview:btn];
    
    self.userName.delegate = self;
    self.userPasswd.delegate = self;
    
    [self.userName becomeFirstResponder];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogin:(id)sender
{
//    //测试本地存储
//    if (1==1) {
//        NSLog(@"测试本地存储");
//        
//        //展现主体view
//        LocalViewController *lvc = [[LocalViewController alloc]initWithNibName:@"LocalViewController" bundle:nil];
//        [self presentViewController:lvc animated:YES completion:nil];
//        
//        return;
//    }
    
    
    NSString *strUserName = _userName.text;
    NSString *strUserPasswd = (_userPasswd.text==nil)?@"":_userPasswd.text;
    NSString *md5Pwd = [MyMD5 md5:strUserPasswd];
    
    
    if ([strUserName isEqualToString:@""]) 
    {
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入登录用户名！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alter show];
        [self.userName becomeFirstResponder];
    }
    else if ([strUserPasswd isEqualToString:@""])
    {
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入登录密码！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alter show];
        [self.userPasswd becomeFirstResponder];
    }
    else
    {
        Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSString *userConfPath = [[commonUtil docPath] stringByAppendingPathComponent:@"/Library/conf.plist"];
        //如果当前无网络连接
        if ([r currentReachabilityStatus] == NotReachable)
        {
            //本地查看
            if ((BOOL)[defaults objectForKey:@"userName"] && (BOOL)[defaults objectForKey:@"userPasswd"]) {
                if ([strUserName isEqualToString:[defaults objectForKey:@"userName"]] && [md5Pwd isEqualToString:[defaults objectForKey:@"userPasswd"]]) {
                    /*UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示信息" message:@"无法连接到网络，本地查看？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alertView show];*/
                    
                    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                    delegate.gLoginName = strUserName;
                    delegate.gServerHost = [self serverHost];
                    delegate.gServerAddress = [self serverAddress];
                    delegate.gPersonId = [defaults objectForKey:@"personId"];
                    
                    MainViewController *mvc = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
                    [self presentViewController:mvc animated:YES completion:nil];
                } else {
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示信息" message:@"用户名或密码错误！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                
                    NSLog(@"与本地用户名或密码不一致！");
                }
            } else {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示信息" message:@"无法连接到网络！首次登录需要联网。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        else
        {
            __weak ViewController *weakself = self;
            [self showActivityIndicator];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *soapMessage = [NSString stringWithFormat:
                                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                         "<soap:Body>\n"
                                         "<ns1:mobilePersonLogin xmlns:ns1=\"%@\">"
                                         "<arg0>%@</arg0>"
                                         "<arg1>%@</arg1>"
                                         "</ns1:mobilePersonLogin>"
                                         "</soap:Body>\n"
                                         "</soap:Envelope>",serverHost, strUserName,md5Pwd];
                
                //NSLog(@"调用webserivce的字符串是:%@",soapMessage);
                NSMutableDictionary *theDict = [commonUtil soapCall:serverHost postMethod:@"" postData:soapMessage];
                
                NSError *err = [theDict objectForKey:@"err"];
                NSData *data = [theDict objectForKey:@"data"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isNull = false;
                    NSMutableArray *arr = [NSMutableArray array];
                    if (err || !data || (BOOL)[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]) {
                        isNull = true;
                    } else {
                        NSString *returnSoapXML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        
                        NSString *methodName = @"mobilePersonLogin";
                        NSString *result = [SoapXmlParseHelper SoapMessageResultXml:returnSoapXML ServiceMethodName:methodName];
                        
                        NSLog(@"*************%@************",result);
                        
                        arr = [SoapXmlParseHelper XmlToArray:result];
                        
//                        NSLog(@"*************%@************",arr);
                        
                        if ([arr count]<=0) {
                            isNull = true;
                        }

                    }
                    if (isNull) {
                        if ((BOOL)[defaults objectForKey:@"userName"] && (BOOL)[defaults objectForKey:@"userPasswd"]) {
                            if ([strUserName isEqualToString:[defaults objectForKey:@"userName"]] && [md5Pwd isEqualToString:[defaults objectForKey:@"userPasswd"]]) {
                                /*UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无法连接到目的服务器，本地查看？" delegate:weakself cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
                                [alert show];*/
                    
                                AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                                delegate.gLoginName = strUserName;
                                delegate.gServerHost = [self serverHost];
                                delegate.gServerAddress = [self serverAddress];
                                delegate.gPersonId = [defaults objectForKey:@"personId"];
                                
                                MainViewController *mvc = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
                                [weakself presentViewController:mvc animated:YES completion:nil];
                                
                            } else {
                                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示信息" message:@"用户名或密码错误！" delegate:weakself cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                [alertView show];
                                
                                NSLog(@"与本地用户名或密码不一致！");
                            }
                        } else {
                            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示信息" message:@"(首次登录)无法连接到目的服务器！" delegate:weakself cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alertView show];
                        }
                    }
                    else
                    {//登录成功
                        NSDictionary *dict = [arr objectAtIndex:0];
                        NSString *isSuccess = [dict objectForKey:@"issuccess"];
                        
                        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                        delegate.gLoginMessage = [dict objectForKey:@"message"];
                        delegate.gLoginName = strUserName;
                        
                        if ([isSuccess isEqualToString:@"true"])
                        {
                            
                            [weakself.userPasswd setText:@""];
                            
                            delegate.bLogin = YES;
                            delegate.gSessionId = [dict objectForKey:@"sessionid"];
                            delegate.gPersonName = [dict objectForKey:@"personname"];
                            delegate.gPersonId = [dict objectForKey:@"personid"];
                            delegate.gServerHost = [weakself serverHost];
                            delegate.gServerAddress = [weakself serverAddress];
                            
                            NSLog(@"%@:::::::%@",delegate.gSessionId, delegate.gPersonName);
                            
                            //展现主体view
                            MainViewController *mvc = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
                            [weakself presentViewController:mvc animated:YES completion:nil];
                            [defaults setObject:strUserName forKey:@"userName"];
                            [defaults setObject:md5Pwd forKey:@"userPasswd"];
                            [defaults setObject:delegate.gPersonId forKey:@"personId"];
                            [defaults synchronize];
                        }
                        else
                        {
                            delegate.bLogin = NO;
                            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示信息" message:@"用户名或密码错误！" delegate:weakself cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alertView show];
                            
                            NSLog(@"用户名或密码错误！");
                        }
                    }
                    [self hideActivityIndicator];
                });
            });

        }
    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    } else if(buttonIndex == 1) {
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.userName isFirstResponder]) {
        [self.userPasswd becomeFirstResponder];
    }
    else if ([self.userPasswd isFirstResponder]) {
        [self onLogin:nil];
    }
    return YES;
}

- (void)hideKeyBoard
{
    [self.userName resignFirstResponder];
    [self.userPasswd resignFirstResponder];
}

- (void)showActivityIndicator
{
    [(UIButton*)[self.view viewWithTag:10001] setEnabled:NO];
    [(UIButton*)[self.view viewWithTag:10001] setBackgroundColor:[UIColor blackColor]];
    [(UIButton*)[self.view viewWithTag:10001] setAlpha:0.4];
    [_indicator startAnimating];
}

- (void)hideActivityIndicator
{
    [_indicator stopAnimating];
    [(UIButton*)[self.view viewWithTag:10001] setBackgroundColor:[UIColor clearColor]];
    [(UIButton*)[self.view viewWithTag:10001] setEnabled:YES];
}



@end
