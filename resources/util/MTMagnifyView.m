//
//  MTMagnifyView.m
//  magnifyScroll
//
//  Created by apple on 14-1-15.
//  Copyright (c) 2014年 mt. All rights reserved.
//

#import "MTMagnifyView.h"

@implementation MTMagnifyView
@synthesize scrollView=_scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.delegate = self;
        
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)addSubview2:(UIView *)view
{
    /*CATiledLayer *layer = (CATiledLayer*)view.layer;
    layer.levelsOfDetail = 4;
    layer.levelsOfDetailBias = 4;
    layer.tileSize = view.frame.size;
    */
    [self.scrollView addSubview:view];
}

- (void)zoomScale: (CGFloat)scale
{
    [self.scrollView setZoomScale:scale];
}

#pragma mark - scroll view
// 实现缩放并居中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    /*CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    [self.webContainer viewWithTag:101].center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
     */
    // NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat zs = scrollView.zoomScale;
    zs = MAX(zs, 1);
    zs = MIN(zs, 2);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    UIView *uv = [self contentView];
    if ([uv isMemberOfClass:[UIWebView class]]) {
        uv.transform = CGAffineTransformMakeScale(zs, zs);
    }
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}


// 返回缩放的那个view
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [_scrollView.subviews objectAtIndex:0];
}

- (UIView*)contentView
{
    return [_scrollView.subviews objectAtIndex:0];
}

@end
