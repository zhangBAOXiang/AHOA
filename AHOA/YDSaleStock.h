//
//  YDSaleStock.h
//  YNOA
//
//  Created by 224 on 15/9/12.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDSaleStock : NSObject<NSCoding, NSCopying>

@property (nonatomic, copy) NSString *stockid;//id
@property (nonatomic, copy) NSString *stockname;//名称
@property (nonatomic, copy) NSString *stoday;//本日
@property (nonatomic, copy) NSString *swholeYear;//本年
@property (nonatomic, copy) NSString *stockr1;//增幅
@property (nonatomic, copy) NSString *stockr2;//增量

@end
