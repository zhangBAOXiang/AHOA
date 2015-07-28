//
//  YDBusinessStore.m
//  SaleAnalysis
//
//  Created by 224 on 15/4/13.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDBusinessStore.h"
#import "YDSoapAndXmlParseUtil.h"
#import "GDataXMLNode.h"
#import "YDBusinessName.h"

@interface YDBusinessStore ()<NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *data;

@end

@implementation YDBusinessStore

+ (instancetype)sharedBusinessStore {
    static YDBusinessStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    
    return sharedStore;
}

- (BOOL)comPareDate:(NSDate *)currentDate
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDate *oldDate=[defaults objectForKey:@"businessDate"];
    if (oldDate) {
        NSTimeInterval firstDate=[oldDate timeIntervalSince1970]*1;
        
        NSTimeInterval secondDate=[currentDate timeIntervalSince1970];
        
        if (secondDate - firstDate < 60*60*24) {
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


- (void)getBusinessSOAP:(NSString *)timeStamp {
    NSString *serverHost=[YDSoapAndXmlParseUtil serverHostFromLocal];
    NSString *soapMessage;
    
    soapMessage=[NSString stringWithFormat:
                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\">"
                 "<soap:Header>\n"
                 "<ns1:authenticationtoken ns1:userId='%@' ns1:clientId='%@'>"//设置首部验证
                 "</ns1:authenticationtoken>"
                 "</soap:Header>\n"
                 "<soap:Body>\n"
                 "<ns1:busGetBusinessNameList>"
                 "<ns1:timestamp>%@</ns1:timestamp>"
                 "</ns1:busGetBusinessNameList>"
                 "</soap:Body>\n"
                 "</soap:Envelope>",serverHost,@"3969710895845681630",@"3452",timeStamp];
    NSString *address=[serverHost stringByAppendingPathComponent:@"services/authorization?wsdl"];
    NSString *soapAction=[serverHost stringByAppendingPathComponent:@"services/authorization"];
    NSURL *url=[NSURL URLWithString:address];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
    //设置首部
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *msgLength=[NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    //如果连接已经建立，初始化data
    if (connection) {
        self.data=[NSMutableData data];
    }else{
        NSLog(@"theConnection is NULL");
    }

}

#pragma mark - conection data delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDate *date=[NSDate date];
    [defaults setObject:date forKey:@"businessDate"];
    NSString *businessResults=[YDSoapAndXmlParseUtil responseXML:self.data methodName:@"busGetBusinessNameList"];
    
    [defaults synchronize];

    NSMutableArray *businessArray=[self saveBusinessInfoToSQLite:businessResults];
    
    if (businessArray != nil && [businessArray count] > 0) {
        if ([self.businessDelegate respondsToSelector:@selector(passBusinessArray:)]) {
            [self.businessDelegate passBusinessArray:businessArray];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示@"
                                                        message:@"对不起，您的版本已过期，当前请求无效!"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

- (NSMutableArray *)saveBusinessInfoToSQLite:(NSString *)businessResults {
    NSMutableArray *soapArray=[[NSMutableArray alloc] init];
    NSError *err;
    GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithXMLString:businessResults options:0 error:&err];
    if (doc!=nil) {
        GDataXMLElement *rootNode=[doc rootElement];
        NSArray *rows=[rootNode children];
        for (GDataXMLElement *row in rows) {
            NSArray *childs=[row children];
            YDBusinessName *business=[[YDBusinessName alloc] init];
            for (int i =0; i<[childs count]; i++) {
                GDataXMLElement *child=[childs objectAtIndex:i];
                switch (i) {
                    case 0:
                        business.code=[child stringValue];
                        break;
                    case 1:
                        business.inputCode=[child stringValue];
                        break;
                    case 2:
                        business.name=[child stringValue];
                        break;
                    case 3:
                        business.type=[child stringValue];
                        break;
                    default:
                        break;
                }
                
            }
            [soapArray addObject:business];
        }
    }
    
    return soapArray;

}

- (NSString *)plistPath
{
    //建立文件管理
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //找到Documents文件所在的路径
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //取得第一个Documents文件夹的路径
    
    NSString *filePath = [path objectAtIndex:0];
    
    //把TestPlist文件加入
    
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"business.plist"];
    //开始创建文件
    if (![fm fileExistsAtPath:plistPath] ) {
        [fm createFileAtPath:plistPath contents:nil attributes:nil];
    }
    return plistPath;
}

- (void)archivedData:(id)object forCode:(NSString *)code
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

- (id)unarchivedData:(NSString *)code
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:[self plistPath]];
    NSData *data=[dict objectForKey:code];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
}

- (void)removePath
{
    NSString *plistPath=[self plistPath];
    NSFileManager *fm=[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:plistPath]) {
        [fm removeItemAtPath:plistPath error:nil];
    }
}


@end
