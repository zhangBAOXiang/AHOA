//
//  YDMenu.h
//  YNOA
//
//  Created by 224 on 14-9-10.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDMenu : NSObject<NSCoding,NSCopying>

@property (copy, nonatomic) NSString *menuCode;
@property (copy, nonatomic) NSString *menuName;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *allowTop;//是否允许定义排列默认
@property (copy, nonatomic) NSString *orderTag;//排列顺序
@property (copy, nonatomic) NSString *version;//版本号,不一致需同步图片
@property (strong, nonatomic) UIImage *Img;

@end
