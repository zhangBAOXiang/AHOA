//
//  YDSoapAndXmlParseUtil.m
//  hnOA
//
//  Created by 224 on 14-6-24.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSoapAndXmlParseUtil.h"
#import "YDAppDelegate.h"
#import "GDataXMLNode.h"

static NSData *responseData;
@implementation YDSoapAndXmlParseUtil

//返回从服务器获取的数据信息
+ (NSMutableDictionary *)requestToWsdl:(NSInteger)methodName loginCode:(NSString *)userName loginPassword:(NSString *)userPassword
{
    YDAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

    NSString *serverHost=[YDSoapAndXmlParseUtil serverHostFromLocal];
    NSString *soapMessage;
    NSString *channelid;
    NSString *userid;
   
    if (delegate.channelid == NULL) {
        if ([defaults valueForKey:@"channelid"]) {
            channelid=[defaults valueForKey:@"channelid"];
            userid=[defaults valueForKey:@"userid"];
        }else{
            if (channelid == NULL) {
                CFUUIDRef puuid = CFUUIDCreate( nil );
                CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
                NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
                CFRelease(puuid);
                CFRelease(uuidString);
                delegate.channelid=result;
                double time=[[NSDate date] timeIntervalSince1970];
                NSString *dateString=[[NSString alloc] initWithFormat:@"%f%d",time,arc4random()+80];
                
                delegate.userid=dateString;
                channelid=result;
                userid=dateString;
                NSLog(@"channelid=%@",channelid);
                NSLog(@"userid=%d",[userid intValue]);
            }

        }
    }else{
        channelid=delegate.channelid;
        userid=delegate.userid;
    }
    
    switch (methodName) {
        case kUserLogin:
            soapMessage=[NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap:Body>\n"
                         "<ns1:userLogin xmlns:ns1=\"%@\">"
                         "<ns1:clientKey>%@</ns1:clientKey>"
                         "<ns1:phoneCode>%d</ns1:phoneCode>"
                         "<ns1:loginCode>%@</ns1:loginCode>"
                         "<ns1:passwrod>%@</ns1:passwrod>"
                         "</ns1:userLogin>"
                         "</soap:Body>\n"
                         "</soap:Envelope>",serverHost,channelid,[userid intValue],userName,userPassword];
            break;
            
        case kUserBind:
            soapMessage=[NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap:Body>\n"
                         "<ns1:userBind xmlns:ns1=\"%@\">"
                         "<ns1:channelId>%@</ns1:channelId>"
                         "<ns1:userId>%d</ns1:userId>"
                         "<ns1:loginCode>%@</ns1:loginCode>"
                         "<ns1:passwrod>%@</ns1:passwrod>"
                         "<ns1:deviceType>%@</ns1:deviceType>"
                         "</ns1:userBind>"
                         "</soap:Body>\n"
                         "</soap:Envelope>",serverHost,channelid,[userid intValue],userName,userPassword,@"4"];
            break;
            
        case kBusGetMenuList:
            soapMessage=[NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\">"
                         "<soap:Header>\n"
                         "<ns1:authenticationtoken>"//设置首部验证
                         "</ns1:authenticationtoken>"
                         "</soap:Header>\n"
                         "<soap:Body>\n"
                         "<ns1:busGetMenuList>"
                         "<ns1:personCode>%@</ns1:personCode>"
                         "</ns1:busGetMenuList>"
                         "</soap:Body>\n"
                         "</soap:Envelope>",serverHost,[defaults valueForKey:@"personid"]];
            break;
            
        case kBusPersonInfo:
            soapMessage=[NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\">"
                         "<soap:Header>\n"
                         "<ns1:authenticationtoken ns1:userId='%@' ns1:clientId='%@'>"//设置首部验证
                         "</ns1:authenticationtoken>"
                         "</soap:Header>\n"
                         "<soap:Body>\n"
                         "<ns1:busPersoninfo />"
                         "</soap:Body>\n"
                         "</soap:Envelope>",serverHost,channelid,[defaults valueForKey:@"personid"]];
            break;
            
        default:
            break;
    }
    
    NSString *address=[serverHost stringByAppendingPathComponent:@"services/authorization?wsdl"];
    NSString *soapAction=[serverHost stringByAppendingPathComponent:@"services/authorization"];
    NSURL *url=[NSURL URLWithString:address];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //设置首部
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *msgLength=[NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
        
    NSError *err=nil;
    
    responseData=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    if (responseData) {
        [dict setValue:err forKey:@"errorMsg"];
        [dict setValue:responseData forKey:@"data"];
    }else{
        dict=nil;
    }

    
    return dict;
    
}

+ (NSString *)responseXML:(NSData *)data methodName:(NSString *)name
{
    NSString *responseXMLResult=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *err=nil;
    GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithXMLString:responseXMLResult options:0 error:&err];
    if (doc==nil) {
        NSLog(@"初始化GDataXMLDocument失败!!!!");
        return nil;
    }
    NSString *resultString;
    GDataXMLElement *root=[doc rootElement];//获取根节点
    NSString *searchStr=[NSString stringWithFormat:@"%@Response",name];
    NSArray *childs=[root children];
    while ([childs count]>0) {
        NSString *nodeName=[[childs objectAtIndex:0] name];
        if ([nodeName isEqualToString:searchStr]) {
            resultString=[[childs objectAtIndex:0] stringValue];
            break;
        }
        childs=[[childs objectAtIndex:0] children];
    }
    
    return resultString;
}

//判断登陆是否成功
+ (NSMutableDictionary *)XmlToDictionary:(id)xml
{
    NSError *err=nil;
    xml=[xml substringFromIndex:38];
//    NSLog(@"xml is %@",xml);
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:&err];
    if (err) {
        NSLog(@"解析出错!!%@",err);
    }
    GDataXMLElement *rootNode=[doc rootElement];
    NSArray *childs=[rootNode children];
    for (GDataXMLElement * child in childs) {
        [dict setObject:[child stringValue] forKey:child.name];
    }
    
    return dict;
}


//从应用程序获得conf.plist文件
+ (NSString *)serverHostFromLocal
{
    NSString *fileName=[[NSBundle mainBundle] pathForResource:@"conf" ofType:@"plist"];
    NSDictionary *dict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        dict=[[NSDictionary alloc] initWithContentsOfFile:fileName];
    }
    
    return [dict valueForKey:@"serverHost"];
}

+ (BOOL)isFirstLogin
{
    BOOL firstLogin=true;//默认为第一次登陆
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"userName"] && [defaults valueForKey:@"password"]) {
//        firstLogin=false;
    }
    return firstLogin;
}


@end
