//
//  YDWebViewController.h
//  YNOA
//
//  Created by 224 on 14-9-11.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (copy, nonatomic) NSString *webURL;
@property (strong, nonatomic) NSURL *requestURL;//tableviewcell中webview的链接

@end
