//
//  VERecommendColumnViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-25.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VERecommendColumnViewController.h"
#import "VERecommendColumnTableViewCell.h"
#import "VERecommendReadDetailVC.h"
#import "UIImageView+WebCache.h"
#import "RecommendReadTool.h"


typedef NS_ENUM(NSInteger, Operation)
{
    OperationNextPage = 501,
    OperationPullToRefresh,
    OperationRefreshAll,
};

@interface VERecommendColumnViewController ()

@property (weak, nonatomic) IBOutlet UITableView               *tableView;

@property (nonatomic, strong) NSMutableArray            *listDatas;
@property (nonatomic, assign) BOOL                      noMoreResults;

@property (nonatomic, assign) BOOL                      isFinishLoad;

@end

@implementation VERecommendColumnViewController

- (NSMutableArray *)listDatas
{
    if (_listDatas == nil){
        _listDatas = [[NSMutableArray alloc] init];
    }
    return _listDatas;
}


- (void)dealloc
{
    if (_listDatas){
        [self.listDatas removeAllObjects];
        self.listDatas = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNav];
    
    self.tableView.header = [RefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(doPullToRefresh)];
    [self.tableView.header beginRefreshing];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"RecommendColumn Disappear");
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"RecommendColumn Disappear");
}

/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title =self.columnTitle;
    NSMutableArray *array = [NSMutableArray array];
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(refreshAll) image:self.config[Tab_Icon_Refresh] highImage:nil];
    [array addObject:more];
    self.navigationItem.rightBarButtonItems = array;
    
}


#pragma mark - 事件监听

- (void)refreshAll
{
    [self grabRecommendColumnListAtContentID:0 WithOperation:OperationRefreshAll];
}


#pragma mark - MyMethods

- (void)doPullToRefresh
{
    NSInteger contentID = 0;
    if (self.listDatas.count > 0){
        contentID = [((RecommendAgent *)[self.listDatas objectAtIndex:0]).articleId integerValue];
    }
    [self grabRecommendColumnListAtContentID:contentID WithOperation:OperationPullToRefresh];
}

- (void)nextPage
{
    NSInteger contentID = 0;
    if (self.listDatas.count > 0){
        contentID = [((RecommendAgent *)[self.listDatas lastObject]).articleId integerValue];
    }
    [self grabRecommendColumnListAtContentID:contentID WithOperation:OperationNextPage];
}

- (void)openDetailViewAtIndex:(NSInteger)index
{
    VERecommendReadDetailVC *detailViewController = [[VERecommendReadDetailVC alloc]
                                                    initWithNibName:@"VERecommendReadDetailVC" bundle:nil];
    detailViewController.agent = self.listDatas[index];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// 已读、未读状态
- (void)dealWithReadState:(Agent *)agent
{
    if (!agent.isRead){
        agent.isRead = YES;
        [RecommendReadTool setRecommendReadInColumn:self.columnID withArticleId:agent.articleId andWarnType:agent.warnType];
    }
}

/* 从服务端获取推荐栏目中的文章列表
 * operation OperationRefreshAll: 获取栏目中的最新文章列表;
 *           OperationNextPage: 下一页
 *           OperationPullToRefresh: 获取比当前最大的文章ID大的文章列表
 */
- (void)grabRecommendColumnListAtContentID:(NSInteger)contentID  WithOperation:(Operation)operation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"id"] = self.columnID;
    dict[@"limit"] = [NSString stringWithFormat:@"%ld",(long)kBatchSize];
  
    if (operation == OperationNextPage || operation == OperationRefreshAll){
        dict[@"before"] = [NSString stringWithFormat:@"%ld",(long)contentID];
    }else if (operation == OperationPullToRefresh){
        dict[@"start"] = [NSString stringWithFormat:@"%ld",(long)contentID];
    }
    
    [PromptView startShowPromptViewWithTip:@"正在刷新数据，请稍后..." view:self.view];
    
    __weak typeof(self) weakSelf = self;
    
    [RecommendReadTool loadSectionWithParam:dict columnID:self.columnID resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [weakSelf updateColumnContentListData:JSON withOperation:operation];
        }
        [PromptView hidePromptFromView:weakSelf.view];
        [self.tableView.header endRefreshing];
    }];
}
- (void)updateColumnContentListData:(NSArray *)listDatas withOperation:(Operation)operation
{
    NSInteger size = listDatas.count;
    if (operation == OperationRefreshAll || operation == OperationNextPage){
        self.noMoreResults = (size == kBatchSize ? NO : YES);
    }

    if (size > 0)
    {
        NSArray *allRecommendAgents = listDatas;
        if (operation == OperationPullToRefresh){
            [self.listDatas insertObjects:allRecommendAgents
                                atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, allRecommendAgents.count)]];
        }else{
            if (operation == OperationRefreshAll){
                [self.listDatas removeAllObjects];
                [self.tableView setContentOffset:CGPointZero animated:YES];
            }
            [self.listDatas addObjectsFromArray:allRecommendAgents];
        }
    }
    
    self.isFinishLoad = YES;
    [self.tableView reloadData];
    self.title = [NSString stringWithFormat:@"%@ (%ld)", self.columnTitle, (unsigned long)self.listDatas.count];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.listDatas.count;
    if (count == 0){
        if (self.isFinishLoad){
            return 1;  // 1 for show no result
        }
        return 0;
    }
    if (self.noMoreResults){
        count += 1;
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
    if (self.listDatas.count == 0)
    {
        UITableViewCell *cell = [VEUtility cellForShowNoResultTableView:tableView
                                           fillMainTip:@"暂无内容"
                                         fillDetailTip:nil
                                       backgroundColor:selectedBackgroundColor];
        return cell;
    }
    
    // has results
    NSInteger section = indexPath.section;
    
    if (self.noMoreResults == YES && section == self.listDatas.count ) {
        UITableViewCell *cell = [VEUtility cellForShowMoreTableView:tableView cellSelectedBackgroundView:nil];
        
        return cell;
    }
    
    
    //上拉自动加载更多
    if (section == [self.listDatas count] - 1 && ((section+1) % kBatchSize == 0) && self.noMoreResults == NO){
        [self nextPage];
    }

    RecommendAgent *recommendAgent = [self.listDatas objectAtIndex:section];
    VERecommendColumnTableViewCell *cell = [VERecommendColumnTableViewCell cellWithTableView:tableView agent:recommendAgent];
    DLog(@"%p",cell);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listDatas.count == 0){
        return 200; // for show no result
    }
    
    NSInteger section = indexPath.section;
    if (section == self.listDatas.count){
        return 48;
    }
    
    if (section >= 0 && section < self.listDatas.count){
        RecommendAgent *recommendAgent = [self.listDatas objectAtIndex:section];
        if (recommendAgent.thumbImageUrl.length > 0){
            return 78;
        }
    }
    
    return 58;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.listDatas.count == 0 || self.listDatas.count == indexPath.section)
    {
        return; // for no result
    }
    
    NSInteger section = indexPath.section;
    [self dealWithReadState:self.listDatas[section]];
    [self openDetailViewAtIndex:section];
}

@end
