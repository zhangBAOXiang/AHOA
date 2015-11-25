//
//  YDSaleStockStore.h
//  YNOA
//
//  Created by 224 on 15/9/12.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDSaleStockStore : NSObject

+ (NSMutableArray *)saveSaleInfoToSQLite:(NSString *)returnString;

+ (void)archivedData:(id)object forCode:(NSString *)code;

+ (id)unarchivedData:(NSString *)code;

+ (void)removePath;

@end
