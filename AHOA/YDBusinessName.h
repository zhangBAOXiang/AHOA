//
//  YDBusinessName.h
//  YNOA
//
//  Created by 224 on 14-9-26.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDBusinessName : NSObject<NSCopying,NSCoding>

@property (copy, nonatomic) NSString *code;
@property (copy, nonatomic) NSString *inputCode;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *type;

@end
