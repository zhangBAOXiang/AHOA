//
//  MTMagnifyView.h
//  magnifyScroll
//
//  Created by apple on 14-1-15.
//  Copyright (c) 2014年 mt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTMagnifyView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

- (void)addSubview2:(UIView *)view;
- (void)zoomScale: (CGFloat)scale;
- (UIView*)contentView;

@end
