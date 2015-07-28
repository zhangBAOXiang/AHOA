//
//  MarsLocation.h
//  platform
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MarsLocation : NSObject

+ (CLLocation *)transformToMars:(CLLocation *)location;
+ (BOOL)outOfChina:(CLLocation *)location;
+ (double)transformLatWithX:(double)x y:(double)y;
+ (double)transformLonWithX:(double)x y:(double)y ;

@end
