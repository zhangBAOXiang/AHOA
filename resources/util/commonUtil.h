//
//  operatePList.h
//  HelloWorld
//
//  Created by apple on 13-9-2.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface commonUtil : NSObject


//操作plist文件
+ (NSDictionary*)dictionaryFromPListFile: (NSString*)strFileName;
+ (NSDictionary*)dictionaryFromSystemPListFile:(NSString *)strFileName;

//Web Service调用
+ (NSMutableDictionary*)soapCall: (NSString*)serverHost postMethod:(NSString*)method postData:(NSString*)data;

//Local Storage
+ (BOOL)fileExists: (NSString*)fileName;
+ (NSString*)docPath;
+ (NSData*) readFileFromLocal: (NSString *)dirPath savedName: (NSString*) fileName;
+ (BOOL) writeFileToLocal: (NSData*)data savedPath: (NSString*)filePath savedName: (NSString*)fileName;
+ (void) emptyFilesAtPath: (NSString*)dirPath;


@end
