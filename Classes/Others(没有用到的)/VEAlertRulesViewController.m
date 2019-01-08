//
//  VEAlertRulesViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEAlertRulesViewController.h"
#import "VENewAlertRuleViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kLoadingAlertRules  = @"正在加载，请稍等...";
static NSString * const kDeletingAlertRules = @"正在删除，请稍等...";

BOOL VEAlertRulesViewIsAddOrChangeAlertRule = NO;
BOOL VEAlertRulesViewIsRemoveRule = NO;

@interface VEAlertRulesViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) FYNHttpRequestLoader *httpRequestLoader;

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *toolBar;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *promptView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *showLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (strong, nonatomic) NSMutableArray *alertRules;
@property (assign, nonatomic) NSInteger shouldDeleteInexRow;
@property (assign, nonatomic) NSInteger currentSelectedRow;

- (IBAction)back;
- (IBAction)newAlertRule;
@end

@implementation VEAlertRulesViewController

#pragma mark - getter

- (FYNHttpRequestLoader *)httpRequestLoader
{
    if (_httpRequestLoader == nil)
    {
        _httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestLoader;
}

- (NSMutableArray *)alertRules
{
    if (_alertRules == nil)
    {
        _alertRules = [[NSMutableArray alloc] init];
    }
    return _alertRules;
}

#pragma mark

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
    [VEUtility initBackgroudImageOfToolBar:self.toolBar];
    
    self.promptView.layer.cornerRadius = 5.0;
    VEAlertRulesViewIsAddOrChangeAlertRule = NO;
    VEAlertRulesViewIsRemoveRule = NO;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self refreshAll];
    }];
}

- (void)viewDidUnload
{
    self.alertRules = nil;
    [self setTableView:nil];
    [self setPromptView:nil];
    [self setIndicator:nil];
    [self setShowLabel:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (VEAlertRulesViewIsAddOrChangeAlertRule)
    {
        // 添加了或修改了预警规则，则从服务器重新获取预警规则数据
        VEAlertRulesViewIsAddOrChangeAlertRule = NO;
        [self refreshAll];
    }
    
    if (VEAlertRulesViewIsRemoveRule)
    {
        // 删除了预警规则，则相应的删除保存在本地的预警规则数据
        VEAlertRulesViewIsRemoveRule = NO;
        [self.alertRules removeObjectAtIndex:self.currentSelectedRow];
        [self.tableView reloadData];     
    }
    [MobClick beginLogPageView:AlertRulesView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cancelAllHttpRequester];
    
    [MobClick endLogPageView:AlertRulesView];
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
}

#pragma mark - My methods

- (void)startShowAlertWithString:(NSString *)showString
{
    self.promptView.alpha = 0.9;
    self.showLabel.text = showString;
    [self.indicator startAnimating];
}

- (void)stopShowAction
{
    [UIView animateWithDuration:1.5 animations:^{
        self.promptView.alpha = 0;
    }];
    [self performSelector:@selector(stopAnimating) withObject:nil afterDelay:3.0];
}

- (void)stopAnimating
{
    [self.indicator stopAnimating];
}

- (void)refreshAll
{
    [self startShowAlertWithString:kLoadingAlertRules];
    NSString *stringUrl = [NSString stringWithFormat:@"%@/WarningRules", COMMONURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSString *paramStr = [NSString stringWithFormat:@"page=1&limit=%d", IntMaxValue];
    
    [self.httpRequestLoader cancelAsynRequest];
    [self.httpRequestLoader startAsynRequestWithURL:url withParams:paramStr];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.httpRequestLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error) {
        [weakSelf stopShowAction];
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf updateAlertRulesData:[jsonParser retrieveListValue]];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

// 刷新数据
- (void)updateAlertRulesData:(NSArray *)listDatas
{
    [self.alertRules removeAllObjects];
    
    if (listDatas != nil)
    {
        for (NSDictionary *item in listDatas)
        {
            NSMutableDictionary *newItem = [[NSMutableDictionary alloc] init];
            [newItem setValue:[item valueForKey:AlertRuleStyle] forKey:AlertRuleStyle];
            [newItem setValue:[item valueForKey:AlertRuleID] forKey:AlertRuleID];
            [newItem setValue:[[item valueForKey:AlertRuleReadCount] stringValue] forKey:AlertRuleReadCount];
            [newItem setValue:[[item valueForKey:AlertRuleReplyCount] stringValue] forKey:AlertRuleReplyCount];
            [newItem setValue:[item valueForKey:AlertRuleName] forKey:AlertRuleName];
            
            NSString *word = [item valueForKey:AlertRuleWord];
            NSArray *wordSeparated = [word componentsSeparatedByString:@" "];  // 按空格符号分割。
            NSString *andKeywords = @"";
            NSString *nonKeywords = @"";
            BOOL firstAnd = YES;
            BOOL firstNon = YES;
            for (NSString *singleWord in wordSeparated)
            {
                if ([singleWord length] == 0) continue;
                if ([singleWord hasPrefix:@"-"])
                {
                    if (firstNon)
                    {
                        firstNon = NO;
                    }
                    else
                    {
                        nonKeywords = [nonKeywords stringByAppendingString:@";"];
                    }
                    nonKeywords = [nonKeywords stringByAppendingString:singleWord];
                }
                else
                {
                    if (firstAnd)
                    {
                        firstAnd = NO;
                    }
                    else
                    {
                        andKeywords = [andKeywords stringByAppendingString:@";"];
                    }
                    andKeywords = [andKeywords stringByAppendingString:singleWord];
                }
            }
            nonKeywords = [nonKeywords stringByReplacingOccurrencesOfString:@"-" withString:@""];

            [newItem setValue:andKeywords forKey:AlertRuleAndKeywords];
            [newItem setValue:nonKeywords forKey:AlertRuleNonKeywords];
            [newItem setValue:[item valueForKey:AlertRuleWord] forKey:AlertRuleWord];
            
            [self.alertRules addObject:newItem];
        } 
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.alertRules count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableCellRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellAlertRules";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImage_white]];
    
    NSInteger row = indexPath.row;
    NSDictionary *alertRule = [self.alertRules objectAtIndex:row];
    NSString *word = [alertRule valueForKey:AlertRuleWord];
    cell.textLabel.text = [alertRule valueForKey:AlertRuleName];
    cell.detailTextLabel.text = word;
    cell.textLabel.textColor = unread_titleColor;
    cell.detailTextLabel.textColor = detailTitle_titleColor;
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"是否删除此条预警规则"
                                                           delegate:self
                                                  cancelButtonTitle:@"否"
                                                  otherButtonTitles:@"是", nil];
        alertView.tag = VENewAlertRuleViewDeleteAlertRuleAlertViewTag;
        [alertView show];
        self.shouldDeleteInexRow = indexPath.row;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == VENewAlertRuleViewDeleteAlertRuleAlertViewTag &&
        [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"是"])
    {
        [MobClick event:DeleteAlertRuleEvent label:@"SwipeGesture"];
        
        NSDictionary *item = [self.alertRules objectAtIndex:self.shouldDeleteInexRow];
        NSString *wrid = [[item valueForKey:@"wrid"] stringValue];
        
        [self deleteAlertRuleWithID:wrid];
    }
}

- (void)deleteAlertRuleWithID:(NSString *)ruleID
{
    [self startShowAlertWithString:kDeletingAlertRules];
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@/WarningRuleDelete", COMMONURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSString *paramStr = [NSString stringWithFormat:@"wrid=%@", ruleID];

    [self.httpRequestLoader cancelAsynRequest];
    [self.httpRequestLoader startAsynRequestWithURL:url withParams:paramStr];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.httpRequestLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error) {
        [weakSelf stopShowAction];
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                [weakSelf.alertRules removeObjectAtIndex:weakSelf.shouldDeleteInexRow];
                [weakSelf.tableView reloadData];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                               message:@"预警规则删除成功"
                                                              delegate:nil
                                                     cancelButtonTitle:@"好的"
                                                     otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentSelectedRow = indexPath.row;
    
    VENewAlertRuleViewController *detailViewController = [[VENewAlertRuleViewController alloc]
        initWithNibName:@"VENewAlertRuleViewController" bundle:nil];
    detailViewController.newAlertRuleDic = [self.alertRules objectAtIndex:self.currentSelectedRow];
    detailViewController.titleName = [detailViewController.newAlertRuleDic valueForKey:AlertRuleName];
    detailViewController.fromAction = VENewAlertRuleViewChangeAlertRuleAction;
    VEAlertRulesViewIsAddOrChangeAlertRule = NO;
    VEAlertRulesViewIsRemoveRule = NO;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - IBAction

// 新建预警规则
- (IBAction)newAlertRule
{
    VENewAlertRuleViewController *newAlertRuleViewController = [[VENewAlertRuleViewController alloc] initWithNibName:@"VENewAlertRuleViewController" bundle:nil];
    newAlertRuleViewController.titleName = @"新建预警规则";
    VEAlertRulesViewIsAddOrChangeAlertRule = NO;
    [self.navigationController pushViewController:newAlertRuleViewController animated:YES];
    
    [MobClick event:NewAlertRuleEvent];
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
