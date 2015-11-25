//
//  YDOperation.h
//  YNOA
//
//  Created by 224 on 14-11-3.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YDSOAPDelegate <NSObject>

@optional
- (void)passSoapArray:(NSMutableArray *)soapArray forCode:(NSString *)code;
- (void)passSoapArray:(NSMutableArray *)soapArray showType:(NSString *)showType;

@end

@interface YDOperation : NSObject<NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSMutableData *webData;
@property (copy,nonatomic) NSString *currentCode;
@property (copy, nonatomic) NSString *showType;
@property (weak, nonatomic) id<YDSOAPDelegate> soapDelegate;

- (void)getSaleAnaylseSOAP:(NSString *)code tobaRange:(NSString *)range showType:(NSString *)type;

- (void)getProSaleStockWithType:(NSString *)type;

@end
