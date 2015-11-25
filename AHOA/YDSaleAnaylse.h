//
//  YDSaleAnaylse.h
//  YNOA
//
//  Created by 224 on 14-9-22.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDSaleAnaylse : NSObject<NSCoding,NSCopying>

//<c>000000</c><n>合计</n><m1>146.78</m1><m2>149.19</m2><m3>-2.41</m3><m4>-1.62</m4><y1>3571.20</y1><y2>3665.70</y2><y3>-94.50</y3><y4>-2.58</y4><mo1>422.76</mo1><mo2>415.80</mo2><mo3>6.95</mo3><mo4>1.67</mo4><yo1>10343.70</yo1><yo2>9942.42</yo2><yo3>401.28</yo3><yo4>4.04</yo4><p>0</p><ms1>28802</ms1><ms2>27871</ms2><ms3>931</ms3><ms4>3.23</ms4><ys1>28964</ys1><ys2>27122</ys2><ys3>1842</ys3><ys4>6.79</ys4><ld>2015-09-10</ld>

@property (copy, nonatomic) NSString *code;//类型 000000
@property (copy, nonatomic) NSString *name;//名称 合计
@property (copy, nonatomic) NSString *saleqtym1;//销售数据 146.78
@property (copy, nonatomic) NSString *saleqtym2;//同期销售数据 149.19
@property (copy, nonatomic) NSString *saleqtym3;//增量数据
@property (copy, nonatomic) NSString *saleqtym4;//增幅
@property (copy, nonatomic) NSString *saleqtyy1;//年销售数据
@property (copy, nonatomic) NSString *saleqtyy2;//同期年销售数据
@property (copy, nonatomic) NSString *saleqtyy3;//年增量数据
@property (copy, nonatomic) NSString *saleqtyy4;//年增幅
@property (copy, nonatomic) NSString *price;//价格

//安徽新加字段
@property (copy, nonatomic) NSString *mo1;//月销售额
@property (copy, nonatomic) NSString *mo2;//月同期销售额
@property (copy, nonatomic) NSString *mo3;//增量
@property (copy, nonatomic) NSString *mo4;//增幅
@property (copy, nonatomic) NSString *yo1;//年销售额
@property (copy, nonatomic) NSString *yo2;//年同期
@property (copy, nonatomic) NSString *yo3;//增量
@property (copy, nonatomic) NSString *yo4;//增幅

@property (copy, nonatomic) NSString *datetime;//时间

@end
