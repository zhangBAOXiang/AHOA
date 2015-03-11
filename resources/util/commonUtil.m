//
//  commonUtil
//  HelloWorld
//
//  Created by apple on 13-9-2.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import "commonUtil.h"


@implementation commonUtil


#pragma mark -
#pragma mark operate plist file

+ (NSDictionary*)dictionaryFromPListFile:(NSString *)strFileName
{
    NSArray *myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//查找Documents目录
    NSString *myDocPath = [myPaths objectAtIndex:0];
    NSString *fileName = [myDocPath stringByAppendingPathComponent:strFileName];//文件重命名
    NSDictionary *retDict;
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        retDict = [[NSDictionary alloc] initWithContentsOfFile:fileName];
    }
    return retDict;
}

+ (NSDictionary*)dictionaryFromSystemPListFile:(NSString *)strFileName//查找系统内的plist文件
{
    NSString *fileName = [[NSBundle mainBundle] pathForResource:strFileName ofType:@"plist"];
    NSDictionary *retDict;
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        retDict = [[NSDictionary alloc] initWithContentsOfFile:fileName];
    }
    return retDict;

}


#pragma mark -
#pragma mark Web Service Invoke

+ (NSMutableDictionary*)soapCall: (NSString*)serverHost postMethod:(NSString*)method postData:(NSString *)data
{    
    NSString * soapAction = [serverHost stringByAppendingPathComponent:@"services/authorization"];
    NSString * soapUrl = [serverHost stringByAppendingPathComponent:@"services/authorization?wsdl"];
    
    NSData *postData = [data dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    
    NSURL *url = [NSURL URLWithString:soapUrl];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc]init];
    [theRequest setTimeoutInterval:30];
    [theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [theRequest setURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:postData];
    
    NSError *err = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:&err];
    
    NSMutableDictionary *theDict = [NSMutableDictionary dictionary];
    [theDict setValue:err forKey:@"err"];
    [theDict setValue:responseData forKey:@"data"];
    
    return theDict;
}

#pragma mark -
#pragma mark Local Storage

+ (BOOL) fileExists: (NSString *)fileName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:fileName];
}

+ (NSString*)docPath
{
    NSArray *myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    return myDocPath;
}

+ (NSData*) readFileFromLocal: (NSString*)dirPath savedName: (NSString*) fileName
{
    NSData *data = nil;
    
    NSArray *myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[NSString alloc]initWithString: [[myDocPath stringByAppendingPathComponent:dirPath] stringByAppendingPathComponent:fileName]];
    NSLog(@"本地目录地址：%@",filePath);
    
    if (![fm fileExistsAtPath:filePath]) {
        NSLog(@"所请求的文件不存在！");
    }
    else {
        data = [NSData dataWithContentsOfFile:filePath];
    }
    
    return data;
}

/*
    filePath: 相对路径，不包含Documents
 */
+ (BOOL) writeFileToLocal: (NSData*)data savedPath: (NSString*)dirPath savedName: (NSString*)fileName
{
    NSArray *myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[NSString alloc] initWithString:[myDocPath stringByAppendingPathComponent:dirPath]];
//    NSLog(@"本地目录地址：%@",filePath);
    BOOL bo = YES;
    if (![fm fileExistsAtPath: filePath]) {
        BOOL bo = [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!bo) {
            NSLog(@"创建目录失败！");
            return NO;
        }
    }
    bo = [data writeToFile:[filePath stringByAppendingPathComponent:fileName] atomically:YES];
    if (bo) {
        return YES;
    }
    else {
        return NO;
    }
}

/*
    删除目录内所有文件,而保留目录，dirPath：相对路径
 */
+ (void) emptyFilesAtPath: (NSString*)dirPath
{
    NSArray *myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[NSString alloc] initWithString:[myDocPath stringByAppendingPathComponent:dirPath]];
    
    // 判断文件夹是否存在
    BOOL isDir;
    if (!([fm fileExistsAtPath:filePath isDirectory:&isDir]&&isDir)) {
        return;
    }

    NSArray *fileList = [fm contentsOfDirectoryAtPath:filePath error:nil];
    for (int i=0, n=[fileList count]; i<n; i++) {
        NSString *tempDir = [filePath stringByAppendingPathComponent:[fileList objectAtIndex:i]];
        [fm removeItemAtPath:tempDir error:nil];
    }
    
}



@end
