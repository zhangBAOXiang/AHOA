//
//  YDBusinessName.m
//  YNOA
//
//  Created by 224 on 14-9-26.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDBusinessName.h"

#define kBusinessCode @"businessCode"
#define kBusinessInputCode @"businessInputCode"
#define kBusinessName @"businessName"
#define kBusinessType @"businessType"

@implementation YDBusinessName

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_code forKey:kBusinessCode];
    [aCoder encodeObject:_inputCode forKey:kBusinessInputCode];
    [aCoder encodeObject:_name forKey:kBusinessName];
    [aCoder encodeObject:_type forKey:kBusinessType];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _code=[aDecoder decodeObjectForKey:kBusinessCode];
        _inputCode=[aDecoder decodeObjectForKey:kBusinessInputCode];
        _name=[aDecoder decodeObjectForKey:kBusinessName];
        _type=[aDecoder decodeObjectForKey:kBusinessType];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    YDBusinessName *copy=[[[self class] allocWithZone:zone] init];
    copy.code=[self.code copyWithZone:zone];
    copy.inputCode=[self.inputCode copyWithZone:zone];
    copy.name=[self.name copyWithZone:zone];
    copy.type=[self.type copyWithZone:zone];
    return copy;
}

@end
