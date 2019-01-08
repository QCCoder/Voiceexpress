//
//  VERecommendReadViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-24.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VERecommendReadViewController.h"
#import "VERecommendColumnViewController.h"
#import "QCDeviceViewController.h"
#import "VEAppDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "RESideMenu.h"
#import "UIImageView+WebCache.h"
#import "VESearchAlertViewController.h"
#import "RefreshHeader.h"
#import "VERecommendReadTableViewCell.h"
#import "RecommendReadTool.h"

extern BOOL g_IsRecommendReadOnRed;

@interface VERecommendReadViewController ()

@property (weak, nonatomic) IBOutlet UITableView               *tableView;

@property (nonatomic, assign) BOOL                      isFinishLoad;
@property (nonatomic, assign) NSInteger                 countsOfNewColumn;
@property (nonatomic, strong) UIView                    *cellSelectedBackgroundView;
@property (nonatomic, strong) NSMutableArray            *secListDatas;
@end

@implementation VERecommendReadViewController


- (NSMutableArray *)secListDatas
{
    if (_secListDatas == nil)
    {
        _secListDatas = [[NSMutableArray alloc] init];
    }
    return _secListDatas;
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
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
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
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self refreshSectionList];
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNav];
    
    self.tableView.header = [RefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshSectionList)];
    
    [self.tableView registerNib:[UINib nibWithNibName:KIdentifier_RecommendRead bundle:nil] forCellReuseIdentifier:KIdentifier_RecommendRead];
    
    [self refleshToggleButtonOnRed];
 
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(refleshToggleButtonOnRed)
                   name:kNewFlagChangedNotification
                 object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"RecommendRead Disappear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"RecommendRead Disappear");
}

/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = self.config[ReadTitle];
    NSMutableArray *array = [NSMutableArray array];
//    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(refreshSectionList) image:self.config[Tab_Icon_Refresh] highImage:nil];
//    [array addObject:more];
    UIBarButtonItem *send =[UIBarButtonItem itemWithTarget:self action:@selector(openSearch) image:self.config[Icon_Search] highImage:nil];
    [array addObject:send];
    self.navigationItem.rightBarButtonItems = array;
}

#pragma mark - My Methods

/**
 *  更新推荐栏目列表信息
 */
- (void)updateSectionListData:(NSArray *)listDatas
{
    if (listDatas.count == 0) {
        if (listDatas)
        {
            self.countsOfNewColumn = 0;
            [self.secListDatas removeAllObjects];
            g_IsRecommendReadOnRed = NO;
            [VEUtility postNewFlagChangedNotification];
        }
    }else{
        [self.secListDatas removeAllObjects];
        [self.secListDatas addObjectsFromArray:listDatas];
        for (RecommendColumnAgent *agent in listDatas) {
            if (agent.newestArticleId > agent.localNewestArticleId){
                ++self.countsOfNewColumn;
            }
        }
        g_IsRecommendReadOnRed = (self.countsOfNewColumn > 0 ? YES : NO);
        [VEUtility postNewFlagChangedNotification];
    }
    self.isFinishLoad = YES;
}


#pragma mark - 事件监听方法
- (void)openSearch
{
    VESearchAlertViewController *searchAlertController = [[VESearchAlertViewController alloc] initWithNibName:@"VESearchAlertViewController" bundle:nil];
    searchAlertController.searchType = SearchTypeRecommendRead;
    
    [self.navigationController pushViewController:searchAlertController animated:YES];
}

- (void)refleshToggleButtonOnRed
{
    VENavViewController *nav = (VENavViewController *)self.navigationController;
    nav.iconType = [VEUtility isOnRed];
}

/**
 *  刷新所有的推荐栏目列表
 */
- (void)refreshSectionList
{
    self.isFinishLoad = NO;
    [PromptView startShowPromptViewWithTip:@"正在刷新数据，请稍后..." view:self.view];
    __weak typeof(self) weakSelf = self;
    [RecommendReadTool loadSectionListSuccess:^(BOOL success, id JSON) {
        if (success) {
            [weakSelf updateSectionListData:JSON];
        }
        [PromptView hidePromptFromView:self.view];
        [weakSelf.tableView.header endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.secListDatas.count;
    if (count == 0)
    {
        if (self.isFinishLoad)
        {
            return 1;  // 1 for show no result
        }
        return 0;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // no results
    if (self.secListDatas.count == 0){
        UITableViewCell *cell = [VEUtility cellForShowNoResultTableView:tableView
                                           fillMainTip:@"暂无内容"
                                         fillDetailTip:nil
                                       backgroundColor:selectedBackgroundColor];
        return cell;
    }else{
        VERecommendReadTableViewCell *recommendCell = [VERecommendReadTableViewCell cellWithTableView:tableView];
        recommendCell.agent = self.secListDatas[indexPath.section];
        return recommendCell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.secListDatas.count == 0)
    {
        return; // for no result
    }
    
    NSInteger section = indexPath.section;
    if (section >= 0 && section < self.secListDatas.count)
    {
        VERecommendColumnViewController *columnViewController = [[VERecommendColumnViewController alloc]
                                                                 initWithNibName:@"VERecommendColumnViewController" bundle:nil];

        RecommendColumnAgent *columnAgent = [self.secListDatas objectAtIndex:section];

        columnViewController.columnID    = columnAgent.columnId;
        columnViewController.columnTitle = columnAgent.columnTitle;
        
        [self.navigationController pushViewController:columnViewController animated:YES];
        
        if (columnAgent.localNewestArticleId < columnAgent.newestArticleId)
        {
            columnAgent.localNewestArticleId = columnAgent.newestArticleId;
            [RecommendCoreDataTool setNewestColumnActicleId:columnAgent.newestArticleId
                                       InColumn:columnAgent.columnId
                                   withUserName:[VEUtility currentUserName]];
            
            --self.countsOfNewColumn;
            g_IsRecommendReadOnRed = (self.countsOfNewColumn > 0 ? YES : NO);
            [VEUtility postNewFlagChangedNotification];
            [self.tableView reloadData];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.secListDatas.count == 0)
    {
        return 200; // for show no result
    }
    
    return 58;
}

#pragma mark - NSNotificationCenter

- (void)applicationWillEnterForeground
{
    double delayInSeconds = 2.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([appDelegate.window.rootViewController isKindOfClass:[RESideMenu class]])
        {
            RESideMenu *deckVC = (RESideMenu *)appDelegate.window.rootViewController;
            if (![deckVC.presentedViewController isKindOfClass:[QCDeviceViewController class]])
            {
                [self refreshSectionList];
            }
        }
    });
}

@end
