//
//  VEQuickReplyViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-12-29.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEQuickReplyViewController.h"
#import "VEAddQuickReplyViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "VETableViewCell.h"

@interface VEQuickReplyViewController ()<EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) FYNHttpRequestLoader *httpDeleteLoader;
@property (nonatomic, strong) FYNHttpRequestLoader *httpLoader;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, strong) NSMutableArray *quickReplyData;
@property (nonatomic, assign) NSInteger maxSize;

@property (weak, nonatomic) IBOutlet UILabel *promptTip;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIView *promptView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)back:(id)sender;
- (IBAction)addQuickReply:(id)sender;

@end

@implementation VEQuickReplyViewController

- (void)dealloc
{
    [self.tableView setEditing:NO];  // 重要的，否则在水平滑动删除按钮出现后，点击返回造成闪退
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
    
    [self setUp];
    [self loadQuickReplys];
    [self setupNav];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    DLog(@"QuickReply Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelAllHttpRequester];
    DLog(@"QuickReply Disappear");
}

-(void)setupNav{
    [self setTitle:@"快捷回复"];
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithTarget:self action:@selector(addQuickReply:) image:self.config[Icon_Add] highImage:nil];
}


- (void)setUp
{
    self.maxSize = 5;
    self.quickReplyData = [NSMutableArray array];
 
    self.promptView.layer.cornerRadius = 5.0;
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc]
                              initWithFrame:CGRectMake(0.0f,
                                                       -self.tableView.bounds.size.height,
                                                       self.view.frame.size.width,
                                                       self.tableView.bounds.size.height)];
    self.refreshHeaderView.delegate = self;
    [self.tableView addSubview:_refreshHeaderView];
    
    // 去掉多余的分割线
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)cancelAllHttpRequester
{
    [self.httpLoader cancelAsynRequest];
    [self.httpDeleteLoader cancelAsynRequest];
}

#pragma -mark My Methods

- (void)showPromptAction:(NSString *)tip
{
    self.promptView.alpha = 0;
    self.promptTip.text = tip;
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

- (void)loadQuickReplys
{
    [self stopEgoRefresh];
    
    if (self.httpLoader == nil)
    {
        self.httpLoader = [[FYNHttpRequestLoader alloc] init];
    }
    
    NSString *stringUrl = [[NSString alloc] initWithFormat:@"%@/QuickReplyList", kBaseURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    [self showPromptAction:@"正在加载数据，请稍等..."];
    [self.httpLoader cancelAsynRequest];
    [self.httpLoader startAsynRequestWithURL:url];
    
    __weak typeof(self) weakSelf = self;
    [self.httpLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error) {
        
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
                [weakSelf updateQuickReplyList:[jsonParser retrieveQuickReplyListValue]];
                weakSelf.maxSize = [jsonParser retrieveMaxSizeValue];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

- (void)updateQuickReplyList:(NSArray *)listData
{
    if (self.quickReplyData == nil)
    {
        self.quickReplyData = [NSMutableArray array];
    }
    [self.quickReplyData removeAllObjects];
    
    for (NSDictionary *item in listData)
    {
        QuickReplyAgent *replyAgent = [[QuickReplyAgent alloc] initWithDictionary:item];
        [self.quickReplyData addObject:replyAgent];
    }
    
    [self.tableView reloadData];
}

- (void)deleteQuickReplyAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.quickReplyData.count)
    {
        if (self.httpDeleteLoader == nil)
        {
            self.httpDeleteLoader = [[FYNHttpRequestLoader alloc] init];
        }
        
        NSString *stringUrl = [[NSString alloc] initWithFormat:@"%@/QuickReplyDelete", kBaseURL];
        NSURL *url = [NSURL URLWithString:stringUrl];
        
        QuickReplyAgent *replyAgent = [self.quickReplyData objectAtIndex:index];
        NSString *params = [NSString stringWithFormat:@"quickReplyId=%@", replyAgent.quickReplyId];
        
        [self showPromptAction:@"正在删除回复，请稍等..."];
        
        [self.httpDeleteLoader cancelAsynRequest];
        [self.httpDeleteLoader startAsynRequestWithURL:url withParams:params];
        
        __weak typeof(self) weakSelf = self;
        [self.httpDeleteLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error) {
            
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
                    [weakSelf updateDeleteQuickReplyAtIndex:index];
                }
                else
                {
                    [jsonParser reportErrorMessage];
                }
            }
        }];
    }
}

- (void)updateDeleteQuickReplyAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.quickReplyData.count)
    {
        [self.quickReplyData removeObjectAtIndex:index];
        [self.tableView reloadData];
    }
}

#pragma -mark IBAction

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addQuickReply:(id)sender
{
    if (self.quickReplyData.count < self.maxSize)
    {
        VEAddQuickReplyViewController *addQuickReplyVC = [[VEAddQuickReplyViewController alloc] initWithNibName:@"VEAddQuickReplyViewController" bundle:nil];
        addQuickReplyVC.quickReplyData = self.quickReplyData;
        
        [self.navigationController pushViewController:addQuickReplyVC animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[NSString stringWithFormat:@"至多添加%ld条快捷回复", (long)self.maxSize]
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma -mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger counts = self.quickReplyData.count;
    return (counts == 0 ? 1 : counts);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"QuickReplyCellIdentifier";
    
    UITableViewCell *cell = nil;
    
    if (self.quickReplyData.count == 0)
    {
        cell = [VEUtility cellForShowNoResultTableView:tableView
                                           fillMainTip:@"暂无快捷回复"
                                         fillDetailTip:@"点击右上角新增"
                                       backgroundColor:selectedBackgroundColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = plainTextColor;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    QuickReplyAgent *replyAgent = [self.quickReplyData objectAtIndex:indexPath.row];
    cell.textLabel.text = replyAgent.quickReplyMessage;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.quickReplyData.count == 0)
    {
        return 200; // for show no result
    }
    return 50;
}

#pragma -mark UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.quickReplyData.count > 0)
    {
        QuickReplyAgent *replyAgent = [self.quickReplyData objectAtIndex:indexPath.row];
        [self.selQuickReplys addObject:replyAgent.quickReplyMessage];
        
        [self back:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.quickReplyData.count > 0)
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.quickReplyData.count > 0)
    {
        [self deleteQuickReplyAtIndex:indexPath.row];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.reloading = YES;
    [self.refreshHeaderView refreshLastUpdatedDate];
    [self performSelector:@selector(loadQuickReplys) withObject:nil afterDelay:0.7];
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

@end
