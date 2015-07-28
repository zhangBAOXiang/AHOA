//
//  YDPerson.m
//  HNOANew
//
//  Created by 224 on 14-7-16.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDPerson.h"

#define kDepartCode @"departCode"
#define kDepartName @"departName"
#define kPersonCode @"personCode"
#define kMobileCode @"mobileCode"
#define kPersonname @"personName"
#define kPhoneCode @"phoneCode"
#define kPosition @"position"
#define kBind @"bind"
#define kSelected @"selected"

@implementation YDPerson

- (instancetype)initPerson
{
    self=[super init];
    if (self) {
        self.departcode=nil;
        self.departname=nil;
        self.personcode=nil;
        self.personname=nil;
        self.mobilecode=nil;
        self.phonecode=nil;
        self.position=nil;
        self.bind=nil;
        self.selected=NO;
    }
    
    return self;
}
/**自定义对象模型归档，解档
*NSUserDefaults对象不能设置自定义对象的值
*但是此时可以使用NSArchiver对象归档自定义对象
 **/
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_departcode forKey:kDepartCode];
    [aCoder encodeObject:_departname forKey:kDepartName];
    [aCoder encodeObject:_personcode forKey:kPersonCode];
    [aCoder encodeObject:_personname forKey:kPersonname];
    [aCoder encodeObject:_mobilecode forKey:kMobileCode];
    [aCoder encodeObject:_phonecode forKey:kPhoneCode];
    [aCoder encodeObject:_position forKey:kPosition];
    [aCoder encodeObject:_bind forKey:kBind];
    [aCoder encodeBool:_selected forKey:kSelected];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _departname=[aDecoder decodeObjectForKey:kDepartName];
        _departcode=[aDecoder decodeObjectForKey:kDepartCode];
        _personcode=[aDecoder decodeObjectForKey:kPersonCode];
        _personname=[aDecoder decodeObjectForKey:kPersonname];
        _mobilecode=[aDecoder decodeObjectForKey:kMobileCode];
        _phonecode=[aDecoder decodeObjectForKey:kPhoneCode];
        _position=[aDecoder decodeObjectForKey:kPosition];
        _bind=[aDecoder decodeObjectForKey:kBind];
        _selected=[aDecoder decodeBoolForKey:kSelected];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    YDPerson *copy=[[[self class] allocWithZone:zone] init];
    copy.departcode=[self.departcode copyWithZone:zone];
    copy.departname=[self.departname copyWithZone:zone];
    copy.personcode=[self.personcode copyWithZone:zone];
    copy.personname=[self.personname copyWithZone:zone];
    copy.mobilecode=[self.mobilecode copyWithZone:zone];
    copy.phonecode=[self.phonecode copyWithZone:zone];
    copy.position=[self.position copyWithZone:zone];
    copy.bind=[self.bind copyWithZone:zone];
    copy.selected=self.selected;
    
    return copy;
}

@end
