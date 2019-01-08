//
//  VESearchResultsViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-30.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VESearchResultsViewController.h"
#import "VEWarnAlertTableViewCell.h"
#import "VERecommendColumnTableViewCell.h"

#import "VERecommendReadDetailVC.H"
#import "UIImageView+WebCache.h"
#import "SearchAlertTool.h"

#import "VEAlertDetailViewController.h"
static const NSInteger kMaxPages = 10;

@interface VESearchResultsViewController ()

@property (weak, nonatomic) IBOutlet UITableView               *tableView;

@property (nonatomic, assign) BOOL                  isFinishLoad;
@property (nonatomic, assign) BOOL                  noMoreResults;
@property (nonatomic, assign) NSInteger             currentPage;
@property (nonatomic, strong) NSMutableArray        *searchAlertData;
@property (nonatomic, strong) UIView                *cellSelectedBackgroundView;
@property (nonatomic, strong) FYNHttpRequestLoader  *httpRequestLoader;

@end

@implementation VESearchResultsViewController

- (FYNHttpRequestLoader *)httpRequestLoader
{
    if (_httpRequestLoader == nil)
    {
        _httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestLoader;
}

- (NSMutableArray *)searchAlertData
{
    if (_searchAlertData == nil)
    {
        _searchAlertData = [[NSMutableArray alloc] init];
    }
    return _searchAlertData;
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
        if (_searchAlertData)
        {
            [self.searchAlertData removeAllObjects];
            self.searchAlertData = nil;
        }
        if (_cellSelectedBackgroundView)
        {
            self.cellSelectedBackgroundView = nil;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refleshAll];
    
    [self setupNav];
}


/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = [NSString stringWithFormat:@"%@0%@",self.config[SearchResult_Left],self.config[SearchResult_Right]];
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(refleshAll) image:self.config[Tab_Icon_Refresh] highImage:nil];
    self.navigationItem.rightBarButtonItem = more;
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     DLog(@"SearchResults Disappear");
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelAllHttpRequester];
    DLog(@"SearchResults Disappear");
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
    for (Agent *agent in self.searchAlertData)
    {
        @autoreleasepool {
            agent.articleContent = nil;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSInteger count = self.searchAlertData.count;
    if (self.noMoreResults) {
        count++;
    }
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchAlertData.count == 0)
    {
        return 200; // for show no result
    }
    
    NSInteger section = indexPath.section;
    if (section == self.searchAlertData.count)
    {
        return 48;
    }
    
    if (self.searchType == SearchTypeRecommendRead)
    {
        if (section >= 0 && section < self.searchAlertData.count)
        {
            RecommendAgent *recommendAgent = [self.searchAlertData objectAtIndex:section];
            if (recommendAgent.thumbImageUrl.length > 0)
            {
                return 78;
            }
        }
    }
    
    return 58;
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

    if (self.searchAlertData.count == 0)
    {
        cell = [VEUtility cellForShowNoResultTableView:tableView
                                           fillMainTip:@"暂无内容"
                                         fillDetailTip:nil
                                       backgroundColor:selectedBackgroundColor];
        return cell;
    }else if (section == self.searchAlertData.count && noMoreResults==YES) {
        cell = [VEUtility cellForShowMoreTableView:tableView cellSelectedBackgroundView:nil];
        return cell;
    }
    
    if (noMoreResults == NO && section == (self.searchAlertData.count - 1) ) {
        [self loadMoreData];
    }
    
    if (self.searchType == SearchTypeRecommendRead){
        // 【推荐阅读搜索】
        RecommendAgent *recommendAgent = [self.searchAlertData objectAtIndex:section];
        VERecommendColumnTableViewCell *cell = [VERecommendColumnTableViewCell cellWithTableView:tableView agent:recommendAgent];
        return cell;
    }else{
        // 【舆情预警搜索】、【舆情搜索】
        cell = [VEWarnAlertTableViewCell cellWithTableView:tableView];
        VEWarnAlertTableViewCell *warnAlertCell = (VEWarnAlertTableViewCell *)cell;
        warnAlertCell.warnAgent = self.searchAlertData[section];
        return warnAlertCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.searchAlertData.count == 0){
        return; // for no result
    }
    
    if (indexPath.section == [self.searchAlertData count]){
        return;
    }
    
    [self openDetailViewAtIndex:indexPath.section];
}

#pragma mark - MyMethods

// 打开详情页

- (void)openDetailViewAtIndex:(NSInteger)index
{
    
    switch (self.searchType)
    {
        case SearchTypeNormal:
        case SearchTypeLatestAlert:{
            VEAlertDetailViewController *VC = [[VEAlertDetailViewController alloc]initWithNibName:@"VEAlertDetailViewController" bundle:nil];
            VC.agent = self.searchAlertData[index];
            [self.navigationController pushViewController:VC animated:YES];
            break;
        }
            
        case SearchTypeRecommendRead:{
            VERecommendReadDetailVC *detailViewController = [[VERecommendReadDetailVC alloc]
                                                             initWithNibName:@"VERecommendReadDetailVC" bundle:nil];
            detailViewController.agent = self.searchAlertData[index];
            [self.navigationController pushViewController:detailViewController animated:YES];
            break;
        }
        default:
            break;
    }
}

// 下一页

- (void)loadMoreData
{
    [self grabNewSearchResults];
}

// 从服务器端获取搜索结果

- (void)grabNewSearchResults
{
    NSString *stringUrl = nil;
    if (self.searchType == SearchTypeLatestAlert || self.searchType == SearchTypeRecommendRead){
        stringUrl = @"localSearch";
    }else{
        stringUrl = @"search";
    }
   
    NSString *scope = nil;
    switch (self.selectedScopeIndex){
        case 0:
            scope = @"all";
            break;
        case 1:
            scope = @"title";
            break;
        case 2:
            scope = @"content";
            break;
        case 3:
            scope = @"localtag";
            break;
        default:
            scope = @"all";
            break;
    }
    
    NSDictionary *param = @{
                            @"page":[NSString stringWithFormat:@"%ld",(long)self.currentPage],
                            @"word":self.searchWord,
                            @"scope":scope,
                            @"size":[NSString stringWithFormat:@"%ld",(long)kBatchSize],
                            @"searchType":[NSString stringWithFormat:@"%ld",(long)self.searchType]
                            };
    
    [PromptView startShowPromptViewWithTip:@"正在加载数据，请稍等..." view:self.view];    
    [SearchAlertTool loadSearchWithUrl:stringUrl param:param resultInto:^(BOOL success, id JSON) {
        [PromptView hidePromptFromView:self.view];
        if (success) {
            
            NSArray *datalist = nil;
            if (self.searchType == SearchTypeRecommendRead){
                datalist = [RecommendAgent objectArrayWithKeyValuesArray:JSON[@"list"]];
            }else{
                datalist = [WarnAgent objectArrayWithKeyValuesArray:JSON[@"list"]];
            }
            [self updateSearchlertData:datalist];
        }
    }];
}

// 刷新数据

- (void)updateSearchlertData:(NSArray *)listDatas
{
    ++self.currentPage;
    NSInteger size = listDatas.count;
    if (size != kBatchSize || self.currentPage > kMaxPages){
        self.noMoreResults = YES;
    }else{
        self.noMoreResults = NO;
    }
    
    if (size > 0){
        [self.searchAlertData addObjectsFromArray:listDatas];
    }
    
    self.isFinishLoad = YES;
    [self.tableView reloadData];
    self.title = [NSString stringWithFormat:@"%@%ld%@", self.config[SearchResult_Left],(unsigned long)self.searchAlertData.count,self.config[SearchResult_Right]];
}

#pragma mark - IBAction

- (void)refleshAll
{
    self.isFinishLoad = NO;
    [self.searchAlertData removeAllObjects];
    [self.tableView reloadData];
    
    self.currentPage = 1;
    [self loadMoreData];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
