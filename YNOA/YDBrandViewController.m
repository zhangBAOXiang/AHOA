//
//  YDBrandViewController.m
//  YNOA
//
//  Created by 224 on 14-11-5.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDBrandViewController.h"
#import "YDOperation.h"
#import "YDSaleStore.h"
#import "YDBusinessName.h"
#import "AHKActionSheet.h"
#import "YDBaseViewController+ConfigureCell.h"

typedef enum {
    kCurrentIsInDustry,
    kCurrentIsBrand,
    kCurrentIsSpec,
    kCurrentIsMarket,
    kCurrentIsCity,
    kCurrentIsStruct
} currentState;

@interface YDBrandViewController ()<YDSOAPDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (copy, nonatomic) NSString *selectCode;
@property (strong, nonatomic) YDOperation *operation;
@property (assign, nonatomic) currentState brandState;
@property (assign, nonatomic) currentState lastStateForMarket;
@property (assign, nonatomic) currentState lastStateForStruct;

@end

@implementation YDBrandViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.yorm=@"year";
    
    [self customTitleView:@"品牌销量(年)" withDateString2:nil];
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x3da8e5)];
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIView *rightView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 105, 63)];
    UIButton *rightBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn1 setFrame:CGRectMake(0, 0, 50, 63)];
    [rightBtn1 setImage:[UIImage imageNamed:@"mainseting.png"] forState:UIControlStateNormal];
    [rightBtn1 addTarget:self action:@selector(handleSet) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightBtn1];
    
    UIButton *rightBtn2=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn2 setFrame:CGRectMake(55, 0, 50, 63)];
    [rightBtn2 setTag:10001];
    [rightBtn2 setImage:[UIImage imageNamed:@"searchicon.png"] forState:UIControlStateNormal];
    [rightBtn2 addTarget:self action:@selector(handleSearch) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightBtn2];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightView];

    [self customButton];
    self.leftTable.delegate = self;
    self.leftTable.dataSource = self;
    self.rightTable.delegate = self;
    self.rightTable.dataSource = self;
    self.scroll.delegate = self;
    self.leftTable.rowHeight = kHeight;
    self.rightTable.rowHeight = kHeight;
    
    self.brandState=kCurrentIsInDustry;
    
    self.operation=[[YDOperation alloc] init];
    self.operation.soapDelegate=self;
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=NO;
    
    self.HUD.labelText=@"加载数据..";
    //显示对花框
    [self.HUD show:YES];
    
    [self getDataFormCacheOrNet:@"1,000000"];
    
    NSNotificationCenter  *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:@"range" object:nil];
    [center addObserver:self selector:@selector(rangeChanged:) name:@"range" object:nil];


}

- (void)customButton
{
    float margin=(self.view.frame.size.width-80*3)/4;
    
    YDImageButton *btn1=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn1 setFrame:CGRectMake(margin, self.view.frame.size.height-120, 80, 48)];
    [btn1 setImage:[UIImage imageNamed:@"icon_industry.png"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"icon_industry_select.png"] forState:UIControlStateSelected];
    [btn1 setTitle:@"整体" forState:UIControlStateNormal];
    [btn1 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor clearColor]];
    [btn1 setTag:1001];
    [btn1 addTarget:self action:@selector(brandMainTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setSelected:YES];
    
    YDImageButton *btn2=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(2*margin+80, self.view.frame.size.height-120, 80, 48)];
    [btn2 setImage:[UIImage imageNamed:@"icon_market.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"icon_market_select.png"] forState:UIControlStateSelected];
    [btn2 setTitle:@"市场" forState:UIControlStateNormal];
    [btn2 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor clearColor]];
    [btn2 setTag:1002];
    [btn2 addTarget:self action:@selector(brandMarketTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setHighlighted:YES];
    
    YDImageButton *btn3=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn3 setFrame:CGRectMake(3*margin+80*2, self.view.frame.size.height-120, 80, 48)];
    [btn3 setImage:[UIImage imageNamed:@"icon_struct.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"icon_struct_select.png"] forState:UIControlStateSelected];
    [btn3 setTitle:@"结构" forState:UIControlStateNormal];
    [btn3 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn3 setBackgroundColor:[UIColor clearColor]];
    [btn3 setTag:1003];
    [btn3 addTarget:self action:@selector(brandStructTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setHighlighted:YES];
    
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
    [self.view addSubview:btn3];
}

#pragma mark - Handle UINavigation Bar

- (void)handleLeft
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    switch (self.brandState) {
        case kCurrentIsInDustry:
            [YDSaleStore removePath];
            [defaults removeObjectForKey:@"selectType"];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case kCurrentIsBrand:
            self.brandState=kCurrentIsInDustry;
            self.leftSource = self.rightSource =[YDSaleStore unarchivedData:@"1,000000"];
            [defaults setValue:@"1,000000" forKey:@"searchCode"];
            [self.leftTable reloadData];
            [self.rightTable reloadData];
            break;
        case kCurrentIsSpec:{
            self.brandState=kCurrentIsBrand;
            NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",[defaults valueForKey:@"preIndusCode"]];
            [defaults setValue:code forKey:@"searchCode"];
            self.leftSource = self.rightSource=[YDSaleStore unarchivedData:code];
            [self.leftTable reloadData];
            [self.rightTable reloadData];
            break;
        }
        case kCurrentIsMarket:{
            YDImageButton *button=(YDImageButton *)[self.view viewWithTag:1001];
            [button setHighlighted:NO];
            [button setSelected:YES];
            [self performSelector:@selector(highlightButton:) withObject:button afterDelay:0.0];
            switch (self.lastStateForMarket) {
                case kCurrentIsInDustry:
                    self.brandState=kCurrentIsInDustry;
                    self.selectCode=nil;
                    self.leftSource = self.rightSource=[YDSaleStore unarchivedData:@"1,000000"];
                    [defaults setValue:@"1,000000" forKey:@"searchCode"];
                    [self.leftTable reloadData];
                    [self.rightTable reloadData];
                    break;
                case kCurrentIsBrand:{
                    self.brandState=kCurrentIsBrand;
                    self.selectCode=nil;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",[defaults valueForKey:@"preIndusCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    self.leftSource = self.rightSource=[YDSaleStore unarchivedData:code];
                    [self.leftTable reloadData];
                    [self.rightTable reloadData];
                    break;
                }
                case kCurrentIsSpec:{
                    self.selectCode=nil;
                    self.brandState=kCurrentIsSpec;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;3,000000",[defaults valueForKey:@"preBrandCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    self.leftSource = self.rightSource=[YDSaleStore unarchivedData:code];
                    [self.leftTable reloadData];
                    [self.rightTable reloadData];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case kCurrentIsCity:{
            self.brandState=kCurrentIsMarket;
            NSString *code=[[NSString alloc] initWithFormat:@"%@;4,000000",[defaults valueForKey:@"preMarketCode"]];
            [defaults setValue:code forKey:@"searchCode"];
            self.leftSource = self.rightSource=[YDSaleStore unarchivedData:code];
            [self.leftTable reloadData];
            [self.rightTable reloadData];
            break;
        }
        case kCurrentIsStruct:{
            UIButton *button=(UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:10001];
            button.enabled=YES;
            switch (self.lastStateForStruct) {
                case kCurrentIsInDustry:{
                    self.brandState=kCurrentIsInDustry;
                    [self backToLastLevelForCode:@"1,000000" buttonTag:1001];
                    [defaults setValue:@"1,000000" forKey:@"searchCode"];
                    break;
                }
                case kCurrentIsBrand:{
                    self.brandState=kCurrentIsBrand;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",[defaults valueForKey:@"preIndusCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1001];
                    break;
                }
                case kCurrentIsSpec:{
                    self.brandState=kCurrentIsSpec;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;3,000000",[defaults valueForKey:@"preBrandCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1001];
                    break;
                }
                case kCurrentIsMarket:{
                    self.brandState=kCurrentIsMarket;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;4,000000",[defaults valueForKey:@"preMarketCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1002];
                    break;
                }
                case kCurrentIsCity:{
                    self.brandState=kCurrentIsCity;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;5,000000",[defaults valueForKey:@"preCityCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1002];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    [defaults synchronize];
}

- (void)handleSearch
{
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    CATransition *animation = [CATransition animation];
    [animation setDuration:1.5];
    [animation setType:kCATransitionFade]; //淡入淡出
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"test"] animated:NO completion:nil];
    [self.view.layer addAnimation:animation forKey:nil];
}

- (void)handleSet
{
    AHKActionSheet *sheet = [[AHKActionSheet alloc] initWithTitle:@"显示年或月销量"];
    sheet.cancelButtonTitle = @"取消";
    sheet.buttonTextCenteringEnabled =@(YES);
    [sheet addButtonWithTitle:@"年销量"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          //年销量
                          self.yorm=@"year";
                          [self customTitleView:@"品牌销量(年)" withDateString2:self.timeStamp];
                          [self.leftTable reloadData];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"月销量"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"month";
                          [self customTitleView:@"品牌销量(月)" withDateString2:self.timeStamp];
                          [self.leftTable reloadData];
                          [self.rightTable reloadData];
                          
                      }];
    [sheet show];
}

- (void)backToLastLevelForCode:(NSString *)code buttonTag:(int)tag
{
    YDImageButton *button=(YDImageButton *)[self.view viewWithTag:tag];
    [button setHighlighted:NO];
    [button setSelected:YES];
    [self performSelector:@selector(highlightButton:) withObject:button afterDelay:0.0];
    self.selectCode=nil;
    self.leftSource = self.rightSource=[YDSaleStore unarchivedData:code];
    [self.leftTable reloadData];
    [self.rightTable reloadData];

}

#pragma mark - NSNotification

- (void)rangeChanged:(NSNotification *)notification
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    YDBusinessName *object=[notification object];
    NSString *range;
    if (object != nil) {
        range=[[NSString alloc] initWithFormat:@"9,%d;%@,%@",[defaults integerForKey:@"selectType"],object.type,object.code];
        NSLog(@"code=%@,range=%@",[defaults valueForKey:@"searchCode"],range);
    }else{
        range=[[NSString alloc] initWithFormat:@"9,%d",[defaults integerForKey:@"selectType"]];
        NSLog(@"code=%@,range=%@",[defaults valueForKey:@"searchCode"],range);
    }
    
    [self.HUD show:YES];
    [self.operation getSaleAnaylseSOAP:[defaults valueForKey:@"searchCode"] tobaRange:range showType:@"0"];
}

#pragma mark - SOAP Delegate

- (void)passSoapArray:(NSMutableArray *)soapArray forCode:(NSString *)code
{
    NSLog(@"code=%@",code);
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:code forKey:@"searchCode"];
    [defaults synchronize];
    
    [self.HUD hide:YES];
    self.leftSource = soapArray;
    self.rightSource = soapArray;
    [self.leftTable reloadData];
    [self.rightTable reloadData];
    
    [YDSaleStore archivedData:soapArray forCode:code];
    self.selectCode=nil;
    //更新时间戳
    YDSaleAnaylse *sale = [soapArray firstObject];
    self.timeStamp = sale.datetime;
    [self customTitleView:@"品牌销量(年)" withDateString2:self.timeStamp];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.leftTable) {
        return self.leftSource.count;
    }else{
        return self.rightSource.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDentifier=@"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellDentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellDentifier];
    }
    
    //清楚subviews
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }

    
    YDSaleAnaylse *sale=[self.leftSource objectAtIndex:indexPath.row];
    if(tableView == self.rightTable){
        [self configureCell:cell withSale:sale];
    }else {
        NSString *content = sale.name;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        [label setText:content];
        label.font = [UIFont  fontWithName:@"STHeiti-Medium.ttc" size:10];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        [label sizeToFit];
        [cell.contentView addSubview:label];
    }
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    [tap setNumberOfTapsRequired:2];
    [cell addGestureRecognizer:tap];
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,(kCount-1)*kWidth, kHeight)];
    if (tableView == self.rightTable) {
        NSArray *headNames=[[NSArray alloc] initWithObjects: @"销量", @"增幅", @"增量", @"单箱", @"价格", nil];
        int count ;
        if (self.brandState == kCurrentIsSpec) {
            count = headNames.count;
        } else {
            count = headNames.count-1;
        }
        self.scroll.contentSize = CGSizeMake(count*kWidth, 0);

        for(int i=0;i<count;i++){
            UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(i*kWidth, 0, kWidth, kHeight)];
            [btn setBackgroundColor:[UIColor blackColor]];
            [btn setTitle:headNames[i] forState:UIControlStateNormal];
            [btn setUserInteractionEnabled:NO];
            [view addSubview:btn];
        }
        
    }
    else {
        view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,100, kHeight)];
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, kHeight)];
        [btn setBackgroundColor:[UIColor blackColor]];
        [btn setTitle:@"名字" forState:UIControlStateNormal];
        [btn setUserInteractionEnabled:NO];
        [view addSubview:btn];
        
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.leftTable) {
        [self.rightTable selectRowAtIndexPath:indexPath animated:NO
                               scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.leftTable selectRowAtIndexPath:indexPath animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    YDSaleAnaylse *selectSale=[self.rightSource objectAtIndex:indexPath.row];
    switch (self.brandState) {
        case kCurrentIsInDustry:
            self.selectCode=[[NSString alloc] initWithFormat:@"1,%@",selectSale.code];
            self.lastStateForMarket=kCurrentIsInDustry;
            self.lastStateForStruct=kCurrentIsInDustry;
            break;
        case kCurrentIsBrand:
            self.selectCode=[[NSString alloc] initWithFormat:@"%@;2,%@",[defaults valueForKey:@"preIndusCode"],selectSale.code];
            self.lastStateForStruct=kCurrentIsBrand;
            self.lastStateForMarket=kCurrentIsBrand;
            break;
        case kCurrentIsSpec:
            self.selectCode=[[NSString alloc] initWithFormat:@"%@;3,%@",[defaults valueForKey:@"preBrandCode"],selectSale.code];
            self.lastStateForMarket=kCurrentIsSpec;
            self.lastStateForStruct=kCurrentIsSpec;
            break;
        case kCurrentIsMarket:
            self.selectCode=[[NSString alloc] initWithFormat:@"%@;4,%@",[defaults valueForKey:@"preMarketCode"],selectSale.code];
            self.lastStateForStruct=kCurrentIsMarket;
            break;
        case kCurrentIsCity:
            self.selectCode=[[NSString alloc] initWithFormat:@"%@;5,%@",[defaults valueForKey:@"preCityCode"],selectSale.code];
            self.lastStateForStruct=kCurrentIsCity;
            break;
        default:
            self.selectCode=nil;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (tableView == self.leftTable) {
        return kHeight;
    } else {
        return kHeight;
    }
}

#pragma mark - TapGesture

- (void)doubleClick:(UITapGestureRecognizer *)recognizer
{
    NSIndexPath *indexPath=[self.rightTable indexPathForCell:(UITableViewCell *)recognizer.view];
    [self.rightTable selectRowAtIndexPath:indexPath
                                 animated:NO
                           scrollPosition:UITableViewScrollPositionNone];
    [self.leftTable selectRowAtIndexPath:indexPath
                                 animated:NO
                           scrollPosition:UITableViewScrollPositionNone];
    
    YDSaleAnaylse *selectSale=[self.rightSource objectAtIndex:indexPath.row];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *code;
    NSString *preCode;
    switch (self.brandState) {
        case kCurrentIsInDustry:
            self.brandState=kCurrentIsBrand;
            code=[[NSString alloc] initWithFormat:@"1,%@;2,000000",selectSale.code];
            preCode=[[NSString alloc] initWithFormat:@"1,%@",selectSale.code];
            [defaults removeObjectForKey:@"preIndusCode"];
            [defaults setValue:preCode forKey:@"preIndusCode"];
            [defaults synchronize];
            
            [self getDataFormCacheOrNet:code];
            break;
        case kCurrentIsBrand:
            self.brandState=kCurrentIsSpec;
            code=[[NSString alloc] initWithFormat:@"%@;2,%@;3,000000",[defaults valueForKey:@"preIndusCode"],selectSale.code];
            preCode=[[NSString alloc] initWithFormat:@"%@;2,%@",[defaults valueForKey:@"preIndusCode"],selectSale.code];
            [defaults removeObjectForKey:@"preBrandCode"];
            [defaults setValue:preCode forKey:@"preBrandCode"];
            [defaults synchronize];
            
            [self getDataFormCacheOrNet:code];
            break;
        case kCurrentIsMarket:
            self.brandState=kCurrentIsCity;
            code=[[NSString alloc] initWithFormat:@"%@;4,%@;5,000000",[defaults valueForKey:@"preMarketCode"],selectSale.code];
            preCode=[[NSString alloc] initWithFormat:@"%@;4,%@",[defaults valueForKey:@"preMarketCode"],selectSale.code];
            [defaults removeObjectForKey:@"preCityCode"];
            [defaults setValue:preCode forKey:@"preCityCode"];
            [defaults synchronize];
            
            [self getDataFormCacheOrNet:code];
            break;
        default:
            break;
    }
    
}

- (void)getDataFormCacheOrNet:(NSString *)code
{
    NSArray *array=[YDSaleStore unarchivedData:code];
    
    if ([array count] != 0) {
        [self.HUD hide:YES];
        self.leftSource=self.rightSource=array;
        self.rightSource = array;
        [self.leftTable reloadData];
        [self.rightTable reloadData];
    }else{
        [self.HUD show:YES];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        if ([defaults integerForKey:@"selectType"]) {
            NSString *range=[[NSString alloc] initWithFormat:@"9,%d",[defaults integerForKey:@"selectType"]];
            [self.operation getSaleAnaylseSOAP:code tobaRange:range showType:@"0"];
        }else{
           [self.operation getSaleAnaylseSOAP:code tobaRange:@"0" showType:@"0"];
        }
    }
 
}

#pragma mark - Button Tapped Methods

- (void)brandMainTapped:(id)sender
{
    NSLog(@"brandMainTapped");
    [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
    [YDSaleStore removePath];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)brandMarketTapped:(id)sender
{
    NSLog(@"brandMarketTapped");
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if (self.brandState != kCurrentIsMarket && self.brandState != kCurrentIsCity) {
        if (self.brandState == kCurrentIsStruct) {
            UIButton *button=(UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:10001];
            button.enabled=YES;
            switch (self.lastStateForStruct) {
                case kCurrentIsMarket:{
                    self.brandState=kCurrentIsMarket;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;4,000000",[defaults valueForKey:@"preMarketCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1002];
                    break;
                }
                case kCurrentIsCity:{
                    self.brandState=kCurrentIsCity;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;5,000000",[defaults valueForKey:@"preCityCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1002];
                    break;
                }
                default:{
                    [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
                    GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                                    initWithText:@"请先选择" showActivity:NO
                                                                    inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom
                                                                    inView:self.view];
                    [notificationView show:YES];
                    [notificationView hideAnimatedAfter:1.5];

                    break;
                }
            }

        }else{
            if ([self.selectCode length] > 0) {
                [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                self.brandState=kCurrentIsMarket;
                NSString *code=[[NSString alloc] initWithFormat:@"%@;4,000000",self.selectCode];
                [defaults removeObjectForKey:@"preMarketCode"];
                [defaults setValue:self.selectCode forKey:@"preMarketCode"];
                [defaults synchronize];
                [self getDataFormCacheOrNet:code];
            }else{
                [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
                //提示视图
                GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                                initWithText:@"请先选择" showActivity:NO
                                                                inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom
                                                                inView:self.view];
                [notificationView show:YES];
                [notificationView hideAnimatedAfter:1.5];
            }
        }
    }else{
        [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
    }
}

- (void)brandStructTapped:(id)sender
{
    NSLog(@"brandStructTapped");
    if (self.brandState != kCurrentIsStruct) {
        if ([self.selectCode length] > 0) {
            [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
            self.brandState=kCurrentIsStruct;
            
            UIButton *button=(UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:10001];
            button.enabled=NO;
            
            [self.HUD show:YES];
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"selectType"]) {
                NSString *range=[[NSString alloc] initWithFormat:@"9,%d",[defaults integerForKey:@"selectType"]];
                [self.operation getSaleAnaylseSOAP:self.selectCode tobaRange:range showType:@"1"];
            }else{
                [self.operation getSaleAnaylseSOAP:self.selectCode tobaRange:@"0" showType:@"1"];
            }
        }else{
            [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
            GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                            initWithText:@"请先选择" showActivity:NO inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom inView:self.view];
            [notificationView show:YES];
            [notificationView hideAnimatedAfter:1.5];
        }
    }else{
        [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
    }
    
}

//强制按钮为高亮状态，否则按钮图片不显示，费解
- (void)highlightButton:(YDImageButton *)button
{
    [button setSelected:YES];
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[YDImageButton class]]) {
            YDImageButton *btn=(YDImageButton *)view;
            if (btn.tag != button.tag) {
                [btn setSelected:NO];
                [btn setHighlighted:YES];
            }
        }
    }
}

- (void)holdButtonState:(YDImageButton *)button
{
    [button setHighlighted:YES];
}

#pragma mark - UIScrollView Delegate

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
