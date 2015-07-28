//
//  YDMenuStore.m
//  YNOA
//
//  Created by 224 on 14-11-7.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDMenuStore.h"
#import "YDSqliteUtil.h"
#import <sqlite3.h>
#import "GDataXMLNode.h"

@implementation YDMenuStore

+ (YDMenuStore *)sharedStore
{
    static YDMenuStore *sharedStore=nil;
    if (!sharedStore) {
        //创建单实力例
        sharedStore=[[super allocWithZone:NULL] init];
    }
    return sharedStore;
}

//防止直接通过调用allocwithzone方法获取新的对象
+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (void)saveImagesToSQLite:(NSString *)returnString
{
    NSError *err;
    GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithXMLString:returnString options:0 error:&err];
    if (doc!=nil) {
        GDataXMLElement *rootNode=[doc rootElement];
        NSArray *rows=[rootNode children];
        
        @try {
            char *errMsg;
            [YDSqliteUtil openDatabase];
            
            NSString *deleteSQL=@"DELETE FROM MENU";
            int result=sqlite3_exec([YDSqliteUtil database], [deleteSQL UTF8String], NULL, NULL, &errMsg);
            if (result != SQLITE_OK) {
                sqlite3_close([YDSqliteUtil database]);
            }
            
            NSString *insertSQL=@"INSERT OR REPLACE INTO MENU "
            "(MENUCODE,MENUNAME,IMAGE,URL,"
            "ALLOWTOP,ORDERTAG,VERSION) "
            "VALUES (?, ?, ?, ?, ?, ?, ?);";
            if (sqlite3_exec([YDSqliteUtil database], "BEGIN", NULL, NULL, &errMsg) == SQLITE_OK) {
                NSLog(@"事务开启成功");
                sqlite3_free(errMsg);
                
                for (GDataXMLElement *row in rows) {
                    NSArray *childs=[row children];
                    sqlite3_stmt *stmt;
                    if (sqlite3_prepare_v2([YDSqliteUtil database], [insertSQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                        for (int i =0; i<[childs count]; i++) {
                            GDataXMLElement *child=[childs objectAtIndex:i];
                            sqlite3_bind_text(stmt, i+1, [[child stringValue] UTF8String], -1, NULL);
                        }
                    }
                    if (sqlite3_step(stmt) != SQLITE_DONE)
                        NSAssert(0, @"Error Insert Table :%s",errMsg);
                    sqlite3_finalize(stmt);
                }
                
                if (sqlite3_exec([YDSqliteUtil database], "COMMIT", NULL, NULL, &errMsg) == SQLITE_OK) {
                    NSLog(@"事务提交成功!");
                    sqlite3_free(errMsg);
                }
                
                NSLog(@"Insert table success");
                
            }
            
        }
        @catch (NSException *exception) {
            char *errorMsg;
            if (sqlite3_exec([YDSqliteUtil database], "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
            sqlite3_free(errorMsg);
        }
        @finally{sqlite3_close([YDSqliteUtil database]);}
        
    }else{
        
    }

}

+ (NSMutableArray *)queryMenu
{
   NSMutableArray *departArray=[[NSMutableArray alloc] init];
    @try {
        char *errMsg;
        [YDSqliteUtil openDatabase];
        if (sqlite3_exec([YDSqliteUtil database], "BEGIN", NULL, NULL, &errMsg) == SQLITE_OK){
            NSString *querySQL=@"SELECT * FROM MENU";
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2([YDSqliteUtil database], [querySQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    YDMenu *menu=[[YDMenu alloc] init];
                    menu.menuCode=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                           encoding:NSUTF8StringEncoding];
                    menu.menuName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                           encoding:NSUTF8StringEncoding];
                    menu.image=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                        encoding:NSUTF8StringEncoding];
                    menu.Img=[self requestImage:menu.image];
                    
                    menu.url=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 3)
                                                      encoding:NSUTF8StringEncoding];
                    menu.allowTop=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 4)
                                                           encoding:NSUTF8StringEncoding];
                    menu.orderTag=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 5)
                                                           encoding:NSUTF8StringEncoding];
                    menu.version=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 6)
                                                          encoding:NSUTF8StringEncoding];
                    [departArray addObject:menu];
                }
                sqlite3_finalize(stmt);
            }
            
            if (sqlite3_exec([YDSqliteUtil database], "COMMIT", NULL, NULL, &errMsg) == SQLITE_OK) {
                NSLog(@"事务提交成功!");
                sqlite3_free(errMsg);
            }
            
        }
    }
    @catch (NSException *exception) {
        char *errorMsg;
        if (sqlite3_exec([YDSqliteUtil database], "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
        
    }
    @finally {sqlite3_close([YDSqliteUtil database]);}
    
    //    NSLog(@"%@",array);
//    if ([departArray count] != 0) {
//        return departArray;
//    }else{
//        YDMenu *menu=[[YDMenu alloc] init];
//        menu.menuName=@"请检查您的权限";
//        [departArray addObject:menu];
//        return departArray;
//    }
    return departArray;

}

+ (UIImage *)requestImage:(NSString *)strUrl
{
    NSString *imageURL=[[self imageURL] stringByAppendingString:strUrl];
    NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    return [UIImage imageWithData:data];
}

//从应用程序获得conf.plist文件
+ (NSString *)imageURL
{
    NSString *fileName=[[NSBundle mainBundle] pathForResource:@"conf" ofType:@"plist"];
    NSDictionary *dict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        dict=[[NSDictionary alloc] initWithContentsOfFile:fileName];
    }
    
    return [dict valueForKey:@"downloadImage"];
}



@end
