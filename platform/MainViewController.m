//
//  MainViewController.m
//  platform
//
//  Created by apple on 13-9-3.
//  Copyright (c) 2013年 zoomlgd. All rights reserved.
//

#import "MainViewController.h"
#import "GradientButton.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (assign, nonatomic) sqlite3 *database;
@property (strong, nonatomic) NSMutableArray *channelArray;
@property (strong, nonatomic) NSMutableArray *reportArray;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIActivityIndicatorView *indicator2;
@property (strong, nonatomic) UILabel *synchLabel;

@property(strong, nonatomic) UIView *sysContainer;
@property(strong, nonatomic) UIScrollView *webContainer;
@property(strong, nonatomic) UIScrollView *menuContainer;
@property(strong, nonatomic) UIPageControl *pageControl;
@property(assign, nonatomic) BOOL pageControlUsed;
@property(strong, nonatomic) UIView *indicatorView;

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) CLLocation *checkLocation;
@property(strong, nonatomic) CLPlacemark *placemark;
@property(strong, nonatomic) PCStackMenu *stackMenu;

@property(strong, nonatomic) AreaStruct * myAreaStruct;
@property(strong, nonatomic) NSMutableDictionary *myLocation;


@end

@implementation MainViewController

//color
#define RGB(r, g, b)             [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define RGBAlpha(r, g, b, a)     [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]


@synthesize delegate;
@synthesize webContainer;
@synthesize menuContainer;
@synthesize pageControl;
@synthesize pageControlUsed;

#define     TOP_HEIGHT              78
#define     CONTENT_HEIGHT          600
#define     BOTTOM_HEIGHT           80
#define     BORDER_WIDTH            16
#define     SETTING_WIDTH           50
#define     SYSTEM_MENU_START_X     415
#define     SYSTEM_MENU_START_Y     35
#define     SYSTEM_MENU_WIDTH       100
#define     SYSTEM_MENU_HEIGHT      35




#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = [[UIApplication sharedApplication]delegate];
        [self setupLocationManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat width = [UIScreen mainScreen].bounds.size.height;
    CGFloat height = [UIScreen mainScreen].bounds.size.width;
    
    self.webContainer = [[UIScrollView alloc]initWithFrame:CGRectMake(BORDER_WIDTH, TOP_HEIGHT, width-BORDER_WIDTH*2, height-TOP_HEIGHT-BOTTOM_HEIGHT)];
    
    //加载areaStruct
    self.myAreaStruct = [[AreaStruct alloc]init];
    self.myLocation = [NSMutableDictionary dictionary];

    //创建web container
    self.webContainer.pagingEnabled = YES;
    self.webContainer.showsHorizontalScrollIndicator = NO;
    self.webContainer.showsVerticalScrollIndicator = NO;
    self.webContainer.scrollsToTop = NO;
    self.webContainer.delegate = self;
    [self.view addSubview:self.webContainer];
    //创建page control
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, TOP_HEIGHT+self.webContainer.frame.size.height, [UIScreen mainScreen].bounds.size.height, 20)];
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    //创建menu container
    self.menuContainer = [[UIScrollView alloc]initWithFrame:CGRectMake(16, height-BOTTOM_HEIGHT, width-BORDER_WIDTH*2-SETTING_WIDTH, BOTTOM_HEIGHT)];
    [self.menuContainer setBounces:YES];
//    [self.menuContainer setBackgroundColor:[UIColor blackColor]];
    [self.menuContainer setContentMode:UIViewContentModeRight];
    [self.view addSubview:self.menuContainer];
    
    // 系统功能菜单
    SEL eventHandler = @selector(sysBtnClickHandler:);
    UIButton *gearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [gearBtn setFrame:CGRectMake(width-SETTING_WIDTH*2, height-BOTTOM_HEIGHT+10, SETTING_WIDTH, SETTING_WIDTH)];
    gearBtn.tag = 61000;
    [gearBtn setBackgroundImage:[UIImage imageNamed:@"btn_gear"] forState:UIControlStateNormal];
    [gearBtn addTarget:self action:eventHandler forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gearBtn];

    
    //绘制页面
    [self redrawIpadView];
    //登录后自动同步
    [self detectReachbility];
}

// 重新绘制页面
- (void) redrawIpadView
{
    //清除缓存（控件）
    for (UIView *subView in [self.menuContainer subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [self.webContainer subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [self.sysContainer subviews]) {
        [subView removeFromSuperview];
    }
    [self.channelArray removeAllObjects];
    [self.reportArray removeAllObjects];
    
    // 加载本地已有数据
    [self prepareDataForNavTableView];
    //创建系统按钮
    NSInteger firstSystemId = [self drawSystemButtons:self.channelArray];
    //加载第一个子系统
    if (firstSystemId!=-1) {
        [self sysChangeProcess:firstSystemId];
    }

}


#pragma mark - prepare the data
- (void) prepareDataForNavTableView
{    
    // 获取本地数据库数据
    // 生成系统菜单数组
    if (![self loadNavData]) {
        NSLog(@"生成系统按钮system container数据失败！");
        return;
    }
    if ([self.channelArray count]<=0) {
        NSLog(@"本地没有任何数据！");
        // TODO:联网同步
        return;
    }
    // 默认加载第一项：生成内容(右边)页面cell数组
    NSString *code = [[NSDictionary dictionaryWithDictionary:[self.channelArray objectAtIndex:0]] objectForKey:@"code"];
    //获取本地数据库数据
    if (![self loadConDataByCode: code]) {
        NSLog(@"生成菜单按钮web container数据失败！！");
    };
}



#pragma mark - sqlite3

- (BOOL) openDB
{
    NSString *dbFilePath = [[commonUtil docPath] stringByAppendingPathComponent:@"mydb"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dbFilePath]) {
        //数据库已存在
        if (sqlite3_open([dbFilePath UTF8String], &_database) == SQLITE_OK) {
            return YES;
        } else{
            UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"打开本地数据库失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alter show];
            return NO;
        }
    } else {
        //创建数据库表
        if ( sqlite3_open([dbFilePath UTF8String], &_database) == SQLITE_OK) {
            //table commonfiles暂不做处理
            //table channel
            const char *mySql = "create table if not exists mytable(id integer primary key autoincrement, code text unique, parentcode text, title text, indexfile text, image text, imageurl text, content text, version integer default -1, serverversion integer, offline integer, isactive integer, ordertag text)";
            
            NSInteger cnt = 0;
            while (cnt <3 && ![self createTable:mySql]) {
                cnt += 1;
            }
            if (cnt>=3) {
                //尝试三次，如果失败则退出
                UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"创建本地数据库失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alter show];
                return NO;
            }
            
        }
        return YES;
    }
    
}

- (BOOL) createTable: (const char*) sql
{
    char *errorMsg;
    if (sqlite3_exec(_database, sql, NULL, NULL, &errorMsg) == SQLITE_OK) {
        NSLog(@"successfully::::::%s", sql);
        return YES;
    }
    else {
        NSLog(@"error:::::%s", sql);
        sqlite3_free(errorMsg);
        return NO;
    }
}

- (BOOL) loadNavData
{
    if (![self openDB]) {
        return NO;
    }
    const char *selectSql = "select id, code, title, image from mytable where parentcode='' and code<>'0' and isactive=1 order by ordertag";
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, selectSql, -1, &statement, nil);
    if (result == SQLITE_OK) {
        self.channelArray = [NSMutableArray array];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSInteger id = sqlite3_column_int(statement, 0);
            NSString *code = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 1)];
            NSString *title = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 2)];
            NSString *image = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 3) ];
            
            NSMutableDictionary *theDict = [NSMutableDictionary dictionary];
            [theDict setValue:[NSNumber numberWithInt:id] forKey:@"id"];
            [theDict setValue:code forKey:@"code"];
            [theDict setValue:title forKey:@"title"];
            [theDict setValue:image forKey:@"image"];
            
            [self.channelArray addObject:theDict];
        }
        sqlite3_finalize(statement);
        
        [self closeDB];
        return YES;
    }
    else {
        [self closeDB];
        return NO;
    }
    
}

-(BOOL) loadConDataById: (NSInteger) systemId
{
    NSString *selectSql = [NSString stringWithFormat:@"select id, code, parentcode, title, indexfile, image, content, offline from mytable where parentcode=(select code from mytable where id=%d) and isactive=1 order by ordertag", systemId] ;
    return [self loadConData:selectSql];
}

-(BOOL) loadConDataByCode: (NSString*) menuCode
{
    NSString *selectSql = [NSString stringWithFormat:@"select id, code, parentcode, title, indexfile, image, content, offline from mytable where parentcode='%@' and isactive=1 order by ordertag", menuCode] ;
    return [self loadConData:selectSql];
}

- (BOOL) loadConData: (NSString*) selectSql
{
    if (![self openDB]) {
        return NO;
    }
    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, [selectSql UTF8String], -1, &statement, nil);
    if (result == SQLITE_OK) {
        self.reportArray = [NSMutableArray array];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSInteger id = sqlite3_column_int(statement, 0);
            NSString *code = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 1)];
            NSString *parentCode = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 2)];
            NSString *title = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 3) ];
            NSString *indexfile = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 4) ];
            NSString *image = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 5) ];
            NSString *content = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 6) ];
            NSInteger offline = sqlite3_column_int(statement, 7);
            
            NSMutableDictionary *theDict = [NSMutableDictionary dictionary];
            [theDict setValue:[NSNumber numberWithInt:id] forKey:@"id"];
            [theDict setValue:code forKey:@"code"];
            [theDict setValue:parentCode forKey:@"parentCode"];
            [theDict setValue:title forKey:@"title"];
            [theDict setValue:indexfile forKey:@"indexfile"];
            [theDict setValue:image forKey:@"image"];
            [theDict setValue:content forKey:@"content"];
            [theDict setValue:[NSNumber numberWithInt:offline] forKey:@"offline"];
            
            [self.reportArray addObject:theDict];
        }
        sqlite3_finalize(statement);
        
        [self closeDB];
        return YES;
    }
    else {
        [self closeDB];
        return NO;
    }
    
    return YES;
}

// 返回值，1连接目的服务器正常，0无法连接目的服务器
- (NSInteger) gainAndReplaceSqliteTable
{
    // 1.获取服务器最新数据列表xml
    NSArray *reportData = [self mobileGetSystemXmlData];
    if (reportData == nil) {
        return 0;
    }
    //4 插入或更新数据库
    for (NSInteger n=[reportData count], i=0; i<n; i++) {
        NSDictionary *theDict = [reportData objectAtIndex:i];
        NSString *code = [theDict objectForKey:@"code"];
        NSString *parentCode = [theDict objectForKey:@"parentcode"];
        NSString *title = [theDict objectForKey:@"title"];
        NSString *imageUrl = [theDict objectForKey:@"image"];
        NSString *image = [[imageUrl componentsSeparatedByString:@"/"] lastObject];
        NSString *indexfile = [theDict objectForKey:@"index"];
        NSString *content = [theDict objectForKey:@"content"];
        NSNumber *serverVersion = [theDict objectForKey:@"version"];
        NSNumber *offline = [theDict objectForKey:@"offline"];
        NSNumber *isactive = [theDict objectForKey:@"isactive"];
        NSString *ordertag = [theDict objectForKey:@"ordertag"];
        
        //系统图片同时下载， 菜单图片在同步数据时按需下载
        if ([parentCode isEqualToString:@""] && ![imageUrl isEqualToString:@""]) {
            //下载图片
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.delegate.gServerAddress stringByAppendingString:imageUrl]]];
            [commonUtil writeFileToLocal:imgData savedPath:[NSString stringWithFormat:@"%@",code] savedName:image];
        }
        
        NSArray *fields = [NSArray arrayWithObjects: code, parentCode, title, image, imageUrl, indexfile, content, serverVersion, offline, isactive, ordertag, nil];
        
        //更新记录
        if (![self insertOrUpdateSqliteTable:fields]) {
            NSLog(@"更新记录失败!code====%@",code);
        }
    }
    return 1;
}

// 插入或更新 表
- (BOOL) insertOrUpdateSqliteTable: (NSArray*)fileds
{
    BOOL returnValue = NO;
    if (![self openDB]) {
        NSLog(@"更新表，打开数据库失败！");
        return NO;
    }
    NSString *selectSql = [NSString stringWithFormat:@"select 1 from mytable where code='%@'",fileds[0]];
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, [selectSql UTF8String], -1, &statement, nil);
    if (result == SQLITE_OK) {
        NSString *replaceSql = @"";
        if (sqlite3_step(statement) == SQLITE_ROW) {
            replaceSql = [NSString stringWithFormat:@"update mytable set code='%@', parentcode='%@', title='%@', image='%@', imageurl='%@', indexfile='%@', content='%@', serverversion=%d, offline=%d, isactive=%d, ordertag='%@' where code='%@' ", fileds[0], fileds[1], fileds[2], fileds[3], fileds[4], fileds[5], fileds[6], [fileds[7]intValue], [fileds[8]intValue], [fileds[9]intValue],fileds[10], fileds[0] ];
        } else {
            replaceSql = [NSString stringWithFormat:@"insert into mytable (code, parentcode, title, image, imageurl, indexfile, content, serverversion, offline, isactive, ordertag) values('%@', '%@', '%@', '%@', '%@', '%@', '%@', %d, %d, %d, '%@') ", fileds[0], fileds[1], fileds[2], fileds[3], fileds[4], fileds[5], fileds[6], [fileds[7]intValue], [fileds[8]intValue], [fileds[9]intValue],fileds[10]];
        }
        char *errorMsg;
        if (sqlite3_exec(_database, [replaceSql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMsg) == SQLITE_OK)
        {
            returnValue = YES;
        }
        else {
            returnValue = NO;
        }

        sqlite3_finalize(statement);
        [self closeDB];
    }
    else {
        [self closeDB];
    }
    return returnValue;
    
}

// 获取要下载的文档列表
- (NSArray*) getUpdateList
{
    if (![self openDB]) {
        return nil;
    }
    const char *selectSql = "select id, code, parentcode, content, imageurl, image, offline from mytable where serverversion>version and parentcode<>'' and isactive=1 ";
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, selectSql, -1, &statement, nil);
    if (result == SQLITE_OK) {
        NSMutableArray *theArray = [NSMutableArray array];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSInteger id = sqlite3_column_int(statement, 0);
            NSString *code = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 1)];
            NSString *parentCode = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 2)];
            NSString *content = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 3)];
            NSString *imageUrl = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 4)];
            NSString *image = [[NSString alloc] initWithUTF8String: (char*)sqlite3_column_text(statement, 5)];
            NSInteger offline = sqlite3_column_int(statement, 6);
            
            NSMutableDictionary *theDict = [NSMutableDictionary dictionary];
            [theDict setValue:[NSNumber numberWithInt:id] forKey:@"id"];
            [theDict setValue:code forKey:@"code"];
            [theDict setValue:parentCode forKey:@"parentCode"];
            [theDict setValue:content forKey:@"content"];
            [theDict setValue:imageUrl forKey:@"imageUrl"];
            [theDict setValue:image forKey:@"image"];
            [theDict setValue:[NSNumber numberWithInt:offline] forKey:@"offline"];
            
            [theArray addObject:theDict];
        }
        sqlite3_finalize(statement);
        
        [self closeDB];
        return theArray;
    }
    else {
        [self closeDB];
        return nil;
    }
    
}

//修改下载状态
- (void) updateVersionToServerVersion: (NSString*)code
{
    if (![self openDB]) {
        NSLog(@"打开数据库失败！");
    }
    NSString *updateSql = [NSString stringWithFormat:@"update mytable set version=serverversion where code='%@'", code];
    char *errorMsg;
    int result = sqlite3_exec(_database, [updateSql UTF8String], NULL, NULL, &errorMsg);
    if (result == SQLITE_OK) {
        NSLog(@"successfully::::::%@", updateSql);
    }
    else {
        NSLog(@"error:::::%@", updateSql);
        sqlite3_free(errorMsg);
    }
    [self closeDB];
}

- (void) closeDB
{
    sqlite3_close(self.database);
}



#pragma mark - synchronise data
//检测网络类型（3g or wi-fi）
- (void) detectReachbility
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无网络连接！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            break;
        }
        case ReachableViaWWAN:
        {//使用3G网络
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前使用2G/3G网络，继续同步？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            [alert setTag:3331];
            [alert show];
            break;
        }
        case ReachableViaWiFi:
        {//wi-fi网络
            [self synchroniseData];
            break;
        }
        default:
            break;
    }

}

//数据同步
- (void)synchroniseData
{    
    //1 显示等待
    /*[self.synchLabel setText:@"正在同步..."];
    [self.synchLabel setAlpha:1.0];*/
    [self showActivityIndicator:1];
    
    __weak MainViewController *weakself = self;
    __block int causeReturn = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //2.1 获取服务器最新数据列表xml,并更新本地数据库
        if ([weakself gainAndReplaceSqliteTable]) {

            //2.2 需要下载的文档列表
            NSArray *theArray = [NSArray arrayWithArray:[weakself getUpdateList]];
            //3 发送请求，获取数据
            for (NSInteger i=0, n=[theArray count]; i<n; i++) {
                
                NSDictionary *theDict = [theArray objectAtIndex:i];
                NSString *parentCode = [theDict objectForKey:@"parentCode"];
                NSString *code = [theDict objectForKey:@"code"];
                NSString *imageUrl = [theDict objectForKey:@"imageUrl"];
                NSString *image = [theDict objectForKey:@"image"];
                NSInteger offline = [[theDict objectForKey:@"offline"]intValue];
                
                //创建本地文件夹
                NSString *savePath;
                if ([code isEqualToString:@"0"]) {
                    savePath = [commonUtil docPath];
                }
                else {
                    savePath = [[commonUtil docPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",parentCode, code]];
                }
                BOOL isDir;
                NSFileManager *fm = [NSFileManager defaultManager];
                if (!([fm fileExistsAtPath:savePath isDirectory:&isDir]&&isDir)) {
                    BOOL bo = [fm createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
                    if (!bo) {
                        NSLog(@"创建目录:%@/%@/失败!",parentCode,code);
                        continue;
                    }
                }
                
                //3.1 清除本地文件
                if (![code isEqualToString:@"0"]) {
                    [commonUtil emptyFilesAtPath:[NSString stringWithFormat:@"%@/%@",parentCode, code]];
                }
                //3.3 下载按钮图片
                if (![imageUrl isEqualToString:@""]) {
                    //下载图
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[delegate.gServerAddress stringByAppendingString:imageUrl]]];
                    [commonUtil writeFileToLocal:imgData savedPath:[NSString stringWithFormat:@"%@/%@",parentCode, code] savedName:image];
                }

                //3.2 下载文档压缩包
                if (offline==1) {
                    NSString *requestUrl = [weakself.delegate.gServerHost stringByAppendingPathComponent:[theDict objectForKey:@"content"]];
                    NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:requestUrl]];
                    if (data != nil) {
                        //4 保存到本地文件
                        [data writeToFile:[savePath stringByAppendingPathComponent:@"temp.zip"] atomically:YES];
                        //5 解压并删除压缩包
                        [SSZipArchive unzipFileAtPath:[savePath stringByAppendingPathComponent:@"temp.zip"] toDestination:savePath overwrite:YES password:nil error:nil];
                        [fm removeItemAtPath:[savePath stringByAppendingPathComponent:@"temp.zip"] error:nil];
                        //6 更新数据库，修改下载状态
                        [weakself updateVersionToServerVersion:code];
                        NSLog(@"%@/%@/成功!",parentCode, code);
                        
                    }
                }
            }
        } else {
            causeReturn = 1;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //7 移除等待状态
            [weakself hideActivityIndicator:1];
            /*[weakself.synchLabel setText:@"同步完成,请点击［重新加载］以生效。"];*/
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            
            if (causeReturn==0) {
                //8 在页面提示：“同步完成，是否重新加载？“
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"同步完成，是否重新加载？" delegate:weakself cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
                [alert setTag:3332];
                [alert show];
            }
            
            NSLog(@"数据更新［同步］完成！");
        });
    });
}

//web service获取channel data
- (NSMutableArray*) mobileGetSystemXmlData
{
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>\n"
                             "<ns1:mobileGetSystem xmlns:ns1=\"%@\">"
                             "<arg0>%@</arg0>"
                             "</ns1:mobileGetSystem>"
                             "</soap:Body>\n"
                             "</soap:Envelope>",self.delegate.gServerHost, self.delegate.gPersonId];
    NSMutableDictionary *theDict = [commonUtil soapCall:self.delegate.gServerHost postMethod:@"" postData:soapMessage];
    NSError *err = [theDict objectForKey:@"err"];
    NSData *data = [theDict objectForKey:@"data"];
    
    if (err) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self hideActivityIndicator:1];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无法连接到目的服务器！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            NSLog(@"无法连接到目的服务器！");
        });
        return nil;
    }
    else if (!data)
    {
        NSLog(@"mobileGetSystem 没有返回数据!");
        return nil;
    }
    else
    {
        NSString *returnSoapXML = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString *methodName = @"mobileGetSystem";
        NSString *result = [SoapXmlParseHelper SoapMessageResultXml:returnSoapXML ServiceMethodName:methodName];
        
        NSMutableArray *theArray = [NSMutableArray arrayWithArray:[SoapXmlParseHelper XmlToArray:result]];
        return theArray;
    }
    
}



#pragma mark - system buttons
//绘制子系统按钮，返回－1时表示没有子系统菜单数据
- (NSInteger) drawSystemButtons: (NSArray*)theArray
{
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    NSInteger coordinateX = SYSTEM_MENU_START_X;
    
    //创建系统菜单容器
    self.sysContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.height, TOP_HEIGHT)];
    self.sysContainer.clipsToBounds = YES;
    [self.view addSubview:self.sysContainer];
    
    SEL eventHandler = @selector(sysBtnClickHandler:);
    
    NSInteger num = [theArray count];
    NSInteger firstSystemId = -1;
    
    if (num==1) {
        firstSystemId = [[[theArray objectAtIndex:0] objectForKey:@"id"]intValue];
    }
    else {
        for (NSInteger i=0; i<num; i++)
        {
            NSMutableDictionary *theDict = [theArray objectAtIndex:i];
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(coordinateX, 35, SYSTEM_MENU_WIDTH, SYSTEM_MENU_HEIGHT)];
//            GradientButton *btn = [[GradientButton alloc]initWithFrame:CGRectMake(coordinateX, 35, SYSTEM_MENU_WIDTH, SYSTEM_MENU_HEIGHT)];
//            [btn useTouchUp4YNStyle];
            
            btn.tag = [[theDict objectForKey:@"id"] intValue];
            if (firstSystemId==-1) {
                firstSystemId = btn.tag;
            }
            
            //按钮背景
//            [btn setBackgroundColor:[UIColor yellowColor]];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
            [btn setTitle:[theDict objectForKey:@"title"] forState:UIControlStateNormal];
            
//            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [btn setBackgroundColor:[UIColor whiteColor]];
            /*NSString *imagePath = [[commonUtil docPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", [theDict objectForKey:@"code"],[theDict objectForKey:@"image"]]];
            if ([commonUtil fileExists:imagePath]) {
                [btn setBackgroundImage: [UIImage imageWithContentsOfFile: imagePath] forState:UIControlStateNormal];
            }*/
            [btn addTarget:self action:eventHandler forControlEvents:UIControlEventTouchUpInside];
            
            CALayer *btnLayer = [btn layer];
            [btnLayer setMasksToBounds:YES];
            [btnLayer setCornerRadius:10.0];
            [btnLayer setBorderWidth:1.0];
            [btnLayer setBorderColor:[HexRGB(0xe0e0e0) CGColor]];
            
            [self.sysContainer addSubview:btn];
            coordinateX += SYSTEM_MENU_WIDTH-1;
            
        }
    }
    //创建加载等待指示器
    [self createActivityIndicator];

    return firstSystemId;
}

//子系统按钮事件处理函数
- (void)sysBtnClickHandler: (id)sender
{
    NSInteger systemId = [sender tag];
    if (systemId == 61000) {
        UIButton *button = (UIButton *)sender;
        _stackMenu = [[PCStackMenu alloc] initWithTitles:[NSArray arrayWithObjects:@"同步数据", @"清空本地",  @"退出登录", nil]
            withImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"btn_synch2"], [UIImage imageNamed:@"btn_trash"], [UIImage imageNamed:@"btn_quit"], nil]
            atStartPoint:CGPointMake(button.frame.origin.x, button.frame.origin.y)
            inView:self.view
            itemHeight:30
            menuDirection:PCStackMenuDirectionClockWiseUp];
        
        for(PCStackMenuItem *item in _stackMenu.items)
        {
//            item.stackTitleLabel.textColor = [UIColor blackColor];
        }
        
        [_stackMenu show:^(NSInteger selectedMenuIndex) {
            NSLog(@"menu index : %d", selectedMenuIndex);
            switch (selectedMenuIndex) {
                case 0:
                {
                    [self detectReachbility];
                    break;
                }
                case 1:
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定清空本地数据？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alert setTag:3333];
                    [alert show];
                    break;
                }
                case 2:
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    break;
                }
                default:
                    break;
            }
        }];
    }
    else {
        [self sysChangeProcess:systemId];
    }
}

//子系统切换
- (void)sysChangeProcess: (NSInteger)systemId
{
    //清除缓存（控件）
    for (UIView *subView in [self.menuContainer subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [self.webContainer subviews]) {
        [subView removeFromSuperview];
    }
    [self.reportArray removeAllObjects];
    
    //修改系统菜单大小
    for (GradientButton *btn in [self.sysContainer subviews]) {
//        CGRect frame = btn.frame;
        if (btn.tag == systemId) {
            // TODO:
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [btn setBackgroundColor:[UIColor darkGrayColor]];
//            [btn useTouchDown4YNStyle];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg_h.png"] forState:UIControlStateNormal];
        }
        else {
            // TODO:
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [btn setBackgroundColor:[UIColor whiteColor]];
//            [btn useTouchUp4YNStyle];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
        }
    }
    
    NSInteger padding = 10;
    NSInteger menuW = 50;
    NSInteger menuH = 50;
    SEL eventHandler = @selector(menuBtnClickHandler:);
    //获取本地数据库数据
    if (![self loadConDataById:systemId]) {
        NSLog(@"生成菜单按钮web container数据失败！");
    };

    NSInteger num = [self.reportArray count];
    
    for (NSInteger i=0; i<num; i++)
    {
        //添加按钮
        NSMutableDictionary *theDict = [self.reportArray objectAtIndex:i];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(padding+i*100, 10, menuW, menuH)];
        btn.tag = i;  //tag 用索引值代替
        
        //按钮背景
        NSString *imagePath = [[commonUtil docPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@", [theDict objectForKey:@"parentCode"],[theDict objectForKey:@"code"],[theDict objectForKey:@"image"]]];
        if ([commonUtil fileExists:imagePath]) {
            [btn setBackgroundImage: [UIImage imageWithContentsOfFile: imagePath] forState:UIControlStateNormal];
        }
        //按钮事件
        [btn addTarget:self action:eventHandler forControlEvents:UIControlEventTouchUpInside];
        [self.menuContainer addSubview:btn];
        
        //添加webview
        UIWebView *uwv = [[UIWebView alloc]initWithFrame:  CGRectMake(self.webContainer.frame.size.width*i, 0, self.webContainer.frame.size.width, self.webContainer.frame.size.height)];
        uwv.scrollView.bounces = NO;
        uwv.scalesPageToFit = YES;
        [uwv setDelegate:self];
        
        /*MTMagnifyView *magnifyView = [[MTMagnifyView alloc]initWithFrame: CGRectMake(self.webContainer.frame.size.width*i, 0, self.webContainer.frame.size.width, self.webContainer.frame.size.height)];
        [magnifyView addSubview2:uwv];
         */
        
        [self.webContainer addSubview:uwv];
        
    }
    
    self.pageControl.numberOfPages = num;
    //设定web container 和 menu container 大小
    CGSize webContainerSize = CGSizeMake(self.webContainer.frame.size.width*num, self.webContainer.frame.size.height);
    [self.webContainer setContentSize: webContainerSize];
    CGSize menuContainerSize = CGSizeMake(padding*2+(num*2-1)*menuW, self.menuContainer.frame.size.height);
    [self.menuContainer setContentSize:menuContainerSize];
    
    //加载子系统第一个页面
    if (num>0) {
        [self menuChangeProcess:0];
    }
}

//menu 点击事件
- (void)menuBtnClickHandler: (id)sender
{
    NSInteger menuIndex = [sender tag];
    [self menuChangeProcess: menuIndex];
}

- (NSInteger)menuChangeProcess:(NSInteger)menuIndex
{
    //修改选中按钮样式
    for (UIButton *btn in [self.menuContainer subviews]) {
        CGRect frame = btn.frame;
        if (btn.tag == menuIndex) {
            if (frame.size.width==65) {
                [btn setFrame:CGRectMake(frame.origin.x, 2, 65, 65)];
            } else {
                [btn setFrame:CGRectMake(frame.origin.x-7, 2, 65, 65)];
            }
        }
        else {
            if (frame.size.width==50) {
                [btn setFrame:CGRectMake(frame.origin.x, 10, 50, 50)];
            } else {
                [btn setFrame:CGRectMake(frame.origin.x+7, 10, 50, 50)];
            }
        }
    }
    
    [self scrollToPage:menuIndex];
    
    return 0;
}


#pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (pageControlUsed) {
        return;
    }
    CGFloat pageWidth = self.webContainer.frame.size.width;
    int page = floor((self.webContainer.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControlUsed = NO;
    NSInteger page = self.pageControl.currentPage;
    //修改选中按钮样式
    for (UIButton *btn in [self.menuContainer subviews]) {
        CGRect frame = btn.frame;
        if (btn.tag == page) {
            if (frame.size.width==65) {
                [btn setFrame:CGRectMake(frame.origin.x, 2, 65, 65)];
            } else {
                [btn setFrame:CGRectMake(frame.origin.x-7, 2, 65, 65)];
            }
        }
        else {
            if (frame.size.width==50) {
                [btn setFrame:CGRectMake(frame.origin.x, 10, 50, 50)];
            } else {
                [btn setFrame:CGRectMake(frame.origin.x+7, 10, 50, 50)];
            }
        }
    }
    
    for (int i=0, n=[self.webContainer.subviews count]; i<n; i++) {
        UIWebView *uv = [self.webContainer.subviews objectAtIndex:i];
        if (i==page) {
            /*UIView *uwv = [(MTMagnifyView*)uv contentView];
            if ([uwv isMemberOfClass:[UIWebView class]] && ![(UIWebView*)uwv request].URL) {
                [self loadThePage:page];
            }*/
            if (![uv request].URL) {
                [self loadThePage:page];
            }

        } else {
            /*NSString *meta = @"document.getElementsByName(\"viewport\")[0].content = \"minimum-scale=1.0, maximum-scale=1.0, initial-scale=1.0, width=990.0, user-scalable=yes\"";
            [uv stringByEvaluatingJavaScriptFromString:meta];*/
        }
    }
    
}

- (void)scrollToPage: (NSInteger)page
{
    CGRect frame = self.webContainer.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.webContainer scrollRectToVisible:frame animated:YES];
    
    [self loadThePage:page];
}


#pragma mark - activity indicator
- (void)createActivityIndicator
{
    // 加载等待指示符
    int width=32, height=32;
    CGRect gearBtnFrame = [self.view viewWithTag:61000].frame;
    _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(775, 34, width, height)];
//    [_indicator setCenter:CGPointMake(gearBtnFrame.origin.x+SETTING_WIDTH/2, gearBtnFrame.origin.x+SETTING_WIDTH/2)];
    [_indicator setCenter:CGPointMake(400, 50)];
    
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:_indicator];
    
    [[self.view viewWithTag:71100] removeFromSuperview];
    CGRect frame = [[UIScreen mainScreen]bounds];
    int x = frame.size.height;
    int y = frame.size.width;
    
    // 页面刷新指示符
    UIActivityIndicatorView *indicator2 = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((x-width)/2, (y-height)/2, width, height)];
    
    [indicator2 setCenter:CGPointMake(x/2, (y-130)/2+20)];
    indicator2.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [indicator2 startAnimating];
    
    self.indicatorView = [[UIView alloc]initWithFrame:CGRectMake(BORDER_WIDTH, TOP_HEIGHT, x-BORDER_WIDTH*2, y-TOP_HEIGHT-BOTTOM_HEIGHT)];
    [self.indicatorView setTag:71100];
    self.indicatorView.backgroundColor = [UIColor blackColor];
    [self.indicatorView addSubview:indicator2];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView setAlpha:0];

}

- (void)showActivityIndicator: (NSInteger) type
{
    if (type==1) {
        [(UIButton*)[self.view viewWithTag:10001] setEnabled:NO];
        [(UIButton*)[self.view viewWithTag:9999] setEnabled:NO];
        [_indicator startAnimating];
    }
    else {
//        [self.view addSubview:self.indicatorView];
        [self.indicatorView setAlpha:0.4];
    }
}

- (void)hideActivityIndicator: (NSInteger) type
{
    if (type==1) {
        [_indicator stopAnimating];
        [(UIButton*)[self.view viewWithTag:10001] setEnabled:YES];
        [(UIButton*)[self.view viewWithTag:9999] setEnabled:YES];
    } else {
//        [self.indicatorView removeFromSuperview];
        [self.indicatorView setAlpha:0.0];
    }
}


#pragma mark - uiwebview & delegate
//加载页面
- (void) loadThePage: (NSInteger)menuIndex
{
    NSMutableDictionary *theDict = [self.reportArray objectAtIndex:menuIndex];
    NSInteger offline = [[theDict objectForKey:@"offline"]intValue];
    NSString *provCode = [self.myLocation objectForKey:@"provCode"];
    NSString *cityCode = [self.myLocation objectForKey:@"cityCode"];
    if (offline==0) {
        // 联网页面
        NSString *strUrl = [self.delegate.gServerAddress stringByAppendingFormat:@"%@&sessionId=%@&provcode=%@&citycode=%@", [theDict objectForKey:@"content"], self.delegate.gSessionId, provCode, cityCode];
        NSURL *url = [NSURL URLWithString:strUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[self.webContainer.subviews objectAtIndex:menuIndex] setTag:70000];
        UIView *uv = [self.webContainer.subviews objectAtIndex:menuIndex];
        if ([uv isMemberOfClass:[UIWebView class]]) {
            [(UIWebView*)uv loadRequest:request];
        }
        
    } else {
        //离线页面
        NSString *strUrl = [[commonUtil docPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@", [theDict objectForKey:@"parentCode"],[theDict objectForKey:@"code"], [theDict objectForKey:@"indexfile"]]];
        NSURL *url = [NSURL fileURLWithPath:strUrl];
        NSString *urlQueryString = [[url absoluteString] stringByAppendingFormat:@"?provcode=%@&citycode=%@",provCode, cityCode];
        NSURL *finalUrl = [NSURL URLWithString:urlQueryString];
        NSURLRequest *request = [NSURLRequest requestWithURL:finalUrl];
        //NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[self.webContainer.subviews objectAtIndex:menuIndex] setTag:70001];
        UIView *uv = [self.webContainer.subviews objectAtIndex:menuIndex];
        if ([uv isMemberOfClass:[UIWebView class]]) {
            [(UIWebView*)uv loadRequest:request];
        }
    }
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showActivityIndicator:2];
}

- (void)webViewDidFinishLoad:(UIWebView *)web
{
    [self hideActivityIndicator:2];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (webView.tag != 70002) {
        NSString *strUrl = [[commonUtil docPath] stringByAppendingPathComponent:@"error.html"];
        NSURL *url = [NSURL fileURLWithPath:strUrl];
        NSString *urlQueryString = [[url absoluteString] stringByAppendingFormat:@"?errorcode=%d&offline=%d", [error code],webView.tag-70000];
        NSURL *finalUrl = [NSURL URLWithString:urlQueryString];
        NSURLRequest *request = [NSURLRequest requestWithURL:finalUrl];
        [webView setTag:70002];
        [webView loadRequest:request];
    }

    [self hideActivityIndicator:2];
}

#pragma mark - alertView
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //取消
    } else if(buttonIndex == 1) {
        if (alertView.tag==3331) {
            //使用2G/3G网络同步
            [self synchroniseData];
        }
        if (alertView.tag==3332) {
            //同步完成，重新加载
            [self redrawIpadView];
        } else if (alertView.tag==3333) {
            //清空本地数据
            [commonUtil emptyFilesAtPath:@""];
            //清空后需要重新加载页面
            [self redrawIpadView];
        }
    }
}

#pragma mark - CLLocation manager
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.checkLocation = newLocation;
    CLLocation *marLocation = [MarsLocation transformToMars: newLocation];
    NSLog(@"%f, %f", marLocation.coordinate.latitude, marLocation.coordinate.longitude);
    // 解析当前地址
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=5) {
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
        {
            for (CLPlacemark * placeMark in placemarks){
                NSLog(@"%@", placeMark.name);
                NSString *provName = placeMark.administrativeArea;
                NSString *cityName = placeMark.locality;
                NSString *provCode = [self.myAreaStruct getProvCode:provName];
                NSString *cityCode = [self.myAreaStruct getCityCode:cityName];
                [self.myLocation setValue:provCode forKey:@"provCode"];
                [self.myLocation setValue:provName forKey:@"provName"];
                [self.myLocation setValue:cityCode forKey:@"cityCode"];
                [self.myLocation setValue:cityName forKey:@"cityName"];
            }
        };
        [geocoder reverseGeocodeLocation:marLocation completionHandler:handle];
        [manager stopUpdatingLocation];
        /*MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc]initWithCoordinate:newLocation.coordinate];
        geocoder.delegate = self;
        [geocoder start] ;*/
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位出错！");

}

/*
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    self.placemark = placemark;
    NSLog(@"===========================Address==============================");
    NSLog(@"lalala Country = %@", placemark.country);
    NSLog(@"Postal Code = %@", placemark.postalCode);
    NSLog(@"Locality = %@", placemark.locality);
    NSLog(@"address = %@",placemark.name);
    NSLog(@"administrativeArea = %@",placemark.administrativeArea);
    NSLog(@"subAdministrativeArea = %@",placemark.subAdministrativeArea);
    NSLog(@"thoroughfare = %@", placemark.thoroughfare);
    NSLog(@"================================================================");
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    //some code
}
*/

- (void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    NSLog( @"Starting CLLocationManager" );
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 200;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}


#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_stackMenu dismiss];
}


@end
