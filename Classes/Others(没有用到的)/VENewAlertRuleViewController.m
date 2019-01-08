//
//  VENewAlertRuleViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-18.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VENewAlertRuleViewController.h"
#import "VENewAlertRuleDetailViewController.h"
#import "VESiteTypeViewController.h"

BOOL VENewAlertRuleViewIsAlertRuleChanged;

 // 标志是否添加或修改、删除了预警规则
extern BOOL VEAlertRulesViewIsAddOrChangeAlertRule;
extern BOOL VEAlertRulesViewIsRemoveRule;

static NSString * const kPromptMessage = @"在包含和不包含关键字、回复数、阅读转发数等四项中,至少需要填写一项。";

@interface VENewAlertRuleViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) NSArray *LabelTagNames;
@property (strong, nonatomic) NSArray *LabelTagNameskey;
@property (strong, nonatomic) NSArray *siteTypes;
//@property (strong, nonatomic) NSArray *listPrompts;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *toolBar;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *deleteRuleBtm;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *promptView;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *promptLabel;

@property (nonatomic, strong) FYNHttpRequestLoader *httpRequestLoader;
@property (nonatomic, strong) UIActionSheet *optionActionSheet;

- (IBAction)back;
- (IBAction)deleteAlertRule:(id)sender;
@end

@implementation VENewAlertRuleViewController

@synthesize newAlertRuleDic = _newAlertRuleDic;

- (FYNHttpRequestLoader *)httpRequestLoader
{
    if (_httpRequestLoader == nil)
    {
        _httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    }
    return _httpRequestLoader;
}

- (NSMutableDictionary *)newAlertRuleDic
{
    if (_newAlertRuleDic == nil)
    {
        _newAlertRuleDic = [[NSMutableDictionary alloc] init];
        [_newAlertRuleDic setValue:[NSNumber numberWithInteger:0] forKey:AlertRuleStyle];
        [_newAlertRuleDic setValue:@"0" forKey:AlertRuleReplyCount];
        [_newAlertRuleDic setValue:@"0" forKey:AlertRuleReadCount];
    }
    return _newAlertRuleDic;
}

- (void)setNewAlertRuleDic:(NSMutableDictionary *)aNewAlertRuleDic
{
    if (aNewAlertRuleDic != self.newAlertRuleDic)
    {
        [self.newAlertRuleDic setValue:[aNewAlertRuleDic valueForKey:AlertRuleStyle]        forKey:AlertRuleStyle];
        [self.newAlertRuleDic setValue:[aNewAlertRuleDic valueForKey:AlertRuleID]           forKey:AlertRuleID];
        [self.newAlertRuleDic setValue:[aNewAlertRuleDic valueForKey:AlertRuleReadCount]    forKey:AlertRuleReadCount];
        [self.newAlertRuleDic setValue:[aNewAlertRuleDic valueForKey:AlertRuleReplyCount]   forKey:AlertRuleReplyCount];
        [self.newAlertRuleDic setValue:[aNewAlertRuleDic valueForKey:AlertRuleName]         forKey:AlertRuleName];
        [self.newAlertRuleDic setValue:[aNewAlertRuleDic valueForKey:AlertRuleAndKeywords]  forKey:AlertRuleAndKeywords];
        [self.newAlertRuleDic setValue:[aNewAlertRuleDic valueForKey:AlertRuleNonKeywords]  forKey:AlertRuleNonKeywords];
    }
}

- (NSArray *)LabelTagNames
{
    if (_LabelTagNames == nil)
    {
        _LabelTagNames = [[NSArray alloc] initWithObjects:@"规则名称", @"包含关键字", @"不包含关键字", @"回复数", @"阅读转发数", @"站点类型", nil];
    }
    return _LabelTagNames;
}

- (NSArray *)LabelTagNameskey
{
    if (_LabelTagNameskey == nil)
    {
        _LabelTagNameskey = [[NSArray alloc] initWithObjects:AlertRuleName, AlertRuleAndKeywords, AlertRuleNonKeywords, AlertRuleReplyCount, AlertRuleReadCount, AlertRuleStyle, nil];
    }
    return _LabelTagNameskey;
}

- (NSArray *)siteTypes
{
    if (_siteTypes == nil) _siteTypes = [[NSArray alloc] initWithObjects:@"全部", @"论坛", @"博客", @"新闻", @"微博", @"纸质媒体",@"微信", nil];
    return _siteTypes;
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
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
    [VEUtility initBackgroudImageOfToolBar:self.toolBar];
    
    self.labelTitle.text = self.titleName;
    self.promptView.layer.cornerRadius = 5.0;
    //self.listPrompts = [[NSArray alloc] initWithObjects:@"全部", @"论坛", @"博客", @"新闻", @"微博", @"纸质媒体", nil];
    VENewAlertRuleViewIsAlertRuleChanged = NO;
    if (self.fromAction != VENewAlertRuleViewChangeAlertRuleAction)
    {
        self.deleteRuleBtm.enabled = NO;
        self.deleteRuleBtm.image = nil;
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setLabelTitle:nil];
    
    [self setDeleteRuleBtm:nil];
    [self setPromptView:nil];
    [self setIndicator:nil];
    [self setPromptLabel:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    [MobClick beginLogPageView:NewOrChangeAlertRuleView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cancelAllHttpRequester];
    
    [MobClick endLogPageView:NewOrChangeAlertRuleView];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.LabelTagNames count];
    }
    if (section == 1)
    {
        return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableCellRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellNewAlertRule";
    static NSString *CellIdentifierDefault = @"CellNewAlertRuleDefault";
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierDefault];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifierDefault];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (self.fromAction == VENewAlertRuleViewChangeAlertRuleAction && !VENewAlertRuleViewIsAlertRuleChanged)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btm-save-noclick.png"]];
        }
        else
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btm-save-normal.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btm-save-pressed.png"]];
        }
        
        return cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    NSInteger row = indexPath.row;
    if (row == 1 || row == 2)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImage_white]];
    cell.textLabel.text = [self.LabelTagNames objectAtIndex:row];
    
    NSString *key = [self.LabelTagNameskey objectAtIndex:row];
    if (row == 5)
    {
        NSInteger siteIndex = [[self.newAlertRuleDic valueForKey:key] integerValue];
        cell.detailTextLabel.text = [self.siteTypes objectAtIndex:siteIndex];
    }
    else
    {
        cell.detailTextLabel.text = [self.newAlertRuleDic valueForKey:key];
    }
    cell.textLabel.textColor = unread_titleColor;
    cell.detailTextLabel.textColor = newAlertRule_right_titleColor;
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        if ([tableView cellForRowAtIndexPath:indexPath].selectionStyle != UITableViewCellSelectionStyleNone)
        {
            // 添加或修改预警规则
            [self AddNewOrChangeAlertRule];
        }
    }
    else
    {
        if (indexPath.row == 5)
        {
            if (self.optionActionSheet == nil)
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:@"关闭"
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:@"全部", @"论坛", @"博客", @"新闻", @"微博", @"纸质媒体", nil];
                actionSheet.tag = 100;
                self.optionActionSheet = actionSheet;
            }
            [self.optionActionSheet  showInView:self.view];
        }
        else
        {
            VENewAlertRuleDetailViewController *detailViewController = [[VENewAlertRuleDetailViewController alloc] initWithNibName:@"VENewAlertRuleDetailViewController" bundle:nil];
            detailViewController.titleName = [self.LabelTagNames objectAtIndex:indexPath.row];
            detailViewController.alertRuleDic = self.newAlertRuleDic;
            detailViewController.fromRow = indexPath.row;
            
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TableCellHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *headView = [[UIImageView alloc] init];
    [headView setBackgroundColor:BackgroundColor];
    return headView;
}


#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100 && buttonIndex != [self.siteTypes count])
    {
        if ([[self.newAlertRuleDic valueForKey:AlertRuleStyle] integerValue] != buttonIndex)
        {
            VENewAlertRuleViewIsAlertRuleChanged = YES;
        }
        [self.newAlertRuleDic setValue:[NSNumber numberWithInteger:buttonIndex]
                             forKey:AlertRuleStyle];
        [self.tableView reloadData];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == VENewAlertRuleViewDeleteAlertRuleAlertViewTag &&
        [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"是"])
    {
        [MobClick event:DeleteAlertRuleEvent label:@"ClickTrash"];
        
        NSString *wrid = [[self.newAlertRuleDic valueForKey:@"wrid"] stringValue];
        [self deleteAlertRuleWithID:wrid];
    }
}

- (void)deleteAlertRuleWithID:(NSString *)ruleID
{
    [self startShowPromptWith:@"正在删除,请稍等..."];
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@/WarningRuleDelete", COMMONURL];
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSString *paramStr = [NSString stringWithFormat:@"wrid=%@", ruleID];
    
    [self.httpRequestLoader cancelAsynRequest];
    [self.httpRequestLoader startAsynRequestWithURL:url withParams:paramStr];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.httpRequestLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error) {
        [weakSelf stopShowPrompt];
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                VEAlertRulesViewIsRemoveRule = YES;
                [weakSelf.navigationController popViewControllerAnimated:YES];
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

#pragma mark - My Methods

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 删除当前预警规则
- (IBAction)deleteAlertRule:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"是否删除此条预警规则"
                                                       delegate:self
                                              cancelButtonTitle:@"否"
                                              otherButtonTitles:@"是", nil];
    alertView.tag = VENewAlertRuleViewDeleteAlertRuleAlertViewTag;
    [alertView show];
}

// 添加或更新预警规则
- (void)AddNewOrChangeAlertRule
{
    NSString *andKeywords = [self.newAlertRuleDic valueForKey:AlertRuleAndKeywords];
    NSString *nonKeywords = [self.newAlertRuleDic valueForKey:AlertRuleNonKeywords];
    NSString *replyCount  = [self.newAlertRuleDic valueForKey:AlertRuleReplyCount];
    NSString *readCount   = [self.newAlertRuleDic valueForKey:AlertRuleReadCount];
    NSString *alertName   = [self.newAlertRuleDic valueForKey:AlertRuleName];
    
    if ([alertName length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"规则名称为必填项"
                                                      delegate:nil
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (([andKeywords length] == 0)     &&
        ([nonKeywords length] == 0)     &&
        ([readCount integerValue] == 0) &&
        ([replyCount integerValue] == 0))
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:kPromptMessage
                                                      delegate:nil
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (andKeywords == nil) andKeywords = @"";
    if (nonKeywords == nil) nonKeywords = @"";
        
    andKeywords = [VEUtility encodeToPercentEscapeString:andKeywords];
    nonKeywords = [VEUtility encodeToPercentEscapeString:nonKeywords];
    alertName   = [VEUtility encodeToPercentEscapeString:alertName];
    
    NSString *siteType = [[self.newAlertRuleDic valueForKey:AlertRuleStyle] stringValue];
    
    NSString *stringUrl = nil;
    NSString *paramStr = @"";
    NSString *message = nil;
    if (self.fromAction == VENewAlertRuleViewChangeAlertRuleAction)
    {
        stringUrl = [NSString stringWithFormat:@"%@/WarningRuleUpdate", COMMONURL];
        
        NSString *wrid = [[self.newAlertRuleDic valueForKey:AlertRuleID] stringValue];
        paramStr = [NSString stringWithFormat:@"wrid=%@&", wrid];
        message = @"正在更新,请稍等...";
    }
    else
    {
        stringUrl = [NSString stringWithFormat:@"%@/WarningRuleSetting", COMMONURL];
        message = @"正在添加,请稍等...";
    }
    paramStr = [paramStr stringByAppendingFormat:@"style=%@&readCount=%@&replyCount=%@&andKeywords=%@&nonKeywords=%@&desc=%@", siteType, readCount, replyCount, andKeywords, nonKeywords, alertName];

    NSURL *url = [NSURL URLWithString:stringUrl];
    
    [self startShowPromptWith:message];
    
    [self.httpRequestLoader cancelAsynRequest];
    [self.httpRequestLoader startAsynRequestWithURL:url withParams:paramStr];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.httpRequestLoader setCompletionHandler:^(NSDictionary *resultData, NSString *error) {
        [weakSelf stopShowPrompt];
        if (error != nil)
        {
            [VEUtility showServerErrorMeassage:error];
        }
        if (resultData != nil)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultData];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                NSString *message = nil;
                if (weakSelf.fromAction == VENewAlertRuleViewChangeAlertRuleAction)
                {
                    message = @"修改预警规则成功";
                }
                else
                {
                    message = @"添加预警规则成功";
                }
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"好的"
                                                     otherButtonTitles:nil];
                [alert show];
                VEAlertRulesViewIsAddOrChangeAlertRule = YES;
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [jsonParser reportErrorMessage];
            }
        }
    }];
}

- (void)startShowPromptWith:(NSString *)promptTitle
{
    self.promptView.alpha = 0.9;
    [self.indicator startAnimating];
    self.promptLabel.text = promptTitle;
}

- (void)stopShowPrompt
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
}
@end
