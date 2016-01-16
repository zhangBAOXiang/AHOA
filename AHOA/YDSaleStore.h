//
//  YDFunction.h
//  YNOA
//
//  Created by 224 on 14-10-8.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YDSaleAnaylse.h"

@interface YDSaleStore : NSObject

+ (BOOL)comPareDate:(NSDate *)currentDate;

+ (NSMutableArray *)saveSaleInfoToSQLite:(NSString *)returnString;

+ (void)archivedData:(id)object forCode:(NSString *)code;

+ (id)unarchivedData:(NSString *)code;

+ (void)removePath;

@end
