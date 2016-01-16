//
//  YDSqliteUtil.h
//  HNOANew
//
//  Created by 224 on 14-7-11.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YDAppDelegate.h"
#import "YDDepartment.h"
#import <sqlite3.h>

@interface YDSqliteUtil : NSObject

+ (void)openDatabase;

+ (sqlite3 *)database;

+ (void)closeDatabase;

+ (void)createTable:(NSString *)createSQL;

+ (void)initializeDatabase;

+ (void)savePersonInfoFromRemote;

+ (void)saveBusinessInfoFromRemote;

+ (void)saveDepartment;

+ (NSMutableArray *)queryDepartment;

+ (NSMutableArray *)queryBusiness;

+ (NSMutableArray *)querySaleAnaylse:(NSInteger)type;

+ (void)updateDataSource;

+ (NSMutableArray *)allPersons;

+ (NSMutableArray *)personInfoByDepartment:(YDDepartment *)department;

@end
