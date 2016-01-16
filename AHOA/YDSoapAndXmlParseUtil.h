//
//  YDSoapAndXmlParseUtil.h
//  hnOA
//
//  Created by 224 on 14-6-24.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YDSoapAndXmlParseUtil;

enum {
    kUserLogin = 0,
    kUserBind,
    kBusGetMenuList,
    kBusPersonInfo,
    kUserRebind,
    kBusGetSaleAnaylse
};

@interface YDSoapAndXmlParseUtil : NSObject <NSURLConnectionDataDelegate>



@property (strong, nonatomic) NSMutableData *data;
//soap请求
+ (NSMutableDictionary *)requestToWsdl:(NSInteger)methodName loginCode:(NSString *)userName
                         loginPassword:(NSString *)userPassword;

//获取返回的xml
+ (NSString *)responseXML:(NSData *)data methodName:(NSString *)name;

//xml转换成Array
+ (NSMutableDictionary *)XmlToDictionary:(id)xml;

//从应用程序获取serverhost地址
+ (NSString *)serverHostFromLocal;

//判断用户是否登陆过
+ (BOOL)isFirstLogin;

@end;
