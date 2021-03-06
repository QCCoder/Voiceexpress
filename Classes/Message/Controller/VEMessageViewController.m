//
//  VEMessageViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-4-9.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEMessageViewController.h"
#import "VEIntelligenceListViewController.h"
#import "VERecommendReadTableViewCell.h"
#import "QCDeviceViewController.h"
#import "RESideMenu.h"
#import "MessageTool.h"
#import "MessageMenu.h"
#import "MessageViewController.h"
#import "IntelligenceColumnAgent.h"
#import "DownloadTool.h"

    #import "VEMessageDistributeViewController.h"

static NSString * const kInstantType            = @"InstantType";
static NSString * const kDailyType              = @"DailyType";
static NSString * const kInternationalType      = @"InternationalType";

BOOL kIsCurrentNetWorkWifi = NO;

extern BOOL g_IsMessageOnRed;

@interface VEMessageViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView   *tableView;

@property (nonatomic, assign) NSInteger                     countsofNew;

@property (nonatomic,strong) NSMutableArray *dataList;

@end

@implementation VEMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                   selector:@selector(applicationWillEnterForeground)
                       name:UIApplicationWillEnterForegroundNotification
                     object:nil];
        // 检测网络类型
        [self checkNetWorkType];
        // 检测最新信息
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doCheckNewAlertAction];
        });
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObserver];
    //设置导航
    [self reloadImage];
  
    //下拉刷新
    [self setupTableView];
    
    // 清理过期数据
    [self doCheckAndClearOverdueData];

    //通知
    [self setupNotification];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"MessageView Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"MessageView Disappear");
}



-(void)reloadImage{
    [super reloadImage];
    [self setTitle:self.config[Msg_Title]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(distributeItemTapped) image:self.config[Icon_Write] highImage:nil];
    
    [self.dataList removeAllObjects];
    NSArray *list = [MessageMenu objectArrayWithFile:[QCZipImageTool getPath:@"Message.plist"]];
    NSMutableArray *datalist= [[NSMutableArray alloc]initWithArray:list];
    if (!self.user.isIntelligenceNeedWhole) {
        [datalist removeLastObject];
    }
    self.dataList = datalist;
    
    [self.tableView reloadData];
}

-(void)setupTableView{
    [self.tableView registerNib:[UINib nibWithNibName:KIdentifier_RecommendRead bundle:nil] forCellReuseIdentifier:KIdentifier_RecommendRead];
    self.tableView.header = [RefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(doCheckNewAlertAction)];
}

-(void)setupNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(doCheckNewAlertAction) name:kAppDidReceiveRemoteNotification object:nil];
    [center addObserver:self selector:@selector(refleshToggleButtonOnRed) name:kNewFlagChangedNotification object:nil];
}

#pragma mark - 我的方法

-(void)setMessageIsRead{
    g_IsMessageOnRed = (self.countsofNew > 0 ? YES : NO);
    [VEUtility postNewFlagChangedNotification];
    [self.tableView reloadData];
}

- (void)refleshToggleButtonOnRed{
    VENavViewController *nav = (VENavViewController *)self.navigationController;
    nav.iconType = [VEUtility isOnRed];
}

// 检测最新信息
- (void)doCheckNewAlertAction{
    __weak typeof(self) weakSelf = self;
    [MessageTool checkNewAlert:^(BOOL success, id JSON) {
        if (success) {
            [weakSelf parseToCheckNewAlert:JSON];
        }
        [self.tableView.header endRefreshing];
    }];
}

- (void)parseToCheckNewAlert:(NSArray *)aList{
    if (aList.count > 0){
        self.countsofNew = 0;
        for (NSDictionary *item in aList){
            IntelligenceColumnAgent *columnAgent = [[IntelligenceColumnAgent alloc] initWithDictionary:item];
            columnAgent.loacalNewestTime = [MessageTool newestTimeAtIntelligenceColumnType:columnAgent.columnType];
            if (columnAgent.newestTime > columnAgent.loacalNewestTime){
                ++self.countsofNew;
                NSInteger index = 0;
                BOOL hasNew = true;
                switch (columnAgent.columnType){
                    case IntelligenceColumnInstant:
                        index = IntelligenceColumnInstant - 1;
                        break;
                        
                    case IntelligenceColumnDaily:
                        index = IntelligenceColumnDaily - 1;
                        break;
                        
                    case IntelligenceColumnInternational:
                        index = IntelligenceColumnInternational - 1;
                        break;
                        
                    default:
                        hasNew = false;
                        index = 3;
                        --self.countsofNew;
                        break;
                }
                if (index < 3) {
                    MessageMenu *menu = self.dataList[index];
                    menu.hasNew = hasNew;
                    self.dataList[index] = menu;
                }
            }
        }
        [self setMessageIsRead];
    }
}

// 清除过期的历史缓存数据
- (void)doCheckAndClearOverdueData{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       [VEUtility clearOverdueDataAtPersistentStore];
    });
}

- (void)openDetailViewAtIndex:(NSInteger)index{
    MessageMenu *menu = self.dataList[index];
    
    // 【情报交互信息】栏
    if (index == 3){
        VEIntelligenceListViewController *intelligenceListVC = [[VEIntelligenceListViewController alloc] initWithNibName:@"VEIntelligenceListViewController" bundle:nil];
        [self.navigationController pushViewController:intelligenceListVC animated:YES];
        return;
    }else{
        MessageViewController *alertViewController = [[MessageViewController alloc]initWithNibName:@"MessageViewController" bundle:nil];
        alertViewController.title = menu.title;
        alertViewController.columnType = index + 1;
        [self.navigationController pushViewController:alertViewController animated:YES];
    }
    
    if (menu.hasNew) {
        menu.hasNew = false;
        self.dataList[index] = menu;
        --self.countsofNew;
        [self setMessageIsRead];
    }

}

- (void)checkNetWorkType
{
    kIsCurrentNetWorkWifi = [VEUtility isCurrentNetworkWifi];
}

#pragma mark - IBAction

/**
 *  预警发布
 */
- (void)distributeItemTapped
{
    VEMessageDistributeViewController *distributeViewController = [[VEMessageDistributeViewController alloc] initWithNibName:@"VEMessageDistributeViewController" bundle:nil];
    distributeViewController.columnType = IntelligenceColumnNone;
    distributeViewController.sendType = SendTypeNewIntelligence;
    [self.navigationController pushViewController:distributeViewController animated:YES];
}


#pragma mark - 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VERecommendReadTableViewCell *recommendCell = [VERecommendReadTableViewCell cellWithTableView:tableView];
    MessageMenu *menu = self.dataList[indexPath.row];
    recommendCell.labelMain.text = menu.title;
    recommendCell.labelMain.textColor = unreadFontColor;
    if (menu.hasNew){
        recommendCell.imageNew.image = [QCZipImageTool imageNamed:self.config[Icon_New]];
    }else{
        recommendCell.imageNew.image  = nil;
    }
    recommendCell.imageTip.image = [QCZipImageTool imageNamed:menu.icon];
    return recommendCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self openDetailViewAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

#pragma mark - NSNotificationCenter

- (void)applicationWillEnterForeground
{
    // 检查网络类型
    [self checkNetWorkType];
    
    // 每次程序从后台进入前台,则检查服务器端有没有最新的预警信息
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([appDelegate.window.rootViewController isKindOfClass:[RESideMenu class]])
        {
            RESideMenu *deckVC = (RESideMenu *)appDelegate.window.rootViewController;
            if (![deckVC.presentedViewController isKindOfClass:[QCDeviceViewController class]])
            {
                [self doCheckNewAlertAction];
            }
        }
    });
}



@end
