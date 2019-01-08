//
//  VEFavoriteDetailViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-6.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEFavoriteDetailViewController.h"
#import "VEWarnAlertTableViewCell.h"
#import "VERecommendColumnTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "VEFavoriteTool.h"
#import "FavoriteRecommendAgent.h"
#import "FavoriteAlertAgent.h"
#import "VERecommendReadDetailVC.h"
#import "VEAlertDetailViewController.h"
typedef NS_ENUM(NSInteger, Operation)
{
    OperationRefleshAll = 601,
    OperationNextPage,
};

static const NSInteger kWarnTypeOrdinary = 1;  // 普通预警类型
static const NSInteger kWarnTypeRecommed = 3;  // 推荐预读类型

@interface VEFavoriteDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView               *tableView;

@property (nonatomic, strong) NSMutableSet          *mayDeleteFavoriteItems;
@property (nonatomic, strong) NSMutableArray        *favoriteListData;
@property (nonatomic, strong) UIView                *cellSelectedBackgroundView;
@property (nonatomic, assign) BOOL                  noMoreResults;
@property (nonatomic, assign) BOOL                  isFinishLoad;

@end

@implementation VEFavoriteDetailViewController

- (NSMutableSet *)mayDeleteFavoriteItems
{
    if (_mayDeleteFavoriteItems == nil)
    {
        _mayDeleteFavoriteItems = [[NSMutableSet alloc] init];
    }
    return _mayDeleteFavoriteItems;
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

- (NSMutableArray *)favoriteListData
{
    if (_favoriteListData == nil)
    {
        _favoriteListData = [[NSMutableArray alloc] init];
    }
    return _favoriteListData;
}

- (void)dealloc
{
    @autoreleasepool {
        if (_mayDeleteFavoriteItems)
        {
            [self.mayDeleteFavoriteItems removeAllObjects];
            self.mayDeleteFavoriteItems = nil;
        }
        if (_favoriteListData)
        {
            [self.favoriteListData removeAllObjects];
            self.favoriteListData = nil;
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNav];
    
    if (self.comeFrom == FavoriteDetailViewFavoriteFromAlerts){
        self.title = self.config[WarnAlertTitle];
    }else if (self.comeFrom == FavoriteDetailViewFavoriteFromRecommend){
        self.title = self.config[ReadTitle];
    }else{
        self.title = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"FavoriteDetail Disappear");
    [self refreshAll];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"FavoriteDetail Disappear");
}


/**
 *  初始化导航
 */
-(void)setupNav
{
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(refreshAll) image:self.config[Tab_Icon_Refresh] highImage:nil];
    self.navigationItem.rightBarButtonItem = more;
}


#pragma mark - 事件监听

- (void)refreshAll
{
    [self grabFavoritelistBeforTimeInterval:@"0" withOperation:OperationRefleshAll];
}

#pragma mark - 我的方法
/**
 *  加载更多
 */
- (void)loadMoreData
{
    NSString *timeFavorited = nil;
    if (self.comeFrom == FavoriteDetailViewFavoriteFromAlerts){
        FavoriteAlertAgent *alertAgent = [self.favoriteListData lastObject];
        timeFavorited = alertAgent.tmFavorites;
    }else{
        FavoriteRecommendAgent *recommendAgent = [self.favoriteListData lastObject];
        timeFavorited = recommendAgent.tmFavorites;
    }
    
    if (timeFavorited)
    {
        [self grabFavoritelistBeforTimeInterval:timeFavorited withOperation:OperationNextPage];
    }
    else
    {
        [self.tableView reloadData];
    }
}

/**
 *  加载数据
 *
 */
- (void)grabFavoritelistBeforTimeInterval:(NSString *)timeInterval withOperation:(Operation)operation
{
    if (timeInterval == nil)
    {
        timeInterval = @"0";
    }
    
    NSInteger warnType = -1;
    if (self.comeFrom == FavoriteDetailViewFavoriteFromAlerts){
        warnType = kWarnTypeOrdinary;
    }else if (self.comeFrom == FavoriteDetailViewFavoriteFromRecommend){
        warnType = kWarnTypeRecommed;
    }
    
    NSDictionary *paramters = @{@"before":timeInterval,
                                @"limit":[NSString stringWithFormat:@"%ld",(long)kBatchSize],
                                @"warnType":[NSString stringWithFormat:@"%ld",(long)warnType]
                                };
    
    [PromptView startShowPromptViewWithTip:@"正在加载数据，请稍等..." view:self.view];
    
    [VEFavoriteTool loadWarnFavoritesWithParam:paramters index:self.comeFrom resultInfo:^(BOOL success, id JSON) {
        [PromptView hidePromptFromView:self.view];
        if (success) {
            [self updateFavoriteListData:JSON withOperation:operation];
        }
    }];
}

// 刷新数据
- (void)updateFavoriteListData:(NSArray *)listDatas withOperation:(Operation)operation
{
    NSInteger size = listDatas.count;
    
    if (size == kBatchSize){
        self.noMoreResults = NO;
    }else{
        self.noMoreResults = YES;
    }
    
    if (operation == OperationRefleshAll){
        [self.favoriteListData removeAllObjects];
//        self.tableView.contentOffset = CGPointZero;
    }
    
    if (size > 0){
        [self.favoriteListData addObjectsFromArray:listDatas];
    }
    self.isFinishLoad = YES;
    [self.tableView reloadData];
}

- (void)openDetailViewAtIndex:(NSInteger)index
{
    if (self.comeFrom == FavoriteDetailViewFavoriteFromAlerts){
        VEAlertDetailViewController *detailViewController = [[VEAlertDetailViewController alloc]
                                                             initWithNibName:@"VEAlertDetailViewController" bundle:nil];
        detailViewController.agent = self.favoriteListData[index];
        [self.navigationController pushViewController:detailViewController animated:YES];

    }else if (self.comeFrom == FavoriteDetailViewFavoriteFromRecommend ){
        VERecommendReadDetailVC *detailVC = [[VERecommendReadDetailVC alloc] initWithNibName:@"VERecommendReadDetailVC" bundle:nil];
        detailVC.agent = self.favoriteListData[index];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
}

/**
 *  预警舆情cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellAlertForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VEWarnAlertTableViewCell *cell = [VEWarnAlertTableViewCell cellWithTableView:tableView];
    cell.warnAgent = self.favoriteListData[indexPath.section];
    return cell;
}

/**
 *  预警舆情推荐阅读cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellRecommendForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoriteRecommendAgent *recommendAgent = [self.favoriteListData objectAtIndex:indexPath.section];
    
    VERecommendColumnTableViewCell *cell = [VERecommendColumnTableViewCell cellWithTableView:tableView agent:recommendAgent];
    return cell;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger counts = self.favoriteListData.count;
    if (counts == 0){
        return 1;
    }
    
    if (self.noMoreResults) {
        counts++;
    }
    
    return counts;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSInteger section = indexPath.section;
    BOOL noMoreResults = self.noMoreResults;
    
    if (self.favoriteListData.count == 0)
    {
        cell = [VEUtility cellForShowNoResultTableView:tableView
                                           fillMainTip:@"暂无内容"
                                         fillDetailTip:nil
                                       backgroundColor:selectedBackgroundColor];
        return cell;
    }
    
    if (section == self.favoriteListData.count && noMoreResults == YES) {
        cell = [VEUtility cellForShowMoreTableView:tableView cellSelectedBackgroundView:nil];
        return cell;
    }
    
    
    if (self.comeFrom == FavoriteDetailViewFavoriteFromAlerts)
    {
        cell = [self tableView:tableView cellAlertForRowAtIndexPath:indexPath];
    }
    else if (self.comeFrom == FavoriteDetailViewFavoriteFromRecommend)
    {
        cell = [self tableView:tableView cellRecommendForRowAtIndexPath:indexPath];
    }
    
    if (noMoreResults == NO && section == (self.favoriteListData.count - 1) ) {
        [self loadMoreData];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.favoriteListData.count == 0 || indexPath.section == self.favoriteListData.count)
    {
        return; // for no result
    }
    
    [self openDetailViewAtIndex:indexPath.section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.favoriteListData.count == 0){
        return 200; // for show no result
    }
    
    if (indexPath.section == self.favoriteListData.count){
        return 48;
    }
    
    if (self.comeFrom == FavoriteDetailViewFavoriteFromRecommend){
        NSInteger section = indexPath.section;
        if (section >= 0 && section < self.favoriteListData.count){
            FavoriteRecommendAgent *recommendAgent = [self.favoriteListData objectAtIndex:section];
            if (recommendAgent.thumbImageUrl.length > 0){
                return 78;
            }
        }
    }
    return 58;
}

@end
