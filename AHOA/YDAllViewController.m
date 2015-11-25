//
//  YDTestViewController.m
//  LZHOA
//
//  Created by 224 on 15/7/9.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDAllViewController.h"
#import "YDOperation.h"
#import "AHKActionSheet.h"
#import "YDBaseViewController+ConfigureCell.h"

@interface YDAllViewController ()<UITableViewDataSource,UIScrollViewDelegate,UITableViewDelegate,YDSOAPDelegate>

@property (strong, nonatomic) YDOperation *operation;

@end

@implementation YDAllViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.yorm = @"year";
    [self customTitleView:@"销售分析(年)" withDateString:nil];
    
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x3da8e5)];
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 50, 63)];
    [rightBtn setImage:[UIImage imageNamed:@"mainseting.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(handleSet) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];

    
    self.leftTable.delegate = self;
    self.leftTable.dataSource = self;
    self.rightTable.delegate = self;
    self.rightTable.dataSource = self;
    self.scroll.delegate = self;
    self.leftTable.rowHeight = kHeight;
    self.rightTable.rowHeight = kHeight;
    self.scroll.contentSize = CGSizeMake((kHeadNameCount-1)*kWidth, 0);
    
    
    YDTabButton *tab1 = [[YDTabButton alloc] init];
    tab1.buttonName = @"品牌";
    tab1.imageName = @"icon_brand.png";
    tab1.selName = @selector(brandTapped:);
    
    YDTabButton *tab2 = [[YDTabButton alloc] init];
    tab2.buttonName = @"企业";
    tab2.imageName = @"guanzhu02.png";
    tab2.selName = @selector(businessTapped:);
    
    YDTabButton *tab3 = [[YDTabButton alloc] init];
    tab3.buttonName = @"市场";
    tab3.imageName = @"icon_market.png";
    tab3.selName = @selector(marketTapped:);
    [self customButtons:@[tab1, tab2, tab3]];
    
    YDTabButton *tab4 = [[YDTabButton alloc] init];
    tab4.buttonName = @"工业";
    tab4.imageName = @"gongye01.png";
    tab4.selName = @selector(indTapped:);
    [self customButtons:@[tab1, tab4, tab2, tab3]];
    
    self.operation=[[YDOperation alloc] init];
    self.operation.soapDelegate=self;
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=NO;
    
    self.HUD.labelText=@"加载数据..";
    //显示对花框
    [self.HUD show:YES];
    
    [self.operation getSaleAnaylseSOAP:@"0,000000" tobaRange:@"0" showType:@"0"];
}

- (void)passSoapArray:(NSMutableArray *)soapArray forCode:(NSString *)code
{
    [self.HUD hide:YES];
    self.leftSource = soapArray;
    self.rightSource = soapArray;
    [self.leftTable reloadData];
    [self.rightTable reloadData];
    
    //更改时间戳
    YDSaleAnaylse *sale = [soapArray firstObject];
    self.timeStamp = sale.datetime;
    [self customTitleView:@"销售分析(年)" withDateString:self.timeStamp];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.timeStamp forKey:@"stockTitleTime"];
    [defaults synchronize];
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
    
    YDSaleAnaylse *sale = [self.leftSource objectAtIndex:indexPath.row];
    if(tableView == self.rightTable){
        [self configureCell:cell withSale:sale];
    }else {
        UILabel *label = [[UILabel alloc] init];
        [label setText:sale.name];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:17.0f];
        //        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.preferredMaxLayoutWidth = cell.bounds.size.width;
        
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    cell.backgroundColor = [UIColor clearColor];
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
    view.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.4];;
    if (tableView == self.rightTable) {
        NSArray *headNames;
        if (self.currentIsSale) {
            headNames=[[NSArray alloc] initWithObjects: @"销量", @"同期", @"增幅%", @"增量", nil];
        }else {
            headNames=[[NSArray alloc] initWithObjects: @"销售额", @"同期", @"增幅%", @"增量", nil];
        }
        for(int i=0;i<headNames.count;i++){
            UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(i*kWidth, 0, kWidth, kHeight)];
            [btn setTitle:headNames[i] forState:UIControlStateNormal];
            [btn setUserInteractionEnabled:NO];
            [view addSubview:btn];
        }
        
    }
    else {
        view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,100, kHeight)];
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, kHeight)];
        view.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.4];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn setUserInteractionEnabled:NO];
        [view addSubview:btn];
        
    }
    return view;
}

- (void)handleLeft
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ActionSheet
- (void)handleSet
{
    AHKActionSheet *sheet = [[AHKActionSheet alloc] initWithTitle:@"显示年或月销量"];
    sheet.cancelButtonTitle = @"取消";
    sheet.buttonTextCenteringEnabled =@(YES);
    [sheet addButtonWithTitle:@"月销量"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          //年销量
                          self.yorm=@"month";
                          self.currentIsSale = YES;
                          [self customTitleView:@"销售分析(月)" withDateString:self.timeStamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"年销量"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"year";
                          self.currentIsSale = YES;
                          [self customTitleView:@"销售分析(年)" withDateString:self.timeStamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"月销售额"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"month";
                          self.currentIsSale = NO;
                          [self customTitleView:@"销售额分析(月)" withDateString:self.timeStamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"年销售额"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"year";
                          self.currentIsSale = NO;
                          [self customTitleView:@"销售额分析(年)" withDateString:self.timeStamp];
                          [self.rightTable reloadData];
                      }];
    
    [sheet show];
    
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

- (void)brandTapped:(id)sender
{
    NSLog(@"brandTapped");
//    [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    CATransition *animation = [CATransition animation];
    [animation setDuration:1.5];
    [animation setType:kCATransitionFade]; //淡入淡出
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"brandanaylse"]
                       animated:NO completion:nil];
    [self.view.layer addAnimation:animation forKey:nil];
}

- (void)businessTapped:(id)sender {
//    [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    CATransition *animation = [CATransition animation];
    [animation setDuration:1.5];
    [animation setType:kCATransitionFade]; //淡入淡出
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"saleStock"]
                       animated:NO completion:nil];
    [self.view.layer addAnimation:animation forKey:nil];
}

- (void)marketTapped:(id)sender
{
    NSLog(@"marketTapped");
//    [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    CATransition *animation = [CATransition animation];
    [animation setDuration:1.5];
    [animation setType:kCATransitionFade]; //淡入淡出
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"marketanaylse"]
                       animated:NO completion:nil];
    [self.view.layer addAnimation:animation forKey:nil];
}

- (void)indTapped:(id)sender {
    NSLog(@"indTapped");
    //    [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"IndSale" bundle:nil];
    CATransition *animation = [CATransition animation];
    [animation setDuration:1.5];
    [animation setType:kCATransitionFade]; //淡入淡出
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self presentViewController:[storyBoard instantiateInitialViewController]
                       animated:NO completion:nil];
    [self.view.layer addAnimation:animation forKey:nil];
}


//强制按钮为高亮状态，否则按钮图片不显示，费解
- (void)highlightButton:(YDImageButton *)button
{
    [button setHighlighted:YES];
}



@end
