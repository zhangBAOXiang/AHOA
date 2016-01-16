//
//  YDIndMainViewController.m
//  AHOA
//
//  Created by 224 on 15/11/15.
//  Copyright © 2015年 zoomlgd. All rights reserved.
//

#import "YDIndMainViewController.h"
#import "YDIndOperation.h"
#import "AHKActionSheet.h"
#import "YDBaseViewController+ConfigureCell.h"
#import "YDIndSale.h"

@interface YDIndMainViewController ()<UITableViewDataSource,UIScrollViewDelegate,UITableViewDelegate,YDIndDelegate>
{
    NSArray *_tabButtons;
}

@property (strong, nonatomic) YDIndOperation *operation;

@end

@implementation YDIndMainViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.yorm = @"year";
    self.timeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:@"analyseTime"];
    [self customTitleView:@"调拨量(年)" withDateString:self.timeStamp];
    
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
    
    [self customButton];
    
    self.leftTable.delegate = self;
    self.leftTable.dataSource = self;
    self.rightTable.delegate = self;
    self.rightTable.dataSource = self;
    self.scroll.delegate = self;
    self.leftTable.rowHeight = kHeight;
    self.rightTable.rowHeight = kHeight;
    self.scroll.contentSize = CGSizeMake((kHeadNameCount-1)*kWidth, 0);
    
    self.operation = [[YDIndOperation alloc] init];
    self.operation.indDelegate = self;
    
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=NO;
    
    self.HUD.labelText=@"加载数据..";
    //显示对花框
    [self.HUD show:YES];
    
    [self.operation getIndSaleAnaylseSOAP:@"0,000000" tobaRange:@"0" showType:@"0"];

}

//按钮定制
- (void)customButton
{
    float margin=(self.view.frame.size.width-80*2)/3;
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 120)];
    [self.view addSubview:tabView];
    tabView.backgroundColor = UIColorFromRGB(0x3da8e5);
    
    YDImageButton *btn1=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn1 setFrame:CGRectMake(margin, 0, 80, 48)];
    [btn1 setImage:[UIImage imageNamed:@"shangye.png"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"shangye02.png"] forState:UIControlStateSelected];
    [btn1 setTitle:@"商业" forState:UIControlStateNormal];
    //    [btn1 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor clearColor]];
    [btn1 setTag:1001];
    [btn1 addTarget:self action:@selector(indMainTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [btn1 setSelected:YES];
    
    YDImageButton *btn2=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(2*margin+80, 0, 80, 48)];
    [btn2 setImage:[UIImage imageNamed:@"icon_brand.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"icon_brand_select.png"] forState:UIControlStateSelected];
    [btn2 setTitle:@"品牌" forState:UIControlStateNormal];
    //    [btn2 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor clearColor]];
    [btn2 setTag:1002];
    [btn2 addTarget:self action:@selector(indBrandTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [btn2 setHighlighted:YES];
    
    [tabView addSubview:btn1];
    [tabView addSubview:btn2];
    
    _tabButtons = @[btn1, btn2];
}


- (void)handleLeft
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *timestamp = [defaults objectForKey:@"indanalyseTime"];
    AHKActionSheet *sheet = [[AHKActionSheet alloc] initWithTitle:@"显示年或月调拨"];
    sheet.cancelButtonTitle = @"取消";
    sheet.buttonTextCenteringEnabled =@(YES);
    [sheet addButtonWithTitle:@"月调拨量"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          //年销量
                          self.yorm=@"month";
                          self.currentIsSale = YES;
                          [self customTitleView:@"调拨量(月)" withDateString:timestamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"年调拨量"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"year";
                          self.currentIsSale = YES;
                          [self customTitleView:@"调拨量(年)" withDateString:timestamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"月调拨收入"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"month";
                          self.currentIsSale = NO;
                          [self customTitleView:@"调拨收入(月)" withDateString:timestamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"年调拨收入"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"year";
                          self.currentIsSale = NO;
                          [self customTitleView:@"调拨收入(年)" withDateString:timestamp];
                          [self.rightTable reloadData];
                      }];
    
    [sheet show];

}

#pragma mark - Ind delegate

- (void)passSoapArray:(NSMutableArray *)soapArray forCode:(NSString *)code{
    [self.HUD hide:YES];
    self.leftSource = soapArray;
    self.rightSource = soapArray;
    [self.leftTable reloadData];
    [self.rightTable reloadData];
    
//    //更改时间戳
    YDIndSale *sale = [soapArray firstObject];
    [self customTitleView:@"调拨量(年)" withDateString:sale.datetime];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sale.datetime forKey:@"indanalyseTime"];
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
    
    YDIndSale *sale = [self.leftSource objectAtIndex:indexPath.row];
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
        NSArray *headNames=[[NSArray alloc] initWithObjects: @"本期", @"同期", @"增幅%", @"增量", nil];
        
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

- (void)indMainTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)indBrandTapped:(id)sender
{
    NSLog(@"brandTapped");
    //    [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"IndSale" bundle:nil];
    CATransition *animation = [CATransition animation];
    [animation setDuration:1.5];
    [animation setType:kCATransitionFade]; //淡入淡出
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"YDIndBrandViewController"]
                       animated:NO completion:nil];
    [self.view.layer addAnimation:animation forKey:nil];
}

//强制按钮为高亮状态，否则按钮图片不显示，费解
- (void)highlightButton:(YDImageButton *)button
{
    [button setHighlighted:YES];
}


@end
