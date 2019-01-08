//
//  VELatestAlertViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-12.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VELatestAlertViewController.h"
#import "VEAppDelegate.h"
#import "VEWarnAlertTableViewCell.h"
#import "VEAlertDetailViewController.h"
#import "VELatestAlertFilterViewController.h"
#import "QCDeviceViewController.h"
#import "VESearchAlertViewController.h"
#import "RESideMenu.h"
#import "Warn.h"

BOOL LatestAlertHaveChanged;
extern BOOL g_IsLatestAlertOnRed;

static const NSInteger kBtnAllIndex         = 0;   // 【全部】按钮的index
static const NSInteger kMaxWarningCheckSize = 100;
static const NSInteger kActionSheetTag      = 170;

typedef NS_ENUM(NSInteger, Operation)
{
    OperationRefreshAll = 401,
    OperationWarningCheck,
    OperationNextPage,
};

@interface VELatestAlertViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray            *latestAlertData;
@property (nonatomic, strong) NSMutableArray            *latestAlertDataAllCopy;
@property (nonatomic, strong) UIActionSheet             *actionSheet;
@property (nonatomic, assign) BOOL                      noMoreResults;
@property (nonatomic, assign) NSInteger                 currentSelectedCategorySlot;
@property (nonatomic, strong) UIView                    *cellSelectedBackgroundView;

@property (weak, nonatomic) IBOutlet UITableView                            *tableView;
@property (weak, nonatomic) IBOutlet UIView                                 *selectedCategoryView;
@property (weak, nonatomic) IBOutlet UIView                                 *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView                *indicator;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray          *categoryCollection;

@property (nonatomic, strong) FYNHttpRequestLoader      *httpRequestLoader;
@property (nonatomic, assign) NSInteger                 countsOfNew;
@property (nonatomic, assign) BOOL                      isFinishLoad;

- (IBAction)categoryBtnTapped:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *redImageView;
@property (weak, nonatomic) IBOutlet UIImageView *yellowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blueImageView;

@end

@implementation VELatestAlertViewController

- (FYNHttpRequestLoader *)httpRequestLoader
{
    if (_httpRequestLoader == nil)
    {
        _httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestLoader;
}

- (NSMutableArray *)latestAlertData
{
    if (_latestAlertData == nil)
    {
        _latestAlertData = [[NSMutableArray alloc] init];
    }
    return _latestAlertData;
}

- (NSMutableArray *)latestAlertDataAllCopy
{
    if (_latestAlertDataAllCopy == nil)
    {
        _latestAlertDataAllCopy = [[NSMutableArray alloc] init];
    }
    return _latestAlertDataAllCopy;
}

- (UIView *)cellSelectedBackgroundView
{
    if (_cellSelectedBackgroundView == nil)
    {  
        _cellSelectedBackgroundView = [[UIView alloc] init];
        _cellSelectedBackgroundView.backgroundColor = selectedBackgroundColor;
        [_cellSelectedBackgroundView sizeToFit];
    }
    return _cellSelectedBackgroundView;
}

- (void)dealloc
{
    @autoreleasepool {
        self.categoryCollection = nil;
        
        LatestAlertHaveChanged = NO;
        if (_cellSelectedBackgroundView)
        {
            self.cellSelectedBackgroundView = nil;
        }
        if (_httpRequestLoader)
        {
            [self.httpRequestLoader cancelAsynRequest];
            self.httpRequestLoader = nil;
        }
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(applicationWillEnterForeground)
                       name:UIApplicationWillEnterForegroundNotification
                     object:nil];
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self doRefreshAll];
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _redImageView.image = Image(Icon_Circle_Red);
    _yellowImageView.image = Image(Icon_Circle_Yellow);
    _blueImageView.image = Image(Icon_Circle_Blue);
    
    [self setupNav];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VEWarnAlertTableViewCell" bundle:nil] forCellReuseIdentifier:@"VEWarnAlertTableViewCell"];
    
    LatestAlertHaveChanged = NO;
    self.promptView.layer.cornerRadius = 5.0;
    
    self.tableView.header = [RefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(doRefreshAll)];
    
    
    [self refleshToggleButtonOnRed];
    [self refreshAllCategoryTitles];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackground)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(doWarningCheck)
                   name:kAppDidReceiveRemoteNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(refleshToggleButtonOnRed)
                   name:kNewFlagChangedNotification
                 object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"LoginVC Appear");
    if (LatestAlertHaveChanged)
    {
        LatestAlertHaveChanged = NO;
        [self.tableView reloadData];
        [self refreshAllCategoryTitles];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"LoginVC Disappear");
    [self cancelAllHttpRequester];

}

- (void)cancelAllHttpRequester
{
    if (_httpRequestLoader)
    {
        [self.httpRequestLoader cancelAsynRequest];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    for (WarnAgent *warnAgent in self.latestAlertDataAllCopy)
    {
        @autoreleasepool {
            warnAgent.articleContent = nil;
        }
    }
}

/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = self.config[WarnAlertTitle];
    NSMutableArray *array = [NSMutableArray array];
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(openSearch:) image:self.config[Icon_Search] highImage:nil];
    UIBarButtonItem *send =[UIBarButtonItem itemWithTarget:self action:@selector(showList:) image:self.config[Tab_Icon_More] highImage:@""];
    [array addObject:send];
    [array addObject:more];
    self.navigationItem.rightBarButtonItems = array;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger counts = [self.latestAlertData count];
    if (counts == 0)
    {
        if (self.isFinishLoad)
        {
            return 1;  // 1 for show no result
        }
        return 0;
    }
    if(self.noMoreResults){
        counts++;
    }
    return counts;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    // no results
    if (self.latestAlertData.count == 0)
    {
        return [VEUtility cellForShowNoResultTableView:tableView
                                           fillMainTip:@"暂无内容"
                                         fillDetailTip:nil
                                       backgroundColor:selectedBackgroundColor];
    }else if (section == self.latestAlertData.count && self.noMoreResults ==YES ) {
        return [VEUtility cellForShowMoreTableView:tableView cellSelectedBackgroundView:nil];
    }
    
    //上拉自动加载更多
    if (section == [self.latestAlertData count] - 1 && ((section+1) % kBatchSize == 0) && self.noMoreResults == NO)
    {
        [self nextPage];
    }
    
    VEWarnAlertTableViewCell *cell = [VEWarnAlertTableViewCell cellWithTableView:tableView];
    cell.warnAgent = self.latestAlertData[section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.latestAlertData.count == 0)
    {
        return 200; // for show no result
    }
    
    if (indexPath.section == self.latestAlertData.count)
    {
        return 48;
    }
    return 58;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.latestAlertData.count == 0 || indexPath.section == self.latestAlertData.count)
    {
        return; // for no result
    }
    
    if (indexPath.section == [self.latestAlertData count])
    {
        [self nextPage];
    }
    else
    {
        [self openDetailViewAtIndex:indexPath.section];
    }
}


#pragma mark - My Methods

// 获取当前时刻之前的最新预警列表

- (void)doRefreshAll
{

    [self grabLatestAlertsAtTimeInterval:@"0" withOperation:OperationRefreshAll];
}

// 检测有没有新的预警数据

- (void)doWarningCheck
{
    NSString *startTime = @"0";
    if (self.latestAlertDataAllCopy.count > 0)
    {
        startTime = ((WarnAgent *)[self.latestAlertDataAllCopy objectAtIndex:0]).tmWarn;
    }
    [self grabLatestAlertsAtTimeInterval:startTime withOperation:OperationWarningCheck];
}

// 下一页

- (void)nextPage
{
    WarnAgent *warnAgent = [self.latestAlertDataAllCopy lastObject];
    if (warnAgent.tmWarn)
    {
        [self grabLatestAlertsAtTimeInterval:warnAgent.tmWarn withOperation:OperationNextPage];
    }
    else
    {
        [self.tableView reloadData];
    }
}

// 打开详情页

- (void)openDetailViewAtIndex:(NSInteger)index
{
    VEAlertDetailViewController *detailViewController = [[VEAlertDetailViewController alloc]
                                                    initWithNibName:@"VEAlertDetailViewController" bundle:nil];
    detailViewController.agent = self.latestAlertData[index];
    LatestAlertHaveChanged = NO;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// 从服务器端获取预警信息

- (void)grabLatestAlertsAtTimeInterval:(NSString *)timeInterval withOperation:(Operation)operation
{
    if (timeInterval == nil)
    {
        timeInterval = @"0";
    }
    
    if (operation != OperationWarningCheck)
    {
        [MBProgressHUD showMessage:@"正在加载数据，请稍后..." toView:self.view];
    }
    if (operation == OperationRefreshAll)
    {
//        self.tableView.contentOffset = CGPointZero;
    }
    
    NSString *stringUrl = [[NSString alloc] initWithFormat:@"%@/warninglist", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSString *paramsStr = nil;
    if (operation == OperationWarningCheck)
    {
        paramsStr = [[NSString alloc] initWithFormat:@"start=%@&limit=%ld", timeInterval, (long)kMaxWarningCheckSize];
    }
    else
    {
        paramsStr = [[NSString alloc] initWithFormat:@"before=%@&limit=%ld", timeInterval, (long)kBatchSize];
    }
    
    [self.httpRequestLoader cancelAsynRequest];
    [self.httpRequestLoader startAsynRequestWithURL:url withParams:paramsStr];

    __weak typeof(self) weakSelf = self;
    [self.httpRequestLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        if (operation != OperationWarningCheck || weakSelf.promptView.alpha > 0.2)
        {
            [MBProgressHUD hideHUDForView:weakSelf.view];
//            [weakSelf stopPromptAction];
        }
        
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf updateLatestAlertData:[jsonParser retrieveListValue]
                                  withOperation:operation];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
        [weakSelf.tableView.header endRefreshing];
    }];
}

// 更新预警信息

- (void)updateLatestAlertData:(NSArray *)listDatas withOperation:(Operation)operation
{
    @autoreleasepool {
        
        NSInteger size = listDatas.count;
        if (operation == OperationRefreshAll)
        {
            [self.latestAlertData removeAllObjects];
            [self.latestAlertDataAllCopy removeAllObjects];
        }
        
        if (operation != OperationWarningCheck)
        {
            if (size == kBatchSize)
            {
                self.noMoreResults = NO;
            }
            else
            {
                self.noMoreResults = YES;
            }
        }
        
        if (size > 0)
        {
            NSMutableArray *allWarnAgents = [NSMutableArray array];
            NSMutableArray *warnAgents = [NSMutableArray array];
            for (NSDictionary *singleData in listDatas)
            {
                WarnAgent *warnAgent = [[WarnAgent alloc] initWithDictionary:singleData];
                warnAgent.isRead = [VEUtility isWarnReadWithArticleId:warnAgent.articleId
                                                          andWarnType:warnAgent.warnType];

                [allWarnAgents addObject:warnAgent];
                NSInteger level = warnAgent.warnLevel;
                if (self.currentSelectedCategorySlot == kBtnAllIndex ||
                    self.currentSelectedCategorySlot == level)
                {
                    [warnAgents addObject:warnAgent];
                }
            }
            
            if (operation == OperationWarningCheck)
            {
                [self.latestAlertDataAllCopy insertObjects:allWarnAgents
                                                 atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, allWarnAgents.count)]];
                [self.latestAlertData insertObjects:warnAgents
                                          atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, warnAgents.count)]];
            }
            else
            {
                [self.latestAlertDataAllCopy addObjectsFromArray:allWarnAgents];
                [self.latestAlertData addObjectsFromArray:warnAgents];
            }
            
            [allWarnAgents removeAllObjects];
            [warnAgents removeAllObjects];
            [self refreshAllCategoryTitles];
        }
        
        self.isFinishLoad = YES;
        [self.tableView reloadData];
    }
}

// 刷新按"全部"、"紧急"、"重要"、"一般"分类的label标题

- (void)refreshAllCategoryTitles
{
    NSInteger unread_urgent  = 0;
    NSInteger unread_serious = 0;
    NSInteger unread_general = 0;
    self.countsOfNew         = 0;
    
    for (WarnAgent *warnAgent in self.latestAlertDataAllCopy)
    {
        if (!warnAgent.isRead)
        {
            switch (warnAgent.warnLevel)
            {
                case 1:
                    ++unread_urgent;
                    break;
                    
                case 2:
                    ++unread_serious;
                    break;
                    
                case 3:
                    ++unread_general;
                    break;
                    
                default:
                    break;
            }
            ++self.countsOfNew;
        }
    }
    
    NSInteger newUnread = 0;
    NSString *newTitle  = @"";
    for (int i = 0; i < 3; ++i)
    {
        switch (i)
        {
            case 0:
                newUnread = unread_urgent;
                newTitle = self.config[Urgent];
                break;
            
            case 1:
                newUnread = unread_serious;
                newTitle = self.config[Import];
                break;
        
            case 2:
                newUnread = unread_general;
                newTitle = self.config[Normal];
                break;
                
            default:
                break;
        }
    
        if (newUnread > 0)
        {
            newTitle = [NSString stringWithFormat:@"%ld", (long)newUnread];
        }
        UIButton *btn = self.categoryCollection[i];
        [btn setTitle:newTitle forState:UIControlStateNormal];
        [btn setTitle:newTitle forState:UIControlStateHighlighted];
    }
    
    g_IsLatestAlertOnRed = (self.countsOfNew > 0 ? YES : NO);
    [VEUtility postNewFlagChangedNotification];
}

// 当与服务器端进行连接时,显示正在加载数据的提示框

//- (void)showPromptAction
//{
//    self.promptView.alpha = 0;
//    [UIView animateWithDuration:1.0 animations:^{
//        self.promptView.alpha = 0.9;
//        [self.indicator startAnimating];
//    }];
//}
//
//// 停止显示加载数据的提示框
//
//- (void)stopPromptAction
//{
//    self.promptView.alpha = 0.9;
//    [UIView animateWithDuration:2.0
//                     animations:^{
//                         self.promptView.alpha = 0;
//                     }
//                     completion:^(BOOL finished) {
//                         [self.indicator stopAnimating];
//                     }
//     ];
//}

// 内容筛选

- (void)filterLatetAlerts
{
    VELatestAlertFilterViewController *alertFilterViewController = [[VELatestAlertFilterViewController alloc] initWithNibName:@"VELatestAlertFilterViewController" bundle:nil];
    [self.navigationController pushViewController:alertFilterViewController animated:YES];
}

// 标记所有为已读

- (void)markAllRead
{
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (WarnAgent *warnAgent in self.latestAlertDataAllCopy)
        {
            warnAgent.isRead = YES;
            [VEUtility setWarnReadWithArticleId:warnAgent.articleId andWarnType:warnAgent.warnType];
        }
        
        [self.tableView reloadData];
        [self refreshAllCategoryTitles];
    });
}


#pragma mark - IBAction

// 按"全部"、"紧急"、"重要"和"一般"进行预警信息分类

- (IBAction)categoryBtnTapped:(UIButton *)sender
{
    if (sender.tag != self.currentSelectedCategorySlot)
    {
        [UIView animateWithDuration:0.1 animations:^{
            self.tableView.contentOffset = CGPointZero;
            NSInteger diff = (sender.tag - self.currentSelectedCategorySlot);
            self.selectedCategoryView.center = CGPointMake(self.selectedCategoryView.center.x + Main_Screen_Width * 0.25 * diff,
                                                           self.selectedCategoryView.center.y);
        }];
        self.currentSelectedCategorySlot = sender.tag;
        
        [self.latestAlertData removeAllObjects];
        [self.latestAlertData addObjectsFromArray:self.latestAlertDataAllCopy];
        
        if (self.currentSelectedCategorySlot != kBtnAllIndex)
        {
            NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
            for (WarnAgent *warnAgent in self.latestAlertData)
            {
                if (warnAgent.warnLevel != self.currentSelectedCategorySlot)
                {
                    [removeObjects addObject:warnAgent];
                }
            }
            [self.latestAlertData removeObjectsInArray:removeObjects];
        }
        [self.tableView reloadData];
        [self refreshAllCategoryTitles];
        
        //////////////////////////////////////////////////////////////////////
    }
}

- (IBAction)showList:(id)sender
{
    if (_actionSheet == nil)
    {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:self.config[RefreshAllData], self.config[MarkToRead], self.config[FitterContent], nil];
        self.actionSheet.tag = kActionSheetTag;
    }
    [self.actionSheet showInView:self.view];

}

- (IBAction)openSearch:(id)sender
{
    VESearchAlertViewController *searchAlertController = [[VESearchAlertViewController alloc] initWithNibName:@"VESearchAlertViewController" bundle:nil];
    searchAlertController.searchType = SearchTypeLatestAlert;
    
    [self.navigationController pushViewController:searchAlertController animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kActionSheetTag)
    {
        if (buttonIndex == 0)
        {
            [self doRefreshAll];
        }
        else if (buttonIndex == 1)
        {
            [self markAllRead];
        }
        else if (buttonIndex == 2)
        {
            [self filterLatetAlerts];
        }
    }
}

#pragma mark - NSNotificationCenter

// 进入前台

- (void)applicationWillEnterForeground
{
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([appDelegate.window.rootViewController isKindOfClass:[RESideMenu class]])
        {
            RESideMenu *deckVC = (RESideMenu *)appDelegate.window.rootViewController;
            if (![deckVC.presentedViewController isKindOfClass:[QCDeviceViewController class]])
            {
                [self doWarningCheck];
            }
        }
    });
}

// 进入后台

- (void)applicationDidEnterBackground
{
    if (self.actionSheet)
    {
        if (self.actionSheet.numberOfButtons)
        {
            [self.actionSheet dismissWithClickedButtonIndex:(self.actionSheet.numberOfButtons - 1)
                                                         animated:NO];
        }
    }
}

- (void)refleshToggleButtonOnRed
{
    VENavViewController *nav = (VENavViewController *)self.navigationController;
    nav.iconType = [VEUtility isOnRed];
}

@end







