//
//  YDLockViewController+DetectUpdate.m
//  YNOA
//
//  Created by 224 on 15/7/19.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDLockViewController+DetectUpdate.h"

@implementation YDLockViewController (DetectUpdate)

- (void)detectUpdate {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    //    //只能登陆一台手机
    if ([defaults valueForKey:@"userName"] && ![defaults valueForKey:@"updatePassword"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *dict=[YDSoapAndXmlParseUtil requestToWsdl:kUserLogin
                                                                 loginCode:[defaults valueForKey:@"userName"]
                                                             loginPassword:[defaults valueForKey:@"password"]];
            NSError *err;
            NSData *data;
            if (dict) {
                err=[dict valueForKey:@"errorMsg"];
                data=[dict valueForKey:@"data"];
                if (err) {
                    NSLog(@"请求绑定失败！！！错误信息:%@",err);
                    return;
                }
                NSString *returnString;
                returnString=[YDSoapAndXmlParseUtil responseXML:data methodName:@"userLogin"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *loginDict=[YDSoapAndXmlParseUtil XmlToDictionary:returnString];
                    if (![[loginDict objectForKey:@"returnValue"] isEqualToString:@"1"]) {
                        [YDTool cleanUserDefaults];
                        YDLoginViewController *loginController=[[YDLoginViewController alloc]   initWithNibName:@"YDLoginViewController" bundle:[NSBundle mainBundle]];
                        YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
                        delegate.window.rootViewController=loginController;
                    }else {
                        //判断版本升级
                        NSString *version=[loginDict valueForKey:@"version"];
                        self.currentVersion = version;
                        NSString *oldVersion=[defaults valueForKey:@"version"];
                        if (![version isEqualToString:oldVersion]) {
                            //版本号不一致，更新提示
                            //大小版本，大版本必须升级
                            //判断版本号第一个字符
                            if (![[oldVersion substringWithRange:NSMakeRange(0, 1)] isEqualToString:[version substringWithRange:NSMakeRange(0, 1)]]) {
                                //必须升级
                                //大版本更新
                                [defaults setInteger:1 forKey:@"updateVersions"];
                                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"必须" message:@"有版本更新，请升级版本"
                                                                             delegate:self cancelButtonTitle:@"确定"
                                                                    otherButtonTitles:@"取消", nil];
                                [alert show];
                                
                            }else{
                                //小版本，建议更新
                                //小版本更新
                                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"建议" message:@"有版本更新，请升级版本"
                                                                             delegate:self cancelButtonTitle:@"确定"
                                                                    otherButtonTitles:@"取消", nil];
                                [alert show];
                            }
                        }
                        
                    }
                    
                });
            }
        });
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (buttonIndex == 0) {
        //在线下载安装ipa
        
        //更新版本号
        [defaults setValue:self.currentVersion forKey:@"version"];
        [defaults synchronize];
        
        NSURL *url=[NSURL URLWithString:@"itms-services://?action=download-manifest&url="
                    "https://git.oschina.net/zoomlgd/zoomlgd/raw/master/ynzy-sale.plist"];
        
        [[UIApplication sharedApplication] openURL:url];
        [self exitApplication];
    }else{
        if ([defaults integerForKey:@"updateVersions"] == 1) {
            //退出程序
            [defaults removeObjectForKey:@"updateVersions"];
            [defaults synchronize];
            [self exitApplication];
        } else {
            [defaults setInteger:2 forKey:@"versionNotUpdate"];
            [defaults synchronize];
        }
        
    }
}

- (void)exitApplication {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"versionNotUpdate"];
    [defaults synchronize];
    
    YDAppDelegate *delegate=(YDAppDelegate *)[UIApplication sharedApplication].delegate;
    
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


@end
