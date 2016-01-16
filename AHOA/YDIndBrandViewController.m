//
//  YDIndBrandViewController.m
//  AHOA
//
//  Created by 224 on 15/11/16.
//  Copyright © 2015年 zoomlgd. All rights reserved.
//

#import "YDIndBrandViewController.h"
#import "YDIndOperation.h"
#import "AHKActionSheet.h"
#import "YDBaseViewController+ConfigureCell.h"
#import "YDIndSale.h" 
#import "YDIndSaleStore.h"
#import "YDAppDelegate.h"

typedef enum {
    kCurrentIsInDustry,
    kCurrentIsBrand,
    kCurrentIsSpec,
    kCurrentIsStruct
} currentState;

@interface YDIndBrandViewController ()<UITableViewDataSource,UIScrollViewDelegate,UITableViewDelegate,YDIndDelegate>
{
    NSArray *_tabButtons;
}

@property (strong, nonatomic) YDIndOperation *operation;
@property (assign, nonatomic) currentState indState;
@property (assign, nonatomic) currentState lastStateForStruct;
@property (copy, nonatomic) NSString *selectCode;

@end

@implementation YDIndBrandViewController

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
    
    self.indState = kCurrentIsInDustry;
    
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=NO;
    
    self.HUD.labelText=@"加载数据..";
    //显示对花框
    [self.HUD show:YES];
    //修改的地方
    [self getDataFormCacheOrNet:@"1,000000,0,0"];
}

//按钮定制
- (void)customButton
{
    float margin=(self.view.frame.size.width-80*3)/4;
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
    [btn2 setImage:[UIImage imageNamed:@"gongye01.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"gongye02.png"] forState:UIControlStateSelected];
    [btn2 setTitle:@"工业" forState:UIControlStateNormal];
    //    [btn2 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor clearColor]];
    [btn2 setTag:1002];
    [btn2 addTarget:self action:@selector(indIndustryTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [btn2 setHighlighted:YES];
    
    YDImageButton *btn3=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn3 setFrame:CGRectMake(3*margin+80*2, 0, 80, 48)];
    [btn3 setImage:[UIImage imageNamed:@"icon_struct.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"icon_struct_select.png"] forState:UIControlStateSelected];
    [btn3 setTitle:@"结构" forState:UIControlStateNormal];
    //    [btn3 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn3 setBackgroundColor:[UIColor clearColor]];
    [btn3 setTag:1003];
    [btn3 addTarget:self action:@selector(indStructTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    [tabView addSubview:btn1];
    [tabView addSubview:btn2];
    [tabView addSubview:btn3];
    
    _tabButtons = @[btn1, btn2, btn3];
}

- (void)handleLeft
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    switch (self.indState) {
        case kCurrentIsInDustry:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case kCurrentIsBrand:
            self.indState = kCurrentIsInDustry;
            self.leftSource = self.rightSource =[YDIndSaleStore unarchivedData:@"1,000000,0,0"];
            [self.leftTable reloadData];
            [self.rightTable reloadData];
            break;
        case kCurrentIsSpec:{
            self.indState = kCurrentIsBrand;
            NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",[defaults valueForKey:@"preIndIndustryCode"]];
            self.leftSource = self.rightSource=[YDIndSaleStore unarchivedData:code];
            [self.leftTable reloadData];
            [self.rightTable reloadData];
            break;
        }
        case kCurrentIsStruct:
            switch (self.lastStateForStruct) {
                case kCurrentIsInDustry:{
                    self.indState=kCurrentIsInDustry;
                    [self backToLastLevelForCode:@"1,000000,0,0" ];
                    break;
                }
                case kCurrentIsBrand:{
                    self.indState=kCurrentIsBrand;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",[defaults valueForKey:@"preIndIndustryCode"]];
                    [self backToLastLevelForCode:code];
                    break;
                }
                case kCurrentIsSpec:{
                    self.indState=kCurrentIsSpec;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;3,000000",[defaults valueForKey:@"preIndBrandCode"]];
                    [self backToLastLevelForCode:code];
                    break;
                }
                default:
                    break;

            }
            
            break;
        default:
            break;
    }
}

- (void)backToLastLevelForCode:(NSString *)code
{
    YDImageButton *button=(YDImageButton *)[self.view viewWithTag:1003];
    //    [button setHighlighted:NO];
    [button setSelected:NO];
    self.selectCode=nil;
    self.leftSource = self.rightSource=[YDIndSaleStore unarchivedData:code];
    [self.leftTable reloadData];
    [self.rightTable reloadData];
    
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

- (void)indMainTapped:(id)sender {
    NSLog(@"indMainTapped");
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)indIndustryTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)indStructTapped:(id)sender {
    NSLog(@"indStructTapped");
    if (self.indState != kCurrentIsStruct) {
        if ([self.selectCode length] > 0) {
            [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
            self.indState = kCurrentIsStruct;
            
            [self.HUD show:YES];
            [self.operation getIndSaleAnaylseSOAP:self.selectCode tobaRange:@"0" showType:@"1"];
        }else {
            GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                            initWithText:@"请先选择" showActivity:NO inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom inView:self.view];
            [notificationView show:YES];
            [notificationView hideAnimatedAfter:1.5];
        }
    }else {
      [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
    }
}

- (void)changeButtonState:(id)sender {
    YDImageButton *button = (YDImageButton *)sender;
    [button setSelected:YES];
    for (YDImageButton *other in _tabButtons) {
        if (other.tag != button.tag) {
            [other setSelected:NO];
        }
        
    }
}

- (void)getDataFormCacheOrNet:(NSString *)code
{
    NSArray *array=[YDIndSaleStore unarchivedData:code];
    
    if ([array count] != 0) {
        [self.HUD hide:YES];
        self.leftSource=self.rightSource=array;
        //self.rightSource = array;
        [self.leftTable reloadData];
        [self.rightTable reloadData];
    }else{
        [self.HUD show:YES];
        [self.operation getIndSaleAnaylseSOAP:code tobaRange:@"0" showType:@"0"];
    }
    
}

- (void)passSoapArray:(NSMutableArray *)soapArray forCode:(NSString *)code{
    [self.HUD hide:YES];
    self.leftSource = soapArray;
    self.rightSource = soapArray;
    [self.leftTable reloadData];
    [self.rightTable reloadData];
    
    [YDIndSaleStore archivedData:soapArray forCode:code];
    self.selectCode = nil;
    
    //更改时间戳
    YDIndSale *sale = [soapArray firstObject];
    [self customTitleView:@"调拨量(年)" withDateString:sale.datetime];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sale.datetime forKey:@"indanalyseTime"];
    [defaults synchronize];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifer =@"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifer];
    }
    
    //清除subviews
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    YDIndSale *sale = [self.leftSource objectAtIndex:indexPath.row];
    if(tableView == self.rightTable){
        [self configureCell:cell withSale:sale];
    }else {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        UILabel *label = [[UILabel alloc] init];
        [label setText:sale.name];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:15.0f];
//        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.preferredMaxLayoutWidth = cell.bounds.size.width;
        
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    [tap setNumberOfTapsRequired:2];
    [cell addGestureRecognizer:tap];
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
        NSArray *headNames=[[NSArray alloc] initWithObjects: @"本期", @"同期", @"增幅%", @"增量", @"价格", nil];
        int count;
        if (self.indState == kCurrentIsSpec) {
            count = headNames.count;
        } else {
            count = headNames.count-1;
        }
        
        self.scroll.contentSize = CGSizeMake(count*kWidth, 0);
        
        for(int i=0;i<count;i++){
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTable) {
        [self.leftTable selectRowAtIndexPath:indexPath animated:NO
                               scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.rightTable selectRowAtIndexPath:indexPath animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    YDIndSale *selectInd = [self.rightSource objectAtIndex:indexPath.row];
    switch (self.indState) {
        case kCurrentIsInDustry:
            self.selectCode = [[NSString alloc] initWithFormat:@"1,%@",selectInd.code];
            self.lastStateForStruct = kCurrentIsInDustry;
            break;
            
        case kCurrentIsBrand:
            self.selectCode = [[NSString alloc] initWithFormat:@"%@;2,%@",[defaults valueForKey:@"preIndIndustryCode"],selectInd.code];
            self.lastStateForStruct = kCurrentIsBrand;

            break;
        case kCurrentIsSpec:
            self.selectCode = [[NSString alloc] initWithFormat:@"%@;3,%@",[defaults valueForKey:@"preIndBrandCode"],selectInd.code];
            self.lastStateForStruct = kCurrentIsSpec;

            break;
        default:
            break;
    }
}

- (void)doubleClick:(UITapGestureRecognizer *)recognizer {
    NSIndexPath *indexPath;
    NSIndexPath *temp1;
    NSIndexPath *temp2;
        temp1=[self.leftTable indexPathForCell:(UITableViewCell *)recognizer.view];
        temp2=[self.rightTable indexPathForCell:(UITableViewCell *)recognizer.view];
    if (temp1 >= temp2) {
        indexPath = temp1;
    }else{
        indexPath = temp2;
    }

    [self.rightTable selectRowAtIndexPath:indexPath
                                 animated:NO
                           scrollPosition:UITableViewScrollPositionNone];
    [self.leftTable selectRowAtIndexPath:indexPath
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    YDIndSale *selectInd = [self.rightSource objectAtIndex:indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *code;
    NSString *preCode;
    switch (self.indState) {
        case kCurrentIsInDustry:
            self.indState = kCurrentIsBrand;
            code = [[NSString alloc] initWithFormat:@"1,%@;2,000000",selectInd.code];
            //NSLog(@"Precode:%@",selectInd.code);
            preCode=[[NSString alloc] initWithFormat:@"1,%@",selectInd.code];
            [defaults removeObjectForKey:@"preIndIndustryCode"];
            [defaults setValue:preCode forKey:@"preIndIndustryCode"];
            [defaults synchronize];
            [self getDataFormCacheOrNet:code];
            
            break;
            
        case kCurrentIsBrand:
            self.indState = kCurrentIsSpec;
            code=[[NSString alloc] initWithFormat:@"%@;2,%@;3,000000",[defaults valueForKey:@"preIndIndustryCode"],selectInd.code];
            //NSLog(@"IsSpec:%@",code);
            preCode=[[NSString alloc] initWithFormat:@"%@;2,%@",[defaults valueForKey:@"preIndIndustryCode"],selectInd.code];
            [defaults removeObjectForKey:@"preIndBrandCode"];
            [defaults setValue:preCode forKey:@"preIndBrandCode"];
            [defaults synchronize];
            
            [self getDataFormCacheOrNet:code];
            break;
            
        default:
            break;
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

//强制按钮为高亮状态，否则按钮图片不显示，费解
- (void)highlightButton:(YDImageButton *)button
{
    [button setHighlighted:YES];
}

@end
