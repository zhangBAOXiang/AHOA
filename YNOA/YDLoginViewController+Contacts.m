//
//  YDLoginViewController+Contacts.m
//  YNOA
//
//  Created by 224 on 15/7/19.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDLoginViewController+Contacts.h"

@implementation YDLoginViewController (Contacts)

- (void)busPersonInfo
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    YDAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    NSString *serverHost=[YDSoapAndXmlParseUtil serverHostFromLocal];
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
                 "<ns1:busPersoninfo />"
                 "</soap:Body>\n"
                 "</soap:Envelope>",serverHost,channelid,[defaults valueForKey:@"personid"]];
    
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
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}


#pragma mark - conection data delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data=[NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *returnString=[YDSoapAndXmlParseUtil responseXML:self.data methodName:@"busPersoninfo"];
    [defaults removeObjectForKey:@"personInfoString"];
    [defaults setValue:returnString forKey:@"personInfoString"];
    [defaults synchronize];
    [YDSqliteUtil savePersonInfoFromRemote];
    [YDSqliteUtil saveDepartment];
}


@end
