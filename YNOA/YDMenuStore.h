//
//  YDMenuStore.h
//  YNOA
//
//  Created by 224 on 14-11-7.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YDMenu.h"

@interface YDMenuStore : NSObject

+(YDMenuStore *)sharedStore;

- (void)saveImagesToSQLite:(NSString *)returnString;

+ (NSMutableArray *)queryMenu;

@end
