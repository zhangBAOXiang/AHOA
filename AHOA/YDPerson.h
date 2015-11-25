//
//  YDPerson.h
//  HNOANew
//
//  Created by 224 on 14-7-16.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDPerson : NSObject <NSCoding,NSCopying>

@property (copy, nonatomic) NSString *departcode;
@property (copy, nonatomic) NSString *departname;
@property (copy, nonatomic) NSString *personcode;
@property (copy, nonatomic) NSString *personname;
@property (copy, nonatomic) NSString *mobilecode;
@property (copy, nonatomic) NSString *phonecode;
@property (copy, nonatomic) NSString *position;
@property (copy, nonatomic) NSString *bind;

@property (nonatomic) BOOL selected;

- (instancetype)initPerson;

@end
