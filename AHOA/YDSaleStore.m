//
//  YDFunction.m
//  YNOA
//
//  Created by 224 on 14-10-8.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSaleStore.h"
#import "GDataXMLNode.h"

@implementation YDSaleStore

+ (BOOL)comPareDate:(NSDate *)currentDate
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDate *oldDate=[defaults valueForKey:@"oldDate"];
    if (oldDate) {
        NSTimeInterval firstDate=[oldDate timeIntervalSince1970]*1;
        
        NSTimeInterval secondDate=[currentDate timeIntervalSince1970];
        
        if (secondDate - firstDate < 60*60) {
            NSLog(@"%f",secondDate-firstDate);
            return YES;
        }
        else{
            return NO;
        }
        
    }else{
        return NO;
    }
}

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
            YDSaleAnaylse *saleAnaylse=[[YDSaleAnaylse alloc] init];
            for (int i =0; i<[childs count]; i++) {
                GDataXMLElement *child=[childs objectAtIndex:i];
                switch (i) {
                    case 0:
                        saleAnaylse.code=[child stringValue];
                        break;
                    case 1:
                        saleAnaylse.name=[child stringValue];
                        break;
                    case 2:
                        saleAnaylse.saleqtym1=[child stringValue];
                        break;
                    case 3:
                        saleAnaylse.saleqtym2=[child stringValue];
                        break;
                    case 4:
                        saleAnaylse.saleqtym3=[child stringValue];
                        break;
                    case 5:
                        saleAnaylse.saleqtym4=[child stringValue];
                        break;
                    case 6:
                        saleAnaylse.saleqtyy1=[child stringValue];
                        break;
                    case 7:
                        saleAnaylse.saleqtyy2=[child stringValue];
                        break;
                    case 8:
                        saleAnaylse.saleqtyy3=[child stringValue];
                        break;
                    case 9:
                        saleAnaylse.saleqtyy4=[child stringValue];
                        break;
                    case 10:
                        saleAnaylse.mo1=[child stringValue];
                        break;
                    case 11:
                        saleAnaylse.mo2=[child stringValue];
                        break;
                    case 12:
                        saleAnaylse.mo3=[child stringValue];
                        break;
                    case 13:
                        saleAnaylse.mo4=[child stringValue];
                        break;
                    case 14:
                        saleAnaylse.yo1=[child stringValue];
                        break;
                    case 15:
                        saleAnaylse.yo2=[child stringValue];
                        break;
                    case 16:
                        saleAnaylse.yo3=[child stringValue];
                        break;
                    case 17:
                        saleAnaylse.yo4=[child stringValue];
                        break;
                    case 18:
                        saleAnaylse.price=[child stringValue];
                        break;
                    default:
                        break;
                }
                //取出时间
                child = [childs objectAtIndex:([childs count] - 1)];
                saleAnaylse.datetime = [child stringValue];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:saleAnaylse.datetime forKey:@"analyseTime"];
                [defaults synchronize];
            }
            [soapArray addObject:saleAnaylse];
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
    
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"anaylse.plist"];
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
