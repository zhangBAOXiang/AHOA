//
//  YDDepartment.m
//  HNOANew
//
//  Created by 224 on 14-7-15.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDDepartment.h"

@implementation YDDepartment

- (instancetype)initDepartment
{
    self=[super init];
    if (self) {
        self.departCode=nil;
        self.departName=nil;
        self.personCount=0;
        self.selected=NO;
    }
    return self;
}
@end
