//
//  YDOfiiceController.m
//  YNOA
//
//  Created by 224 on 15/4/10.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDOfiiceController.h"
#import "NSString+urlExtension.h"

@interface YDOfiiceController ()


@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation YDOfiiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
//    self.webview.opaque = NO;
    self.webview.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.webview.backgroundColor = [UIColor clearColor];
    
    switch (self.mimeType) {
        case MIMEOFDOC:
            [self.webview loadData:self.data MIMEType:@"application/msword"
                    textEncodingName:@"UTF-8" baseURL:nil];
            self.webview.scalesPageToFit = YES;
            break;
        case MIMEOFDOCX:
            [self.webview loadData:self.data MIMEType:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                    textEncodingName:@"UTF-8" baseURL:nil];
            self.webview.scalesPageToFit = YES;
            break;
        case MIMEOFXLSX:
            [self.webview loadData:self.data MIMEType:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    textEncodingName:@"UTF-8" baseURL:nil];
            self.webview.scalesPageToFit = NO;
            break;
        case MIMEOFXLS:
            [self.webview loadData:self.data MIMEType:@"application/vnd.ms-excel"
                    textEncodingName:@"UTF-8" baseURL:nil];
            self.webview.scalesPageToFit = NO;
            break;
        case MIMEOFRAR:
            [self.webview loadData:self.data MIMEType:@"application/octet-stream" textEncodingName:@"UTF-8" baseURL:nil];
            break;
        default:
            break;
    }

}

//禁止横屏
- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
