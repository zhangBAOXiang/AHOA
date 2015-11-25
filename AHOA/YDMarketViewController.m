//
//  YDMarketViewController.m
//  YNOA
//
//  Created by 224 on 14-11-10.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDMarketViewController.h"
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

@interface YDMarketViewController ()<YDSOAPDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    NSArray *_tabButtons;
}
@property (copy, nonatomic) NSString *selectCode;
@property (strong, nonatomic) YDOperation *operation;
@property (assign, nonatomic) currentState marketState;
@property (assign, nonatomic) currentState lastStateForBrand;
@property (assign, nonatomic) currentState lastStateForStruct;
@property (assign, nonatomic) currentState lastStateForIndustry;

@end

@implementation YDMarketViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.yorm=@"year";
    self.timeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:@"analyseTime"];
    [self customTitleView:@"销售分析(年)" withDateString2:self.timeStamp];
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
    [rightBtn2 setTag:10002];
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
    
    self.marketState=kCurrentIsMarket;
    
    self.operation=[[YDOperation alloc] init];
    self.operation.soapDelegate=self;
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=NO;
    
    self.HUD.labelText=@"加载数据..";
    //显示对花框
    [self.HUD show:YES];
    
    [self getDataFormCacheOrNet:@"4,000000"];
    
    NSNotificationCenter  *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:@"range" object:nil];
    [center addObserver:self selector:@selector(rangeChanged:) name:@"range" object:nil];

}

//按钮定制
- (void)customButton
{
    float margin=(self.view.frame.size.width-80*4)/5;
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
    [btn1 addTarget:self action:@selector(marketMainTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [btn1 setSelected:YES];
    
    YDImageButton *btn2=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(2*margin+80, 0, 80, 48)];
    [btn2 setImage:[UIImage imageNamed:@"icon_market.png"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"icon_market_select.png"] forState:UIControlStateSelected];
    [btn2 setTitle:@"工业" forState:UIControlStateNormal];
//    [btn2 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor clearColor]];
    [btn2 setTag:1002];
    [btn2 addTarget:self action:@selector(marketIndustryTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [btn2 setHighlighted:YES];
    
    YDImageButton *btn3=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn3 setFrame:CGRectMake(3*margin+80*2, 0, 80, 48)];
    [btn3 setImage:[UIImage imageNamed:@"icon_brand.png"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"icon_brand_select.png"] forState:UIControlStateSelected];
    [btn3 setTitle:@"品牌" forState:UIControlStateNormal];
//    [btn3 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn3 setBackgroundColor:[UIColor clearColor]];
    [btn3 setTag:1003];
    [btn3 addTarget:self action:@selector(marketBrandTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [btn3 setHighlighted:YES];
    
    YDImageButton *btn4=[YDImageButton buttonWithType:UIButtonTypeCustom];
    [btn4 setFrame:CGRectMake(4*margin+80*3, 0, 80, 48)];
    [btn4 setImage:[UIImage imageNamed:@"icon_struct.png"] forState:UIControlStateNormal];
    [btn4 setImage:[UIImage imageNamed:@"icon_struct_select.png"] forState:UIControlStateSelected];
    [btn4 setTitle:@"结构" forState:UIControlStateNormal];
//    [btn4 setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    [btn4 setBackgroundColor:[UIColor clearColor]];
    [btn4 setTag:1004];
    [btn4 addTarget:self action:@selector(marketStructTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [btn4 setHighlighted:YES];
    
    [tabView addSubview:btn1];
    [tabView addSubview:btn2];
    [tabView addSubview:btn3];
    [tabView addSubview:btn4];
    
    _tabButtons = @[btn1, btn2, btn3, btn4];
}

- (void)handleLeft
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    switch (self.marketState) {
        case kCurrentIsMarket:
            [YDSaleStore removePath];
            [defaults removeObjectForKey:@"selectType"];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case kCurrentIsCity:
            self.marketState=kCurrentIsMarket;
            self.leftSource = self.rightSource=[YDSaleStore unarchivedData:@"4,000000"];
            [defaults setValue:@"4,000000" forKey:@"searchCode"];
            [self.leftTable reloadData];
            [self.rightTable reloadData];
            break;
        case kCurrentIsInDustry:
            if (self.lastStateForIndustry == kCurrentIsMarket) {
                self.marketState=kCurrentIsMarket;
                [self backToLastLevelForCode:@"4,000000" buttonTag:1001];
                [defaults setValue:@"4,000000" forKey:@"searchCode"];
            }else{
                self.marketState=kCurrentIsCity;
                NSString *code=[[NSString alloc] initWithFormat:@"%@;5,000000",[defaults valueForKey:@"lastMarketCode"]];
                [defaults setValue:code forKey:@"searchCode"];
                [self backToLastLevelForCode:code buttonTag:1001];
            }
            break;
        case kCurrentIsBrand:
            switch (self.lastStateForBrand) {
                case kCurrentIsMarket:
                    self.marketState=kCurrentIsMarket;
                    [self backToLastLevelForCode:@"4,000000" buttonTag:1001];
                    [defaults setValue:@"4,000000" forKey:@"searchCode"];
                    break;
                case kCurrentIsCity:{
                    self.marketState=kCurrentIsCity;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;5,000000",[defaults valueForKey:@"lastMarketCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1001];
                    break;
                }
                case kCurrentIsInDustry:{
                    self.marketState=kCurrentIsInDustry;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;1,000000",[defaults valueForKey:@"lastIndustryCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1002];
                    break;
                }
                default:
                    break;
            }
            break;
        case kCurrentIsSpec:{
            self.marketState=kCurrentIsBrand;
            NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",[defaults valueForKey:@"lastBrandCode"]];
            [defaults setValue:code forKey:@"searchCode"];
            self.leftSource = self.rightSource=[YDSaleStore unarchivedData:code];
            [self.leftTable reloadData];
            [self.rightTable reloadData];
            break;
        }
        case kCurrentIsStruct:{
            UIButton *button=(UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:10002];
            button.enabled=YES;
            switch (self.lastStateForStruct) {
                case kCurrentIsMarket:
                    self.marketState=kCurrentIsMarket;
                    [self backToLastLevelForCode:@"4,000000" buttonTag:1001];
                    [defaults setValue:@"4,000000" forKey:@"searchCode"];
                    break;
                case kCurrentIsCity:{
                    self.marketState=kCurrentIsCity;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;5,000000",[defaults valueForKey:@"lastMarketCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1001];
                    break;
                }
                case kCurrentIsInDustry:{
                    self.marketState=kCurrentIsInDustry;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;1,000000",[defaults valueForKey:@"lastIndustryCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1002];
                    break;
                }
                case kCurrentIsBrand:{
                    self.marketState=kCurrentIsBrand;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",[defaults valueForKey:@"lastBrandCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1003];
                    break;
                }
                case kCurrentIsSpec:{
                    self.marketState=kCurrentIsSpec;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;3,000000",[defaults valueForKey:@"lastSpecCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1003];
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
                          [self customTitleView:@"销售分析(月)" withDateString2:self.timeStamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"年销量"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"year";
                          self.currentIsSale = YES;
                          [self customTitleView:@"销售分析(年)" withDateString2:self.timeStamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"月销售额"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"month";
                          self.currentIsSale = NO;
                          [self customTitleView:@"销售额分析(月)" withDateString2:self.timeStamp];
                          [self.rightTable reloadData];
                      }];
    [sheet addButtonWithTitle:@"年销售额"
                         type:AHKActionSheetButtonTypeDefault
                      handler:^(AHKActionSheet *actionSheet) {
                          self.yorm=@"year";
                          self.currentIsSale = NO;
                          [self customTitleView:@"销售额分析(年)" withDateString2:self.timeStamp];
                          [self.rightTable reloadData];
                      }];
    
    [sheet show];

}

- (void)backToLastLevelForCode:(NSString *)code buttonTag:(int)tag
{
    YDImageButton *button=(YDImageButton *)[self.view viewWithTag:tag];
    [button setHighlighted:NO];
    [button setSelected:YES];
    [self performSelector:@selector(changeButtonState:) withObject:button afterDelay:0.0];
    self.selectCode=nil;
    self.leftSource = self.rightSource=[YDSaleStore unarchivedData:code];
    [self.leftTable reloadData];
    [self.rightTable reloadData];
    
}

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
}

- (void)getDataFormCacheOrNet:(NSString *)code
{
    NSArray *array=[YDSaleStore unarchivedData:code];
    
    if ([array count] != 0) {
        [self.HUD hide:YES];
        self.leftSource = self.rightSource=array;
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
    
    //清除subviews
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    
    YDSaleAnaylse *sale=[self.leftSource objectAtIndex:indexPath.row];
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
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    [tap setNumberOfTapsRequired:2];
    [cell addGestureRecognizer:tap];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,(kCount-1)*kWidth, kHeight)];
    view.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.4];
    if (tableView == self.rightTable) {
        int count ;
        if (self.currentIsSale) {
            NSArray *headNames=[[NSArray alloc] initWithObjects: @"销量", @"同期", @"增幅%", @"增量", @"价格", nil];
            if (self.marketState == kCurrentIsSpec) {
                count = headNames.count;
            } else {
                count = headNames.count-1;
            }
            self.scroll.contentSize = CGSizeMake(count*kWidth, 0);
            
            for(int i=0;i<count;i++){
                UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(i*kWidth, 0, kWidth, kHeight)];
//                [btn setBackgroundColor:[UIColor blackColor]];
                [btn setTitle:headNames[i] forState:UIControlStateNormal];
                [btn setUserInteractionEnabled:NO];
                [view addSubview:btn];
            }

        }else {
            NSArray *headNames=[[NSArray alloc] initWithObjects: @"销售额", @"同期", @"增幅%", @"增量", nil];
            count = headNames.count;
            self.scroll.contentSize = CGSizeMake(count*kWidth, 0);
            for(int i=0;i<count;i++){
                UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(i*kWidth, 0, kWidth, kHeight)];
//                [btn setBackgroundColor:[UIColor blackColor]];
                [btn setTitle:headNames[i] forState:UIControlStateNormal];
                [btn setUserInteractionEnabled:NO];
                [view addSubview:btn];
            }
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
    switch (self.marketState) {
        case kCurrentIsMarket:
            self.selectCode=[[NSString alloc] initWithFormat:@"4,%@",selectSale.code];
            self.lastStateForBrand=kCurrentIsMarket;
            self.lastStateForStruct=kCurrentIsMarket;
            self.lastStateForIndustry=kCurrentIsMarket;
            break;
        case kCurrentIsCity:
            self.selectCode=[[NSString alloc] initWithFormat:@"%@;5,%@",[defaults valueForKey:@"lastMarketCode"],
                        selectSale.code];
            self.lastStateForBrand=kCurrentIsCity;
            self.lastStateForStruct=kCurrentIsCity;
            self.lastStateForIndustry=kCurrentIsCity;
            break;
        case kCurrentIsInDustry:
            self.selectCode=[[NSString alloc] initWithFormat:@"%@;1,%@",[defaults valueForKey:@"lastIndustryCode"],
                        selectSale.code];
            self.lastStateForBrand=kCurrentIsInDustry;
            self.lastStateForStruct=kCurrentIsInDustry;
            break;
        case kCurrentIsBrand:
            self.selectCode=[[NSString alloc] initWithFormat:@"%@;2,%@",[defaults valueForKey:@"lastBrandCode"],selectSale.code];
            self.lastStateForStruct=kCurrentIsBrand;
            break;
        case kCurrentIsSpec:
            self.selectCode=[[NSString alloc] initWithFormat:@"%@;3,%@",[defaults valueForKey:@"lastSpecCode"],selectSale.code];
            self.lastStateForStruct=kCurrentIsSpec;
            break;
        default:
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
    switch (self.marketState) {
        case kCurrentIsMarket:
            self.marketState=kCurrentIsCity;
            code=[[NSString alloc] initWithFormat:@"4,%@;5,000000",selectSale.code];
            preCode=[[NSString alloc] initWithFormat:@"4,%@",selectSale.code];
            [defaults removeObjectForKey:@"lastMarketCode"];
            [defaults setValue:preCode forKey:@"lastMarketCode"];
            [defaults synchronize];
            
            [self getDataFormCacheOrNet:code];
            break;
        case kCurrentIsInDustry:{
            self.marketState=kCurrentIsBrand;
            self.lastStateForBrand=kCurrentIsInDustry;
            code=[[NSString alloc] initWithFormat:@"%@;1,%@;2,000000",[defaults valueForKey:@"lastIndustryCode"],
                  selectSale.code];
            preCode=[[NSString alloc] initWithFormat:@"%@;1,%@",[defaults valueForKey:@"lastIndustryCode"],selectSale.code];
            [defaults removeObjectForKey:@"lastBrandCode"];
            [defaults setValue:preCode forKey:@"lastBrandCode"];
            [defaults synchronize];
            
            [self getDataFormCacheOrNet:code];
            
            YDImageButton *button=(YDImageButton *)[self.view viewWithTag:1003];
            [button setHighlighted:NO];
            [button setSelected:YES];
            [self performSelector:@selector(changeButtonState:) withObject:button afterDelay:0.0];

            break;
        }
        case kCurrentIsBrand:
            self.marketState=kCurrentIsSpec;
            code=[[NSString alloc] initWithFormat:@"%@;2,%@;3,000000",[defaults valueForKey:@"lastBrandCode"],
                  selectSale.code];
            preCode=[[NSString alloc] initWithFormat:@"%@;2,%@",[defaults valueForKey:@"lastBrandCode"],selectSale.code];
            [defaults removeObjectForKey:@"lastSpecCode"];
            [defaults setValue:preCode forKey:@"lastSpecCode"];
            [defaults synchronize];
            
            [self getDataFormCacheOrNet:code];
        default:
            break;
    }
    
}

- (void)marketMainTapped:(id)sender
{
    NSLog(@"martketMainTapped");
    [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
    [YDSaleStore removePath];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)marketIndustryTapped:(id)sender
{
    NSLog(@"marketIndustryTapped");
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if (self.marketState !=kCurrentIsInDustry) {
        if (self.marketState == kCurrentIsStruct) {
            UIButton *button=(UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:10002];
            button.enabled=YES;
            switch (self.lastStateForStruct) {
                case kCurrentIsInDustry:{
                    self.marketState=kCurrentIsInDustry;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;1,000000",[defaults valueForKey:@"lastIndustryCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1002];
                    break;
                }
                default:{
//                    [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
                    GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                                    initWithText:@"请先选择" showActivity:NO inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom inView:self.view];
                    [notificationView show:YES];
                    [notificationView hideAnimatedAfter:1.5];
                    break;
                }
            }

        }else if(self.marketState == kCurrentIsBrand){
            switch (self.lastStateForBrand) {
                case kCurrentIsInDustry:{
                    self.marketState=kCurrentIsInDustry;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;1,000000",[defaults valueForKey:@"lastIndustryCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1002];
                    break;
                }
                default:{
//                    [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
                    GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                                    initWithText:@"请先选择" showActivity:NO inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom inView:self.view];
                    [notificationView show:YES];
                    [notificationView hideAnimatedAfter:1.5];

                    break;
                }
            }
            
        }else{
            if (self.selectCode.length>0) {
                [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                self.marketState=kCurrentIsInDustry;
                NSString *code=[[NSString alloc] initWithFormat:@"%@;1,000000",self.selectCode];
                [defaults removeObjectForKey:@"lastIndustryCode"];
                [defaults setValue:self.selectCode forKey:@"lastIndustryCode"];
                [defaults synchronize];
                [self getDataFormCacheOrNet:code];
            }else{
//                [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
                GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                                initWithText:@"请先选择" showActivity:NO inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom inView:self.view];
                [notificationView show:YES];
                [notificationView hideAnimatedAfter:1.5];
            }
        }

    }else{
       [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
    }
}

- (void)marketBrandTapped:(id)sender
{
    NSLog(@"marketBrandTapped");
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if (self.marketState !=kCurrentIsBrand && self.marketState != kCurrentIsSpec) {
        if (self.marketState == kCurrentIsStruct) {
            UIButton *button=(UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:10002];
            button.enabled=YES;
            switch (self.lastStateForStruct) {
                case kCurrentIsBrand:{
                    self.marketState=kCurrentIsBrand;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",[defaults valueForKey:@"lastBrandCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1003];
                    break;
                }
                case kCurrentIsSpec:{
                    self.marketState=kCurrentIsSpec;
                    NSString *code=[[NSString alloc] initWithFormat:@"%@;3,000000",[defaults valueForKey:@"lastSpecCode"]];
                    [defaults setValue:code forKey:@"searchCode"];
                    [self backToLastLevelForCode:code buttonTag:1003];
                    break;
                }
                default:{
//                    [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
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
            if (self.selectCode.length>0) {
                [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                self.marketState=kCurrentIsBrand;
                NSString *code=[[NSString alloc] initWithFormat:@"%@;2,000000",self.selectCode];
                [defaults removeObjectForKey:@"lastBrandCode"];
                [defaults setValue:self.selectCode forKey:@"lastBrandCode"];
                [defaults synchronize];
                [self getDataFormCacheOrNet:code];
            }else{
//                [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
                GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                                initWithText:@"请先选择" showActivity:NO inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom inView:self.view];
                [notificationView show:YES];
                [notificationView hideAnimatedAfter:1.5];
            }
        }
        
    }else{
        [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
    }

}

- (void)marketStructTapped:(id)sender
{
    NSLog(@"marketStructTapped");
    if (self.marketState != kCurrentIsStruct) {
        if ([self.selectCode length] > 0) {
            [self performSelector:@selector(changeButtonState:) withObject:sender afterDelay:0.0];
            self.marketState=kCurrentIsStruct;
            
            UIButton *button=(UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:10002];
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
//            [self performSelector:@selector(holdButtonState:) withObject:sender afterDelay:0.0];
            GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]
                                                            initWithText:@"请先选择" showActivity:NO inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom inView:self.view];
            [notificationView show:YES];
            [notificationView hideAnimatedAfter:1.5];
        }
    }else{
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

- (void)dealloc {
    _tabButtons = nil;
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
