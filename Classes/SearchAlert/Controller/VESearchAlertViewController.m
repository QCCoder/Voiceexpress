//
//  VESearchAlertViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-12.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VESearchAlertViewController.h"
#import "VESearchAlertTableViewCell.h"
#import "RESideMenu.h"
#import "SearchAlertTool.h"
#import "LocalAreaCell.h"

static const NSInteger kCellBackImageViewTag        = 106;
static const NSInteger kOptionActionSheetTag        = 390;
static const NSInteger kMaxHistoryRecords           = 11;



@interface VESearchAlertViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView   *tableView;
@property (weak, nonatomic) IBOutlet UITextField   *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton      *searchScopeBtn;
@property (weak, nonatomic) IBOutlet UIButton      *searchBtn;
@property (nonatomic, strong) UIView               *cellSelectedBackgroundView;

@property (strong, nonatomic) NSMutableArray       *localAreaTagsList;
@property (strong, nonatomic) NSMutableArray       *searchHistory;
@property (nonatomic, strong) UIActionSheet        *optionActionSheet;
@property (assign, nonatomic) NSInteger            currentScopeIndex;


@end

@implementation VESearchAlertViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"SearchAlert Disappear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"SearchAlert Disappear");
}

- (NSMutableArray *)searchHistory
{
    if (_searchHistory == nil)
    {
        _searchHistory = [[NSMutableArray alloc] init];
    }
    return _searchHistory;
}

- (void)dealloc
{
    @autoreleasepool {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
    
    [self.view setBackgroundColor:[UIColor colorWithHexString:self.config[MainColor]]];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (self.searchType == SearchTypeNormal)
    {
        [self refleshToggleButtonOnRed];
        [center addObserver:self
                   selector:@selector(refleshToggleButtonOnRed)
                       name:kNewFlagChangedNotification
                     object:nil];
    }
    
    [center addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
}

- (void)setUp
{
    switch (self.searchType){
        case SearchTypeNormal:
            self.title = self.config[WarnSearch];
            break;
        case SearchTypeLatestAlert:
            self.title = self.config[WarnAlertSearch];
            break;
        case SearchTypeRecommendRead:
            self.title = self.config[ReadSearch];
            break;
        default:
            self.title = self.config[WarnSearch];
            break;
    }
    
    // 历史搜索数据
    [self.searchHistory addObjectsFromArray:[SearchAlertTool getKeyWord:self.searchType]];
    
    // 区域分类数据
    if (self.searchType == SearchTypeLatestAlert)
    {
        self.tableView.header = [RefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadLocalAreaTags)];
        [self.tableView.header beginRefreshing];
    }
}

-(UIActionSheet *)optionActionSheet
{
    if (!_optionActionSheet) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:
                                      (self.currentScopeIndex == 0 ? @"全部  √" : @"全部"),
                                      (self.currentScopeIndex == 1 ? @"按标题  √" : @"按标题"),
                                      (self.currentScopeIndex == 2 ? @"按内容  √" : @"按内容"), nil];
        actionSheet.tag = kOptionActionSheetTag;
        self.optionActionSheet = actionSheet;
    }
    return _optionActionSheet;
}


#pragma mark - MyMethods

/**
 *  进入搜索结果界面
 */
- (void)searchAction:(NSString *)keyword withScope:(NSInteger)scopeIndex
{
    VESearchResultsViewController *searchResultsViewController = [[VESearchResultsViewController alloc] initWithNibName:@"VESearchResultsViewController" bundle:nil];
    
    searchResultsViewController.searchWord = keyword;
    searchResultsViewController.selectedScopeIndex = scopeIndex;
    searchResultsViewController.searchType = self.searchType;
    
    [self.navigationController pushViewController:searchResultsViewController animated:YES];
}

/**
 *  清除历史记录
 */
- (void)clearAllHistoryRecord
{
    [SearchAlertTool saveKeyWord:self.searchHistory key:self.searchType];
    [self.tableView reloadData];
}

/**
 *  获取地域标签
 */
- (void)loadLocalAreaTags
{
    if (self.localAreaTagsList == nil){
        self.localAreaTagsList = [NSMutableArray array];
    }
    
    [SearchAlertTool loadTagListResultInto:^(BOOL success, id JSON) {
        if (success) {
            NSArray *list = JSON;
            [self.localAreaTagsList removeAllObjects];
            [self.localAreaTagsList addObjectsFromArray:list];
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
        }
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.searchType == SearchTypeLatestAlert ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchType == SearchTypeLatestAlert && section == 0){
        return ceil((float)self.localAreaTagsList.count / 3);
    }else{
        NSInteger counts = self.searchHistory.count;
        return (counts > 0 ? (counts + 1) : counts);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchType == SearchTypeLatestAlert && indexPath.section == 0){
        //本地标签列表
        return [self tableView:tableView localTagCellForRowAtIndexPath:indexPath];
    }else{
        VESearchAlertTableViewCell *searchCell = [VESearchAlertTableViewCell cellWithTableView:tableView];
        NSInteger row = indexPath.row;
        if (row < self.searchHistory.count){
            searchCell.title = self.searchHistory[row];
        }else{
            searchCell.title = kClearAllName;
        }
        return searchCell;
    }
}

/**
 *  区域分类
 */
- (UITableViewCell *)tableView:(UITableView *)tableView localTagCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocalAreaCell *cell = [LocalAreaCell cellWithTableView:tableView];
    NSInteger row = (indexPath.row * 3);
    NSInteger index = -1;
    for (int i = 0; i < 3; ++i){
        UIButton *btnTag = (UIButton *)[cell viewWithTag:(kCellAreaTagOne + i)];
        btnTag.hidden = YES;
        btnTag.tag = -1;
        index = (row + i);
        if (index >= 0 && index < self.localAreaTagsList.count){
            LocalAreaAgent *areaAgent = [self.localAreaTagsList objectAtIndex:index];
            [btnTag setTitle:areaAgent.tagName forState:UIControlStateNormal];
            btnTag.hidden = NO;
            btnTag.tag = index;
            [btnTag addTarget:self action:@selector(areaTagBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchType == SearchTypeLatestAlert && indexPath.section == 0){
        return 42;
    }else{
        return 35;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.searchType == SearchTypeLatestAlert && indexPath.section == 0)
    {
        // do nothing
    }
    else
    {
        NSInteger row = indexPath.row;
        if (row == self.searchHistory.count)
        {
            [self clearAllHistoryRecord];
        }
        else
        {
            [self searchAction:[self.searchHistory objectAtIndex:row]
                     withScope:self.currentScopeIndex];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searchType == SearchTypeLatestAlert && section == 0){
        return 22;
    }else{
        return 32;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lable = [[UILabel alloc] init];
    lable.font = [UIFont boldSystemFontOfSize:14];
    lable.textColor = readFontColor;
    lable.backgroundColor = selectedBackgroundColor;
    
    if (self.searchType == SearchTypeLatestAlert && section == 0)
    {
        lable.text = self.config[SearchTypeArea];
    }
    else
    {
        lable.text = self.config[SearchTypeHistory];
    }
    
    return lable;
}

#pragma mark 时间监听
- (void)toggleBtnTapped
{
    [self.sideMenuViewController presentLeftMenuViewController];
    [self.searchTextField resignFirstResponder];
}

- (void)areaTagBtnTapped:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    if (tag >= 0 && tag < self.localAreaTagsList.count)
    {
        LocalAreaAgent *areaAgent = [self.localAreaTagsList objectAtIndex:tag];
        [self searchAction:areaAgent.tagID withScope:3];
    }
}

- (IBAction)searchBtnTapped:(UIButton *)sender
{
    [self.searchTextField resignFirstResponder];
    
    NSString *searchWord = self.searchTextField.text;
    if (searchWord.length == 0){
        return;
    }
    
    // 保存历史搜索记录
    [self.searchHistory removeObject:searchWord];
    [self.searchHistory insertObject:searchWord atIndex:0];
    
    if ([self.searchHistory count] == kMaxHistoryRecords){
        [self.searchHistory removeLastObject];
    }
    
    [SearchAlertTool saveKeyWord:self.searchHistory key:self.searchType];
    
    [self.tableView reloadData];
    
    [self searchAction:searchWord withScope:self.currentScopeIndex];
}

- (IBAction)searchScopeBtnTapped:(id)sender;
{
    [self.optionActionSheet showInView:self.view];
}

- (void)veResignFirstResponer
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kOptionActionSheetTag &&
        ![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"取消"])
    {
        self.currentScopeIndex = buttonIndex;
    }
}

#pragma mark - Notification

- (void)refleshToggleButtonOnRed
{
    VENavViewController *nav = (VENavViewController *)self.navigationController;
    nav.iconType = [VEUtility isOnRed];
}

- (void)applicationDidEnterBackgroundNotification
{
    if (self.optionActionSheet){
        if (self.optionActionSheet.numberOfButtons){
            [self.optionActionSheet dismissWithClickedButtonIndex:(self.optionActionSheet.numberOfButtons - 1)
                                                         animated:NO];
        }
    }
}

@end
