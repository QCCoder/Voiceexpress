//
//  VEAlertNotificationViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-12-12.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEAlertNotificationViewController.h"
#import "VEMainRightDetailTableViewCell.h"
#import "VEFilterLevelTableViewCell.h"
#import "VEAlertNotificationTool.h"
#import "FYNHttpRequestLoader.h"
#import "PromptView.h"
static const NSInteger kStateIsLoading      = 160;
static const NSInteger kStateLoadSuccessed  = 161;

static const NSInteger kAutoPushSwitchTag = 300;

static const NSInteger kVETableViewCellLabelMainTag   = 10;
static const NSInteger kVETableCellLogImageTag        = 15;

extern BOOL isTopLeader;

@interface VEAlertNotificationViewController ()

@property (weak, nonatomic) IBOutlet UITableView               *tableView;

@property (strong, nonatomic) UISwitch *autoPushNotificationSwitcher;
@property (strong, nonatomic) UISwitch *warnLevelUrgentSwitcher;
@property (strong, nonatomic) UISwitch *warnLevelSeriousSwitcher;
@property (strong, nonatomic) UISwitch *warnLevelGeneralSwitcher;
@property (strong, nonatomic) UISwitch *disturbSwitcher;

@property (nonatomic, strong) FYNHttpRequestLoader *httpRequestLoader;
@property (nonatomic, assign) NSInteger currentLoadState;

@end

@implementation VEAlertNotificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNav];
    
    self.autoPushNotificationSwitcher = [[UISwitch alloc] init];
    [self.autoPushNotificationSwitcher setOn:NO];
    self.autoPushNotificationSwitcher.tag = kAutoPushSwitchTag;
    [self.autoPushNotificationSwitcher addTarget:self
                                          action:@selector(switcherValueChanged:)
                                forControlEvents:UIControlEventValueChanged];

    self.disturbSwitcher = [[UISwitch alloc] init];
    [self.disturbSwitcher setOn:NO];
    
    if (!isTopLeader)
    {
        self.warnLevelGeneralSwitcher = [[UISwitch alloc] init];
        self.warnLevelSeriousSwitcher = [[UISwitch alloc] init];
        self.warnLevelUrgentSwitcher  = [[UISwitch alloc] init];
        
        [self.warnLevelGeneralSwitcher setOn:NO];
        [self.warnLevelSeriousSwitcher setOn:NO];
        [self.warnLevelUrgentSwitcher  setOn:NO];
    }
    
    self.currentLoadState = kStateIsLoading;
    [self downloadUserConfiguration];
}
/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = @"通知选项";
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(saveUserConfig) image:Config(Tab_Icon_Ok) highImage:nil];
    self.navigationItem.rightBarButtonItem = more;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelAllHttpRequester];
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


- (void)downloadUserConfiguration
{
    [PromptView startShowPromptViewWithTip:@"正在同步配置，请稍等..." view:self.view];
    __weak typeof(self) weakSelf = self;
    [VEAlertNotificationTool findNotificationConfigSuccess:^(id JSON) {
        [PromptView hidePromptFromView:self.view];
        VEAlertNotification *alertNotify = JSON;
        if (alertNotify.result == 0) {
            [weakSelf.autoPushNotificationSwitcher setOn:alertNotify.isPush];
            [weakSelf.disturbSwitcher setOn:alertNotify.isNightNodisturb];
            if (!isTopLeader) {
                [weakSelf.warnLevelGeneralSwitcher setOn:alertNotify.isGenralAlert];
                [weakSelf.warnLevelSeriousSwitcher setOn:alertNotify.isSeriousAlert];
                [weakSelf.warnLevelUrgentSwitcher setOn:alertNotify.isUrgentAlert];
            }
            weakSelf.currentLoadState = kStateLoadSuccessed;
            [weakSelf.tableView reloadData];
        }else{
            [AlertTool showAlertToolWithCode:alertNotify.result];
        }
    } failure:^(NSError *error) {
        [PromptView hidePromptFromView:self.view];
        DLog(@"%@",[error localizedDescription]);
    }];
}

#pragma mark - IBAction

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveUserConfig
{
    if (self.currentLoadState == kStateIsLoading)
    {
        [self back];
        return;
    }
    
     NSString *veLevels = @"_";
    if (!isTopLeader)
    {
        if (self.warnLevelGeneralSwitcher.isOn)
        {
            veLevels = [veLevels stringByAppendingString:@"3_"];
        }
        if (self.warnLevelSeriousSwitcher.isOn)
        {
            veLevels = [veLevels stringByAppendingString:@"2_"];
        }
        if (self.warnLevelUrgentSwitcher.isOn)
        {
            veLevels = [veLevels stringByAppendingString:@"1_"];
        }
    }
    
    VEAlertNotificationModefy *param = [[VEAlertNotificationModefy alloc]init];
    param.isPush = self.autoPushNotificationSwitcher.isOn ? @"true" : @"false";
    param.isNightNodisturb = self.disturbSwitcher.isOn ? @"true" : @"false";
    param.veLevels = veLevels;
    
    [PromptView startShowPromptViewWithTip:@"正在保存配置，请稍等..." view:self.view];
    
    __weak typeof(self) weakSelf = self;
    
    
    [VEAlertNotificationTool updateNotificationWithParam:param ConfigSuccess:^(id JSON) {
        NSInteger result = [JSON[@"result"] integerValue];
        [PromptView hidePromptFromView:self.view];
        if (result == 0) {
            [weakSelf back];
        }else{
            [AlertTool showAlertToolWithCode:result];
        }
    } failure:^(NSError *error) {
        [PromptView hidePromptFromView:self.view];
        DLog(@"%@",[error localizedDescription]);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentLoadState == kStateIsLoading)
    {
        return 0;
    }
    
    if (self.autoPushNotificationSwitcher.isOn)
    {
        return (isTopLeader ? 2 : 3);
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return (isTopLeader ? 1 : 3);
    }
    else if (section == 2)
    {
        return 1;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *cellIdentifier = KIdentifier_MainRightDetail;
    NSString *nibName = kNibName_MainRightDetail;
    
    // 预警级别
    if (section == 1 && !isTopLeader)
    {
        cellIdentifier = KIdentifier_FilterLevel;
        nibName = kNibName_FilterLevel;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        cell = [cellNib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    UILabel *cellLableMain = (UILabel *)[cell viewWithTag:kVETableViewCellLabelMainTag];
    cellLableMain.text = nil;
    cellLableMain.textColor = unreadFontColor;
    UIView *itemView = (UIView *)[cell viewWithTag:32];

    if (section == 0)
    {
        if (row == 0)
        {
            cellLableMain.text = @"自动推送预警";
            [itemView addSubview:self.autoPushNotificationSwitcher];
            [self.autoPushNotificationSwitcher sizeToFit];
        }
    }
    else if (section == 1)
    {
        if (isTopLeader)
        {
            if (row == 0)
            {
                cellLableMain.text = @"夜间免打扰模式";
                
                cell.accessoryView = self.disturbSwitcher;
                [itemView addSubview:self.disturbSwitcher];
                [self.disturbSwitcher sizeToFit];
            }
        }
        else
        {
            UIImageView *cellLogImage = (UIImageView *)[cell viewWithTag:kVETableCellLogImageTag];
            UIView *itemView = (UIView *)[cell viewWithTag:32];
            cellLogImage.image = nil;
            
            NSString *title = nil;
            NSString *imageName = nil;
            UISwitch *switcher = nil;
            if (row == 0)
            {
                title     = self.config[Urgent];
                imageName = self.config[Icon_Circle_Red];
                switcher  = self.warnLevelUrgentSwitcher;
            }
            else if (row == 1)
            {
                title     = self.config[Import];
                imageName = self.config[Icon_Circle_Yellow];
                switcher  = self.warnLevelSeriousSwitcher;
            }
            else if (row == 2)
            {
                title     = self.config[Normal];
                imageName = self.config[Icon_Circle_Blue];
                switcher  = self.warnLevelGeneralSwitcher;
            }
            
            cellLableMain.text = title;
            cellLogImage.image = [QCZipImageTool imageNamed:imageName];
            
            [itemView addSubview:switcher];
            [switcher sizeToFit];
        }
    }
    else if (section == 2)
    {
        if (row == 0)
        {
            cellLableMain.text = @"夜间免打扰模式";
            
            [itemView addSubview:self.disturbSwitcher];
            [self.disturbSwitcher sizeToFit];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return (isTopLeader ? 0 : 40);
    }
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2 || (section == 1 && isTopLeader))
    {
        return 20;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lable = [[UILabel alloc] init];
    lable.backgroundColor = selectedBackgroundColor;
    if (section == 1 && !isTopLeader)
    {
        lable.text = @"  预警级别";
        lable.font = [UIFont boldSystemFontOfSize:15];
        lable.textColor = unreadFontColor;
    }

    return lable;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2 || (section == 1 && isTopLeader))
    {
        UILabel *lable = [[UILabel alloc] init];
        lable.text = @"开启后，自动屏蔽00:00~07:00间的任何预警";
        lable.textAlignment = NSTextAlignmentCenter;
        lable.font = [UIFont boldSystemFontOfSize:14];
        lable.backgroundColor = selectedBackgroundColor;
        lable.textColor = detailTitleColor;
        
        return lable;
    }
    return nil;
}

- (void)switcherValueChanged:(UISwitch *)switcher
{
    NSInteger tag = switcher.tag;
    if (kAutoPushSwitchTag == tag)
    {
        [self.tableView reloadData];
    }
}
 
@end
