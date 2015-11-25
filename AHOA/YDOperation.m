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
#import "YDSaleStockStore.h"

@interface YDOperation ()
{
    BOOL currentIsStock;
    NSString *_soapResults;
}

@end

@implementation YDOperation

@synthesize webData;
@synthesize currentCode;
@synthesize showType;

- (void)getSaleAnaylseSOAP:(NSString *)code tobaRange:(NSString *)range showType:(NSString *)type
{
    currentIsStock = NO;
    _soapResults = @"";
    
    NSString *serverHost=[YDSoapAndXmlParseUtil serverHostFromLocal];
    YDAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *soapMessage;
    NSString *channelid;
    NSString *userid;
    if (delegate.channelid != nil && delegate.channelid.length > 0) {
        channelid = delegate.channelid;
        userid = delegate.userid;
    }else{
        channelid = [defaults valueForKey:@"deviceUUID"];
        userid = [defaults valueForKey:@"deviceUUID"];
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

- (void)getProSaleStockWithType:(NSString *)type {
    
    currentIsStock = YES;
    _soapResults = @"";
    
    NSString *serverHost=[YDSoapAndXmlParseUtil serverHostFromLocal];
    YDAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *soapMessage;
    NSString *channelid;
    NSString *userid;
    if (delegate.channelid != nil && delegate.channelid.length > 0) {
        channelid = delegate.channelid;
        userid = delegate.userid;
    }else{
        channelid = [defaults valueForKey:@"deviceUUID"];
        userid = [defaults valueForKey:@"deviceUUID"];
    }
    if (type == nil) {
        soapMessage=[NSString stringWithFormat:
                     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                     "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\">"
                     "<soap:Header>\n"
                     "<ns1:authenticationtoken ns1:userId='%@' ns1:clientId='%@'>"//设置首部验证
                     "</ns1:authenticationtoken>"
                     "</soap:Header>\n"
                     "<soap:Body>\n"
                     "<ns1:getProSaleStock>"
                     "</ns1:getProSaleStock>"
                     "</soap:Body>\n"
                     "</soap:Envelope>",
                     serverHost,channelid,[defaults valueForKey:@"personid"]];
    }else {
        NSLog(@"enter--------------");
        soapMessage=[NSString stringWithFormat:
                     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                     "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\">"
                     "<soap:Header>\n"
                     "<ns1:authenticationtoken ns1:userId='%@' ns1:clientId='%@'>"//设置首部验证
                     "</ns1:authenticationtoken>"
                     "</soap:Header>\n"
                     "<soap:Body>\n"
                     "<ns1:getProSaleStockInOut>"
                     "<ns1:showType>%@</ns1:showType>"
                     "</ns1:getProSaleStockInOut>"
                     "</soap:Body>\n"
                     "</soap:Envelope>",
                     serverHost,channelid,[defaults valueForKey:@"personid"],type];
    }
    
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
        showType = type;
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

    if (currentIsStock) {
        if (showType == nil) {
            _soapResults=[YDSoapAndXmlParseUtil responseXML:webData methodName:@"getProSaleStock"];
        }else {
            _soapResults=[YDSoapAndXmlParseUtil responseXML:webData methodName:@"getProSaleStockInOut"];

        }

        
        NSMutableArray *soapArray=[YDSaleStockStore saveSaleInfoToSQLite:_soapResults];
        if ([self.soapDelegate respondsToSelector:@selector(passSoapArray:showType:)]) {
            [self.soapDelegate passSoapArray:soapArray showType:showType];
        }
    }else {
        _soapResults=[YDSoapAndXmlParseUtil responseXML:webData methodName:@"busGetSaleAnaylse"];
        NSMutableArray *soapArray=[YDSaleStore saveSaleInfoToSQLite:_soapResults];
        if ([self.soapDelegate respondsToSelector:@selector(passSoapArray:forCode:)]) {
            [self.soapDelegate passSoapArray:soapArray forCode:currentCode];
        }
    }
}

@end
