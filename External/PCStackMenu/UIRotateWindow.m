//
//  UIRotateWindow.m
//  platform
//
//  Created by apple on 13-10-22.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import "UIRotateWindow.h"
#define degreesToRadian(x)(M_PI * (x) / 180.0)

@implementation UIRotateWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void) addSubview:(UIView *)view
{
    float angle = 0;
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"UIDeviceOrientationLandscapeLeft");
        angle = 90;
    } else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        NSLog(@"UIDeviceOrientationLandscapeRight");
        angle = -90;
    } else if([UIDevice currentDevice].orientation ==  UIInterfaceOrientationPortrait) {
        NSLog(@"UIDeviceOrientationPortrait");
        angle = 90;
    } else if([UIDevice currentDevice].orientation ==  UIInterfaceOrientationPortraitUpsideDown) {
        NSLog(@"UIDeviceOrientationPortraitUpsideDown");
        angle = -90;
    } else {
        NSLog(@"unknown");
        angle = -90;
    }
    view.transform = CGAffineTransformMakeRotation(degreesToRadian(angle));
    view.frame = CGRectOffset(self.frame, 0, 0);
    [super addSubview:view];
}

@end
