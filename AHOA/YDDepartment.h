//
//  YDDepartment.h
//  HNOANew
//
//  Created by 224 on 14-7-15.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDDepartment : NSObject

@property (copy, nonatomic) NSString *departCode;
@property (copy, nonatomic) NSString *departName;
@property (assign, nonatomic) int personCount;

//是否选中该部门人员
@property (nonatomic) BOOL selected;

- (instancetype)initDepartment;

@end
