//
//  NSString+urlExtension.h
//  YNOA
//
//  Created by 224 on 15/4/9.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    MIMEOFDOC,
    MIMEOFDOCX,
    MIMEOFXLSX,
    MIMEOFXLS,
    MIMEOFRAR
}MIMETYPE;

@interface NSString (urlExtension)

- (BOOL)isFileURLString;

- (NSInteger)suffix;

@end
