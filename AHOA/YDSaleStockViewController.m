//
//  YDBusinessViewController.m
//  YNOA
//
//  Created by 224 on 15/9/12.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDSaleStockViewController.h"
#import "YDBaseViewController+ConfigureCell.h"
#import "YDOperation.h"
#import "AHKActionSheet.h"
#import "YDSaleStock.h"

@interface YDSaleStockViewController ()<UITableViewDataSource,UIScrollViewDelegate,UITableViewDelegate,YDSOAPDelegate>

@property (strong, nonatomic) YDOperation *operation;

@property (assign, nonatomic) BOOL isDoubleClick;

@end

@implementation YDSaleStockViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self customTitleView:@"工业产调销" withDateString:[defaults objectForKey:@"stockTitleTime"]];
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x3da8e5)];
    
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self customButton];
    
    self.leftTable.delegate = self;
    self.leftTable.dataSource = self;
    self.rightTable.delegate = self;
    self.rightTable.dataSource = self;
    self.scroll.delegate = self;
    self.leftTable.rowHeight = kHeight;
    self.rightTable.rowHeight = kHeight;
    self.scroll.contentSize = CGSizeMake((kHeadNameCount-1)*kWidth, 0);
    
    self.operation=[[YDOperation alloc] init];
    self.operation.soapDelegate=self;
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=NO;
    
    self.HUD.labelText=@"加载数据..";
    //显示对花框
    [self.HUD show:YES];
    
    [self.operation getProSaleStockWithType:nil];
    self.isDoubleClick = YES;

}

//按钮定制
- (void)customButton
{
    float margin=(self.view.frame.size.width-80*3)/4;
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 120)];
    [self.view addSubview:tabView];
    tabView.backgroundColor = UIColorFromRGB(0x3da8e5);
    
    YDImageButton *btn = [YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(margin, 0, 80, 48)];
    [btn setImage:[UIImage imageNamed:@"shangye.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"shangye02.png"] forState:UIControlStateSelected];
    [btn setTitle:@"商业" forState:UIControlStateNormal];
    //    [btn1 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:@selector(mainTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTag:1000];

    
    YDImageButton *btn1=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn1 setFrame:CGRectMake(2*margin+80, 0, 80, 48)];
    [btn1 setImage:[UIImage imageNamed:@"guanzhu02.png"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"guanzhu02h.png"] forState:UIControlStateSelected];
    [btn1 setTitle:@"企业" forState:UIControlStateNormal];
    //    [btn1 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor clearColor]];
    [btn1 setTag:1001];
    [btn1 setSelected:YES];
    
    YDImageButton *btn3=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn3 setFrame:CGRectMake(3*margin+80*2, 0, 80, 48)];
    [btn3 setImage:[UIImage imageNamed:@"icon_struct.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"icon_struct_select.png"] forState:UIControlStateSelected];
    [btn3 setTitle:@"结构" forState:UIControlStateNormal];
    //    [btn3 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn3 setBackgroundColor:[UIColor clearColor]];
    [btn3 setTag:1003];
    [btn3 addTarget:self action:@selector(stockTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [btn3 setHighlighted:YES];
    
    [tabView addSubview:btn];
    [tabView addSubview:btn1];
    [tabView addSubview:btn3];
}

- (void)mainTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stockTapped:(id)sender {
//    [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    CATransition *animation = [CATransition animation];
    [animation setDuration:1.5];
    [animation setType:kCATransitionFade]; //淡入淡出
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"stockStruct"]
                       animated:NO completion:nil];
    [self.view.layer addAnimation:animation forKey:nil];
}

- (void)passSoapArray:(NSMutableArray *)soapArray showType:(NSString *)showType {
    
    [self.HUD hide:YES];
    self.leftSource = soapArray;
    self.rightSource = soapArray;
    [self.leftTable reloadData];
    [self.rightTable reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifer =@"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifer];
    }
    
    //清楚subviews
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    YDSaleStock *stock = [self.leftSource objectAtIndex:indexPath.row];
    if(tableView == self.rightTable){
        [self configureCell:cell withStock:stock];
    }else {
        UILabel *label = [[UILabel alloc] init];
        [label setText:stock.stockname];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:17.0f];
        //        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.preferredMaxLayoutWidth = cell.bounds.size.width;
        
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    if (![stock.stockid isEqualToString:@"-1"] && self.isDoubleClick) {
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        [tap setNumberOfTapsRequired:2];
        [cell addGestureRecognizer:tap];
    }
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.leftTable) {
        return self.leftSource.count;
    }else{
        return self.rightSource.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTable) {
        [self.rightTable selectRowAtIndexPath:indexPath animated:NO
                               scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.leftTable selectRowAtIndexPath:indexPath animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.leftTable) {
        return kHeight;
    } else {
        return kHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,(kCount-1)*kWidth, kHeight)];
    view.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.4];
    if (tableView == self.rightTable) {
        NSArray *headNames=[[NSArray alloc] initWithObjects: @"本日", @"本年", @"增幅%", @"增量", nil];
       
        for(int i=0;i<headNames.count;i++){
            UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(i*kWidth, 0, kWidth, kHeight)];
//            [btn setBackgroundColor:[UIColor blackColor]];
            [btn setTitle:headNames[i] forState:UIControlStateNormal];
            [btn setUserInteractionEnabled:NO];
            [view addSubview:btn];
        }
        
    }
    else {
        view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,100, kHeight)];
        view.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.4];
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, kHeight)];
//        [btn setBackgroundColor:[UIColor blackColor]];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn setUserInteractionEnabled:NO];
        [view addSubview:btn];
        
    }
    return view;
}

- (void)handleLeft
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *source = [defaults objectForKey:@"stocks"];
    if (source) {
        self.isDoubleClick = YES;
        self.leftSource = self.rightSource = [NSKeyedUnarchiver unarchiveObjectWithData:source];
        [self.leftTable reloadData];
        [self.rightTable reloadData];
        [defaults removeObjectForKey:@"stocks"];
        [defaults synchronize];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)doubleClick:(UITapGestureRecognizer *)recognizer {
    if (self.isDoubleClick) {
        NSIndexPath *indexPath=[self.rightTable indexPathForCell:(UITableViewCell *)recognizer.view];
        [self.rightTable selectRowAtIndexPath:indexPath
                                     animated:NO
                               scrollPosition:UITableViewScrollPositionNone];
        [self.leftTable selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        YDSaleStock *select = [self.leftSource objectAtIndex:indexPath.row];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.leftSource] forKey:@"stocks"];
        [defaults synchronize];
        [self.HUD show:YES];
        self.isDoubleClick = NO;
        [self.operation getProSaleStockWithType:select.stockid];
    }else {
        
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.leftTable || scrollView == self.rightTable) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if(offsetY >= 0) {
            self.leftTable.contentOffset = self.rightTable.contentOffset = scrollView.contentOffset;
        } else {
            CGPoint offSet = CGPointMake(scrollView.contentOffset.x, 0);
            self.leftTable.contentOffset = self.rightTable.contentOffset = offSet;
        }
        
    }
    
    if (scrollView == self.scroll) {
        CGFloat offsetX = scrollView.contentOffset.x;
        if (offsetX <= 0) {
            self.scroll.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
        }
    }
    
}

@end
