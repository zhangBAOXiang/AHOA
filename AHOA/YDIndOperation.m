//
//  YDIndOperation.m
//  AHOA
//
//  Created by 224 on 15/11/15.
//  Copyright © 2015年 zoomlgd. All rights reserved.
//

#import "YDIndOperation.h"
#import "YDSoapAndXmlParseUtil.h"
#import "YDAppDelegate.h"
#import "YDIndSaleStore.h"

@implementation YDIndOperation
{
    NSString *_code;
}

- (void)getIndSaleAnaylseSOAP:(NSString *)code tobaRange:(NSString *)range showType:(NSString *)type {
    
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
                 "<ns1:busGetIndSaleAnaylse>"
                 "<ns1:code>%@</ns1:code>"
                 "<ns1:tobaRange>%@</ns1:tobaRange>"
                 "<ns1:showType>%@</ns1:showType>"
                 "</ns1:busGetIndSaleAnaylse>"
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
        self.webData=[NSMutableData data];
        _code=code;
    }else{
        NSLog(@"theConnection is NULL");
    }

}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.webData setLength:0];
    NSLog(@"connection: didReceiveResponse:1");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.webData appendData:data];
    NSLog(@"connection: didReceiveData:2");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"3 DONE. Received Bytes: %d", [self.webData length]);
    
    NSString *soapResults=[YDSoapAndXmlParseUtil responseXML:self.webData methodName:@"busGetIndSaleAnaylse"];
    NSMutableArray *soapArray=[YDIndSaleStore saveSaleInfoToSQLite:soapResults];
    if ([self.indDelegate respondsToSelector:@selector(passSoapArray:forCode:)]) {
        [self.indDelegate passSoapArray:soapArray forCode:_code];
    }
}


@end
