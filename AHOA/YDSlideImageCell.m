//
//  YDSlideImageCell.m
//  AHOA
//
//  Created by Zhang-mac on 16/1/5.
//  Copyright © 2016年 zoomlgd. All rights reserved.
//

#import "YDSlideImageCell.h"

@interface YDSlideImageCell()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,strong) NSArray *adShops;

@end

@implementation YDSlideImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.pageCount = self.adShops.count;
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 125);
        [self initScrollView];
    }
    return self;
}

//顶部自动滑动图片
- (NSArray *)adShops{
    if (_adShops == nil) {
        _adShops = [[NSArray alloc] initWithObjects:@"ad1",@"ad2",@"ad3", nil];
    }
    return _adShops;
}
- (void)initScrollView{
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 130;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,width,height)];
    
    self.scrollView.contentSize = CGSizeMake(width * self.pageCount,height);
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.contentView addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, height - 20, width, 20)];
    self.pageControl.center = CGPointMake(self.contentView.frame.size.width/2, height - 20);
    self.pageControl.numberOfPages = self.pageCount;
    self.pageControl.currentPage = 0;
    [self.contentView addSubview:self.pageControl];
    
    
    for (int i = 0; i < self.pageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",self.adShops[i]]]];
        [self.scrollView addSubview:imageView];
    }
    [self addTimer];
}

- (void)nextImage{
    NSInteger page = (NSInteger)self.pageControl.currentPage;
    if (page == (self.pageCount -1)) {
        page =0;
    }else{
        page++;
    }
    
    CGFloat x = page *self.scrollView.frame.size.width;
    self.scrollView.contentOffset = CGPointMake(x, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat scrollViewW = self.scrollView.frame.size.width;
    CGFloat x = scrollView.contentOffset.x;
    
    NSInteger page = (x + scrollViewW / 2)/scrollViewW;
    self.pageControl.currentPage = page;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self removeTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self addTimer];
}
- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
}

- (void)removeTimer{
    [self.timer invalidate];
}


//



@end
