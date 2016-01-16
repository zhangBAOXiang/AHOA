//
//  YDSqliteUtil.m
//  HNOANew
//
//  Created by 224 on 14-7-11.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//


/**
 *SQLITE事务的使用
 **/
#import "YDSqliteUtil.h"
#import "YDSoapAndXmlParseUtil.h"
#import "YDMenu.h"
#import "YDPerson.h"
#import "YDSaleAnaylse.h"
#import "YDBusinessName.h"
#import "GDataXMLNode.h"

#define DBFILENAME @"zldb.sqlite"
static sqlite3 *db;
static NSMutableArray *departArray;
static GDataXMLDocument *doc;

@implementation YDSqliteUtil

//打开数据库
+ (void)openDatabase
{
    
        //获取数据库路径
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory=[paths objectAtIndex:0];
        NSString *path=[documentDirectory stringByAppendingPathComponent:DBFILENAME];
        
        if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
            sqlite3_close(db);
            NSAssert(0, @"Failed to open database");
        }
//        NSLog(@"database open success!");
}

+ (sqlite3 *)database
{
    return db;
}

+ (void)closeDatabase
{
    sqlite3_close(db);
}

//建表
+ (void)createTable:(NSString *)createSQL
{
    char *errorMsg;
    int result=sqlite3_exec(db, [createSQL UTF8String], NULL, NULL, &errorMsg);
    if (result != SQLITE_OK) {
        sqlite3_close(db);
    }
    NSLog(@"create table success!");
}

+ (void)initializeDatabase {
    [self openDatabase];
    NSString *createSQL=@"CREATE TABLE IF NOT EXISTS MENU "
    "(MENUCODE VARCHAR(5) UNIQUE,MENUNAME VARCHAR(50),"
    "IMAGE VARCHAR(20),URL VARCHAR(100),ALLOWTOP VARCHAR(2),"
    "ORDERTAG VARCHAR(2),VERSION VARCHAR(10))";
    [self createTable:createSQL];
    
    createSQL=@"CREATE TABLE IF NOT EXISTS PERSONINFO "
    "(DEPARTCODE VARCHAR(10),DEPARTNAME VARCHAR(100),"
    "PERSONCODE VARCHAR(10) UNIQUE,PERSONNAME VARCHAR(50),"
    "MOBILECODE VARCHAR(20),PHONECODE VARCHAR(20),"
    "POSITION VARCHAR(50),BIND VARCHAR(2));";
    [self createTable:createSQL];
    
    createSQL=@"CREATE TABLE IF NOT EXISTS DEPARTMENTINFO "
    "(DEPARTCODE VARCHAR(10) UNIQUE,DEPARTNAME VARCHAR(100),COUNT INT);";
    [self createTable:createSQL];
    
    createSQL=@"CREATE TABLE IF NOT EXISTS SALEANAYLSE "
    "(CODES VARCHAR(100) UNIQUE,NAMES VARCHAR(100),"
    "SALEQTYMO VARCHAR(100),SALEQTYMT VARCHAR(100),"
    "SALEQTYMTH VARCHAR(100),SALEQTYMF VARCHAR(100),"
    "SALEQTYYO VARCHAR(100),SALEQTYYT VARCHAR(100),"
    "SALEQTYYTH VARCHAR(100),SALEQTYYF VARCHAR(100), PRICE VARCHAR(50),TYPE VARCHAR(2));";
    [self createTable:createSQL];
    
    createSQL=@"CREATE TABLE IF NOT EXISTS BUSINESSLIST "
    "(BUSINESSCODE VARCHAR(20),INPUTCODE VARCHAR(20),BUSINESSNAME VARCHAR(20),BUSINESSTYPE VARCHAR(10))";
    [self createTable:createSQL];
    [self closeDatabase];

}


+ (NSMutableArray *)personInfoByDepartment:(YDDepartment *)department
{
    NSMutableArray *persons;
    [YDSqliteUtil openDatabase];
    persons=[NSMutableArray array];
    
    
    @try {
        char *errMsg;
        if (sqlite3_exec(db, "BEGIN", NULL, NULL, &errMsg) == SQLITE_OK){
            NSString *querySQL=@"SELECT * FROM PERSONINFO WHERE DEPARTNAME=?";
            
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
                //            NSLog(@"prepare success");
                sqlite3_bind_text(stmt, 1, [department.departName UTF8String], -1, NULL);
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    YDPerson *person=[[YDPerson alloc] initPerson];
                    person.departcode=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
                    person.departname=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
                    person.personcode=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                    person.personname=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
                    person.mobilecode=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
                    person.phonecode=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 5)];
                    person.position=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
                    person.bind=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
                    
                    [persons addObject:person];
                }
                sqlite3_finalize(stmt);
                if (sqlite3_exec(db, "COMMIT", NULL, NULL, &errMsg) == SQLITE_OK) {
                    NSLog(@"事务提交成功!");
                    sqlite3_free(errMsg);
                }
            }
        }
    }
    @catch (NSException *exception) {
        char *errorMsg;
        if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);

    }
    @finally {}
    
    sqlite3_close(db);

    return persons;
}

+ (NSMutableArray *)allPersons
{
    NSString *querySQL=@"SELECT * FROM PERSONINFO";
    [YDSqliteUtil openDatabase];
    NSMutableArray *personArray=[NSMutableArray array];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            YDPerson *person=[[YDPerson alloc] initPerson];
            person.departcode=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
            person.departname=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
            person.personcode=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
            person.personname=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
            person.mobilecode=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
            person.phonecode=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 5)];
            person.position=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
            person.bind=[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
            
            [personArray addObject:person];
        }
        sqlite3_finalize(stmt);
    }
    sqlite3_close(db);
    NSLog(@"count=%d",[personArray count]);
    
    return personArray;
}

+ (void)saveDepartment
{
    [YDSqliteUtil openDatabase];
    
    char *errMsg;
    NSString *deleteSQL=@"DELETE FROM DEPARTMENTINFO";
    int result=sqlite3_exec(db, [deleteSQL UTF8String], NULL, NULL, &errMsg);
    if (result != SQLITE_OK) {
        sqlite3_close(db);
    }
    
    NSString *departSQL=@"INSERT OR REPLACE INTO DEPARTMENTINFO "
    "SELECT DEPARTCODE,DEPARTNAME,COUNT(*) FROM PERSONINFO "
    "GROUP BY DEPARTNAME ORDER BY ROWID";
    char *error;
    result=sqlite3_exec(db, [departSQL UTF8String], NULL, NULL, &error);
    if (result !=SQLITE_OK) {
        NSAssert(0, @"Insert Table Failed: %s",error);
    }
    
    NSLog(@"insert departmentinfo success!");
    sqlite3_close(db);
}

+ (NSMutableArray *)queryDepartment
{
    NSMutableArray *array=[NSMutableArray array];
    @try {
        char *errMsg;
        [YDSqliteUtil openDatabase];
        if (sqlite3_exec(db, "BEGIN", NULL, NULL, &errMsg) == SQLITE_OK){
            
            departArray=[[NSMutableArray alloc] init];
            NSString *querySQL=@"SELECT * FROM DEPARTMENTINFO";
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    YDDepartment *department=[[YDDepartment alloc] initDepartment];
                    department.departCode=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                                   encoding:NSUTF8StringEncoding];
                    department.departName=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                                   encoding:NSUTF8StringEncoding];
                    department.personCount=sqlite3_column_int(stmt, 2);
                    [array addObject:department];
                }
                sqlite3_finalize(stmt);
            }
            
            if (sqlite3_exec(db, "COMMIT", NULL, NULL, &errMsg) == SQLITE_OK) {
                NSLog(@"事务提交成功!");
                sqlite3_free(errMsg);
            }
            
        }
    }
    @catch (NSException *exception) {
        char *errorMsg;
        if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
        
    }
    @finally {sqlite3_close(db);}
    
    //    NSLog(@"%@",array);
    
    return array;
}

+ (NSMutableArray *)querySaleAnaylse:(NSInteger)type
{
    NSMutableArray *array=[NSMutableArray array];
    @try {
        char *errMsg;
        [YDSqliteUtil openDatabase];
        if (sqlite3_exec(db, "BEGIN", NULL, NULL, &errMsg) == SQLITE_OK){
            
            departArray=[[NSMutableArray alloc] init];
            NSString *querySQL;
            switch (type) {
                case 0:
                    querySQL=@"SELECT CODES,NAMES,SALEQTYMO,SALEQTYMT,SALEQTYMTH,SALEQTYMF,"
                    "SALEQTYYO,SALEQTYYT,SALEQTYYTH,SALEQTYYF,PRICE FROM SALEANAYLSE WHERE TYPE = '0'";
                    break;
                case 1:
                    //工业
                    querySQL=@"SELECT CODES,NAMES,SALEQTYMO,SALEQTYMT,SALEQTYMTH,SALEQTYMF,"
                                "SALEQTYYO,SALEQTYYT,SALEQTYYTH,SALEQTYYF,PRICE FROM SALEANAYLSE WHERE TYPE = '1'";
                    break;
                case 2:
                    //品牌
                    querySQL=@"SELECT CODES,NAMES,SALEQTYMO,SALEQTYMT,SALEQTYMTH,SALEQTYMF,"
                    "SALEQTYYO,SALEQTYYT,SALEQTYYTH,SALEQTYYF,PRICE FROM SALEANAYLSE WHERE TYPE = '2'";
                    break;
                case 3:
                    //规格
                    querySQL=@"SELECT CODES,NAMES,SALEQTYMO,SALEQTYMT,SALEQTYMTH,SALEQTYMF,"
                    "SALEQTYYO,SALEQTYYT,SALEQTYYTH,SALEQTYYF,PRICE FROM SALEANAYLSE WHERE TYPE = '3'";
                    break;
                case 4:
                    //省份
                    querySQL=@"SELECT CODES,NAMES,SALEQTYMO,SALEQTYMT,SALEQTYMTH,SALEQTYMF,"
                    "SALEQTYYO,SALEQTYYT,SALEQTYYTH,SALEQTYYF,PRICE FROM SALEANAYLSE WHERE TYPE = '4'";
                    break;
                case 5:
                    //市场
                    querySQL=@"SELECT CODES,NAMES,SALEQTYMO,SALEQTYMT,SALEQTYMTH,SALEQTYMF,"
                    "SALEQTYYO,SALEQTYYT,SALEQTYYTH,SALEQTYYF,PRICE FROM SALEANAYLSE WHERE TYPE = '5'";
                    break;
                case 6:
                    //结构
                    querySQL=@"SELECT CODES,NAMES,SALEQTYMO,SALEQTYMT,SALEQTYMTH,SALEQTYMF,"
                    "SALEQTYYO,SALEQTYYT,SALEQTYYTH,SALEQTYYF,PRICE FROM SALEANAYLSE WHERE TYPE = '6'";
                    break;
                case 7:
                    //临时搜索
                    querySQL=@"SELECT CODES,NAMES,SALEQTYMO,SALEQTYMT,SALEQTYMTH,SALEQTYMF,"
                    "SALEQTYYO,SALEQTYYT,SALEQTYYTH,SALEQTYYF,PRICE FROM SALEANAYLSE WHERE TYPE = '7'";
                    break;

                default:
                    break;
            }
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    YDSaleAnaylse *saleAnaylse=[[YDSaleAnaylse alloc] init];
                    saleAnaylse.code=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.name=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.saleqtym1=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.saleqtym2=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 3)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.saleqtym3=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 4)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.saleqtym4=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 5)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.saleqtyy1=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 6)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.saleqtyy2=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 7)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.saleqtyy3=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 8)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.saleqtyy4=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 9)
                                                                   encoding:NSUTF8StringEncoding];
                    saleAnaylse.price=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 10)
                                                                   encoding:NSUTF8StringEncoding];
                    [array addObject:saleAnaylse];
                }
                sqlite3_finalize(stmt);
            }
            
            if (sqlite3_exec(db, "COMMIT", NULL, NULL, &errMsg) == SQLITE_OK) {
                NSLog(@"事务提交成功!");
                sqlite3_free(errMsg);
            }
            
        }
    }
    @catch (NSException *exception) {
        char *errorMsg;
        if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
        
    }
    @finally {sqlite3_close(db);}
    
    //    NSLog(@"%@",array);
    
    return array;
}

+ (void)updateDataSource
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    dict=[YDSoapAndXmlParseUtil requestToWsdl:kBusPersonInfo
                                    loginCode:@""
                                loginPassword:@""];
    
    NSError *error;
    NSData *data;
    if (dict) {
        error=[dict valueForKey:@"errorMsg"];
        data=[dict valueForKey:@"data"];
        if (error) {
            NSLog(@"请求绑定失败！！！错误信息:%@",error);
            return;
        }
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSString *returnString=[YDSoapAndXmlParseUtil responseXML:data methodName:@"busPersoninfo"];
        [defaults removeObjectForKey:@"personInfoString"];
        [defaults setValue:returnString forKey:@"personInfoString"];
        [defaults synchronize];

    }

}

//保存人员信息
+ (void)savePersonInfoFromRemote
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *busString=[defaults valueForKey:@"personInfoString"];
    NSError *err;
    doc=[[GDataXMLDocument alloc] initWithXMLString:busString options:0 error:&err];
    if (doc!=nil) {
        GDataXMLElement *rootNode=[doc rootElement];
        NSArray *rows=[rootNode children];
        
        @try {
            char *errMsg;
            [YDSqliteUtil openDatabase];
            
            NSString *deleteSQL=@"DELETE FROM PERSONINFO";
            int result=sqlite3_exec(db, [deleteSQL UTF8String], NULL, NULL, &errMsg);
            if (result != SQLITE_OK) {
                sqlite3_close(db);
            }
            
            NSString *insertSQL=@"INSERT OR REPLACE INTO PERSONINFO "
            "(DEPARTCODE,DEPARTNAME,PERSONCODE,PERSONNAME,"
            "MOBILECODE,PHONECODE,POSITION,BIND) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
            if (sqlite3_exec(db, "BEGIN", NULL, NULL, &errMsg) == SQLITE_OK) {
                NSLog(@"事务开启成功");
                sqlite3_free(errMsg);
                
                for (GDataXMLElement *row in rows) {
                    NSArray *childs=[row children];
                    sqlite3_stmt *stmt;
                    if (sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                        for (int i =0; i<[childs count]; i++) {
                            GDataXMLElement *child=[childs objectAtIndex:i];
                            sqlite3_bind_text(stmt, i+1, [[child stringValue] UTF8String], -1, NULL);
                        }
                    }
                    if (sqlite3_step(stmt) != SQLITE_DONE)
                        NSAssert(0, @"Error Insert Table :%s",errMsg);
                    sqlite3_finalize(stmt);
                }
                
                if (sqlite3_exec(db, "COMMIT", NULL, NULL, &errMsg) == SQLITE_OK) {
                    NSLog(@"事务提交成功!");
                    sqlite3_free(errMsg);
                }
                
                NSLog(@"Insert table personinfo success");
                
            }
            
        }
        @catch (NSException *exception) {
            char *errorMsg;
            if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
            sqlite3_free(errorMsg);
        }
        @finally{sqlite3_close(db);}
        
    }else{
        
    }

}

//保存工业，品牌，规格，省份，市场信息
+ (void)saveBusinessInfoFromRemote
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *busString=[defaults valueForKey:@"businessString"];
    [defaults removeObjectForKey:@"businessString"];
    [defaults synchronize];
    NSError *err;
    doc=[[GDataXMLDocument alloc] initWithXMLString:busString options:0 error:&err];
    if (doc!=nil) {
        GDataXMLElement *rootNode=[doc rootElement];
        NSArray *rows=[rootNode children];
        
        @try {
            char *errMsg;
            [YDSqliteUtil openDatabase];
            
            
            NSString *deleteSQL=@"DELETE FROM BUSINESSLIST";
            int result=sqlite3_exec(db, [deleteSQL UTF8String], NULL, NULL, &errMsg);
            if (result != SQLITE_OK) {
                sqlite3_close(db);
            }
            
            
            NSString *insertSQL=@"INSERT OR REPLACE INTO BUSINESSLIST "
            "(BUSINESSCODE,INPUTCODE,BUSINESSNAME,BUSINESSTYPE) "
            "VALUES (?, ?, ?, ?);";
            if (sqlite3_exec(db, "BEGIN", NULL, NULL, &errMsg) == SQLITE_OK) {
                NSLog(@"事务开启成功");
                sqlite3_free(errMsg);
                
                for (GDataXMLElement *row in rows) {
                    NSArray *childs=[row children];
                    sqlite3_stmt *stmt;
                    if (sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                        for (int i =0; i<[childs count]; i++) {
                            GDataXMLElement *child=[childs objectAtIndex:i];
                            sqlite3_bind_text(stmt, i+1, [[child stringValue] UTF8String], -1, NULL);
                        }
                    }
                    if (sqlite3_step(stmt) != SQLITE_DONE)
                        NSAssert(0, @"Error Insert Table :%s",errMsg);
                    sqlite3_finalize(stmt);
                }
                
                if (sqlite3_exec(db, "COMMIT", NULL, NULL, &errMsg) == SQLITE_OK) {
                    NSLog(@"事务提交成功!");
                    sqlite3_free(errMsg);
                }
                
                NSLog(@"Insert table success");
                
            }
            
        }
        @catch (NSException *exception) {
            char *errorMsg;
            if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
            sqlite3_free(errorMsg);
        }
        @finally{sqlite3_close(db);}
        
    }else{
        
    }
    
}

+ (NSMutableArray *)queryBusiness
{
    NSMutableArray *array=[NSMutableArray array];
    @try {
        char *errMsg;
        [YDSqliteUtil openDatabase];
        if (sqlite3_exec(db, "BEGIN", NULL, NULL, &errMsg) == SQLITE_OK){
            
            departArray=[[NSMutableArray alloc] init];
            NSString *querySQL=@"SELECT * FROM BUSINESSLIST ORDER BY CASE WHEN BUSINESSTYPE=3 THEN 0 ELSE BUSINESSTYPE END DESC";
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    YDBusinessName *business=[[YDBusinessName alloc] init];
                    business.code=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                                   encoding:NSUTF8StringEncoding];
                    business.inputCode=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                                   encoding:NSUTF8StringEncoding];
                    business.name=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                           encoding:NSUTF8StringEncoding];
                    business.type=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(stmt, 3)
                                                           encoding:NSUTF8StringEncoding];
                    [array addObject:business];
                }
                sqlite3_finalize(stmt);
            }
            
            if (sqlite3_exec(db, "COMMIT", NULL, NULL, &errMsg) == SQLITE_OK) {
                NSLog(@"事务提交成功!");
                sqlite3_free(errMsg);
            }
            
        }
    }
    @catch (NSException *exception) {
        char *errorMsg;
        if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
        
    }
    @finally {sqlite3_close(db);}
    
    //    NSLog(@"%@",array);
    
    return array;
}

@end
