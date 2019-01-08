//
//  VEInternetViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-9-18.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEInternetViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "RESideMenu.h"
#import "NetworkReportingAgent.h"
#import "VEIntertDetailViewController.h"
#import "VEAppDelegate.h"
#import "QCDeviceViewController.h"
#import "VENetWorkReportingTableViewCell.h"
#import "VEInternetAlertTableViewCell.h"
#import "VEInternetTool.h"
#import "InformationReviewTool.h"
#import "VEIntertDetailController.h"

static const NSInteger kActionSheetTag              = 270;
static const NSInteger kSettingTableTag             = 180;
static const NSInteger kMaxInternetWarnCheckSize    = 10000;
static const NSInteger kResetBtnTag                 = 301;
static const NSInteger kFinishBtnTag                = 302;
static const NSInteger kInternetInfoBtnTag          = 100;
static const NSInteger kNetworkReportingBtnTag      = 101;

extern BOOL LatestAlertHaveChanged;
extern BOOL g_IsInternetAlertOnRed;

typedef NS_ENUM(NSInteger, Operation)
{
    OperationRefreshAll = 701,
    OperationInternetWarnCheck,
    OperationNextPage,
};

@interface VEInternetViewController () <EGORefreshTableHeaderDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView               *tableView;
@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UIButton                  *categoryBtn;
@property (weak, nonatomic) IBOutlet UIButton                  *filterBtn;
@property (weak, nonatomic) IBOutlet UIButton                  *organizeBtn;
@property (weak, nonatomic) IBOutlet UIView                    *informationCategorView;
@property (strong, nonatomic) IBOutlet UIView                  *settingTableHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView               *tipImageView;

@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;

@property (nonatomic, strong) FYNHttpRequestLoader      *httpRequestLoader;
@property (nonatomic, strong) FYNHttpRequestLoader      *httpRequestLoader2;
@property (nonatomic, strong) FYNHttpRequestLoader      *httpCategoryRequestLoader;

@property (nonatomic, assign) NSInteger                 currentSelCategorySlot;
@property (nonatomic, assign) BOOL                      reloading;
@property (nonatomic, assign) BOOL                      noMoreResults;
@property (nonatomic, assign) BOOL                      noMoreResults2;
@property (nonatomic, strong) UIActionSheet             *actionSheet;
@property (nonatomic, strong) UIView                    *cellSelectedBackgroundView;
@property (nonatomic, strong) UIView                    *settingView;
@property (nonatomic, strong) UITableView               *settingTableView;
@property (nonatomic, strong) UIView                    *settingBackView;
@property (nonatomic, strong) UIView                    *settingFooterView;
@property (nonatomic, strong) UITapGestureRecognizer    *tapGesturer;

@property (nonatomic, copy)   NSString                  *curCheckedInternetArea;
@property (nonatomic, copy)   NSString                  *curCheckedInternetDept;
@property (nonatomic, assign) NSInteger                 curCheckedInternetAreaId;
@property (nonatomic, assign) NSInteger                 curCheckedInternetDeptId;
@property (nonatomic, copy)   NSString                  *curCheckedInternetTypes;
@property (nonatomic, copy)   NSString                  *prevCheckedInternetTypes;
@property (nonatomic, assign) NSInteger                 countsofNew;
@property (nonatomic, assign) NSInteger                 internetPage;

@property (nonatomic, strong) NSMutableArray            *internetAreaListData;      // 所有地区
@property (nonatomic, strong) NSMutableArray            *internetTypeListData;      // 信息筛选
@property (nonatomic, strong) NSMutableArray            *internetOrganizeListData;  // 所有单位

@property (nonatomic, strong) NSMutableArray            *internetAlertData;         // 区县上报
@property (nonatomic, strong) NSMutableArray            *networkReportingData;      // 外部上报

@property (nonatomic, assign) BOOL                      isFinishLoad;
@property (nonatomic, assign) BOOL                      isFinishLoad2;
@property (nonatomic, assign) NSInteger                 curSelectedInformationIndex;

@property (nonatomic, strong) CAAnimation *showMenuAnimation;
@property (nonatomic, strong) CAAnimation *dismissMenuAnimation;
@property (nonatomic, strong) CAAnimation *dimingAnimation;
@property (nonatomic, strong) CAAnimation *lightingAnimation;

- (IBAction)showList:(id)sender;

- (IBAction)categoryBtnTapped:(UIButton *)sender;  //所有地区、信息筛选、所有单位
- (IBAction)informationCategoryBtnTapped:(UIButton *)sender; // 区县上报、外部上报
@property (weak, nonatomic) IBOutlet UIButton *insideBtn;

@property (weak, nonatomic) IBOutlet UIButton *outsideBtn;


// 重置
- (void)resetCheckedInternetTypes;
// 完成
- (void)finishCheckInternetTypes;

@end

@implementation VEInternetViewController

- (FYNHttpRequestLoader *)httpRequestLoader
{
    if (_httpRequestLoader == nil)
    {
        _httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestLoader;
}

- (FYNHttpRequestLoader *)httpRequestLoader2
{
    if (_httpRequestLoader2 == nil)
    {
        _httpRequestLoader2 = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestLoader2;
}

- (FYNHttpRequestLoader *)httpCategoryRequestLoader
{
    if (_httpCategoryRequestLoader == nil)
    {
        _httpCategoryRequestLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpCategoryRequestLoader;
}

- (NSMutableArray *)internetAlertData
{
    if (_internetAlertData == nil)
    {
        _internetAlertData = [[NSMutableArray alloc] init];
    }
    return _internetAlertData;
}

- (NSMutableArray *)networkReportingData
{
    if (_networkReportingData == nil)
    {
        _networkReportingData = [NSMutableArray array];
    }
    return _networkReportingData;
}

- (NSMutableArray *)internetAreaListData
{
    if (_internetAreaListData == nil)
    {
        _internetAreaListData = [[NSMutableArray alloc] init];
    }
    return _internetAreaListData;
}

- (NSMutableArray *)internetOrganizeListData
{
    if (_internetOrganizeListData == nil)
    {
        _internetOrganizeListData = [[NSMutableArray alloc] init];
    }
    return _internetOrganizeListData;
}

- (NSMutableArray *)internetTypeListData
{
    if (_internetTypeListData == nil)
    {
        _internetTypeListData = [[NSMutableArray alloc] init];
    }
    return _internetTypeListData;
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
        _settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          250,
                                                                          200)
                                                         style:UITableViewStylePlain];
        _settingTableView.delegate = self;
        _settingTableView.dataSource = self;
        
        // 去掉多余的分割线
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        _settingTableView.tableFooterView = view;
        _settingTableView.tag = kSettingTableTag;
    }
    return _settingTableView;
}

- (void)dealloc
{
    @autoreleasepool {
        self.refreshHeaderView.delegate = nil;
        self.refreshHeaderView = nil;
        
        if (_cellSelectedBackgroundView)
        {
            self.cellSelectedBackgroundView = nil;
        }
        
        if (_httpRequestLoader)
        {
            [self.httpRequestLoader cancelAsynRequest];
            self.httpRequestLoader = nil;
        }
        if (_httpCategoryRequestLoader)
        {
            [self.httpCategoryRequestLoader cancelAsynRequest];
            self.httpCategoryRequestLoader = nil;
        }
        if (_httpRequestLoader2)
        {
            [self.httpRequestLoader2 cancelAsynRequest];
            self.httpRequestLoader2 = nil;
        }
        
        if (_internetAlertData)
        {
            [self.internetAlertData removeAllObjects];
            self.internetAlertData = nil;
        }
        if (_networkReportingData)
        {
            [self.networkReportingData removeAllObjects];
            self.networkReportingData = nil;
        }
        if (_internetAreaListData)
        {
            [self.internetAreaListData removeAllObjects];
            self.internetAreaListData = nil;
        }
        if (_internetTypeListData)
        {
            [self.internetTypeListData removeAllObjects];
            self.internetTypeListData = nil;
        }
        if (_internetOrganizeListData)
        {
            [self.internetOrganizeListData removeAllObjects];
            self.internetOrganizeListData = nil;
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
        
        [center addObserver:self
                   selector:@selector(newDayHappenedNotification)
                       name:kNewDayHappenedNotification
                     object:nil];
        self.internetPage = 0;
        self.curCheckedInternetArea   = self.config[AllArea];
        self.curCheckedInternetAreaId = 0;
        self.curCheckedInternetDeptId = 0;
        self.curCheckedInternetDept   = self.config[AllDept];
        self.curCheckedInternetTypes  = @"";
        self.prevCheckedInternetTypes = self.curCheckedInternetTypes;
        self.curSelectedInformationIndex = kInternetInfoBtnTag;
        
        double delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadAllData];
        });
    }
    return self;
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _tipImageView.ve_x = Main_Screen_Width * 0.5 - 20;
    self.tableView.ve_height = Main_Screen_Height - 108;
    self.view.backgroundColor = RGBCOLOR(246, 246, 246);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserver];
    [self setUp];
    [self reloadImage];
    [self.tableView registerNib:[UINib nibWithNibName:KIdentifier_NetWorkReport bundle:nil] forCellReuseIdentifier:KIdentifier_NetWorkReport];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackground)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(refleshToggleButtonOnRed)
                   name:kNewFlagChangedNotification
                 object:nil];
}
-(void)reloadImage{
    [super reloadImage];
    [_insideBtn setTitle:self.config[InsideInternet] forState:UIControlStateNormal];
    [_outsideBtn setTitle:self.config[OutsideInternet] forState:UIControlStateNormal];
    _informationCategorView.backgroundColor = [UIColor colorWithHexString:self.config[MainColor]];
}
- (void)setUp
{
    LatestAlertHaveChanged = NO;
    self.promptView.layer.cornerRadius = 5.0;
    
    // TableView的下拉刷新
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc]
                              initWithFrame:CGRectMake(0.0f,
                                                       -self.tableView.bounds.size.height,
                                                       self.view.frame.size.width,
                                                       self.tableView.bounds.size.height)];
    self.refreshHeaderView.delegate = self;
    [self.tableView addSubview:self.refreshHeaderView];
    [self.refreshHeaderView refreshLastUpdatedDate];
    
    [self refleshToggleButtonOnRed];
    
    [self setupNav];
}
/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = self.config[InternetTitle];
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(showList:) image:Config(Tab_Icon_More) highImage:nil];
    self.navigationItem.rightBarButtonItem = more;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setPromptView:nil];
    [self setIndicator:nil];
    [self setCategoryBtn:nil];
    [self setFilterBtn:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"InternetList Appear");
    if (LatestAlertHaveChanged)
    {
        LatestAlertHaveChanged = NO;
        [self.tableView reloadData];
        [self refreshCountsOfNew];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"InternetList Disappear");
    [self cancelAllHttpRequester];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    for (Agent *agent in [self getCurrentListData])
    {
        @autoreleasepool {
            agent.articleContent = nil;
        }
    }
}

- (void)cancelAllHttpRequester
{
    if (_httpRequestLoader)
    {
        [self.httpRequestLoader cancelAsynRequest];
    }
    if (_httpRequestLoader2)
    {
        [self.httpRequestLoader2 cancelAsynRequest];
    }
    if (_httpCategoryRequestLoader)
    {
        [self.httpCategoryRequestLoader cancelAsynRequest];
    }
}

#pragma mark - MyMethods

// 检测最新预警

- (void)doWarningCheck
{
    // 如下拉刷新正在进行，则取消下拉效果
    if (self.reloading)
    {
        self.reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    
    NSString *startTime = @"0";
    NSArray *listDatas = [self getCurrentListData];
    if (listDatas.count > 0)
    {
//        startTime = ((InternetAgent *)[listDatas objectAtIndex:0]).timeWarn;
    }
    if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
    {
//        [self grabInternetWarnAtTimeInterval:startTime
//                               withOperation:OperationInternetWarnCheck];
        [self doRefreshInternetInformationPage];
    }
    else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag)
    {
        [self doRefreshNetworkReportingPage];
    }
}

// 加载【区县上报】和【外部上报】

- (void)loadAllData
{
    [self doRefreshInternetInformationPage];
    [self loadCategoryList];
    [self doRefreshNetworkReportingPage];
}

// 刷新全部数据

- (void)doRefreshAll
{
    if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
    {
        [self doRefreshInternetInformationPage];
        [self loadCategoryList];
    }
    else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag)
    {
        [self doRefreshNetworkReportingPage];
    }
}

// 刷新【区县上报】页面

- (void)doRefreshInternetInformationPage
{
    self.isFinishLoad = NO;
    [self grabInternetWarnAtTimeInterval:@"0" withOperation:OperationRefreshAll];
}

// 刷新【外部上报】页面

- (void)doRefreshNetworkReportingPage
{
    self.isFinishLoad2 = NO;
    [self grabNetworkReportingAtTimeInterval:@"0" withOperation:OperationRefreshAll];
}

// 下一页

- (void)nextPage
{
    NSArray *listDatas = [self getCurrentListData];
    InternetAgent *internetAgent = [listDatas lastObject];
    
    if (self.curSelectedInformationIndex == kInternetInfoBtnTag && self.noMoreResults == NO)
    {
        [self grabInternetWarnAtTimeInterval:internetAgent.timeWarn
                               withOperation:OperationNextPage];
    }
    else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag && self.noMoreResults2 == NO)
    {
        [self grabNetworkReportingAtTimeInterval:internetAgent.timeWarn
                                   withOperation:OperationNextPage];
    }
}

// 打开详情页

- (void)openDetailViewAtIndex:(NSInteger)index
{
//    VEIntertDetailViewController *detailViewController = [[VEIntertDetailViewController alloc]
//                                                          initWithNibName:@"VEIntertDetailViewController" bundle:nil];
//    detailViewController.listDatas = [self getCurrentListData];
//    detailViewController.selectedRow = index;
//    if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
//    {
//        detailViewController.comeFrom = VEIntertDetailViewFromIntert;
//        InternetAgent *agent =[self getCurrentListData][index];
//        detailViewController.uuid = agent.uuid;
//    }
//    else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag)
//    {
//        detailViewController.comeFrom = VEIntertDetailViewFromNetwork;
//    }
//    
//    LatestAlertHaveChanged = NO;
    
    VEIntertDetailController *detailVC = [[VEIntertDetailController alloc]init];
    detailVC.agent =  [self getCurrentListData][index];
    
    
    if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
    {
        detailVC.comeFrom = VEIntertDetailViewFromIntert;
        InternetAgent *agent =[self getCurrentListData][index];
        agent.isRead = YES;
        [VEUtility setWarnReadWithArticleId:agent.articleId andWarnType:agent.warnType];
        [self.tableView reloadData];
    }else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag){
        detailVC.comeFrom = VEIntertDetailViewFromNetwork;
    }
    [self.navigationController pushViewController:detailVC animated:YES];
}

// 标记当前Tab已读

- (void)markAllRead
{
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (Agent *agent in [self getCurrentListData])
        {
            agent.isRead = YES;
            [VEUtility setWarnReadWithArticleId:agent.articleId andWarnType:agent.warnType];
        }
        [self.tableView reloadData];
        [self refreshCountsOfNew];
    });
}

// 显示菜单选项

- (void)showCategoryMemuAnimated:(BOOL)animated
{
    // 设置View
    if (self.settingView == nil)
    {
        self.settingView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.settingView.backgroundColor = [UIColor clearColor];
    }
    
    // 设置的背景View
    if (self.settingBackView == nil)
    {
        self.settingBackView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    if (self.settingFooterView == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:KNibName_InternetAlert owner:self options:nil];
        UITableViewCell *cell = [cellNib objectAtIndex:1];

        UIButton *resetBtn = (UIButton *)[cell viewWithTag:kResetBtnTag];
        UIButton *finishBtn = (UIButton *)[cell viewWithTag:kFinishBtnTag];
        [resetBtn addTarget:self action:@selector(resetCheckedInternetTypes) forControlEvents:UIControlEventTouchUpInside];
        [finishBtn addTarget:self action:@selector(finishCheckInternetTypes) forControlEvents:UIControlEventTouchUpInside];
        
        self.settingFooterView = cell;
    }
    
    if (![self.settingView superview])
    {
        // 全屏模式
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.settingView];
        
        self.tapGesturer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        self.tapGesturer.delegate = self;
        [self.settingView addGestureRecognizer:self.tapGesturer];
        
        [self.settingView addSubview:self.settingBackView];
        [self.settingView addSubview:self.settingTableHeaderView];
        [self.settingView addSubview:self.settingTableView];
        
        CGFloat h = self.tableView.frame.origin.y + 61;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
        {
            h += 20;
        }
        self.settingTableHeaderView.top = h;
        self.settingBackView.top = h;
        self.settingTableView.top = (h + self.settingTableHeaderView.height);
    }
    
    if (animated)
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.2];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
        [self.settingBackView.layer addAnimation:self.dimingAnimation forKey:@"diming"];
        [self.settingTableView.layer addAnimation:self.showMenuAnimation forKey:@"showMenu"];
        [CATransaction commit];
    }
}

// 取消显示菜单选项

- (void)dismissCategoryMemuAnimated:(BOOL)animated
{
    [self.categoryBtn setSelected:NO];
    [self.filterBtn   setSelected:NO];
    [self.organizeBtn setSelected:NO];
    
    if (animated)
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.2];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [CATransaction setCompletionBlock:^{
            [self.settingTableView removeFromSuperview];
            [self.settingFooterView removeFromSuperview];
            [self.settingView removeFromSuperview];
            [self.settingView removeGestureRecognizer:self.tapGesturer];
            
            self.tapGesturer = nil;
            self.settingView = nil;
        }];
        
        [self.settingBackView.layer addAnimation:self.lightingAnimation forKey:@"lighting"];
        [self.settingTableView.layer addAnimation:self.dismissMenuAnimation forKey:@"dismissMenu"];
        [CATransaction commit];
    }
    else
    {
        [self.settingTableView removeFromSuperview];
        [self.settingFooterView removeFromSuperview];
        [self.settingView removeFromSuperview];
        [self.settingView removeGestureRecognizer:self.tapGesturer];
        
        self.tapGesturer = nil;
        self.settingView = nil;
    }
}

// 调整SettingTable的尺寸

- (void)resizeSettingTableFrame
{
    NSInteger counts = 0;
    switch (self.currentSelCategorySlot)
    {
        case 0:
            counts = self.internetAreaListData.count;
            break;
            
        case 1:
            counts = self.internetOrganizeListData.count;
            break;
            
        case 2:
            counts = self.internetTypeListData.count;
            break;
        
        default:
            counts = 0;
            break;
    }
    
    CGFloat h = 0;
    if (counts == 0)
    {
        h = 200;
    }
    else
    {
        if (self.currentSelCategorySlot == 0 ||
            self.currentSelCategorySlot == 1)
        {
            h = (counts + 1) * 40;
            h = MIN(h, ([UIScreen mainScreen].bounds.size.height - self.settingTableView.frame.origin.y));
        }
        else
        {
            h = counts * 40;
            h = MIN(h, ([UIScreen mainScreen].bounds.size.height - self.settingTableView.frame.origin.y - 40));
        }
    }

    self.settingTableView.frame = CGRectMake(self.settingTableView.frame.origin.x,
                                             self.settingTableView.frame.origin.y,
                                             self.settingTableView.frame.size.width,
                                             h);
    
    if (self.currentSelCategorySlot == 0 ||
        self.currentSelCategorySlot == 1)
    {
        self.settingFooterView.frame = CGRectZero;
    }
    else
    {
        self.settingFooterView.frame = CGRectMake(0,
                                                  (self.settingTableView.frame.origin.y + self.settingTableView.frame.size.height),
                                                  self.settingTableView.frame.size.width,
                                                  40);
    }
}

// 获取过滤选项的标题

- (NSDictionary *)getTitleInSettingTableAtIndex:(NSInteger)index
{
    NSDictionary *dict;
    
    if (self.currentSelCategorySlot == 0)
    {
        if (index == 0)
        {
            dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"id",self.config[AllArea],@"name", nil];
        }
        else
        {
            NSInteger slot = (index - 1);
            if (slot >= 0 && slot < self.internetAreaListData.count)
            {
                dict = [self.internetAreaListData objectAtIndex:slot];
            }
        }
    }
    else if (self.currentSelCategorySlot == 1)
    {
        if (index == 0)
        {
            dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"id",self.config[AllDept],@"name", nil];
        }
        else
        {
            NSInteger slot = (index - 1);
            if (slot >= 0 && slot < self.internetOrganizeListData.count)
            {
                dict = [self.internetOrganizeListData objectAtIndex:slot];
            }
        }
    }
    else if (self.currentSelCategorySlot == 2)
    {
        if (index >= 0 && index < self.internetTypeListData.count)
        {
            dict = [self.internetTypeListData objectAtIndex:index];
        }
    }
    
    return dict;
}

- (void)showPromptAction
{
    self.promptView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        self.promptView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

- (void)stopPromptAction
{
    self.promptView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.promptView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                     }
     ];
}

// 加载过滤选项数据

- (void)loadCategoryList
{
    NSString *stringUrl = [[NSString alloc] initWithFormat:@"%@/internetInformationFilterList", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];

    [self.httpCategoryRequestLoader cancelAsynRequest];
    [self.httpCategoryRequestLoader startAsynRequestWithURL:url withParams:@""];
    
    __weak typeof(self) weakSelf = self;
    [self.httpCategoryRequestLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf updateInternetAreaList:[jsonParser retrieveInternetAreaListValue]
                             andInternetTypeList:[jsonParser retrieveInternetTypeListValue]
                         andInternetOrganizeList:[jsonParser retrieveInternetOrganizeListValue]];
            }
        }
    }];
}

- (void)updateInternetAreaList:(NSArray *)areaList
           andInternetTypeList:(NSArray *)typeList
       andInternetOrganizeList:(NSArray *)organizeList
{
    if (areaList)
    {
        [self.internetAreaListData removeAllObjects];
        for (NSDictionary *item in areaList)
        {
            NSString *name = [item valueForKey:@"name"];
            if (name)
            {
                [self.internetAreaListData addObject:item];
            }
        }
    }
    
    if (typeList)
    {
        [self.internetTypeListData removeAllObjects];
        for (NSDictionary *item in typeList)
        {
            NSString *name = [item valueForKey:@"name"];
            if (name)
            {
                [self.internetTypeListData addObject:item];
            }
        }
    }
    
    if (organizeList)
    {
        [self.internetOrganizeListData removeAllObjects];
        for (NSDictionary *item in organizeList)
        {
//            NSString *name = [item valueForKey:@"name"];
            [self.internetOrganizeListData addObject:item];
        }
    }
    
    [self resizeSettingTableFrame];
    [self.settingTableView reloadData];
}

// 从服务器端获取【区县上报】信息

- (void)grabInternetWarnAtTimeInterval:(NSString *)timeInterval
                         withOperation:(Operation)operation
{
    NSString *stringUrl = [[NSString alloc] initWithFormat:@"%@/internetInformationListForGA", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSString *paramsStr = nil;
    if (operation == OperationRefreshAll)
    {
        paramsStr = @"page=0&limit=20";
    }
    else
    {
        paramsStr = [[NSString alloc] initWithFormat:@"page=%ld&limit=%ld",[self getCurrentListDataCounts]/kBatchSize, (long)kBatchSize];
    }
    
    paramsStr = [paramsStr stringByAppendingFormat:@"&areaType=%ld&infoTypes=%@&dept=%ld",
                    (long)self.curCheckedInternetAreaId,
                    [VEUtility encodeToPercentEscapeString:self.curCheckedInternetTypes],
                    (long)self.curCheckedInternetDeptId];
    
    [self httpLoader:self.httpRequestLoader
          requestURL:url
          withParams:paramsStr
        andOperation:operation
        fromCategory:kInternetInfoBtnTag];
}

// 从服务器端获取【外部上报】信息

- (void)grabNetworkReportingAtTimeInterval:(NSString *)timeInterval withOperation:(Operation)operation
{
    if (timeInterval == nil){
        timeInterval = @"0";
    }
    
    NSString *size = nil;
    if (operation == OperationInternetWarnCheck){
        size = [[NSString alloc] initWithFormat:@"%ld",(long)kMaxInternetWarnCheckSize];
    }else{
        size = [[NSString alloc] initWithFormat:@"%ld",(long)kBatchSize];
    }
    
    
    NSDictionary *dict = @{
                           @"listType":@"1",
                           @"start":timeInterval,
                           @"limit":size
                           };
    [InformationReviewTool loadNetworkReportWithParam:dict resultInfo:^(BOOL success, id JSON) {
        if (success) {
            NSArray *array = JSON;
            [self updateListData:array withOperation:operation fromCategory:kNetworkReportingBtnTag];
        }
    }];
}

- (void)httpLoader:(FYNHttpRequestLoader *)httpLoader
        requestURL:(NSURL *)url
        withParams:(NSString *)paramsStr
      andOperation:(Operation)operation
      fromCategory:(NSInteger)categoryIndex
{
    if (operation != OperationInternetWarnCheck)
    {
        [self showPromptAction];
    }
    
    [httpLoader cancelAsynRequest];
    [httpLoader startAsynRequestWithURL:url withParams:paramsStr];
    
    __weak typeof(self) weakSelf = self;
    [httpLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        [MBProgressHUD hideHUD];
        if (operation != OperationInternetWarnCheck || weakSelf.promptView.alpha > 0.2)
        {
            [weakSelf stopPromptAction];
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
                [weakSelf updateListData:[jsonParser retrieveListValue]
                           withOperation:operation
                            fromCategory:categoryIndex];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

- (void)updateListData:(NSArray *)listDatas
         withOperation:(Operation)operation
          fromCategory:(NSInteger)categoryIndex
{
    if (operation == OperationRefreshAll){
        if (categoryIndex == kInternetInfoBtnTag){
            [self.internetAlertData removeAllObjects];
        }else if (categoryIndex == kNetworkReportingBtnTag){
            [self.networkReportingData removeAllObjects];
        }
        
        if (self.curSelectedInformationIndex == categoryIndex){
            self.tableView.contentOffset = CGPointZero;
            [self.tableView reloadData];
        }
    }
    
    NSInteger size = listDatas.count;
    NSMutableArray *listAgents = nil;
    if (categoryIndex == kInternetInfoBtnTag){
        if (operation != OperationInternetWarnCheck){
            if (size == kBatchSize){
                self.noMoreResults = NO;
            }else{
                self.noMoreResults = YES;
            }
        }
        self.isFinishLoad = YES;
        listAgents = self.internetAlertData;
    }else if (categoryIndex == kNetworkReportingBtnTag){
        if (operation != OperationInternetWarnCheck){
            if (size == kBatchSize){
                self.noMoreResults2 = NO;
            }else{
                self.noMoreResults2 = YES;
            }
        }
        self.isFinishLoad2 = YES;
        listAgents = self.networkReportingData;
    }
    
    if (size > 0)
    {
        NSMutableArray *agents = [NSMutableArray array];
        for (NSDictionary *singleData in listDatas){
            if (categoryIndex == kInternetInfoBtnTag){  // 区县上报
                InternetAgent *internetAgent = [[InternetAgent alloc] initWithDictionary:singleData];
                internetAgent.isRead = [VEUtility isWarnReadWithArticleId:internetAgent.articleId
                                                              andWarnType:internetAgent.warnType];
                [agents addObject:internetAgent];
            }
        }
        
        if (categoryIndex == kNetworkReportingBtnTag){  // 外部上报
            agents = [NSMutableArray arrayWithArray:listDatas];
        }
        
        
        if (operation == OperationInternetWarnCheck){
            [listAgents insertObjects:agents
                            atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, agents.count)]];
        }else{
            [listAgents addObjectsFromArray:agents];
        }
        [agents removeAllObjects];
    }
    
    if (self.curSelectedInformationIndex == categoryIndex)
    {
        [self.tableView reloadData];
    }
    [self refreshCountsOfNew];
}

// 更新未读信息数，标记Red

- (void)refreshCountsOfNew
{
    self.countsofNew = 0;
    NSArray *listData = nil;
    for (int i = 0; i < 2; i++)
    {
        if (i == 0)
        {
            listData = self.internetAlertData;
        }
        else if (i == 1)
        {
            listData = self.networkReportingData;
        }
        for (Agent *agent in listData)
        {
            if (!agent.isRead)
            {
                ++self.countsofNew;
            }
        }
    }
    g_IsInternetAlertOnRed = (self.countsofNew > 0 ? YES : NO);
    [VEUtility postNewFlagChangedNotification];
}

- (NSMutableArray *)getCurrentListData
{
    NSMutableArray *listDatas = nil;
    if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
    {
        listDatas = self.internetAlertData;
    }
    else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag)
    {
        listDatas = self.networkReportingData;
    }
    return listDatas;
}

- (NSInteger)getCurrentListDataCounts
{
    NSInteger counts = 0;
    if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
    {
        counts = [self.internetAlertData count];
    }
    else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag)
    {
        counts = [self.networkReportingData count];
    }
    return counts;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self.tapGesturer])
    {
        CGPoint p = [gestureRecognizer locationInView:self.settingView];
        if (CGRectContainsPoint(self.settingTableView.frame, p) ||
            CGRectContainsPoint(self.settingTableHeaderView.frame, p) ||
            CGRectContainsPoint(self.settingFooterView.frame, p))
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - IBAction

- (IBAction)showList:(id)sender
{
    if (_actionSheet == nil)
    {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"刷新全部数据", @"全部标记已读",nil];
        self.actionSheet.tag = kActionSheetTag;
    }
    [self.actionSheet showInView:self.view];
    
}


- (IBAction)categoryBtnTapped:(UIButton *)sender
{
    self.currentSelCategorySlot = sender.tag;
    
    // 调整settingTable尺寸
    if (self.currentSelCategorySlot == 0 ||
        self.currentSelCategorySlot == 1)
    {
        if ([self.settingFooterView superview])
        {
            [self.settingFooterView removeFromSuperview];
        }
    }
    else
    {
        if (![self.settingFooterView superview])
        {
            [self.settingView addSubview:self.settingFooterView];
        }
    }
    [self resizeSettingTableFrame];
    
    [self.categoryBtn setSelected:NO];
    [self.filterBtn   setSelected:NO];
    [self.organizeBtn setSelected:NO];
    [sender           setSelected:YES];
    
    self.settingTableView.contentOffset = CGPointZero;
    [self.settingTableView reloadData];
}

- (IBAction)informationCategoryBtnTapped:(UIButton *)sender
{
    if (self.curSelectedInformationIndex != sender.tag)
    {
        [UIView animateWithDuration:0.1 animations:^{
            NSInteger diff = (sender.tag - self.curSelectedInformationIndex);
            self.informationCategorView.center = CGPointMake(self.informationCategorView.center.x + Main_Screen_Width * 0.5 * diff,
                                                           self.informationCategorView.center.y);
        }];
        
        self.curSelectedInformationIndex = sender.tag;
        self.tipImageView.hidden = ((self.curSelectedInformationIndex == kInternetInfoBtnTag) ? NO : YES);
        [self.tableView reloadData];
    }
    else if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
    {
        [self showCategoryMemuAnimated:YES];
        [self categoryBtnTapped:self.categoryBtn];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    CGPoint touchPoint = [tapGesture locationInView:self.settingView];
    if (!CGRectContainsPoint(self.settingTableView.frame, touchPoint) &&
        !CGRectContainsPoint(self.settingTableHeaderView.frame, touchPoint) &&
        !CGRectContainsPoint(self.settingFooterView.frame, touchPoint))
    {
        [self dismissCategoryMemuAnimated:YES];
        if (self.currentSelCategorySlot == 2)
        {
            [self doFilter];
        }
    }
}

- (void)resetCheckedInternetTypes
{
    self.curCheckedInternetTypes = @"";
    [self.settingTableView reloadData];
}

- (void)finishCheckInternetTypes
{
    [self dismissCategoryMemuAnimated:YES];
    [self doFilter];
}

- (void)doFilter
{
    if (![self.prevCheckedInternetTypes isEqualToString:self.curCheckedInternetTypes])
    {
        self.prevCheckedInternetTypes = self.curCheckedInternetTypes;
        [self doRefreshInternetInformationPage];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kSettingTableTag)
    {
        NSInteger counts = 0;
        if (self.currentSelCategorySlot == 0)
        {
            counts = self.internetAreaListData.count;
            return (counts > 0 ? (counts + 1) : 0);
        }
        else if (self.currentSelCategorySlot == 1)
        {
            counts = self.internetOrganizeListData.count;
            return (counts > 0 ? (counts + 1) : 0);
        }
        else if (self.currentSelCategorySlot == 2)
        {
            counts = self.internetTypeListData.count;
            return counts;
        }
        return 0;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == kSettingTableTag)
    {
        return 1;
    }
    else
    {
        NSInteger counts = [self getCurrentListDataCounts];
        BOOL isFinished = NO;
        BOOL noMore = YES;
        if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
        {
            isFinished = self.isFinishLoad;
            noMore = self.noMoreResults;
        }
        else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag)
        {
            isFinished = self.isFinishLoad2;
            noMore = self.noMoreResults2;
        }
        
        if (counts == 0)
        {
            if (isFinished)
            {
                return 1;  // 1 for show no result
            }
            return 0;
        }
        
        if (noMore)
        {
            counts += 1;
        }
        return counts;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kSettingTableTag)
    {
        // setting TableView
        static NSString *CellIdentifier = @"CellDefault";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *tipImgageView = (UIImageView *)[cell viewWithTag:130];
        if (tipImgageView == nil)
        {
            tipImgageView = [[UIImageView alloc] initWithFrame:CGRectMake((250 - 38), 11, 18, 18)];
            tipImgageView.tag = 130;
            [cell.contentView addSubview:tipImgageView];
        }
        
        UILabel *tipLabel = (UILabel *)[cell viewWithTag:131];
        if (tipLabel == nil)
        {
            tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 200, 30)];
            tipLabel.tag = 131;
            tipLabel.font = [UIFont boldSystemFontOfSize:17];
            tipLabel.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:tipLabel];
        }
        
        NSDictionary *title = [self getTitleInSettingTableAtIndex:indexPath.row];
        tipLabel.text = title[@"name"];
        
        if (self.currentSelCategorySlot == 0 ||
            self.currentSelCategorySlot == 1)
        {
            BOOL bSel = NO;
            if (self.currentSelCategorySlot == 0)
            {
                bSel = [self.curCheckedInternetArea isEqualToString:title[@"name"]];
            }
            else if (self.currentSelCategorySlot == 1)
            {
                bSel = [self.curCheckedInternetDept isEqualToString:title[@"name"]];
            }
            
            if (bSel)
            {
                tipImgageView.image = Image(Icon_Selected);
                tipLabel.textColor = unreadFontColor;
            }
            else
            {
                tipImgageView.image = nil;
                tipLabel.textColor = readFontColor;
            }
        }
        else
        {
            if ([self.curCheckedInternetTypes rangeOfString:[NSString stringWithFormat:@"%@",title[@"id"]]].location != NSNotFound)
            {
                tipImgageView.image = Image(Icon_Checkbox_Pressed);
                tipLabel.textColor = unreadFontColor;
            }
            else
            {
                tipImgageView.image = Image(Icon_Checkbox_Normal);
                tipLabel.textColor = readFontColor;
            }
        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = nil;
        
        NSInteger counts = [self getCurrentListDataCounts];
        NSArray *listDatas = [self getCurrentListData];
        // no results
        if (counts == 0)
        {
            cell = [VEUtility cellForShowNoResultTableView:tableView
                                               fillMainTip:@"暂无内容"
                                             fillDetailTip:nil
                                           backgroundColor:selectedBackgroundColor];
            return cell;
        }
        
        NSInteger section = indexPath.section;
        
        if (self.curSelectedInformationIndex == kInternetInfoBtnTag){
            if (self.noMoreResults == YES && section == listDatas.count ) {
                cell = [VEUtility cellForShowMoreTableView:tableView cellSelectedBackgroundView:nil];
                return cell;
            }
        }else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag){
            if (self.noMoreResults2==YES && section == listDatas.count ) {
                cell = [VEUtility cellForShowMoreTableView:tableView cellSelectedBackgroundView:nil];
                return cell;
            }
        }
        
        
        if ((section == [listDatas count] - 1) && ((section+1) % kBatchSize == 0) )
        {
            [self nextPage];
        }
        
        
        NSString *cellIdentifier = KIdentifier_InternetAlert;
        NSString *cellNibName = KNibName_InternetAlert;
        
        if (self.curSelectedInformationIndex == kNetworkReportingBtnTag)
        {
            NetworkReportingAgent *agent = [listDatas objectAtIndex:section];
            VENetWorkReportingTableViewCell *veCell = [VENetWorkReportingTableViewCell cellWithTableView:tableView];
            veCell.agent = agent;
            [veCell.areaLabel setText:agent.siteName];
            [veCell.stateLabel setText:agent.area];
            return veCell;
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:cellNibName owner:self options:nil];
            cell = [cellNib objectAtIndex:0];
            cell.selectedBackgroundView = self.cellSelectedBackgroundView;
        }
        
        UILabel *cellLableTitle  = (UILabel *)[cell viewWithTag:kCellTitleTag];      // 标题
        UILabel *cellLableInfo   = (UILabel *)[cell viewWithTag:kCellInfoTag];       // 类型
        UILabel *cellLableTime   = (UILabel *)[cell viewWithTag:kCellTimePostTag];   // 发文时间
        UILabel *cellLableAuthor = (UILabel *)[cell viewWithTag:kCellAuthorTag];     // 作者
        UIImageView *cellBKImage = (UIImageView *)[cell viewWithTag:kCellImgBKTag];
        
        BOOL isRead = NO;
        if (self.curSelectedInformationIndex == kInternetInfoBtnTag)
        {
            InternetAgent *internetAgent = [listDatas objectAtIndex:section];
            
            cellLableTitle.text = [NSString stringWithFormat:@"  %@",internetAgent.title];
            cellLableInfo.text  = internetAgent.internetType;
            cellLableTime.text  = internetAgent.timePost;
            
            NSString *authorPlusDept = [NSString  stringWithFormat:@"%@  %@", (internetAgent.author ? internetAgent.author : @""), (internetAgent.internetDept ? internetAgent.internetDept : @"")];
            authorPlusDept = [authorPlusDept stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            cellLableAuthor.text = authorPlusDept;
            
            isRead = internetAgent.isRead;
        }
        else if (self.curSelectedInformationIndex == kNetworkReportingBtnTag)
        {
            NetworkReportingAgent *networkAgent = [listDatas objectAtIndex:section];
            
            cellLableTitle.text  = networkAgent.title;
            cellLableInfo.text   = networkAgent.area;
            cellLableTime.text   = networkAgent.orgTime;
            cellLableAuthor.text = networkAgent.siteName;
            
            isRead = networkAgent.isRead;
        }
    
        // 已读、未读背景颜色
        NSString *bkImageName = nil;
        if (isRead)
        {
            cellLableTitle.textColor = readFontColor;
            bkImageName = kGrayBK;
        }
        else
        {
            cellLableTitle.textColor = unreadFontColor;
            bkImageName = kWhiteBK;
        }
        cellBKImage.image = [QCZipImageTool imageNamed:bkImageName];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kSettingTableTag)
    {
        return 40 ;
    }
    else
    {
        NSInteger counts = [self getCurrentListDataCounts];
        NSArray *listDatas = [self getCurrentListData];
        if (counts == 0)
        {
            return 200; // for show no result
        }
        
        if (indexPath.section == listDatas.count)
        {
            return 48;
        }

        return 58;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == kSettingTableTag)
    {
        if (self.currentSelCategorySlot == 0 ||
            self.currentSelCategorySlot == 1)
        {
            [self.internetAlertData removeAllObjects];
            NSDictionary *title = [self getTitleInSettingTableAtIndex:indexPath.row];
            if (self.currentSelCategorySlot == 0)
            {
                self.curCheckedInternetArea = title[@"name"];
                self.curCheckedInternetAreaId = [title[@"id"] integerValue];
            }
            else
            {
                self.curCheckedInternetDept = title[@"name"];
                self.curCheckedInternetDeptId = [title[@"id"] integerValue];
            }
           
            [self dismissCategoryMemuAnimated:YES];
            
            // 刷新页面
            [self doRefreshInternetInformationPage];
        }
        else
        {
            NSDictionary *title = [self getTitleInSettingTableAtIndex:indexPath.row];
            NSString *titleName = title[@"name"];
            NSString *infoId = title[@"id"];
            if (titleName.length > 0)
            {
                NSString *formateTitle = [NSString stringWithFormat:@"%@_", infoId];
                if ([self.curCheckedInternetTypes rangeOfString:[NSString stringWithFormat:@"%@",infoId]].location == NSNotFound)
                {
                    self.curCheckedInternetTypes = [self.curCheckedInternetTypes stringByAppendingString:formateTitle];
                }
                else
                {
                    self.curCheckedInternetTypes = [self.curCheckedInternetTypes stringByReplacingOccurrencesOfString:formateTitle withString:@""];
                }
            }
        }
        [self.settingTableView reloadData];
    }
    else
    {
        NSInteger counts = [self getCurrentListDataCounts];
        if (counts == 0)
        {
            return; // for no result
        }
        if (indexPath.section == counts)
        {
            return;
        }
        
        
        NSArray *listDatas = [self getCurrentListData];
        if (indexPath.section == listDatas.count)
        {
            [self nextPage];
        }
        else
        {
            [self openDetailViewAtIndex:indexPath.section];
        }
    }
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    // 更新最后下拉刷新时间
    if (view == self.refreshHeaderView)
    {
         self.reloading = YES;
        [self.refreshHeaderView refreshLastUpdatedDate];
        [self performSelector:@selector(doWarningCheck) withObject:nil afterDelay:1.0];
    } 
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    if (view == self.refreshHeaderView)
    {
        return  self.reloading;
    }
    else
    {
        return NO;
    }
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == kSettingTableTag)
    {
        return;
    }
    else
    {
        [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag == kSettingTableTag)
    {
        return;
    }
    else
    {
        [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
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
    }
}

#pragma mark - NSNotificationCenter

- (void)applicationWillEnterForeground
{
    double delayInSeconds = 3.5;
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
    
    if ([self.settingTableView superview])
    {
        [self dismissCategoryMemuAnimated:NO];
    }
}

- (void)refleshToggleButtonOnRed
{
    VENavViewController *nav = (VENavViewController *)self.navigationController;
    nav.iconType = [VEUtility isOnRed];
}

- (void)newDayHappenedNotification
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadAllData];
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
