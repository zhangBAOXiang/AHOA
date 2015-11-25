//
//  YDSlipCell.m
//  YNOA
//
//  Created by 224 on 14-9-5.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSlipCell.h"
#import "YDMenuStore.h"

#define RMarginX 10
#define RMarginY 8
#define RStartTag 100
#define RCellHeight 90
static NSString *ImageCellIdentifier1=@"imageCellIdentifier1";
static NSString *ImageCellIdentifier2=@"imageCellIdentifier2";

@interface YDSlipCell()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollview;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (assign, nonatomic) BOOL pageControlUsed;

@end

@implementation YDSlipCell

//用于storyboard,则需用initWithCoder,initWithStyle不调用,谨记!*
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        self.menuArray=[YDMenuStore queryMenu];
        self.menuArray = [self.menuArray sortedArrayUsingComparator:^NSComparisonResult(YDMenu *obj1, YDMenu *obj2) {
            return [obj1.orderTag integerValue] > [obj2.orderTag integerValue];
        }];
        
        for (int i = 0; i < [self.menuArray count]; i++) {
            YDMenu *menu=self.menuArray[i];
            if ([menu.menuName isEqualToString:@"通   知"]) {
                [defaults setInteger:i forKey:@"defaultMain"];
                [defaults setValue:menu.url forKey:@"defaultMainURL"];
                [defaults synchronize];
                break;
            }
        }
        
        [defaults removeObjectForKey:@"menuItems"];
        [defaults setValue:[NSKeyedArchiver archivedDataWithRootObject:self.menuArray] forKey:@"menuItems"];
        [defaults synchronize];
        
        NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
        [center removeObserver:self name:@"menuList" object:nil];
        [center addObserver:self selector:@selector(menuListChanged:) name:@"menuList" object:nil];
        
        //初始化scrollview
        self.scrollview=[[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollview.showsHorizontalScrollIndicator=NO;
        self.scrollview.showsVerticalScrollIndicator=NO;
        self.scrollview.pagingEnabled=YES;
        //可以滚动的大小
        self.scrollview.contentSize=CGSizeMake(self.scrollview.frame.size.width*2, self.scrollview.frame.size.height);
        self.scrollview.scrollsToTop=NO;
        self.scrollview.delegate=self;
        self.scrollview.directionalLockEnabled=YES;
        
        //设置tableview
        self.tableview=[[UITableView alloc] initWithFrame:self.frame];
        self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
        self.tableview.allowsSelection=NO;
        self.tableview.scrollEnabled=NO;
        [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:ImageCellIdentifier1];
        self.tableview.tag=1000;//区分两个tableview
        self.tableview.delegate=self;
        self.tableview.dataSource=self;
        self.tableview.backgroundColor=[UIColor clearColor];
        
        [self.scrollview addSubview:self.tableview];
        
        //第二个tableview
        self.anotherTableView=[[UITableView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        self.anotherTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        self.anotherTableView.allowsSelection=NO;
        self.tableview.scrollEnabled=NO;
        [self.anotherTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ImageCellIdentifier2];
        self.anotherTableView.delegate=self;
        self.anotherTableView.dataSource=self;
        self.anotherTableView.tag=1001;
        self.anotherTableView.backgroundColor=[UIColor clearColor];
        
        [self.scrollview addSubview:self.anotherTableView];
        self.scrollview.backgroundColor=[UIColor clearColor];
        
        //初始化pagecontrol
        self.pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 5)];
        self.pageControl.center = CGPointMake(self.center.x-60, 183);
        self.pageControl.currentPageIndicatorTintColor=[UIColor blackColor];
        self.pageControl.pageIndicatorTintColor=[UIColor grayColor];
        self.pageControl.hidesForSinglePage=YES;
        self.pageControl.userInteractionEnabled=NO;
        
        //页数设置
        if ([self.menuArray count]>8) {
            self.pageControl.numberOfPages=2;
        }else{
            self.pageControl.numberOfPages=1;
            [self.anotherTableView removeFromSuperview];
            self.scrollview.contentSize=CGSizeMake(self.scrollview.frame.size.width, self.scrollview.frame.size.height);
        }
        
        [self.contentView addSubview:self.scrollview];
        [self.contentView addSubview:self.pageControl];
        
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth=[UIScreen mainScreen].bounds.size.width;
    NSInteger width=cellWidth/RColCount;
    
    if (tableView == [self.scrollview viewWithTag:1000]) {
        //1--8
        UITableViewCell *cell1=[tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier1];
        if (cell1 == nil) {
            cell1=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImageCellIdentifier1];
        }
        if ([self.menuArray count] == 1) {
            //判断菜单返回为空的情况
            if (indexPath.row == 0) {
                cell1.imageView.image=[UIImage imageNamed:@"about_info.png"];
                cell1.textLabel.font=[UIFont systemFontOfSize:18];
                cell1.textLabel.text=@"您的权限不足";
            }else{
                YDImageButton *btn=[[YDImageButton alloc] init];
                btn.frame=CGRectMake(RMarginX, RMarginY, width-2*RMarginX, RCellHeight-2*RMarginY);
                btn.tag=RStartTag+[self.menuArray count];
                [btn setImage:[UIImage imageNamed:@"Settings.png"] forState:UIControlStateNormal];
                [btn setTitle:@"设置" forState:UIControlStateNormal];
                [btn setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor clearColor]];
                [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [cell1.contentView addSubview:btn];
            }
            
        }else{
            //菜单选项不为空
            for (NSInteger i=0; i<RColCount; i++) {
                YDImageButton *btn=[[YDImageButton alloc] init];
                btn.frame=CGRectMake(i*width+RMarginX, RMarginY, width-2*RMarginX, RCellHeight-2*RMarginY);
                btn.tag=RStartTag+i+indexPath.row*RColCount;
                
                int index=i+indexPath.row*RColCount;
                //菜单项小于四个，需要判断
                if (index < [self.menuArray count]) {
                    YDMenu *menu=[self.menuArray objectAtIndex:index];
                    NSString *title=menu.menuName;
                    
                    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:[YDMenuStore imagePath]];
                    NSData *data=[dict objectForKey:menu.image];
                    if (data) {
                        menu.Img = [UIImage imageWithData:data];
                        [btn setImage:menu.Img forState:UIControlStateNormal];
                    }else {
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            NSString *imageURL=[[YDMenuStore imageURL] stringByAppendingString:menu.image];
                            NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                            //存储图片
                            NSString *path = [YDMenuStore imagePath];
                            NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:path];
                            if (dict == nil) {
                                dict=[NSMutableDictionary dictionary];
                            }
                            [dict setObject:data forKey:menu.image];
                            [dict writeToFile:path atomically:YES];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                menu.Img = [UIImage imageWithData:data];
                                [btn setImage:menu.Img forState:UIControlStateNormal];
                            });
                            
                        });
                    }
                    
                    [btn setTitle:title forState:UIControlStateNormal];
                    [btn setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
                    [btn setBackgroundColor:[UIColor clearColor]];
                    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    [cell1.contentView addSubview:btn];
                }
            }

        }
        cell1.backgroundColor=[UIColor clearColor];
        return cell1;
    
    }else{
        //9--16
        UITableViewCell *cell2=[tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier2];
        if (cell2 == nil) {
            cell2=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImageCellIdentifier2];
        }
        for (NSInteger i=0; i<RColCount; i++) {
            YDImageButton *btn=[[YDImageButton alloc] init];
            btn.frame=CGRectMake(i*width+RMarginX, RMarginY, width-2*RMarginX, RCellHeight-2*RMarginY);
            btn.tag=RStartTag+i+indexPath.row*RColCount+8;
            
            int index=i+indexPath.row*RColCount+8;//第二页的图标index
            if (index <[self.menuArray count]) {
                YDMenu *menu=[self.menuArray objectAtIndex:index];
                NSString *title=menu.menuName;
                
                NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:[YDMenuStore imagePath]];
                NSData *data=[dict objectForKey:menu.image];
                if (data) {
                    menu.Img = [UIImage imageWithData:data];
                    [btn setImage:menu.Img forState:UIControlStateNormal];
                }else {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        NSString *imageURL=[[YDMenuStore imageURL] stringByAppendingString:menu.image];
                        NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                        //存储图片
                        NSString *path = [YDMenuStore imagePath];
                        NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:path];
                        if (dict == nil) {
                            dict=[NSMutableDictionary dictionary];
                        }
                        [dict setObject:data forKey:menu.image];
                        [dict writeToFile:path atomically:YES];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            menu.Img = [UIImage imageWithData:data];
                            [btn setImage:menu.Img forState:UIControlStateNormal];
                        });
                        
                    });
                }
                
                [btn setTitle:title forState:UIControlStateNormal];
                [btn setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor clearColor]];
                [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [cell2.contentView addSubview:btn];
            }
        }
        cell2.backgroundColor=[UIColor clearColor];
        return cell2;
    }
}

- (void)buttonTapped:(YDImageButton *)sender
{
    int index=sender.tag-RStartTag;
    if (index < [self.menuArray count]) {
        YDMenu *selectedMenu=[self.menuArray objectAtIndex:(sender.tag-RStartTag)];
        if ([selectedMenu.menuName isEqualToString:@"设置"]) {
            self.selectedURL=nil;
        }
        else if([selectedMenu.menuName isEqualToString:@"销售分析"]){
            self.selectedURL=@"Anaylse";
        }
        else{
            self.selectedURL=selectedMenu.url;
        }

    }else{
        self.selectedURL=nil;
    }
    [_cellDelegate productCell:self actionWithFlag:sender.tag];
}

#pragma mark - scrollview delegata method

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //当前第几个视图
    int index=fabs(self.scrollview.contentOffset.x)/self.scrollview.frame.size.width;
    self.pageControl.currentPage=index;
}

- (void)menuListChanged:(NSNotification *)notification
{
    self.menuArray=[YDMenuStore queryMenu];
    [self.tableview reloadData];
    [self.anotherTableView reloadData];
}

@end
