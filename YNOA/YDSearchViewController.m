//
//  YDTestViewController.m
//  YNOA
//
//  Created by 224 on 14-10-24.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSearchViewController.h"
#import "YDCommonHead.h"
#import "YDBusinessName.h"
#import "YDBusinessStore.h"

@interface YDSearchViewController ()<UISearchBarDelegate,
UITableViewDataSource,UITableViewDelegate,BusinessSOAPDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (assign, nonatomic) NSInteger specType;//一类，二类，三类以上...
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (copy, nonatomic) NSString *searchString;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) YDBusinessStore *sharedStore;

@end

@implementation YDSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.delegate=self;
    
    self.navigationItem.title=@"搜索";
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x3da8e5)];
    self.navigationController.navigationBar.translucent=YES;
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self customTypeButtons];
    
    //设置tableview
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 149, self.view.frame.size.width, self.view.frame.size.height-100)
                                                style:UITableViewStylePlain];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=YES;
    self.HUD.labelText=@"加载数据..";
    [self.HUD show:YES];
    
    self.sharedStore = [YDBusinessStore sharedBusinessStore];
    self.sharedStore.businessDelegate = self;
    if ([self.sharedStore comPareDate:[NSDate date]]) {
        [self.HUD hide:YES];
        self.dataSource = [self.sharedStore unarchivedData:@"business"];
    } else {
        [self.sharedStore getBusinessSOAP:@"0"];
    }
    
    
}

- (void)customTypeButtons
{
    NSArray *buttonNames=[NSArray arrayWithObjects:@"全部", @"一类烟", @"二类烟", @"三类以上", @"细支", nil];
    float margin=(self.view.frame.size.width)/5;
    for (int i=0; i<5; i++) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(0+margin*i, 109, margin, 40)];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(handleType:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.numberOfTapsRequired=2;
        [button setTag:i+100];
        [button addGestureRecognizer:tap];
        CALayer *layer=[button layer];
        [layer setMasksToBounds:YES];
        [layer setBorderWidth:0.5];
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:button];
        if (i == 0) {
            button.selected=YES;
            self.specType=button.tag-100;
        }
    }
}

- (void)handleLeft
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

//双击
- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (self.searchString.length == 0) {
        UIButton *button=(UIButton *)tap.view;
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        UIButton *oldButton=(UIButton *)[self.view viewWithTag:self.specType+100];
        
        oldButton.selected=NO;
        button.selected=YES;
        self.specType=button.tag-100;
        
        NSLog(@"tag=%d",button.tag);
        
        [defaults setInteger:self.specType forKey:@"selectType"];
        [defaults setBool:YES forKey:@"searching"];
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"range" object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)handleType:(UIButton *)button
{
    UIButton *oldButton=(UIButton *)[self.view viewWithTag:self.specType+100];
    oldButton.selected=NO;
    button.selected=YES;
    self.specType=button.tag-100;
}


- (void)passBusinessArray:(NSMutableArray *)businessArray {
    self.dataSource = businessArray;
    [self.HUD hide:YES];
    
    [self.tableView reloadData];
    [self.sharedStore archivedData:businessArray forCode:@"business"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count]>0?[self.dataSource count]:0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchIndetifier"];
    
    YDBusinessName *business=[self.dataSource objectAtIndex:indexPath.row];
    for(int i=0;i<2;i++){
        UIButton *btn;
        btn=[[UIButton alloc]initWithFrame:CGRectMake(i*(self.view.frame.size.width/2), 0, self.view.frame.size.width/2, kHeight)];
        switch (i) {
            case 0:
                [btn setTitle:business.inputCode forState:UIControlStateNormal];
                break;
            case 1:
                [btn setTitle:business.name forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        
        
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setUserInteractionEnabled:NO];
        [cell.contentView addSubview:btn];
    }
    
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YDBusinessName *business=[self.dataSource objectAtIndex:indexPath.row];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.specType forKey:@"selectType"];
    [defaults setBool:YES forKey:@"searching"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"range" object:business];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, kHeight)];
    [view setBackgroundColor:[UIColor clearColor]];
    if ([self.dataSource count] >0) {
        NSArray *headNames=[[NSArray alloc] initWithObjects:@"简码", @"名称", nil];
        for(int i=0;i<2;i++){
            UIButton *btn;
            btn=[[UIButton alloc]initWithFrame:CGRectMake(i*(self.view.frame.size.width/2), 0, self.view.frame.size.width/2, kHeight)];
            [btn setTitle:headNames[i] forState:UIControlStateNormal];
            [btn setUserInteractionEnabled:NO];
            [btn setBackgroundColor:[UIColor colorWithRed:80/255 green:80/255 blue:80/255 alpha:0.3]];
            [view addSubview:btn];
        }
        return view;
        
    }else{
        return view;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 当用户改变搜索字符串时，让列表的数据来源重新加载数据
    // 根据搜索栏的内容和范围更新过滤后的数组。
    // 先将过滤后的数组清空。
    [self.dataSource removeAllObjects];
    self.searchString=searchText;
    //过滤数组
    if (searchText.length > 0) {
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"SELF.inputCode contains[cd] %@",searchText];
        self.dataSource=[NSMutableArray arrayWithArray:[[self.sharedStore unarchivedData:@"business"]filteredArrayUsingPredicate:predicate]];
        
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
