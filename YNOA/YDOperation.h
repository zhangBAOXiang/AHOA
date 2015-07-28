//
//  YDOperation.h
//  YNOA
//
//  Created by 224 on 14-11-3.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YDSOAPDelegate <NSObject>

- (void)passSoapArray:(NSMutableArray *)soapArray forCode:(NSString *)code;

@end

@interface YDOperation : NSObject<NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSMutableData *webData;
@property (strong, nonatomic) NSString *soapResults;
@property (assign, nonatomic) BOOL recordResults;
@property (copy,nonatomic) NSString *currentCode;
@property (weak, nonatomic) id<YDSOAPDelegate> soapDelegate;

- (void)getSaleAnaylseSOAP:(NSString *)code tobaRange:(NSString *)range showType:(NSString *)type;

@end
