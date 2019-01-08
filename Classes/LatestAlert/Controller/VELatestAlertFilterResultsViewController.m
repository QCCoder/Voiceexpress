//
//  VELatestAlertFilterResultsViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-11-20.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VELatestAlertFilterResultsViewController.h"
#import "VEWarnAlertTableViewCell.h"
#import "VEAlertDetailViewController.h"
#import "VEAppDelegate.h"

extern BOOL LatestAlertHaveChanged;

typedef NS_ENUM(NSInteger, Operation)
{
    OperationRefreshAll = 901,
    OperationNextPage,
};

@interface VELatestAlertFilterResultsViewController ()

@property (weak, nonatomic) IBOutlet UITableView               *tableView;
@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;

@property (nonatomic, strong) FYNHttpRequestLoader  *httpRequestLoader;
@property (nonatomic, strong) NSMutableArray        *alertfilterResults;
@property (nonatomic, assign) BOOL                  noMoreResults;
@property (nonatomic, assign) BOOL                      isFinishLoad;

- (IBAction)back:(id)sender;
- (IBAction)refleshAll;

@end

@implementation VELatestAlertFilterResultsViewController

- (FYNHttpRequestLoader *)httpRequestLoader
{
    if (_httpRequestLoader == nil)
    {
        _httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestLoader;
}

- (NSMutableArray *)alertfilterResults
{
    if (_alertfilterResults == nil)
    {
        _alertfilterResults = [[NSMutableArray alloc] init];
    }
    return _alertfilterResults;
}

- (void)dealloc
{
    @autoreleasepool {
        LatestAlertHaveChanged = NO;
        if (_httpRequestLoader)
        {
            [self.httpRequestLoader cancelAsynRequest];
            self.httpRequestLoader = nil;
        }
        if (_alertfilterResults)
        {
            [self.alertfilterResults removeAllObjects];
            self.alertfilterResults = nil;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNav];
    LatestAlertHaveChanged = NO;
    self.promptView.layer.cornerRadius = 5.0;

   
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self refleshAll];
    }];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setPromptView:nil];
    [self setIndicator:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    for (WarnAgent *warnAgent in self.alertfilterResults)
    {
        @autoreleasepool {
            warnAgent.articleContent = nil;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"VELatestAlertFilterResultsViewController Appear");
    if (LatestAlertHaveChanged)
    {
        LatestAlertHaveChanged = NO;
        [self.tableView reloadData];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"LatestAlertFilterResultsViewController Disappear");
    [self cancelAllHttpRequester];
}

- (void)cancelAllHttpRequester
{
    if (_httpRequestLoader)
    {
        [self.httpRequestLoader cancelAsynRequest];
    }
}

/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = [NSString stringWithFormat:@"%@0%@",self.config[FitterResults_Left],self.config[FitterResults_Right]];
    UIBarButtonItem *send =[UIBarButtonItem itemWithTarget:self action:@selector(refleshAll) image:self.config[Tab_Icon_Refresh] highImage:nil];
    self.navigationItem.rightBarButtonItem = send;
    
}


#pragma mark - IBAction

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)refleshAll
{
    self.isFinishLoad = NO;
    [self grabFilterAlertsBeforeTimeInterval:@"0" withOperation:OperationRefreshAll];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger counts = self.alertfilterResults.count;
    if (counts == 0)
    {
        if (self.isFinishLoad)
        {
            return 1;  // 1 for show no result
        }
        return 0;
    }
    if (!self.noMoreResults)
    {
        counts += 1;
    }
    return counts;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // no results
    if (self.alertfilterResults.count == 0)
    {
        return [VEUtility cellForShowNoResultTableView:tableView
                                           fillMainTip:@"暂无内容"
                                         fillDetailTip:nil
                                       backgroundColor:selectedBackgroundColor];
    }
    
    NSInteger section = indexPath.section;
    BOOL noMoreResults = self.noMoreResults;
    if (noMoreResults == NO && section == (self.alertfilterResults.count - 1) ) {
        [self nextPage];
    }
    
    

    VEWarnAlertTableViewCell *warnAlertCell = [VEWarnAlertTableViewCell cellWithTableView:tableView];
    warnAlertCell.warnAgent = self.alertfilterResults[section];
    return warnAlertCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.alertfilterResults.count == 0)
    {
        return 200; // for show no result
    }
    
    if (indexPath.section == self.alertfilterResults.count)
    {
        return 48;
    }
    return 58;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.alertfilterResults.count == 0)
    {
        return; // for no result
    }
    
//    if (indexPath.section == [self.alertfilterResults count])
//    {
//        [self nextPage];
//    }
//    else
//    {
        [self openDetailViewAtIndex:indexPath.section];
//    }
}

#pragma mark - MyMethods

// 打开详情页

- (void)openDetailViewAtIndex:(NSInteger)index
{
    VEAlertDetailViewController *detailViewController = [[VEAlertDetailViewController alloc]
                                                         initWithNibName:@"VEAlertDetailViewController" bundle:nil];
    detailViewController.agent = self.alertfilterResults[index];
    LatestAlertHaveChanged = NO;
    [self.navigationController pushViewController:detailViewController animated:YES];
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

- (void)nextPage
{
    WarnAgent *warnAgent = [self.alertfilterResults lastObject];
    if (warnAgent.tmWarn)
    {
        [self grabFilterAlertsBeforeTimeInterval:warnAgent.tmWarn withOperation:OperationNextPage];
    }
    else
    {
        [self.tableView reloadData];
    }
}

- (void)grabFilterAlertsBeforeTimeInterval:(NSString *)timeInterval withOperation:(Operation)operation
{
    if (timeInterval == nil)
    {
        timeInterval = @"0";
    }
    
    NSString *stringUrl = [[NSString alloc] initWithFormat:@"%@/warningFilterList", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSString *paramsStr = [NSString stringWithFormat:@"before=%@&warnFilterCatagory=1_2&warnLevel=%@&limit=%ld",
                           timeInterval, self.filterWarnLevel, (long)kBatchSize];
    
    [self showPromptAction];
    
    [self.httpRequestLoader cancelAsynRequest];
    [self.httpRequestLoader startAsynRequestWithURL:url withParams:paramsStr];
    
    __weak typeof(self) weakSelf = self;
    [self.httpRequestLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error){
        
        [weakSelf stopPromptAction];
        
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf updateLatestAlertFilterData:[jsonParser retrieveListValue]
                                        withOperation:operation];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

- (void)updateLatestAlertFilterData:(NSArray *)listDatas withOperation:(Operation)operation
{
    @autoreleasepool {
        
        NSInteger size = listDatas.count;
        if (size == kBatchSize)
        {
            self.noMoreResults = NO;
        }
        else
        {
            self.noMoreResults = YES;
        }
        
        if (size > 0)
        {
            NSMutableArray *allWarnAgents = [NSMutableArray array];
            for (NSDictionary *singleData in listDatas)
            {
                WarnAgent *warnAgent = [[WarnAgent alloc] initWithDictionary:singleData];
                warnAgent.isRead = [VEUtility isWarnReadWithArticleId:warnAgent.articleId
                                                          andWarnType:warnAgent.warnType];
                
                [allWarnAgents addObject:warnAgent];
            }
            
            if (operation == OperationRefreshAll)
            {
                [self.alertfilterResults removeAllObjects];
                self.tableView.contentOffset = CGPointZero;
            }
            [self.alertfilterResults addObjectsFromArray:allWarnAgents];
            [allWarnAgents removeAllObjects];
        }
    }
    
    self.isFinishLoad = YES;
    [self.tableView reloadData];
    self.title = [NSString stringWithFormat:@"%@%ld%@",self.config[FitterResults_Left] ,(unsigned long)self.alertfilterResults.count,self.config[FitterResults_Right]];
}

@end


