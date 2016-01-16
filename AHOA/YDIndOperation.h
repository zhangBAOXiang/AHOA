//
//  YDIndOperation.h
//  AHOA
//
//  Created by 224 on 15/11/15.
//  Copyright © 2015年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YDIndDelegate <NSObject>

@optional
- (void)passSoapArray:(NSMutableArray *)soapArray forCode:(NSString *)code;

@end

@interface YDIndOperation : NSObject<NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSMutableData *webData;
@property (copy, nonatomic) NSString *showType;
@property (weak, nonatomic) id<YDIndDelegate> indDelegate;

- (void)getIndSaleAnaylseSOAP:(NSString *)code tobaRange:(NSString *)range showType:(NSString *)type;

@end
