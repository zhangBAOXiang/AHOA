//
//  YDMenuSetController.m
//  YNOA
//
//  Created by 224 on 14-9-15.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDMenuSetController.h"
#import "YDMenuStore.h"

static NSString *CellIdentifier=@"menuSetIdentifier";
@interface YDMenuSetController ()

@property (strong, nonatomic) NSArray *menuArray;
@property (assign, nonatomic) NSUInteger selectedMenuIndex;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation YDMenuSetController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor=UIColorFromRGB(0x48ADE8);
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

    
    NSData *data=[defaults valueForKey:@"selectIndex"];
    if (data != nil) {
        NSIndexPath *indexPath=[NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.selectedMenuIndex=indexPath.section;
    }else{
        self.selectedMenuIndex=[defaults integerForKey:@"defaultMain"];
    }
    
    NSData *menuData=[defaults valueForKey:@"menuItems"];
    self.menuArray=[NSKeyedUnarchiver unarchiveObjectWithData:menuData];
    //allowtop为1的菜单项允许显示在主界面
    self.dataSource=[NSMutableArray array];
    for (YDMenu *menu in self.menuArray) {
        if ([menu.allowTop isEqualToString:@"1"]) {
            [self.dataSource addObject:menu];
        }
    }
    
    self.navigationItem.title=@"首页设置";
    
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(handleLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *btn1=[[UIButton alloc] init];
    [btn1 setImage:[UIImage imageNamed:@"firstpage.png"] forState:UIControlStateNormal];
    btn1.contentMode=UIViewContentModeCenter;
    [btn1 setFrame:CGRectMake(0, 0, 50, 63)];
    [btn1 addTarget:self action:@selector(handleRight) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn1];
    
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tableView.contentSize=CGSizeMake(self.view.frame.size.width, 50*[self.dataSource count]);
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    //    iOS7上tableview的分割线左边短了一点，用这个方法来解决
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)handleLeft
{
    self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleRight
{
    self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tableView Delegate Mehthods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    YDMenu *menu=self.dataSource[indexPath.section];
    cell.imageView.image=menu.Img;
    cell.textLabel.text=menu.menuName;
    cell.detailTextLabel.text=@"是否显示在主界面?";
    if (indexPath.section == self.selectedMenuIndex) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != self.selectedMenuIndex) {
        if (self.selectedMenuIndex != NSNotFound) {
            NSIndexPath *oldIndexPath=[NSIndexPath indexPathForRow:0 inSection:self.selectedMenuIndex];
            UITableViewCell *oldCell=[tableView cellForRowAtIndexPath:oldIndexPath];
            oldCell.accessoryType=UITableViewCellAccessoryNone;
        }
        //当前行选中
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        self.selectedMenuIndex=indexPath.section;
        //保留选中状态
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        //若直接[defaults setObject:indexPath forKey:]会报错:Attempt to set a non-property-list object
        [defaults removeObjectForKey:@"selectIndex"];
        [defaults setValue:[NSKeyedArchiver archivedDataWithRootObject:indexPath] forKey:@"selectIndex"];
        [defaults synchronize];
        
        YDMenu *selectMenu=self.dataSource[self.selectedMenuIndex];
//        [defaults setValue:[NSKeyedArchiver archivedDataWithRootObject:selectMenu] forKey:@"selectMenu"];
//        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"menuChanged"
                                                            object:[NSKeyedArchiver archivedDataWithRootObject:selectMenu]];
       
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
