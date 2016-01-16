//
//  YDIndSale.m
//  AHOA
//
//  Created by 224 on 15/11/15.
//  Copyright © 2015年 zoomlgd. All rights reserved.
//

#import "YDIndSale.h"

#define kSaleCode @"indcode"
#define kSaleName @"indname"
#define kSaleQTYM1 @"kSaleINDYM1"
#define kSaleQTYM2 @"kSaleINDYM2"
#define kSaleQTYM3 @"kSaleINDYM3"
#define kSaleQTYM4 @"kSaleINDYM4"
#define kSaleQTYY1 @"kSaleINDYY1"
#define kSaleQTYY2 @"kSaleINDYY2"
#define kSaleQTYY3 @"kSaleINDYY3"
#define kSaleQTYY4 @"kSaleINDYY4"
#define kSaleQTYMO1 @"kSaleINDYMO1"
#define kSaleQTYMO2 @"kSaleINDYMO2"
#define kSaleQTYMO3 @"kSaleINDYMO3"
#define kSaleQTYMO4 @"kSaleINDYMO4"
#define kSaleQTYYO1 @"kSaleINDYYO1"
#define kSaleQTYYO2 @"kSaleINDYYO2"
#define kSaleQTYYO3 @"kSaleINDYYO3"
#define kSaleQTYYO4 @"kSaleINDYYO4"
#define kSalePrice @"indprice"
#define kSaleDateTime @"inddatetime"

@implementation YDIndSale

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.code forKey:kSaleCode];
    [aCoder encodeObject:self.name forKey:kSaleName];
    [aCoder encodeObject:self.saleqtym1 forKey:kSaleQTYM1];
    [aCoder encodeObject:self.saleqtym2 forKey:kSaleQTYM2];
    [aCoder encodeObject:self.saleqtym3 forKey:kSaleQTYM3];
    [aCoder encodeObject:self.saleqtym4 forKey:kSaleQTYM4];
    [aCoder encodeObject:self.saleqtyy1 forKey:kSaleQTYY1];
    [aCoder encodeObject:self.saleqtyy2 forKey:kSaleQTYY2];
    [aCoder encodeObject:self.saleqtyy3 forKey:kSaleQTYY3];
    [aCoder encodeObject:self.saleqtyy4 forKey:kSaleQTYY4];
    [aCoder encodeObject:self.mo1 forKey:kSaleQTYMO1];
    [aCoder encodeObject:self.mo2 forKey:kSaleQTYMO2];
    [aCoder encodeObject:self.mo3 forKey:kSaleQTYMO3];
    [aCoder encodeObject:self.mo4 forKey:kSaleQTYMO4];
    [aCoder encodeObject:self.yo1 forKey:kSaleQTYYO1];
    [aCoder encodeObject:self.yo2 forKey:kSaleQTYYO2];
    [aCoder encodeObject:self.yo3 forKey:kSaleQTYYO3];
    [aCoder encodeObject:self.yo4 forKey:kSaleQTYYO4];
    [aCoder encodeObject:self.price forKey:kSalePrice];
    [aCoder encodeObject:self.datetime forKey:kSaleDateTime];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.code=[aDecoder decodeObjectForKey:kSaleCode];
        self.name=[aDecoder decodeObjectForKey:kSaleName];
        self.saleqtym1=[aDecoder decodeObjectForKey:kSaleQTYM1];
        self.saleqtym2=[aDecoder decodeObjectForKey:kSaleQTYM2];
        self.saleqtym3=[aDecoder decodeObjectForKey:kSaleQTYM3];
        self.saleqtym4=[aDecoder decodeObjectForKey:kSaleQTYM4];
        self.saleqtyy1=[aDecoder decodeObjectForKey:kSaleQTYY1];
        self.saleqtyy2=[aDecoder decodeObjectForKey:kSaleQTYY2];
        self.saleqtyy3=[aDecoder decodeObjectForKey:kSaleQTYY3];
        self.saleqtyy4=[aDecoder decodeObjectForKey:kSaleQTYY4];
        self.mo1=[aDecoder decodeObjectForKey:kSaleQTYMO1];
        self.mo2=[aDecoder decodeObjectForKey:kSaleQTYMO2];
        self.mo3=[aDecoder decodeObjectForKey:kSaleQTYMO3];
        self.mo4=[aDecoder decodeObjectForKey:kSaleQTYMO4];
        self.yo1=[aDecoder decodeObjectForKey:kSaleQTYYO1];
        self.yo2=[aDecoder decodeObjectForKey:kSaleQTYYO2];
        self.yo3=[aDecoder decodeObjectForKey:kSaleQTYYO3];
        self.yo4=[aDecoder decodeObjectForKey:kSaleQTYYO4];
        self.price=[aDecoder decodeObjectForKey:kSalePrice];
        self.datetime = [aDecoder decodeObjectForKey:kSaleDateTime];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    YDIndSale *copy=[[[self class] allocWithZone:zone] init];
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
    copy.mo1=[self.mo1 copyWithZone:zone];
    copy.mo2=[self.mo2 copyWithZone:zone];
    copy.mo3=[self.mo3 copyWithZone:zone];
    copy.mo4=[self.mo4 copyWithZone:zone];
    copy.yo1=[self.yo1 copyWithZone:zone];
    copy.yo2=[self.yo2 copyWithZone:zone];
    copy.yo3=[self.yo3 copyWithZone:zone];
    copy.yo4=[self.yo4 copyWithZone:zone];
    copy.price=[self.price copyWithZone:zone];
    copy.datetime = [self.datetime copyWithZone:zone];
    
    return copy;
}


@end
