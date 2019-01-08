//
//  VEInformationReviewViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 15-1-12.
//  Copyright (c) 2015年 CYYUN. All rights reserved.
//

#import "VEInformationReviewViewController.h"
#import "VEInformationDetailViewController.h"
#import "VENetWorkReportingTableViewCell.h"
#import "InformationReviewTool.h"

static const NSInteger kReadyReviewBtnTag    = 2;
static const NSInteger kFinishedReviewBtnTag = 3;
static const NSInteger kMaxWarnCheckSize     = 100;

extern BOOL g_IsInformReviewOnRed;

typedef NS_ENUM(NSInteger, Operation){
    OperationRefreshAll = 801,
    OperationWarnCheck,
    OperationNextPage,
};

typedef NS_ENUM(NSInteger, ListType){
    ListType_ReadyToReview  = 2,
    ListType_FinishedReview = 3,
};

@interface VEInformationReviewViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView         *categoryView;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UIImageView    *redImageView;

@property (nonatomic, assign) NSInteger       curSelectedCategoryIndex;

//待审核
@property (nonatomic, assign) BOOL                      noMoreResults;
@property (nonatomic, assign) BOOL                      isFinishLoad;
@property (nonatomic, strong) NSMutableArray *readyToReviewListData;
@property (nonatomic, strong) NetworkReportingAgent     *curSelectedReadyAgent;

//已审核
@property (nonatomic, assign) BOOL                      noMoreResults2;
@property (nonatomic, assign) BOOL                      isFinishLoad2;
@property (nonatomic, strong) NSMutableArray *finishedReviewListData;
@property (nonatomic, strong) NetworkReportingAgent     *curSelectedFinishedAgent;
@property (nonatomic, assign) NSInteger                 countsofNew;

@end

@implementation VEInformationReviewViewController

#pragma mark -懒加载
- (NSMutableArray *)readyToReviewListData
{
    if (_readyToReviewListData == nil)
    {
        _readyToReviewListData = [NSMutableArray array];
    }
    return _readyToReviewListData;
}

- (NSMutableArray *)finishedReviewListData
{
    if (_finishedReviewListData == nil)
    {
        _finishedReviewListData = [NSMutableArray array];
    }
    return _finishedReviewListData;
}


#pragma mark -初始化

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self doWarningCheck];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObserver];
    [self reloadImage];
    [self setup];
    
    
    self.curSelectedCategoryIndex = kReadyReviewBtnTag;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self refreshAllReadyToReview];
    });
    
    [self refleshToggleButtonOnRed];
    [self checkOnRed];
    
    [self refreshAllFinishedReview];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(refleshToggleButtonOnRed)
                   name:kNewFlagChangedNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"InformationReview Disappear");
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"InformationReview Disappear");
    if (self.curSelectedReadyAgent){
        // 待审核列表
        if (self.curSelectedReadyAgent.status != 1){
            [self.readyToReviewListData removeObject:self.curSelectedReadyAgent];
            if (self.finishedReviewListData.count == 0){
                [self.finishedReviewListData addObject:self.curSelectedReadyAgent];
            }else{
                [self.finishedReviewListData insertObject:self.curSelectedReadyAgent atIndex:0];
            }
        }
        self.curSelectedReadyAgent = nil;
        [self.tableView reloadData];
    }else if (self.curSelectedFinishedAgent){
        // 已审核列表
        if (self.curSelectedFinishedAgent.isChanged){
            self.tableView.contentOffset = CGPointZero;
            [self sortFinishedReviewListData];
        }
        self.curSelectedFinishedAgent = nil;
    }
}

-(void)reloadImage{
    [super reloadImage];

    _categoryView.backgroundColor = [UIColor colorWithHexString:self.config[MainColor]];
    self.view.backgroundColor = _categoryView.backgroundColor;
}

- (void)setup
{
    self.title =self.config[InformationTitle];
    self.curSelectedCategoryIndex = kReadyReviewBtnTag;
    [self.tableView registerNib:[UINib nibWithNibName:KIdentifier_NetWorkReport bundle:nil] forCellReuseIdentifier:KIdentifier_NetWorkReport];
    
    self.tableView.header = [RefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(doWarningCheck)];
}

#pragma mark - 事件监听
/**
 *  选择分类
 */
- (IBAction)categoryBtnTapped:(UIButton *)sender
{
    if (self.curSelectedCategoryIndex != sender.tag){
        [UIView animateWithDuration:0.1 animations:^{
            NSInteger diff = (sender.tag - self.curSelectedCategoryIndex);
            self.categoryView.center = CGPointMake(self.categoryView.center.x + Main_Screen_Width * 0.5 * diff,
                                                             self.categoryView.center.y);
        }];
        self.curSelectedCategoryIndex = sender.tag;
        [self.tableView reloadData];
    }
}

/**
 *  刷新未审核
 */
- (void)refreshAllReadyToReview
{
    [self refreshAllListType:ListType_ReadyToReview];
}

/**
 *  刷新已审核
 */
- (void)refreshAllFinishedReview
{
    [self refreshAllListType:ListType_FinishedReview];
}

/**
 *  上拉加载更多
 */
- (void)loadMore
{
    NSArray *listData = [self getCurrentListData];
    NetworkReportingAgent *agent = [listData lastObject];
    if (agent.timeWarn){
        ListType type = (self.curSelectedCategoryIndex == kReadyReviewBtnTag ? ListType_ReadyToReview : ListType_FinishedReview);
        [self grabListType:type atTimeInterval:agent.timeWarn withOperation:OperationNextPage];
    }else{
        [self.tableView reloadData];
    }
}

/**
 *  下拉刷新
 */
- (void)refreshAllListType:(ListType)listType
{
    [self grabListType:listType
        atTimeInterval:@"0"
         withOperation:OperationRefreshAll];
}



#pragma mark - 我的方法
- (void)doWarningCheck
{
    ListType listType = ListType_ReadyToReview;
    if (self.curSelectedCategoryIndex == kFinishedReviewBtnTag){
        listType = ListType_FinishedReview;
    }
    
    NSString *startTime = @"0";
    [self grabListType:listType atTimeInterval:startTime withOperation:OperationRefreshAll];
}

/**
 *  打开详情页
 * */
- (void)openDetailViewAtIndex:(NSInteger)index
{
    NSArray *listData = self.finishedReviewListData;
    VEInformationDetailViewController *detailVC = [[VEInformationDetailViewController alloc] initWithNibName:@"VEInformationDetailViewController" bundle:nil];
    NetworkReportingAgent *agent = [listData objectAtIndex:index];
    if (agent.status == 1){// 1 待审核  2 已录用 3 未录用
        self.curSelectedReadyAgent = agent;
    }else{
        self.curSelectedFinishedAgent = agent;
    }
    agent.isChanged = NO;
    detailVC.networkReportAgent = agent;
    [self.navigationController pushViewController:detailVC animated:YES];
    
    // 【待审核】标记已读
    if (!agent.isRead && (self.curSelectedCategoryIndex == kReadyReviewBtnTag))
    {
        agent.isRead = YES;
        [VEUtility setWarnReadWithArticleId:agent.articleId andWarnType:agent.warnType];
        [self refreshCountsOfNew];
    }
}

/**
 *  HTTP抓取数据
 */
- (void)grabListType:(ListType)listType
      atTimeInterval:(NSString *)timeInterval
       withOperation:(Operation)operation
{
    if (timeInterval == nil){
        timeInterval = @"0";
    }
    
    NSDictionary *params=nil;
    if (operation == OperationWarnCheck){
        params = @{
                   @"listType":[NSString stringWithFormat:@"%ld",(long)listType],
                   @"start":timeInterval,
                   @"limit":[NSString stringWithFormat:@"%ld",(long)kMaxWarnCheckSize]
                   };
    }else{
        params = @{
                   @"listType":[NSString stringWithFormat:@"%ld",(long)listType],
                   @"start":timeInterval,
                   @"limit":[NSString stringWithFormat:@"%ld",(long)kBatchSize]
                   };
    }
    
    [InformationReviewTool loadNetworkReportWithParam:params resultInfo:^(BOOL success, id JSON) {
        if (success) {
            [self updateListData:JSON withOperation:operation fromListType:listType];
        }
        [self.tableView.header endRefreshing];
    }];
}

/**
 *  更新内存数据
 */
- (void)updateListData:(NSArray *)listDatas
         withOperation:(Operation)operation
          fromListType:(ListType)listType
{
    if (operation == OperationRefreshAll){
        if (listType == ListType_ReadyToReview){
            [self.readyToReviewListData removeAllObjects];
        }else if (listType == ListType_FinishedReview){
            [self.finishedReviewListData removeAllObjects];
        }if (self.curSelectedCategoryIndex == listType){
            [self.tableView reloadData];
        }
    }
    
    NSInteger size = listDatas.count;
    NSMutableArray *listAgents = nil;
    if (listType == ListType_ReadyToReview){
        if (operation != OperationWarnCheck){
            if (size == kBatchSize){
                self.noMoreResults = NO;
            }else{
                self.noMoreResults = YES;
            }
        }
        self.isFinishLoad = YES;
        listAgents = self.readyToReviewListData;
    }else if (listType == ListType_FinishedReview){
        if (operation != OperationWarnCheck){
            if (size == kBatchSize){
                self.noMoreResults2 = NO;
            }else{
                self.noMoreResults2 = YES;
            }
        }
        self.isFinishLoad2 = YES;
        listAgents = self.finishedReviewListData;
    }
    
    if (size > 0){
        if (operation == OperationWarnCheck){
            [listAgents insertObjects:listDatas
                            atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, listDatas.count)]];
        }else{
            [listAgents addObjectsFromArray:listDatas];
        }
    }
    
    [self.tableView reloadData];
    
    if (listType == ListType_ReadyToReview){
        [self refreshCountsOfNew];
    }
}

/**
 *  更新未读信息数，标记Red
 */
- (void)refreshCountsOfNew
{
    self.countsofNew = 0;
    for (NetworkReportingAgent *agent in self.readyToReviewListData)
    {
        if (!agent.isRead)
        {
            ++self.countsofNew;
        }
    }
    g_IsInformReviewOnRed = (self.countsofNew > 0 ? YES : NO);
    [VEUtility postNewFlagChangedNotification];
    [self checkOnRed];
}

- (void)checkOnRed
{
    NSString *imgName = (self.countsofNew > 0 ? Config(Menu_Icon_Red_Point) : nil);
    if (imgName.length > 0) {
        self.redImageView.image = [QCZipImageTool imageNamed:imgName];
    }else{
        self.redImageView.image = nil;
    }
    
}

- (NSMutableArray *)getCurrentListData
{
    NSMutableArray *listDatas = nil;
    if (self.curSelectedCategoryIndex == kReadyReviewBtnTag){
        listDatas = self.readyToReviewListData;
    }else if (self.curSelectedCategoryIndex == kFinishedReviewBtnTag){
        listDatas = self.finishedReviewListData;
    }
    return listDatas;
}

- (void)sortFinishedReviewListData
{
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"timeWarn" ascending:NO];
    [self.finishedReviewListData sortUsingDescriptors:[NSArray arrayWithObject:desc]];
    [self.tableView reloadData];
}

#pragma mark - tableView代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger counts = 0;
    BOOL isFinished = NO;
    BOOL noMore = YES;
    
    if (self.curSelectedCategoryIndex == kReadyReviewBtnTag){
        isFinished = self.isFinishLoad;
        noMore = self.noMoreResults;
        counts = self.readyToReviewListData.count;
    }else if (self.curSelectedCategoryIndex == kFinishedReviewBtnTag)
    {
        isFinished = self.isFinishLoad2;
        noMore = self.noMoreResults2;
        counts = self.finishedReviewListData.count;
    }
    
    if (counts == 0){
        if (isFinished){
            return 1;  // 1 for show no result
        }
        return 0;
    }if (noMore) {
        counts +=1;
    }
    return counts;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listDatas = [self getCurrentListData];
    NSInteger counts = listDatas.count;
    NSInteger section = indexPath.section;
    BOOL noMoreResults = NO;
    if (self.curSelectedCategoryIndex == kReadyReviewBtnTag){
        noMoreResults = self.noMoreResults;
    }else{
        noMoreResults = self.noMoreResults2;
    }
    
    // no results
    if (counts == 0){
        UITableViewCell *cell = [VEUtility cellForShowNoResultTableView:tableView
                                           fillMainTip:@"暂无内容"
                                         fillDetailTip:nil
                                       backgroundColor:selectedBackgroundColor];
        return cell;
    }else if(section == counts && noMoreResults) {
        UITableViewCell *cell = [VEUtility cellForShowMoreTableView:tableView cellSelectedBackgroundView:nil];
        return cell;
    }else if (!noMoreResults && section == (counts - 1)){
        [self loadMore];
    }
    
    NetworkReportingAgent *agent = [listDatas objectAtIndex:section];
    VENetWorkReportingTableViewCell *cell = [VENetWorkReportingTableViewCell cellWithTableView:tableView];
    if(self.curSelectedCategoryIndex == kFinishedReviewBtnTag){
        agent.isRead = NO;
    }
    cell.agent = agent;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listDatas = [self getCurrentListData];
    NSInteger counts = listDatas.count;
    if (counts == 0){
        return 200; // for show no result
    }else if (indexPath.section == counts){
        return 48;
    }
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *listData = [self getCurrentListData];
    NSInteger counts = listData.count;
    if (counts == 0 || indexPath.section == counts){
        return;
    }else{
        
        [self openDetailViewAtIndex:indexPath.section];
    }
}
#pragma mark - 通知
- (void)refleshToggleButtonOnRed
{
    VENavViewController *nav = (VENavViewController *)self.navigationController;
    nav.iconType = [VEUtility isOnRed];
}

@end
