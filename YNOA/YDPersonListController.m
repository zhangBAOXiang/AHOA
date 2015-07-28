//
//  YDPersonListController.m
//  HNOANew
//
//  Created by 224 on 14-7-24.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDPersonListController.h"
#import "YDPerson.h"
#import "YDPersonDetailController.h"
#import "YDContactViewController.h"
#import "YDSqliteUtil.h"
#import "YDAppDelegate.h"

@interface YDPersonListController (){
//    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    YDAppDelegate *appDelegate;
}

//@property (strong, nonatomic) MFMessageComposeViewController *picker;

@property (strong, nonatomic) NSMutableArray *personDataSource;
@property (strong, nonatomic) NSMutableArray *persons;

@property (copy, nonatomic) NSString *path;

@property (strong, nonatomic) NSMutableArray *filtedContactArray;//存储搜索结果

@end


@implementation YDPersonListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)personDataSource
{
    if (!_personDataSource) {
        _personDataSource=[YDSqliteUtil personInfoByDepartment:self.department];
        if (self.department.selected) {
            for (YDPerson *person in _personDataSource) {
                [person setSelected:YES];
            }
        }
    }
    return _personDataSource;
}

//- (NSString *)path
//{
//    if (!_path) {
//        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentDirectory=[paths objectAtIndex:0];
//        _path=[documentDirectory stringByAppendingPathComponent:@"persons"];
//
//    }
//    return _path;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    //背景图片
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:self.tableView.frame];
    imageView.image=[UIImage imageNamed:@"bg.png"];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:imageView];

    
//    NSData *data=[[NSMutableData alloc] initWithContentsOfFile:self.path];
//    NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSMutableDictionary *mobilecodes=[YDAppDelegate sharedMobileCodes];
    if ([mobilecodes valueForKey:self.department.departName] && self.department.selected) {
//        self.persons=[unarchiver decodeObjectForKey:self.department.departName];
//        [unarchiver finishDecoding];
        self.persons=[mobilecodes valueForKey:self.department.departName];
        
    }else{
         self.persons=self.personDataSource;
    }
    
    self.title=@"所有联系人";
    
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *btn2=[[UIButton alloc] init];
    [btn2 setImage:[UIImage imageNamed:@"firstpage.png"] forState:UIControlStateNormal];
    btn2.contentMode=UIViewContentModeCenter;
    [btn2 setFrame:CGRectMake(270, 0, 50, 63)];
    [btn2 addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn2];
    
    
    self.filtedContactArray=[NSMutableArray array];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //下拉刷新
//    if (_refreshHeaderView == nil) {
//		
//		EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
//		refreshView.delegate = self;
//		[self.tableView addSubview:refreshView];
//		_refreshHeaderView = refreshView;
//		
//	}
//	
//	//  update the last update date
//	[_refreshHeaderView refreshLastUpdatedDate];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    BOOL flag=NO;
    for (YDPerson *person in self.persons) {
        if (person.selected) {
            flag=YES;
            break;
        }
    }
    
    if (flag) {
//        NSMutableData *data=[NSMutableData data];
//        NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//        [archiver encodeObject:self.persons forKey:self.department.departName];
//        [archiver finishEncoding];
//        
//        [data writeToFile:self.path atomically:YES];
        
        NSMutableDictionary *mobilecodes=[YDAppDelegate sharedMobileCodes];
        NSMutableArray *departments=[YDAppDelegate sharedDepartments];
        [mobilecodes setValue:self.persons forKey:self.department.departName];
        [departments addObject:self.department.departName];
        
    }else{
//        NSFileManager *fileManger=[NSFileManager defaultManager];
//        if ([fileManger fileExistsAtPath:self.path isDirectory:NO]) {
//            [fileManger removeItemAtPath:self.path error:nil];
//        }
    }
    
//    //代理传值
//    if ([self.delegate respondsToSelector:@selector(setSelection:)]) {
//        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
//        [dict setValue:self.indexPath forKey:@"indexPath"];
//        [dict setValue:flag?@"yes":@"no" forKey:@"personSelected"];
//        [self.delegate setSelection:dict];
//    }
    
    if (self.returnBlock != nil) {
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setValue:self.indexPath forKey:@"indexPath"];
        [dict setValue:flag?@"yes":@"no" forKey:@"personSelected"];
        self.returnBlock(dict);
    }

}

- (void)returnText:(ReturnBolck)block
{
    self.returnBlock=block;
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

- (void)back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)home
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filtedContactArray count];
    }
    return [self.persons count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    YDPerson *person;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
         cell= [tableView dequeueReusableCellWithIdentifier:@"searchIndetifier"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchIndetifier"];
        }
        
        person=[self.filtedContactArray objectAtIndex:indexPath.row];
        cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
       
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"personListIdentifier"];
        
        // Configure the cell...
        if (cell == nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personListIdentifier"];
        }
        person=[self.persons objectAtIndex:indexPath.row];

    }
    
    if (person.selected) {
        cell.imageView.image=[UIImage imageNamed:@"cb_glossy_on.png"];
    }else{
        cell.imageView.image=[UIImage imageNamed:@"cb_glossy_off.png"];
    }
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 48, 24)];
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(33, 0, 15, 24)];
    imageView.image=[UIImage imageNamed:@"sign_choic_city.png"];
    [button addSubview:imageView];
    button.tag=indexPath.row;
    cell.accessoryView=button;

    cell.textLabel.text=person.personname;
    
    UITapGestureRecognizer *cellGesture=[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(cellRecognizer:)];
    
    cell.textLabel.userInteractionEnabled=YES;
    [cell.textLabel addGestureRecognizer:cellGesture];
    
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YDPerson *person;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        person=[self.filtedContactArray objectAtIndex:indexPath.row];
        if (!person.selected) {
            [person setSelected:YES];
        }else{
            [person setSelected:NO];
        }
        
        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath]
                                                                   withRowAnimation:NO];
    }else{
        person=[self.persons objectAtIndex:indexPath.row];
        if (!person.selected) {
            [person setSelected:YES];
        }else{
            [person setSelected:NO];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
}

- (void)cellRecognizer:(UITapGestureRecognizer*)recognizer
{
    
    UILabel *textLabel=(UILabel *)recognizer.view;
    YDPerson *person;
    int index=0;
    for (int i=0; i<[self.persons count]; i++) {
        person=self.persons[i];
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
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"SELF.personname contains[cd] %@ || SELF.mobilecode contains[cd] %@ || SELF.phonecode contains[cd] %@",searchString,searchString,searchString];
        self.filtedContactArray=[NSMutableArray arrayWithArray:[self.persons filteredArrayUsingPredicate:predicate]];
        
    }
    
    // 返回YES，让table view重新加载.
    return YES;
}

//#pragma mark - Data Source Loading / Reloading Methods
//
////开始重新加载时调用的方法
//- (void)reloadTableDataSource
//{
//    _reloading=YES;
//    //开始刷新后执行后台线程，在此之前可以开启HUD或其他对UI进行阻塞
//    [NSThread detachNewThreadSelector:@selector(doInBackGround) toTarget:self withObject:nil];
//}
//
////这个方法运行于子线程中，完成获取刷新数据的操作
//- (void)doInBackGround
//{
//    NSLog(@"doInBackGround");
//    
//    //更新数据源
//    [NSThread sleepForTimeInterval:3];
//    
//    //后台操作完成后，到主线程更新UI
//    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
//}
//
//
////完成加载时调用的方法
//- (void)doneLoadingTableViewData
//{
//    NSLog(@"doneLoadingTableViewData");
//    
//    _reloading=NO;
//    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
//    //刷新表格
//    [self.tableView reloadData];
//}
//
//
//#pragma mark - EGORefreshTableHeaderDelegate Methods
//
////下拉触发调用的委托方法
//- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
//{
//    [self reloadTableDataSource];
//    //    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
//}
//
////返回当前使刷新还是无刷新状态
//- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
//{
//    return _reloading;
//}
//
////返回刷新时间的回调方法
//- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
//{
//    return [NSDate date];
//}
//
//#pragma mark - UIScrollViewDelegate Methods
//
////滑动控件的委托
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
//}


//#pragma mark - MFMessageComposeViewController Delegate Methods
//
//- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
//{
//    // Notifies users about errors associated with the interface
//    switch (result) {
//        case MessageComposeResultCancelled:
//            NSLog(@"Result: Canceled");
//            break;
//            
//        case MessageComposeResultSent:
//            NSLog(@"Result: Sent");
//            break;
//            
//        case MessageComposeResultFailed:
//            NSLog(@"Result: Failed");
//            break;
//            
//        default:
//            break;
//    }
//    [self dismissViewControllerAnimated:YES completion:nil];
//}



@end
