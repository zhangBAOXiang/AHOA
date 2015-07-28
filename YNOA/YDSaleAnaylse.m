//
//  YDSaleAnaylse.m
//  YNOA
//
//  Created by 224 on 14-9-22.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSaleAnaylse.h"

#define kSaleCode @"code"
#define kSaleName @"name"
#define kSaleQTYM1 @"kSaleQTYM1"
#define kSaleQTYM2 @"kSaleQTYM2"
#define kSaleQTYM3 @"kSaleQTYM3"
#define kSaleQTYM4 @"kSaleQTYM4"
#define kSaleQTYY1 @"kSaleQTYY1"
#define kSaleQTYY2 @"kSaleQTYY2"
#define kSaleQTYY3 @"kSaleQTYY3"
#define kSaleQTYY4 @"kSaleQTYY4"
#define kSalePrice @"price"
#define kSaleDateTime @"datetime"

@implementation YDSaleAnaylse

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_code forKey:kSaleCode];
    [aCoder encodeObject:_name forKey:kSaleName];
    [aCoder encodeObject:_saleqtym1 forKey:kSaleQTYM1];
    [aCoder encodeObject:_saleqtym2 forKey:kSaleQTYM2];
    [aCoder encodeObject:_saleqtym3 forKey:kSaleQTYM3];
    [aCoder encodeObject:_saleqtym4 forKey:kSaleQTYM4];
    [aCoder encodeObject:_saleqtyy1 forKey:kSaleQTYY1];
    [aCoder encodeObject:_saleqtyy2 forKey:kSaleQTYY2];
    [aCoder encodeObject:_saleqtyy3 forKey:kSaleQTYY3];
    [aCoder encodeObject:_saleqtyy4 forKey:kSaleQTYY4];
    [aCoder encodeObject:_price forKey:kSalePrice];
    [aCoder encodeObject:_datetime forKey:kSaleDateTime];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        _code=[aDecoder decodeObjectForKey:kSaleCode];
        _name=[aDecoder decodeObjectForKey:kSaleName];
        _saleqtym1=[aDecoder decodeObjectForKey:kSaleQTYM1];
        _saleqtym2=[aDecoder decodeObjectForKey:kSaleQTYM2];
        _saleqtym3=[aDecoder decodeObjectForKey:kSaleQTYM3];
        _saleqtym4=[aDecoder decodeObjectForKey:kSaleQTYM4];
        _saleqtyy1=[aDecoder decodeObjectForKey:kSaleQTYY1];
        _saleqtyy2=[aDecoder decodeObjectForKey:kSaleQTYY2];
        _saleqtyy3=[aDecoder decodeObjectForKey:kSaleQTYY3];
        _saleqtyy4=[aDecoder decodeObjectForKey:kSaleQTYY4];
        _price=[aDecoder decodeObjectForKey:kSalePrice];
        _datetime = [aDecoder decodeObjectForKey:kSaleDateTime];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    YDSaleAnaylse *copy=[[[self class] allocWithZone:zone] init];
    copy.code=[self.code copyWithZone:zone];
    copy.name=[self.name copyWithZone:zone];
    copy.saleqtym1=[self.saleqtym1 copyWithZone:zone];
    copy.saleqtym2=[self.saleqtym2 copyWithZone:zone];
    copy.saleqtym3=[self.saleqtym3 copyWithZone:zone];
    copy.saleqtym4=[self.saleqtym4 copyWithZone:zone];
    copy.saleqtyy1=[self.saleqtyy1 copyWithZone:zone];
    copy.saleqtyy2=[self.saleqtyy2 copyWithZone:zone];
    copy.saleqtyy3=[self.saleqtyy3 copyWithZone:zone];
    copy.saleqtyy4=[self.saleqtyy4 copyWithZone:zone];
    copy.price=[self.price copyWithZone:zone];
    copy.datetime = [self.datetime copyWithZone:zone];
    
    return copy;
}

@end
