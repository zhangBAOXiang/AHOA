//
//  YDSaleStock.m
//  YNOA
//
//  Created by 224 on 15/9/12.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDSaleStock.h"

@implementation YDSaleStock

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _stockid = [aDecoder decodeObjectForKey:@"stockid"];
        _stockname = [aDecoder decodeObjectForKey:@"stockname"];
        _stoday = [aDecoder decodeObjectForKey:@"stoday"];
        _swholeYear = [aDecoder decodeObjectForKey:@"swholeyear"];
        _stockr1 = [aDecoder decodeObjectForKey:@"stockr1"];
        _stockr2 = [aDecoder decodeObjectForKey:@"stockr2"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_stockid forKey:@"stockid"];
    [aCoder encodeObject:_stockname forKey:@"stockname"];
    [aCoder encodeObject:_stoday forKey:@"stoday"];
    [aCoder encodeObject:_swholeYear forKey:@"swholeyear"];
    [aCoder encodeObject:_stockr1 forKey:@"stockr1"];
    [aCoder encodeObject:_stockr2 forKey:@"stockr2"];
}

- (id)copyWithZone:(NSZone *)zone {
    YDSaleStock *copy = [[self copyWithZone:zone] init];
    copy.stockid = [self.stockid copyWithZone:zone];
    copy.stockname = [self.stockname copyWithZone:zone];
    copy.stoday = [self.stoday copyWithZone:zone];
    copy.swholeYear = [self.swholeYear copyWithZone:zone];
    copy.stockr1 = [self.stockr1 copyWithZone:zone];
    copy.stockr2 = [self.stockr2 copyWithZone:zone];
    return copy;
}

@end
