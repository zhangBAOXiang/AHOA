//
//  YDOperation.m
//  YNOA
//
//  Created by 224 on 14-11-3.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDOperation.h"
#import "YDAppDelegate.h"
#import "YDSoapAndXmlParseUtil.h"
#import "YDSaleStore.h"

@implementation YDOperation

@synthesize webData;
@synthesize soapResults;
@synthesize recordResults;
@synthesize currentCode;

- (void)getSaleAnaylseSOAP:(NSString *)code tobaRange:(NSString *)range showType:(NSString *)type
{
    NSString *serverHost=[YDSoapAndXmlParseUtil serverHostFromLocal];
    YDAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *soapMessage;
    NSString *channelid;
    NSString *userid;
    if ([defaults valueForKey:@"channelid"]) {
        channelid=[defaults valueForKey:@"channelid"];
        userid=[defaults valueForKey:@"userid"];
    }else{
        channelid=delegate.channelid;
        userid=delegate.userid;
    }
    soapMessage=[NSString stringWithFormat:
                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\">"
                 "<soap:Header>\n"
                 "<ns1:authenticationtoken ns1:userId='%@' ns1:clientId='%@'>"//设置首部验证
                 "</ns1:authenticationtoken>"
                 "</soap:Header>\n"
                 "<soap:Body>\n"
                 "<ns1:busGetSaleAnaylse>"
                 "<ns1:code>%@</ns1:code>"
                 "<ns1:tobaRange>%@</ns1:tobaRange>"
                 "<ns1:showType>%@</ns1:showType>"
                 "</ns1:busGetSaleAnaylse>"
                 "</soap:Body>\n"
                 "</soap:Envelope>",serverHost,channelid,[defaults valueForKey:@"personid"],code,range,type];
    NSString *address=[serverHost stringByAppendingPathComponent:@"services/authorization?wsdl"];
    NSString *soapAction=[serverHost stringByAppendingPathComponent:@"services/authorization"];
    NSURL *url=[NSURL URLWithString:address];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
    //设置首部
    [request addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *msgLength=[NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    //如果连接已经建立，初始化data
    if (connection) {
        webData=[NSMutableData data];
        currentCode=code;
    }else{
        NSLog(@"theConnection is NULL");
    }
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength:0];
    NSLog(@"connection: didReceiveResponse:1");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
    NSLog(@"connection: didReceiveData:2");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"3 DONE. Received Bytes: %d", [webData length]);
//    NSString *theXML=[[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length]
//                                            encoding:NSUTF8StringEncoding];
//    NSLog(@"theXML is %@",theXML);

    soapResults=[YDSoapAndXmlParseUtil responseXML:webData methodName:@"busGetSaleAnaylse"];
    NSMutableArray *soapArray=[YDSaleStore saveSaleInfoToSQLite:soapResults];
    if ([self.soapDelegate respondsToSelector:@selector(passSoapArray:forCode:)]) {
        [self.soapDelegate passSoapArray:soapArray forCode:currentCode];
    }
}

@end
