//
//  YDSaleStockStore.m
//  YNOA
//
//  Created by 224 on 15/9/12.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDSaleStockStore.h"
#import "GDataXMLNode.h"
#import "YDSaleStock.h"

@implementation YDSaleStockStore

+ (NSMutableArray *)saveSaleInfoToSQLite:(NSString *)returnString
{
    NSMutableArray *soapArray=[[NSMutableArray alloc] init];
    NSError *err;
    GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithXMLString:returnString options:0 error:&err];
    if (doc!=nil) {
        GDataXMLElement *rootNode=[doc rootElement];
        NSArray *rows=[rootNode children];
        for (GDataXMLElement *row in rows) {
            NSArray *childs=[row children];
            YDSaleStock *saleStock=[[YDSaleStock alloc] init];
            for (int i =0; i<[childs count]; i++) {
                GDataXMLElement *child=[childs objectAtIndex:i];
                switch (i) {
                    case 0:
                        saleStock.stockid=[child stringValue];
                        break;
                    case 1:
                        saleStock.stockname=[child stringValue];
                        break;
                    case 2:
                        saleStock.stoday=[child stringValue];
                        break;
                    case 3:
                        saleStock.swholeYear=[child stringValue];
                        break;
                    case 4:
                        saleStock.stockr1=[child stringValue];
                        break;
                    case 5:
                        saleStock.stockr2=[child stringValue];
                        break;
                    default:
                        break;
                }
            }
            [soapArray addObject:saleStock];
        }
    }
    
    return soapArray;
    
}

+ (NSString *)plistPath
{
    //建立文件管理
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //找到Documents文件所在的路径
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //取得第一个Documents文件夹的路径
    
    NSString *filePath = [path objectAtIndex:0];
    
    //把TestPlist文件加入
    
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"saleStock.plist"];
    //开始创建文件
    if (![fm fileExistsAtPath:plistPath] ) {
        [fm createFileAtPath:plistPath contents:nil attributes:nil];
    }
    return plistPath;
}

+ (void)archivedData:(id)object forCode:(NSString *)code
{
    NSString *path=[self plistPath];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:path];
    if (dict == nil) {
        dict=[NSMutableDictionary dictionary];
    }
    NSData *data=[NSKeyedArchiver archivedDataWithRootObject:object];
    [dict setObject:data forKey:code];
    [dict writeToFile:path atomically:YES];
}

+ (id)unarchivedData:(NSString *)code
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:[self plistPath]];
    NSData *data=[dict objectForKey:code];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
}

+ (void)removePath
{
    NSString *plistPath=[self plistPath];
    NSFileManager *fm=[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:plistPath]) {
        [fm removeItemAtPath:plistPath error:nil];
    }
}


@end
