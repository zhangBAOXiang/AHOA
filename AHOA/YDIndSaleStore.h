//
//  YDIndSaleStore.h
//  AHOA
//
//  Created by 224 on 15/11/15.
//  Copyright © 2015年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDIndSaleStore : NSObject

+ (NSMutableArray *)saveSaleInfoToSQLite:(NSString *)returnString;

+ (void)archivedData:(id)object forCode:(NSString *)code;

+ (id)unarchivedData:(NSString *)code;

+ (void)removePath;

@end
