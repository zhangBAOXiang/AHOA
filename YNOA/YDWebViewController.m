//
//  YDWebViewController.m
//  YNOA
//
//  Created by 224 on 14-9-11.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDWebViewController.h"
#import "YDSoapAndXmlParseUtil.h"
#import "NSString+urlExtension.h"
#import "YDOfiiceController.h"

@interface YDWebViewController ()<UIWebViewDelegate>

@property (strong ,nonatomic) MBProgressHUD *HUD;
@property (copy, nonatomic) NSString *serverAddress;
@property (strong, nonatomic) NSURLSession *session;
//@property (strong, nonatomic) YDOfiiceController *office;

@end

@implementation YDWebViewController

//禁止横屏
- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *btn1=[[UIButton alloc] init];
    [btn1 setImage:[UIImage imageNamed:@"firstpage.png"] forState:UIControlStateNormal];
    btn1.contentMode=UIViewContentModeCenter;
    [btn1 setFrame:CGRectMake(0, 0, 50, 63)];
    [btn1 addTarget:self action:@selector(handleRight) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn1];

    
    /////////////////////////////////////////////////////////////////////////////////////////
    //webview设置
    
    self.serverAddress=[YDSoapAndXmlParseUtil serverHostFromLocal];
    
    self.webview.delegate=self;
    self.webview.scalesPageToFit=YES;//自适应
    [self.webview setOpaque:NO];
    self.webview.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.webview.backgroundColor=[UIColor clearColor];
    //禁止横向滚动
//    [(UIScrollView *)[[self.webview subviews] objectAtIndex:0] setBounces:NO];
    
    //设置cookie和请求
    NSMutableDictionary *properties=[[NSMutableDictionary alloc] init];
    NSString *cookieValue=[[NSUserDefaults standardUserDefaults] valueForKey:@"personid"];
    [properties setValue:@"zoomlgd.user.personid" forKey:NSHTTPCookieName];
    [properties setValue:cookieValue forKey:NSHTTPCookieValue];
    [properties setValue:nil forKey:NSHTTPCookieExpires];
    [properties setValue:self.serverAddress forKey:NSHTTPCookieDomain];
    
    [properties setValue:self.webURL forKey:NSHTTPCookiePath];
    
    NSHTTPCookie *cookie=[[NSHTTPCookie alloc] initWithProperties:properties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    NSURL *url;
    if (self.webURL) {
        url=[NSURL URLWithString:[self.serverAddress stringByAppendingPathComponent:self.webURL]];
    }else{
        url=self.requestURL;
    }
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:20.0];
    //设置cookie
    NSDictionary *headers=[NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObjects:cookie, nil]];
    [request setValue:[headers valueForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    [self.webview loadRequest:request];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)handleLeft
{
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleRight
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Web View Delegate Mehthods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.HUD=[[MBProgressHUD alloc] initWithView:self.webview];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=YES;
    
    self.HUD.labelText=@"请稍等";
    
    //显示对花框
    [self.HUD show:YES];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.HUD hide:YES];
    self.navigationItem.title=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    //webview于js交互设置cookie
    NSLog(@"url=%@",[request URL]);
    
    //下载文件 doc...等等

    NSString *requestURLString = [[request URL] absoluteString];
    if ([requestURLString isFileURLString]) {
        self.session = [NSURLSession sharedSession];
        [self.HUD show:YES];
        __weak YDWebViewController *weakSelf = self;
        NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request
                                                        completionHandler:
                                          ^(NSURL *location, NSURLResponse *response, NSError *error) {
                                              NSData *data = [NSData dataWithContentsOfURL:location];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [self.HUD hide:YES];
                                                  UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main"
                                                                                                       bundle:nil];
                                                  YDOfiiceController *office = [storyBoard instantiateViewControllerWithIdentifier:@"officeboard"];
                                                  office.mimeType = [requestURLString suffix];
                                                  office.data = data;
                                                  
                                                  [weakSelf.navigationController pushViewController:office animated:NO];
                                                  
                                              });
                                              
                                          }];
        [task resume];
        
        return NO;

    } else {
        NSString *cookieString=[[NSString alloc] initWithFormat:@"document.cookie='zoomlgd.user.personid=%@'",[[NSUserDefaults standardUserDefaults] valueForKey:@"personid"]];
        [webView stringByEvaluatingJavaScriptFromString:cookieString];
        return YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.HUD hide:YES];
    NSLog(@"%@",error);
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"对不起，服务器连接失败，请重新尝试" delegate:nil
                                        cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
