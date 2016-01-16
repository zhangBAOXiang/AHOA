//
//  YDFunctionMenuCell.m
//  AHOA
//
//  Created by Zhang-mac on 15/12/8.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDFunctionMenuCell.h"
#import "YDImageButton.h"
#import "YDMenuStore.h"
#import "YDMenu.h"
#define RMarginX 5
#define RMarginY 5
#define RStartTag 100
#define RCellHeight 100
#define RHeight 100

static NSString *ImageCellIdentifier=@"UITableViewCell";
@interface YDFunctionMenuCell()

@property (nonatomic,strong) UIScrollView *scrollview;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (assign, nonatomic) BOOL pageControlUsed;

@end

@implementation YDFunctionMenuCell

//用于storyboard,则需用initWithCoder,initWithStyle不调用,谨记!*非常重要
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400);
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
        self.frame = self.bounds;
        //设置tableview
        self.tableview=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
        self.tableview.allowsSelection=NO;
        self.tableview.scrollEnabled=NO;
        [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:ImageCellIdentifier];
        self.tableview.tag=1000;//区分两个tableview
        self.tableview.delegate=self;
        self.tableview.dataSource=self;
        self.tableview.backgroundColor=[UIColor clearColor];
        //self.tableview.rowHeight = [UIScreen mainScreen].bounds.size.width / ColCount  * 10 / 8;
        
        [self addSubview:self.tableview];
        self.backgroundColor=[UIColor clearColor];
        [self initMenuAllArray];
        [self initScroll];
        [self initPageControll];
        if (self.menuArray.count > 12 && self.menuArray.count < 25) {
            self.pageControl.numberOfPages=2;
            //第二个tableview
            self.anotherTableView=[[UITableView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width,0 , self.frame.size.width, self.frame.size.height)];
            self.anotherTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            self.anotherTableView.allowsSelection=NO;
            self.tableview.scrollEnabled=NO;
            [self.anotherTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ImageCellIdentifier];
            self.anotherTableView.delegate=self;
            self.anotherTableView.dataSource=self;
            self.anotherTableView.tag=1001;
            self.anotherTableView.backgroundColor=[UIColor clearColor];
            //self.anotherTableView.rowHeight = [UIScreen mainScreen].bounds.size.width / ColCount * 10 / 8;
            
            [self.scrollview addSubview:self.anotherTableView];
            
        }else{
        
            self.pageControl.numberOfPages=1;
             //PageControl.Pages[i].TabVisible := False
            //self.pageControl.
            //[self.anotherTableView removeFromSuperview];
            //self.scrollview.contentSize=CGSizeMake(self.scrollview.frame.size.width, self.scrollview.frame.size.height);
        }
        
        
            [self addSubview:self.scrollview];
            [self addSubview:self.pageControl];
    }
    return self;

}
- (void)initScroll{
    //初始化scrollview
    self.scrollview=[[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollview.showsHorizontalScrollIndicator=NO;
    self.scrollview.showsVerticalScrollIndicator=NO;
    self.scrollview.pagingEnabled=YES;
    //可以滚动的大小
    int pageCount = 1;
    if (self.menuArray.count > 12) {
        pageCount = 2;
    }
    self.scrollview.contentSize=CGSizeMake(self.scrollview.frame.size.width*pageCount, self.scrollview.frame.size.height);
    self.scrollview.scrollsToTop=NO;
    self.scrollview.delegate=self;
    self.scrollview.directionalLockEnabled=YES;
    self.scrollview.backgroundColor=[UIColor clearColor];
    [self.scrollview addSubview:self.tableview];
}


- (void)initPageControll{
    //初始化pagecontrol
    self.pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    self.pageControl.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2,(self.menuAllArray.count/4 +1)*([UIScreen mainScreen].bounds.size.width / 4));
    
    self.pageControl.currentPageIndicatorTintColor=UIColorFromRGB(0xEAEAEA);
    //self.pageControl.pageIndicatorTintColor=[UIColor grayColor];
    self.pageControl.hidesForSinglePage=NO;
    
    self.pageControl.userInteractionEnabled=NO;
}

- (void)initMenuAllArray{
    self.menuAllArray = [[NSArray alloc] initWithObjects:@"销售分析.png",@"营销动态.png",@"通知.png",@"公告.png",@"账款公告.png",@"群众路线.png",@"学习参考.png",@"会议纪要.png",@"规章制度.png",@"设置.png",@"订单查询.png",@"物料审批.png",nil];
    self.menuCodeArray = [[NSArray alloc] initWithObjects:@"999999998",@"8802",@"8800",@"8801",@"8803",@"8804",@"8805",@"8806",@"8807",@"999999999",@"8809",nil];
    
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount =[self.menuArray count] / ColCount + 1;
    
        return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIScreen mainScreen].bounds.size.width  / 4 ;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth=[UIScreen mainScreen].bounds.size.width;
    NSInteger width = cellWidth/ColCount;
    //CGFloat cellheight = ([UIScreen mainScreen].bounds.size.width - 20) / 3;
    if(tableView == [self.scrollview viewWithTag:1000]){
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier];
        if (cell == nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImageCellIdentifier];
        }
    
    
        if ([self.menuArray count] == 1) {
            //判断菜单返回为空的情况
            if (indexPath.row == 0) {
                cell.imageView.image=[UIImage imageNamed:@"about_info.png"];
                cell.textLabel.font=[UIFont systemFontOfSize:18];
                cell.textLabel.text=@"您的权限不足";
            }else{
                YDImageButton *btn=[[YDImageButton alloc] init];
                btn.frame=CGRectMake(RMarginX, RMarginY, width-2*RMarginX, RCellHeight-2*RMarginY);
                btn.tag=RStartTag+[self.menuArray count];
                btn.tag=RStartTag+[self.menuArray count];
                [btn setImage:[UIImage imageNamed:@"Settings.png"] forState:UIControlStateNormal];
                [btn setTitle:@"设置" forState:UIControlStateNormal];
                [btn setTitleColor:UIColorFromRGB(0x4F4F4F) forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor clearColor]];
                [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn];
            }
        }else{
            //菜单选项不为空
            //判断每行几个图标
            NSInteger menuCount = 0;
            NSInteger tempCount = 0;
            if ((indexPath.row + 1) * ColCount > [self.menuArray count]) {
                menuCount = [self.menuArray count] - indexPath.row * ColCount;
                tempCount = menuCount;
            }else{
                tempCount = ColCount;
            }
            for (NSInteger i=0; i<tempCount; i++) {
                
                YDImageButton *btn=[[YDImageButton alloc] initWithFrame:CGRectMake(width * i, 0, width -1, width  - 1)];
                if (i + 1 < tempCount || tempCount < 4) {
                    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((i+1)*width - 1, 0, 1, width - 1)];
                    lineView.layer.masksToBounds = YES;
                    
                    lineView.backgroundColor = UIColorFromRGB(0xE7E8E9);
                    [cell addSubview:lineView];
                    
                }
                if (i < tempCount || tempCount < 4) {
                    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(i * width, width-1  , width,1)];
                    
                    bottomLineView.backgroundColor = UIColorFromRGB(0xE7E8E9);
                    [cell addSubview:bottomLineView];
                }
                
                btn.tag=RStartTag+i+indexPath.row*ColCount;
                
                int index=i+indexPath.row*ColCount;
                YDMenu *menu=[self.menuArray objectAtIndex:index];
                NSString *title=menu.menuName;
                
                NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:[YDMenuStore imagePath]];
                NSData *data=[dict objectForKey:menu.image];
                if (data) {
                    menu.Img = [UIImage imageWithData:data];
                    //[btn setImage:menu.Img forState:UIControlStateNormal];
                    if ([self.menuCodeArray containsObject:menu.menuCode]) {
                        NSInteger index = [self.menuCodeArray indexOfObject:menu.menuCode];
                        UIImage *img = [UIImage imageNamed:self.menuAllArray[index]];
                        [btn setImage:img forState:UIControlStateNormal];
                    }else{
                        [btn setImage:menu.Img forState:UIControlStateNormal];
                    }
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
                            //[btn setImage:menu.Img forState:UIControlStateNormal];
                            if ([self.menuCodeArray containsObject:menu.menuCode]) {
                                NSInteger index = [self.menuCodeArray indexOfObject:menu.menuCode];
                                UIImage *img = [UIImage imageNamed:self.menuAllArray[index]];
                                [btn setImage:img forState:UIControlStateNormal];
                            }else{
                                [btn setImage:menu.Img forState:UIControlStateNormal];
                            }
                        });
                        
                    });
                }
                
 
                    /*menu.Img = [UIImage imageWithData:data];
                    if ([self.menuCodeArray containsObject:menu.menuCode]) {
                        NSInteger index = [self.menuCodeArray indexOfObject:menu.menuCode];
                        UIImage *img = [UIImage imageNamed:self.menuAllArray[index]];
                        [btn setImage:img forState:UIControlStateNormal];
                    }*/
                    
                
                [btn setTitle:title forState:UIControlStateNormal];
                [btn setTitleColor:UIColorFromRGB(0x4F4F4F)  forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor clearColor]];
                [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn];
                
            }
        }
        cell.backgroundColor=[UIColor clearColor];
        return cell;
    }else{//如果图标大于12个
        UITableViewCell *cell1=[tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier];
        if (cell1 == nil) {
            cell1=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImageCellIdentifier];
        }

        NSInteger menuCount = 0;
        NSInteger tempCount = 0;
        if ((indexPath.row + 1) * ColCount > [self.menuArray count] - 12) {
            menuCount = [self.menuArray count]- 12 - indexPath.row * ColCount;
            tempCount = menuCount;
        }else{
            tempCount = ColCount;
        }
        
        for (NSInteger i=0; i<tempCount; i++) {
            
            YDImageButton *btn=[[YDImageButton alloc] initWithFrame:CGRectMake(width * i, 0, width -1, width  - 1)];
            if (i + 1 < tempCount || tempCount < 4) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((i+1)*width - 1, 0, 1, width - 1)];
                lineView.layer.masksToBounds = YES;
                
                lineView.backgroundColor = UIColorFromRGB(0xE7E8E9);
                [cell1 addSubview:lineView];
                
            }
            if (i < tempCount || tempCount < 4) {
                UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(i * width, width-1  , width,1)];
                
                bottomLineView.backgroundColor = UIColorFromRGB(0xE7E8E9);
                [cell1 addSubview:bottomLineView];
            }
            
            btn.tag=RStartTag+i+indexPath.row*ColCount +12;
            
            int index=i+indexPath.row*ColCount+12;
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
            
            /*menu.Img = [UIImage imageWithData:data];
            if ([self.menuCodeArray containsObject:menu.menuCode]) {
                NSInteger index = [self.menuCodeArray indexOfObject:menu.menuCode];
                UIImage *img = [UIImage imageNamed:self.menuAllArray[index]];
                [btn setImage:img forState:UIControlStateNormal];
            }*/
            
            
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGB(0x4F4F4F)  forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell1.contentView addSubview:btn];
            
        }
        cell1.backgroundColor=[UIColor clearColor];
        return cell1;
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
}

@end
