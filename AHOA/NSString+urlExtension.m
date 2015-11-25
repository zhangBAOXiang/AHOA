//
//  NSString+urlExtension.m
//  YNOA
//
//  Created by 224 on 15/4/9.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "NSString+urlExtension.h"

@implementation NSString (urlExtension)

//判断当前字符串是否以.doc或.结尾
- (BOOL)isFileURLString {
    if ([self hasSuffix:@".doc"] || [self hasSuffix:@".docx"] ||[self hasSuffix:@".xlsx"] || [self hasSuffix:@"xls"]) {
        return YES;
    }
    return NO;
}

- (NSInteger)suffix {
    if ([self hasSuffix:@".doc"]) {
        return MIMEOFDOC;
    } else if([self hasSuffix:@".docx"]) {
        return MIMEOFDOCX;
    } else if([self hasSuffix:@".xlsx"]) {
        return MIMEOFXLSX;
    } else if([self hasSuffix:@".xls"]){
        return MIMEOFXLS;
    } else {
        return MIMEOFRAR;
    }
}

@end
