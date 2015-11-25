//
//  YDIndSale.h
//  AHOA
//
//  Created by 224 on 15/11/15.
//  Copyright © 2015年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

//<row><c>04</c><n>四类烟</n><m1>38.96</m1><m2>39.19</m2><m3>-0.23</m3><m4>-0.59</m4><y1>823.66</y1><y2>864.76</y2><y3>-41.10</y3><y4>-4.75</y4><mo1>28.88</mo1><mo2>30.60</mo2><mo3>-1.72</mo3><mo4>-5.62</mo4><yo1>639.95</yo1><yo2>677.04</yo2><yo3>-37.09</yo3><yo4>-5.48</yo4><p>0</p><ms1>7414</ms1><ms2>7809</ms2><ms3>-395</ms3><ms4>-5.33</ms4><ys1>7769</ys1><ys2>7829</ys2><ys3>-60</ys3><ys4>-0.77</ys4><st1>249</st1><ld>2015-11-13</ld></row>

@interface YDIndSale : NSObject<NSCoding,NSCopying>

@property (copy, nonatomic) NSString *code;//类型 000000
@property (copy, nonatomic) NSString *name;//名称 合计
@property (copy, nonatomic) NSString *saleqtym1;
@property (copy, nonatomic) NSString *saleqtym2;
@property (copy, nonatomic) NSString *saleqtym3;
@property (copy, nonatomic) NSString *saleqtym4;
@property (copy, nonatomic) NSString *saleqtyy1;
@property (copy, nonatomic) NSString *saleqtyy2;
@property (copy, nonatomic) NSString *saleqtyy3;
@property (copy, nonatomic) NSString *saleqtyy4;

//安徽新加字段
@property (copy, nonatomic) NSString *mo1;
@property (copy, nonatomic) NSString *mo2;
@property (copy, nonatomic) NSString *mo3;
@property (copy, nonatomic) NSString *mo4;
@property (copy, nonatomic) NSString *yo1;
@property (copy, nonatomic) NSString *yo2;
@property (copy, nonatomic) NSString *yo3;
@property (copy, nonatomic) NSString *yo4;

@property (copy, nonatomic) NSString *price;//价格

@property (copy, nonatomic) NSString *datetime;//时间

@end
