//
//  YDMainViewController.m
//  YNOA
//
//  Created by 224 on 14-9-5.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDMainViewController.h"
#import "YDWebViewController.h"
#import "YDSettingViewController.h"
#import "YDCommonHead.h"
#import "YDMenuStore.h"
#import "YDSlipCell.h"
#import "YDMenu.h"


#define RStartTag 100

@interface YDMainViewController ()<YDSlipCellDelegate,UIWebViewDelegate,NSURLConnectionDataDelegate>

@property (strong ,nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) YDMenu *menu;
@property (copy, nonatomic) NSString *serverAddress;
@property (strong, nonatomic) UILabel *leftLabel;
@property (strong, nonatomic) NSMutableData *data;

@end

@implementation YDMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIImageView *imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
//    imageView.image=[UIImage imageNamed:@"welcome.png"];
//    [self.tableView setBackgroundView:imageView];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    self.serverAddress=[YDSoapAndXmlParseUtil serverHostFromLocal];
    
    //    iOS7上tableview的分割线左边短了一点，用这个方法来解决
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x3da8e5)];
    
    //导航栏左上角
    UIView *leftView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 135, 30)];
    UIButton *leftBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftBtn.contentMode = UIViewContentModeScaleAspectFit;
    [leftBtn setImage:[UIImage imageNamed:@"People.png"] forState:UIControlStateNormal];
    [leftView addSubview:leftBtn];

    self.leftLabel=[[UILabel alloc] init];
    self.leftLabel.textColor=[UIColor whiteColor];
    
    
    self.leftLabel.text=[defaults valueForKey:@"personName"];
    self.leftLabel.frame=CGRectMake(35, 0, 100, 30);
    [leftView addSubview:self.leftLabel];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftView];
//    [defaults addObserver:self forKeyPath:@"personName" options:NSKeyValueObservingOptionNew context:NULL];
    //通知中心，有的时候比KVO管用，实话
    NSNotificationCenter  *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"nameChanged" object:nil];
    [center addObserver:self selector:@selector(nameChanged:) name:@"nameChanged" object:nil];
    
    //导航栏右上角
    UIButton *rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImage *image=[UIImage imageNamed:@"ft_head_image.png"];
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn setImage:image forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [rightBtn addTarget:self action:@selector(handleContact) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    NSData *data=[defaults valueForKey:@"theSelectedMenu"];
 
    self.menu=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    [center removeObserver:self name:@"menuChanged" object:nil];
    [center addObserver:self selector:@selector(menuChanged:) name:@"menuChanged" object:nil];
}

- (void)handleContact
{
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Contacts" bundle:nil];
    [self.view.window.rootViewController presentViewController:[storyBoard instantiateInitialViewController]
                                                      animated:YES completion:nil];
}

- (void)handleSwipe
{
    [self.tableView setContentOffset:CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

//注册通知函数
- (void)nameChanged:(NSNotification*)notification
{
    id object=[notification object];
    self.leftLabel.text=object;
    //重新绑定过后，需重新请求菜单，每个人的权限不一样菜单不一样
    [self.HUD show:YES];
    [self busGetMenuList];
}

- (void)menuChanged:(NSNotification*)notification
{
    NSData *data=[notification object];
    self.menu=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:data forKey:@"theSelectedMenu"];
    [defaults synchronize];
    
    NSLog(@"菜单名称:%@",self.menu.menuName);
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 1) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 200;
            break;
            
        case 1:
            if (indexPath.row == 0) {
                return 20;
            }else{
                return [[UIScreen mainScreen] bounds].size.height - 200 - 20 - 5;
                
            }
            break;
            
        default:
            return 45;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 5;
    }else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        //滑动菜单
        YDSlipCell *menuCell=[tableView dequeueReusableCellWithIdentifier:@"SlipCell"];
        menuCell.cellDelegate=self;
        menuCell.backgroundColor=[UIColor clearColor];
        return menuCell;
    }else {
        UITableViewCell *webcell=[tableView dequeueReusableCellWithIdentifier:@"webcell"];
        webcell.backgroundColor = [UIColor clearColor];
        
        if (indexPath.row == 0) {
            webcell.imageView.image=[UIImage imageNamed:@"first_page_tzck_icon.png"];
            webcell.textLabel.font=[UIFont systemFontOfSize:15];
            if (self.menu) {
                webcell.textLabel.text=self.menu.menuName;
            }else{
                webcell.textLabel.text=@"通 知";
            }
            webcell.selectionStyle = UITableViewCellSelectionStyleNone;//不可点击
        }
        if (indexPath.row == 1) {
            //webview设置
            [webcell.contentView.subviews
             makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            UIWebView *webview=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, webcell.bounds.size.width, webcell.bounds.size.height-50)];
            webview.backgroundColor = [UIColor clearColor];
            [webview setOpaque:NO];
            [webcell.contentView addSubview:webview];
            //webview设置
            webview.delegate=self;
            webview.scalesPageToFit=YES;//自适应
            webview.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            
            //设置cookie和请求
            NSMutableDictionary *properties=[[NSMutableDictionary alloc] init];
            NSString *cookieValue=[[NSUserDefaults standardUserDefaults] valueForKey:@"personid"];
            [properties setValue:@"zoomlgd.user.personid" forKey:NSHTTPCookieName];
            [properties setValue:cookieValue forKey:NSHTTPCookieValue];
            [properties setValue:nil forKey:NSHTTPCookieExpires];
            [properties setValue:self.serverAddress forKey:NSHTTPCookieDomain];
            
            NSURL *url;
            
            if (self.menu) {
                [properties setValue:self.menu.url forKey:NSHTTPCookiePath];
                url=[NSURL URLWithString:[self.serverAddress stringByAppendingPathComponent:self.menu.url]];
            }else{
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                [properties setValue:[defaults valueForKey:@"defaultMainURL"] forKey:NSHTTPCookiePath];
                url=[NSURL URLWithString:[self.serverAddress stringByAppendingPathComponent:[defaults valueForKey:@"defaultMainURL"]]];
            }
            
            
            NSHTTPCookie *cookie=[[NSHTTPCookie alloc] initWithProperties:properties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url
                                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                             timeoutInterval:20.0];
            //设置cookie
            NSDictionary *headers=[NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObjects:cookie, nil]];
            [request setValue:[headers valueForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
            [webview loadRequest:request];
        }
        
        return webcell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Web View Delegate Mehthods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.HUD=[[MBProgressHUD alloc] initWithView:webView];
    [webView addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=NO;
    
    self.HUD.labelText=@"请稍等";
    
    //显示对花框
    [self.HUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.HUD hide:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    //webview于js交互设置cookie
    NSString *cookieString=[[NSString alloc] initWithFormat:@"document.cookie='zoomlgd.user.personid=%@'",[[NSUserDefaults standardUserDefaults] valueForKey:@"personid"]];
    [webView stringByEvaluatingJavaScriptFromString:cookieString];
    //点击页面中的链接
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        YDWebViewController *webview=[storyBoard instantiateViewControllerWithIdentifier:@"webview"];
        webview.requestURL=[request URL];
        [self.navigationController pushViewController:webview animated:YES];
        
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.HUD hide:YES];
}

#pragma mark - YDSlipCell Delegate Method
- (void)productCell:(YDSlipCell *)cell actionWithFlag:(NSInteger)flag
{
//    NSLog(@"url=%@",cell.selectedURL); 
    if ([cell.selectedURL isEqualToString:@"Anaylse"]) {
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Brand" bundle:nil];
        CATransition *animation = [CATransition animation];
        [animation setDuration:1.5];
        [animation setType:kCATransitionFade]; //淡入淡出
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [self presentViewController:[storyBoard instantiateInitialViewController] animated:NO completion:nil];
        [self.view.layer addAnimation:animation forKey:nil];
    }else if(cell.selectedURL == nil){
        //进入设置界面
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Contacts" bundle:nil];
        YDSettingViewController *settingController=[storyBoard instantiateViewControllerWithIdentifier:@"settingView"];
        [self.view.window.rootViewController presentViewController:settingController animated:YES completion:nil];
    }else{
        //显示webview
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        YDWebViewController *webview=[storyBoard instantiateViewControllerWithIdentifier:@"webview"];
        webview.webURL=cell.selectedURL;
        [self.navigationController pushViewController:webview animated:YES];
    }
    
}

#pragma mark- network delegate

- (void)busGetMenuList
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    YDAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    NSString *serverHost=[YDSoapAndXmlParseUtil serverHostFromLocal];
    NSString *soapMessage;
    NSString *channelid;
    NSString *userid;
    if ([defaults valueForKey:@"channelid"]) {
        channelid=[defaults valueForKey:@"channelid"];
        userid=[defaults valueForKey:@"userid"];
    }else{
        channelid=delegate.channelid;
        userid=delegate.userid;
    }
    
    soapMessage=[NSString stringWithFormat:
                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\">"
                 "<soap:Header>\n"
                 "<ns1:authenticationtoken ns1:userId='%@' ns1:clientId='%@'>"//设置首部验证
                 "</ns1:authenticationtoken>"
                 "</soap:Header>\n"
                 "<soap:Body>\n"
                 "<ns1:busGetMenuList>"
                 "<ns1:personCode>%@</ns1:personCode>"
                 "</ns1:busGetMenuList>"
                 "</soap:Body>\n"
                 "</soap:Envelope>",serverHost,channelid,[defaults valueForKey:@"personid"],
                 [defaults valueForKey:@"personid"]];
    
    NSString *address=[serverHost stringByAppendingPathComponent:@"services/authorization?wsdl"];
    NSString *soapAction=[serverHost stringByAppendingPathComponent:@"services/authorization"];
    NSURL *url=[NSURL URLWithString:address];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
    //设置首部
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *msgLength=[NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //如果连接已经建立，初始化data
    if (connection) {
        self.data=[NSMutableData data];
    }else{
        NSLog(@"theConnection is NULL");
    }

    
}


#pragma mark - conection data delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *returnString=[YDSoapAndXmlParseUtil responseXML:self.data methodName:@"busGetMenuList"];
    
    //第一次请求菜单
    YDMenuStore *sharedStore=[YDMenuStore sharedStore];
    [sharedStore saveImagesToSQLite:returnString];

    [self performSelectorOnMainThread:@selector(tableReload) withObject:nil waitUntilDone:NO];
    [self.HUD hide:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.HUD hide:YES];
}

- (void)tableReload
{
    [self.tableView reloadData];
}


@end
