//
//  YDImageButton.m
//  YNOA
//
//  Created by Rannie on 14-9-05.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDImageButton.h"

#define RImageHeightPercent 0.7

@implementation YDImageButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.font = [UIFont systemFontOfSize:12.5f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
                self.frame = frame;
        
        
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * RImageHeightPercent;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = contentRect.size.height * RImageHeightPercent;
    CGFloat width = contentRect.size.width;
    CGFloat height = contentRect.size.height * (1 - RImageHeightPercent);
    
    return CGRectMake(x, y, width, height);
}

@end
