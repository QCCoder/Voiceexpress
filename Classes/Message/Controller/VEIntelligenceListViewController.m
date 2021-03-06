//
//  VEIntelligenceListViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-10-27.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEIntelligenceListViewController.h"
#import "VECustomAlertTableViewCell.h"
#import "EGORefreshTableHeaderView.h"
#import "VEAppDelegate.h"
#import "VEIntelligenceLabel.h"
#import "MessageDetailViewController.h"
typedef NS_ENUM(NSInteger, Operation)
{
    OperationNewCheck,
    OperationRefreshAll,
    OperationNextPage,
};

typedef NS_ENUM(NSInteger, ExchangeType)
{
    // 数值不要修改 
    ExchangeTypeInstant = 1,            // 网安信息快报
    ExchangeTypeDaily = 2,              // 网安每日舆情
    ExchangeTypeInternational = 3,      // 外宣每日舆情
    ExchangeTypeAll = 4,                // 情报交互信息
};

static const NSInteger kOptionActionSheetTag = 290;
static const NSInteger kUpdateAlertViewTag   = 291;
static const NSInteger kSettingTableTag      = 300;

@interface VEIntelligenceListViewController ()<EGORefreshTableHeaderDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView   *tableView;

@property (weak, nonatomic) IBOutlet UIView                    *actionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UILabel                   *labelTip;

@property (strong, nonatomic) UITableView                       *settingTableView;
@property (nonatomic, strong) UIView                            *cellSelectedBackgroundView;
@property (nonatomic, strong) NSMutableArray                    *intelliListData;
@property (nonatomic, strong) FYNHttpRequestLoader              *httpLoader;
@property (nonatomic, assign) BOOL                              noMoreResults;
@property (nonatomic, assign) BOOL                              reloading;
@property (nonatomic, assign) NSInteger                         currentPage;
@property (nonatomic, assign) ExchangeType                      currentExchangeType;

@property (nonatomic, strong) UIView                            *categoryView;
@property (nonatomic, strong) UIView                            *categoryBackView;
@property (nonatomic, strong) UITapGestureRecognizer            *tapGesturer;

@property (nonatomic, strong) EGORefreshTableHeaderView         *refreshHeaderView;
@property (nonatomic, strong) UIActionSheet                     *optionActionSheet;

@property (nonatomic, strong) CAAnimation *showMenuAnimation;
@property (nonatomic, strong) CAAnimation *dismissMenuAnimation;
@property (nonatomic, strong) CAAnimation *dimingAnimation;
@property (nonatomic, strong) CAAnimation *lightingAnimation;

@property (nonatomic, assign) BOOL        isFinishLoad;

- (IBAction)back:(id)sender;
- (IBAction)showList:(id)sender;

@end

@implementation VEIntelligenceListViewController

- (NSMutableArray *)intelliListData
{
    if (_intelliListData == nil)
    {
        _intelliListData = [[NSMutableArray alloc] init];
    }
    return _intelliListData;
}

- (FYNHttpRequestLoader *)httpLoader
{
    if (_httpLoader == nil)
    {
        _httpLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpLoader;
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

- (UITableView *)settingTableView
{
    if (_settingTableView == nil)
    {
        _settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 185,170)
                                                         style:UITableViewStylePlain];
        _settingTableView.delegate = self;
        _settingTableView.dataSource = self;
        _settingTableView.tag = kSettingTableTag;
        
        // 去掉多余的分割线
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        _settingTableView.tableFooterView = view;
    }
    return _settingTableView;
}

- (void)initHeaderView
{
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc]
                              initWithFrame:CGRectMake(0.0f,
                                                       -self.tableView.bounds.size.height,
                                                       self.view.frame.size.width,
                                                       self.tableView.bounds.size.height)];
    self.refreshHeaderView.delegate = self;
    self.refreshHeaderView.backgroundColor = [UIColor clearColor];
    [self.tableView addSubview:_refreshHeaderView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
    
    // 加载数据
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //[self loadFirstPageFromServer];
        self.currentPage = 1;
        [self grapDataFromExChangeType:self.currentExchangeType
                                AtPage:self.currentPage
                         withOperation:OperationRefreshAll
                               andSize:kBatchSize];
    }];
    
    

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(newDayHappenedNotification)
                   name:kNewDayHappenedNotification
                 object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"IntelligenceList Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"IntelligenceList Disappear");
}

- (void)setUp
{
    [self initHeaderView];
    
    self.noMoreResults = YES;
    self.currentExchangeType = ExchangeTypeAll;
    self.actionView.layer.cornerRadius  = 5.0;
    
    [self setupNav];
}

/**
 *  初始化导航
 */
-(void)setupNav
{
    
    VEIntelligenceLabel *label = [[VEIntelligenceLabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setUserInteractionEnabled:YES];
    [label setText:@"情报交互信息"];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(showCategoryMenu)];
    
    [label addGestureRecognizer:tapGestureRecognizer];
    [self.navigationItem setTitleView:label];
    self.navigationItem.titleView = label;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(showList:) image:Config(Tab_Icon_More) highImage:@""];;
    
}


- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSettingTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self cancelAllHttpRequester];
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self.tapGesturer])
    {
        CGPoint p = [gestureRecognizer locationInView:self.categoryView];
        if (CGRectContainsPoint(self.settingTableView.frame, p))
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - My Methods

- (void)tapBackground:(UITapGestureRecognizer *)tapGesture
{
    CGPoint touchPoint = [tapGesture locationInView:self.categoryView];
    if (!CGRectContainsPoint(self.settingTableView.frame, touchPoint))
    {
        [self dismissCategoryMemuAnimated:YES];
    }
}

- (void)showCategoryMenu
{
    [self showCategoryMemuAnimated:YES];
}

- (void)showCategoryMemuAnimated:(BOOL)animated
{
    if (self.categoryView == nil)
    {
        self.categoryView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.categoryView.backgroundColor = [UIColor clearColor];
    }
    
    if (self.categoryBackView == nil)
    {
        self.categoryBackView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    if (![self.categoryView superview])
    {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.categoryView];
        
        [self.categoryView addSubview:self.categoryBackView];
        
        self.tapGesturer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
        self.tapGesturer.delegate = self;
        
        [self.categoryView addGestureRecognizer:self.tapGesturer];
        [self.categoryView addSubview:self.settingTableView];
        
        self.settingTableView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - self.settingTableView.frame.size.width) / 2,
                                                 64,
                                                 self.settingTableView.frame.size.width,
                                                 self.settingTableView.frame.size.height);
    }
    
    [self.settingTableView reloadData];
    
    if (animated)
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.2];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        
        [self.categoryBackView.layer addAnimation:self.dimingAnimation forKey:@"diming"];
        [self.settingTableView.layer addAnimation:self.showMenuAnimation forKey:@"showMenu"];
        [CATransaction commit];
    }
}

- (void)dismissCategoryMemuAnimated:(BOOL)animated
{
    if (animated)
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.2];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [CATransaction setCompletionBlock:^{
            [self.settingTableView removeFromSuperview];
            [self.categoryView removeFromSuperview];
            [self.categoryView removeGestureRecognizer:self.tapGesturer];
            
            self.tapGesturer = nil;
            self.categoryView = nil;
        }];
        
        [self.categoryBackView.layer addAnimation:self.lightingAnimation forKey:@"lighting"];
        [self.settingTableView.layer addAnimation:self.dismissMenuAnimation forKey:@"dismissMenu"];
        [CATransaction commit];
    }
    else
    {
        [self.settingTableView removeFromSuperview];
        [self.categoryView removeFromSuperview];
        [self.categoryView removeGestureRecognizer:self.tapGesturer];
        
        self.tapGesturer = nil;
        self.categoryView = nil;
    }
}

- (void)cancelAllHttpRequester
{
    if (_httpLoader)
    {
        [self.httpLoader cancelAsynRequest];
    }
}

- (void)startShowActionView:(NSString *)strTip
{
    self.actionView.alpha = 0;
    self.labelTip.text = strTip;
    [UIView animateWithDuration:1.0 animations:^{
        self.actionView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

- (void)stopShowActionView
{
    self.actionView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.actionView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                         //self.labelTip.text = nil;
                     }
     ];
}

- (void)nextPage
{
    [self grapDataFromExChangeType:ExchangeTypeAll
                            AtPage:(self.currentPage + 1)
                     withOperation:OperationNextPage
                           andSize:kBatchSize];
}

- (void)openDetailViewAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.intelliListData.count)
    {
        MessageDetailViewController *detailViewController = [[MessageDetailViewController alloc]initWithNibName:@"MessageDetailViewController" bundle:nil];
        IntelligenceAgent *agent = self.intelliListData[index];
        detailViewController.intelligAgent = agent;
        detailViewController.boxType = BoxTypeAllIntelligence;
        detailViewController.columnType = IntelligenceColumnAllIntelligence;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)categoryIndexChanged:(NSInteger)index
{
    [self dismissCategoryMemuAnimated:YES];
    self.title = [self getTitleInSettingTableAtIndex:index];

    switch (index)
    {
        case 0:
            self.currentExchangeType = ExchangeTypeAll;
            break;
            
        case 1:
            self.currentExchangeType = ExchangeTypeInstant;
            break;
            
        case 2:
            self.currentExchangeType = ExchangeTypeDaily;
            break;
            
        case 3:
            self.currentExchangeType = ExchangeTypeInternational;
            break;
            
        default:
            self.currentExchangeType = ExchangeTypeAll;
            break;
    }
    
    self.currentPage = 1;
    [self grapDataFromExChangeType:self.currentExchangeType
                            AtPage:self.currentPage
                     withOperation:OperationRefreshAll
                           andSize:kBatchSize];
    
}

- (void)doCheckNewAction
{
    [self stopEgoRefresh];
    
    self.currentPage = 1;
    [self grapDataFromExChangeType:self.currentExchangeType
                            AtPage:self.currentPage
                     withOperation:OperationNewCheck
                           andSize:kBatchSize];
}

- (void)loadFirstPageFromServer
{
    self.currentPage = 1;
    [self grapDataFromExChangeType:self.currentExchangeType
                            AtPage:self.currentPage
                     withOperation:OperationRefreshAll
                           andSize:kBatchSize];
}

// 获取数据

- (void)grapDataFromExChangeType:(ExchangeType)exchangeType
                          AtPage:(NSInteger)page
                   withOperation:(Operation)operation
                         andSize:(NSInteger)size
{
    page = (page <= 0 ? 1 : page);
    size = (size <= 0 ? kBatchSize : size);
    
    NSDictionary *param = @{
                            @"io":@"3",
                            @"exchangeType":[NSString stringWithFormat:@"%ld",(long)exchangeType],
                            @"page":[NSString stringWithFormat:@"%ld",(long)page],
                            @"limit":[NSString stringWithFormat:@"%ld",(long)size],
                            @"device":@"iga"
                            };
    
    
    [MBProgressHUD showMessage:@"正在加载数据，请稍等..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    [HttpTool postWithUrl:@"CustomWarnListForGA" Parameters:param Success:^(id JSON) {
        [MBProgressHUD hideHUDForView:self.view];
        NSInteger result = [JSON[@"result"] integerValue];
        if (result == 0) {
            [weakSelf updateExchangeType:exchangeType
                            withListData:JSON[@"list"]
                           fromOperation:operation
                                  atPage:page];

        }else if (result == 10){
            // 有强制更新
            NSString *updateDiscrip = JSON[@"discription"];
            UIAlertView *alertShow = [[UIAlertView alloc] initWithTitle:@"更新提示"
                                                                message:updateDiscrip
                                                               delegate:weakSelf
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"立刻更新", nil];
            alertShow.tag = kUpdateAlertViewTag;
            [alertShow show];
        }else{
            [AlertTool showAlertToolWithCode:result];
        }
    } Failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        DLog(@"%@",[error localizedDescription]);
    }];
}

// 更新列表信息

- (void)updateExchangeType:(ExchangeType)exchangeType
              withListData:(NSArray *)listData
             fromOperation:(Operation)operation
                    atPage:(NSInteger)page
{
    @autoreleasepool {
        NSInteger size = listData.count;
        self.noMoreResults = (size == kBatchSize ? NO : YES);
        
        self.currentPage = page;
        if (self.currentPage == 1)
        {
            [self.intelliListData removeAllObjects];
        }
        
        if (size > 0)
        {
            NSMutableArray *allAgents = [NSMutableArray array];
            for (NSDictionary *singleItem in listData)
            {
                IntelligenceAgent *intelligAgent = [[IntelligenceAgent alloc] initWithDictionary:singleItem];
                NSDictionary *intelligInfo = [MessageTool intelligenceInfoInBoxType:BoxTypeAllIntelligence
                                                                    withArticleID:intelligAgent.articleId
                                                                      andWarnType:intelligAgent.warnType];
                
                double localLatestTimeReply    = [[intelligInfo valueForKey:kIntelligenceLatestTimeReply] doubleValue];
                intelligAgent.latestTimeReply  = MAX(localLatestTimeReply, intelligAgent.latestTimeReply);
        
                [allAgents addObject:intelligAgent];
            }
            
            [self.intelliListData addObjectsFromArray:allAgents];
            
            // 记录最大的回复时间
            if (1 == page)
            {
                double maxNewestTimeReply = ((IntelligenceAgent *)[allAgents objectAtIndex:0]).newestTimeReply;
                double localNewestTimeReply = [MessageTool newestTimeAtIntelligenceColumnType:IntelligenceColumnAllIntelligence];
                if (maxNewestTimeReply > localNewestTimeReply)
                {
                    [MessageTool setNewestTime:maxNewestTimeReply atIntelligenceColumnType:IntelligenceColumnAllIntelligence];
                }
            }
            
            [allAgents removeAllObjects];
        }
        
//        if (operation != OperationNextPage)
//        {
//            self.tableView.contentOffset = CGPointZero;
//        }
        self.isFinishLoad = YES;
        [self.tableView reloadData];
    }
}

- (NSString *)getTitleInSettingTableAtIndex:(NSInteger)index
{
    NSString *title = @"";
    
    switch (index)
    {
        case 0:
            title = @"情报交互信息";
            break;
        
        case 1:
            title = @"网安信息快报";
            break;
            
        case 2:
            title = @"网安每日舆情";
            break;
            
        case 3:
            title = @"外宣每日舆情";
            break;
        
        default:
            break;
    }
    
    return title;
}

- (BOOL)isSelectedAtIndex:(NSInteger)index
{
    BOOL bSel = NO;
    
    switch (index)
    {
        case 0:
            bSel = (self.currentExchangeType == ExchangeTypeAll ? YES : NO);
            break;
            
        case 1:
            bSel = (self.currentExchangeType == ExchangeTypeInstant ? YES : NO);
            break;
            
        case 2:
            bSel = (self.currentExchangeType == ExchangeTypeDaily ? YES : NO);
            break;
            
        case 3:
            bSel = (self.currentExchangeType == ExchangeTypeInternational ? YES : NO);
            break;
            
        default:
            break;
    }
    
    return bSel;
}

#pragma mark - IBAction

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showList:(id)sender
{
    if (self.optionActionSheet == nil)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"刷新全部数据", nil];
        actionSheet.tag = kOptionActionSheetTag;
        self.optionActionSheet = actionSheet;
    }
    
    [self.optionActionSheet showInView:self.view];
}


#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kOptionActionSheetTag)
    {
        if (buttonIndex == 0)
        {
            [self loadFirstPageFromServer];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == kSettingTableTag)
    {
        return 1;
    }
    else
    {
        NSInteger counts = self.intelliListData.count;
        if (counts == 0)
        {
            if (self.isFinishLoad)
            {
                return 1; // for showing no result
            }
            return 0;
        }
        
        if (self.noMoreResults) {
            counts++;
        }
        
        return counts;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kSettingTableTag)
    {
        return 4;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellDefault";
    
    UITableViewCell *cell = nil;
    
    if (tableView.tag == kSettingTableTag)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *tipImgageView = (UIImageView *)[cell viewWithTag:130];
        if (tipImgageView == nil)
        {
            tipImgageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.settingTableView.frame.size.width - 38), 12.25f, 18, 18)];
            tipImgageView.tag = 130;
            [cell.contentView addSubview:tipImgageView];
        }
        
        UILabel *tipLabel = (UILabel *)[cell viewWithTag:131];
        if (tipLabel == nil)
        {
            tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 6.25f, 200, 30)];
            tipLabel.tag = 131;
            tipLabel.font = [UIFont boldSystemFontOfSize:17];
            tipLabel.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:tipLabel];
        }
        
        NSString *title = [self getTitleInSettingTableAtIndex:indexPath.row];
        tipLabel.text = title;
       
        if ([self isSelectedAtIndex:indexPath.row])
        {
            tipImgageView.image = Image(Icon_Selected);
             tipLabel.textColor = lowGreenColor;
        }
        else
        {
            tipImgageView.image = nil;
            tipLabel.textColor = unreadFontColor;
        }
    }
    else
    {
        NSInteger section = indexPath.section;
        // no results
        if (self.intelliListData.count == 0)
        {
            cell = [VEUtility cellForShowNoResultTableView:tableView
                                               fillMainTip:@"暂无内容"
                                             fillDetailTip:nil
                                           backgroundColor:selectedBackgroundColor];
            return cell;
        }
        
        if (self.noMoreResults == YES && section == self.intelliListData.count ) {
            cell = [VEUtility cellForShowMoreTableView:tableView cellSelectedBackgroundView:nil];
            return cell;
        }
        
        
        
     
        if ((section == [self.intelliListData count] - 1) && ((section+1) % kBatchSize == 0) )
        {
            [self nextPage];
        }
        
        VECustomAlertTableViewCell * cell = [VECustomAlertTableViewCell cellWithTableView:tableView];
        cell.agent = [self.intelliListData objectAtIndex:section];
        return  cell;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kSettingTableTag)
    {
        return 42.5f ;
    }
    else
    {
        if (self.intelliListData.count == 0)
        {
            return 200; // for show no result
        }
        
        if (indexPath.section == self.intelliListData.count)
        {
            return 58;
        }
        return 78;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        return 8;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        UIView *bkView = [[UIView alloc] init];
        bkView.backgroundColor =  selectedBackgroundColor;
        
        return bkView;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == kSettingTableTag)
    {
        [self categoryIndexChanged:indexPath.row];
    }
    else
    {
        if (self.intelliListData.count == 0)
        {
            return; // for no result
        }
        
        NSInteger section = indexPath.section;
        
        // 下一页
        if (section == self.intelliListData.count)
        {
            [self nextPage];
        }
        else
        {
            [self openDetailViewAtIndex:section];
        }
    }
}


#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.reloading = YES;
    [self performSelector:@selector(doCheckNewAction) withObject:nil afterDelay:0.1];
}

- (void)stopEgoRefresh
{
    if (self.reloading)
    {
        self.reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return  self.reloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (kUpdateAlertViewTag == alertView.tag)
    {
        [VEUtility downLoadNewVersion];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.tableView)
    {
        [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - Notification

- (void)applicationDidEnterBackgroundNotification
{
    if (self.optionActionSheet)
    {
        if (self.optionActionSheet.numberOfButtons)
        {
            [self.optionActionSheet dismissWithClickedButtonIndex:(self.optionActionSheet.numberOfButtons - 1)
                                                         animated:NO];
        }
    }
    
    if ([self.settingTableView superview])
    {
        [self dismissCategoryMemuAnimated:NO];
    }
}

- (void)newDayHappenedNotification
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadFirstPageFromServer];
    });
}


#pragma mark - Animation

- (CAAnimation *)dimingAnimation
{
    if (_dimingAnimation == nil)
    {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        opacityAnimation.fromValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor];
        opacityAnimation.toValue   = (id)[[UIColor colorWithWhite:0.0 alpha:0.4] CGColor];
        opacityAnimation.removedOnCompletion = NO;
        opacityAnimation.fillMode = kCAFillModeBoth;
        
        _dimingAnimation = opacityAnimation;
    }
    return _dimingAnimation;
}

- (CAAnimation *)showMenuAnimation
{
    if (_showMenuAnimation == nil)
    {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setFromValue:@0.4];
        [opacityAnimation setToValue:@1.0];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        [group setAnimations:@[opacityAnimation]];
        group.removedOnCompletion = NO;
        group.fillMode = kCAFillModeBoth;
        
        _showMenuAnimation = group;
    }
    return _showMenuAnimation;
}

- (CAAnimation *)lightingAnimation
{
    if (_lightingAnimation == nil )
    {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        opacityAnimation.fromValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.4] CGColor];
        opacityAnimation.toValue   = (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor];
        opacityAnimation.removedOnCompletion = NO;
        opacityAnimation.fillMode = kCAFillModeBoth;
        
        _lightingAnimation = opacityAnimation;
    }
    return _lightingAnimation;
}

- (CAAnimation *)dismissMenuAnimation
{
    if (_dismissMenuAnimation == nil)
    {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setFromValue:@1.0];
        [opacityAnimation setToValue:@0.4];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        [group setAnimations:@[opacityAnimation]];
        group.removedOnCompletion = NO;
        group.fillMode = kCAFillModeBoth;
        
        _dismissMenuAnimation = group;
    }
    return _dismissMenuAnimation;
}


@end
