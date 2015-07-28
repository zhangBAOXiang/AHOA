//
//  YDSameViewController.m
//  HNOA
//
//  Created by 224 on 14-8-6.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSameViewController.h"
#import "YDSqliteUtil.h"
#import "YDDepartment.h"
#import "YDPerson.h"
#import "YDAppDelegate.h"
#import "YDPersonListController.h"
#import "YDPersonDetailController.h"

@interface YDSameViewController () <EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (strong ,nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) NSMutableArray *departDataSouce;
@property (strong, nonatomic) NSMutableArray *departments;
@property (strong, nonatomic) NSArray *allPersons;

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSMutableArray *filtedContactArray;//存储搜索结果

@property (strong, nonatomic) NSIndexPath *indexPath;

@end


@implementation YDSameViewController

- (NSMutableArray *)departDataSouce
{
    if (!_departDataSouce) {
        _departDataSouce=[YDSqliteUtil queryDepartment];
    }
    
    return _departDataSouce;
}

- (NSArray *)allPersons
{
    if (!_allPersons) {
        _allPersons=[YDSqliteUtil allPersons];
    }
    
    return _allPersons;
}

- (NSMutableArray *)departments
{
    if (!_departments) {
        _departments=self.departDataSouce;
    }
    if ([_departments count] == 0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提醒" message:@"请下拉刷新获取通讯录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    return _departments;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadTableDataSource];
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:self.tableView.frame];
    imageView.image=[UIImage imageNamed:@"bg.png"];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:imageView];
    
    self.filtedContactArray=[NSMutableArray array];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		refreshView.delegate = self;
		[self.tableView addSubview:refreshView];
		_refreshHeaderView = refreshView;
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filtedContactArray count];
    }else{
        return [self.departments count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YDPerson *person;
    YDDepartment *department;
    UITableViewCell *cell;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"searchIdentifier"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchIdentifier"];
        }
        person=[self.filtedContactArray objectAtIndex:indexPath.row];
        if (person.selected) {
            cell.imageView.image=[UIImage imageNamed:@"cb_glossy_on.png"];
        }else{
            cell.imageView.image=[UIImage imageNamed:@"cb_glossy_off.png"];
        }
        cell.textLabel.text=person.personname;
        
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 48, 24)];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(33, 0, 15, 24)];
        imageView.image=[UIImage imageNamed:@"sign_choic_city.png"];
        [button addSubview:imageView];
        button.tag=indexPath.row;
        cell.accessoryView=button;
        
        UITapGestureRecognizer *cellGesture=[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(detailRecognizer:)];
        
        cell.textLabel.userInteractionEnabled=YES;
        [cell.textLabel addGestureRecognizer:cellGesture];
        
        
    }else{
        cell=[tableView dequeueReusableCellWithIdentifier:@"personIdentifier"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personIdentifier"];
        }
        department=[self.departments objectAtIndex:indexPath.row];
        
        if (department.selected) {
            cell.imageView.image=[UIImage imageNamed:@"cb_glossy_on.png"];
        }else{
            cell.imageView.image=[UIImage imageNamed:@"cb_glossy_off.png"];
        }
        
        cell.textLabel.text=department.departName;
        //自定义cell的accessoryView
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 48, 24)];
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 24)];
        label.text=[[NSString alloc] initWithFormat:@"(%d)",department.personCount];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(33, 0, 15, 24)];
        imageView.image=[UIImage imageNamed:@"sign_choic_city.png"];
        [button addSubview:label];
        [button addSubview:imageView];
        button.tag=indexPath.row;
        cell.accessoryView=button;
        
        UITapGestureRecognizer *cellGesture=[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(cellRecognizer:)];
        
        cell.textLabel.userInteractionEnabled=YES;
        [cell.textLabel addGestureRecognizer:cellGesture];
        
    }
    
    cell.backgroundColor=[UIColor clearColor];
    
    return cell;
}

//部门选中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YDDepartment *department;
    YDPerson *person;
    NSMutableDictionary *mobilecodes=[YDAppDelegate sharedMobileCodes];
    NSMutableArray *departments=[YDAppDelegate sharedDepartments];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        person=[self.filtedContactArray objectAtIndex:indexPath.row];
        if (!person.selected) {
            [person setSelected:YES];
        }else{
            [person setSelected:NO];
        }
        
        //刷新搜索显示控制器的列表
        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath]
                                                                   withRowAnimation:NO];
    }else {
        department=[self.departments objectAtIndex:indexPath.row];
        if (!department.selected) {
            [department setSelected:YES];
            
            //测试
            NSArray *persons=[YDSqliteUtil personInfoByDepartment:department];
            for (YDPerson *person in persons) {
                [person setSelected:YES];
            }
            [mobilecodes setValue:persons forKey:department.departName];
            NSLog(@"array=%@",persons);
            
            [departments addObject:department.departName];
            
        }else{
            [department setSelected:NO];
            
            if (mobilecodes !=nil) {
                [mobilecodes removeObjectForKey:department.departName];
            }
            if (departments != nil) {
                [departments removeObject:department.departName];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)cellRecognizer:(UITapGestureRecognizer*)recognizer
{
    
    UILabel *textLabel=(UILabel *)recognizer.view;
    YDDepartment *department;
    int index=0;
    for (int i=0; i<[self.departments count]; i++) {
        department=self.departments[i];
        if ([department.departName isEqualToString:textLabel.text]) {
            index=i;
            break;
        }
    }
    
    //通过取得在tableview中的位置，取得所在的indexPath
    CGPoint currentPoint=[textLabel convertPoint:textLabel.bounds.origin toView:self.tableView];
    NSIndexPath *indexPath=[self.tableView indexPathForRowAtPoint:currentPoint];
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Contacts" bundle:nil];
    YDPersonListController *listController=[storyBoard instantiateViewControllerWithIdentifier:@"personlist"];
    listController.department=department;
    listController.indexPath=indexPath;
    [self.navigationController pushViewController:listController animated:YES];
    
    //block传值，接受listcontroller传过来的值动态确定部门选中
    [listController returnText:^(NSMutableDictionary *dict){
        NSIndexPath *indexPath=dict[@"indexPath"];
        
        YDDepartment *department=[self.departments objectAtIndex:indexPath.row];
        if ([dict[@"personSelected"] isEqualToString:@"yes"]) {
            [department setSelected:YES];
        }else {
            [department setSelected:NO];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }];
}

- (void)detailRecognizer:(UITapGestureRecognizer*)recognizer
{
    UILabel *textLabel=(UILabel *)recognizer.view;
    YDPerson *person;
    int index=0;
    for (int i=0; i<[self.filtedContactArray count]; i++) {
        person=[self.filtedContactArray objectAtIndex:i];
        if ([person.personname isEqualToString:textLabel.text]) {
            index=i;
            break;
        }
    }
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Contacts" bundle:nil];
    YDPersonDetailController *detailController=[storyBoard instantiateViewControllerWithIdentifier:@"personDetail"];
    detailController.person=person;
    [self.navigationController pushViewController:detailController animated:YES];
    
}

#pragma mark - Search Bar Delegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:@"searchIndetifier"];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // 当用户改变搜索字符串时，让列表的数据来源重新加载数据
    // 根据搜索栏的内容和范围更新过滤后的数组。
    // 先将过滤后的数组清空。
    [self.filtedContactArray removeAllObjects];
    //过滤数组
    if (searchString.length > 0) {
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"SELF.personname contains[cd] %@",searchString];
        self.filtedContactArray=[NSMutableArray arrayWithArray:[self.allPersons filteredArrayUsingPredicate:predicate]];
        
    }
    
    // 返回YES，让table view重新加载.
    return YES;
}

#pragma mark - Data Source Loading / Reloading Methods

//开始重新加载时调用的方法
- (void)reloadTableDataSource
{
    _reloading=YES;
    //开始刷新后执行后台线程，在此之前可以开启HUD或其他对UI进行阻塞
    
    self.HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    //如果设置此属性则当前的view置于后台
    self.HUD.dimBackground=YES;
    
    self.HUD.labelText=@"同步中...";
    
    //显示对花框
    [self.HUD show:YES];
    
    [NSThread detachNewThreadSelector:@selector(doInBackGround) toTarget:self withObject:nil];
}

//这个方法运行于子线程中，完成获取刷新数据的操作
- (void)doInBackGround
{
    NSLog(@"doInBackGround");
    
    //更新数据源
    [YDSqliteUtil updateDataSource];
    [YDSqliteUtil savePersonInfoFromRemote];
    [YDSqliteUtil saveDepartment];
    
    //后台操作完成后，到主线程更新UI
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}


//完成加载时调用的方法
- (void)doneLoadingTableViewData
{
    NSLog(@"doneLoadingTableViewData");
    [self.HUD hide:YES];
    
    _reloading=NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    //刷新表格
    self.departments=[YDSqliteUtil queryDepartment];
    [self.tableView reloadData];
    
    //选中第一个item
    self.tabBarController.selectedIndex=0;
}


#pragma mark - EGORefreshTableHeaderDelegate Methods

//下拉触发调用的委托方法
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableDataSource];
    //    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

//返回当前使刷新还是无刷新状态
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

//返回刷新时间的回调方法
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate Methods

//滑动控件的委托
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

@end
