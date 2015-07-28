//
//  YDSaleAnaylse.h
//  YNOA
//
//  Created by 224 on 14-9-22.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDSaleAnaylse : NSObject<NSCoding,NSCopying>

@property (copy, nonatomic) NSString *code;//类型
@property (copy, nonatomic) NSString *name;//名称
@property (copy, nonatomic) NSString *saleqtym1;//销售数据
@property (copy, nonatomic) NSString *saleqtym2;//同期销售数据
@property (copy, nonatomic) NSString *saleqtym3;//增量数据
@property (copy, nonatomic) NSString *saleqtym4;//增幅
@property (copy, nonatomic) NSString *saleqtyy1;//年销售数据
@property (copy, nonatomic) NSString *saleqtyy2;//同期年销售数据
@property (copy, nonatomic) NSString *saleqtyy3;//年增量数据
@property (copy, nonatomic) NSString *saleqtyy4;//年增幅
@property (copy, nonatomic) NSString *price;//价格
@property (copy, nonatomic) NSString *datetime;//时间

@end
