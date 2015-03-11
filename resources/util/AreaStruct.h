//
//  AreaStruct.h
//  platform
//
//  Created by apple on 13-12-11.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AreaStruct : NSObject

@property(strong, nonatomic) NSDictionary* provDict;
@property(strong, nonatomic) NSDictionary* cityDict;

- (NSString *) getProvCode: (NSString*)provName;
- (NSString *) getCityCode: (NSString*)cityName;

@end
