//
//  VEMoreSettingViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-22.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEMoreSettingViewController.h"
#import "VEChangePassWordViewController.h"
#import "VEAboutUsViewController.h"
#import "VEAppDelegate.h"
#import "VEHelpMeViewController.h"
#import "VEUploadLogViewController.h"
#import "VEAlertNotificationViewController.h"
#import "VEDeviceLockViewController.h"
#import "VEMainRightDetailTableViewCell.h"

static const NSInteger kVETableViewCellLabelMainTag   = 10;
static const NSInteger kVETableViewCellLabelDetailTag = 11;
static const NSInteger kAutoLoginSwitchTag            = 14;
static const NSInteger KShouldReceivePicSwitchTag     = 16;

static const NSInteger kOptionActionSheetTag        = 110;
static const NSInteger kHasVersionAlertTag          = 120;

@interface VEMoreSettingViewController ()

@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UILabel                   *labelTip;
@property (weak, nonatomic) IBOutlet UITableView               *tableView;
@property (weak, nonatomic) IBOutlet UIButton                  *toggleBtn;

@property (strong, nonatomic) UISwitch              *autoLoginSwitcher;
@property (strong, nonatomic) UISwitch              *shouldReceivePictureSwitcher;
@property (strong, nonatomic) NSArray               *sectionTitles;
@property (strong, nonatomic) NSArray               *rowsInSection;
@property (nonatomic, strong) UIActionSheet         *optionActionSheet;

@end

@implementation VEMoreSettingViewController

// switcher: 2G/3G下是否自动接收图片

- (UISwitch *)shouldReceivePictureSwitcher
{
    if (_shouldReceivePictureSwitcher == nil)
    {
        _shouldReceivePictureSwitcher = [[UISwitch alloc] init];
        _shouldReceivePictureSwitcher.tag = KShouldReceivePicSwitchTag;
        [_shouldReceivePictureSwitcher addTarget:self action:@selector(switcherValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _shouldReceivePictureSwitcher;
}

// switcher: 是否程序启动后自动登录

- (UISwitch *)autoLoginSwitcher
{
    if (_autoLoginSwitcher == nil)
    {
        _autoLoginSwitcher = [[UISwitch alloc] init];
        _autoLoginSwitcher.tag = kAutoLoginSwitchTag;
        [_autoLoginSwitcher addTarget:self action:@selector(switcherValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _autoLoginSwitcher;
}

// section标题

- (NSArray *)sectionTitles
{
    if (_sectionTitles == nil)
    {
        _sectionTitles = [NSArray arrayWithObjects:self.config[User_Option],  self.config[Data_Option], self.config[System_Option], @"", nil];
    }
    return  _sectionTitles;
}

// section中的row

- (NSArray *)rowsInSection
{
    if (_rowsInSection == nil)
    {
        _rowsInSection = [NSArray arrayWithObjects:@"3", @"2", @"5", @"1", nil];
    }
    return _rowsInSection;
}

- (void)dealloc
{
    @autoreleasepool {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.config[Setting_Title];
    self.promptView.layer.cornerRadius = 5.0;
    [self refleshToggleButtonOnRed];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(refleshToggleButtonOnRed)
                   name:kNewFlagChangedNotification
                 object:nil];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setAutoLoginSwitcher:nil];
    [self setShouldReceivePictureSwitcher:nil];
    [self setSectionTitles:nil];
    [self setRowsInSection:nil];
    [self setPromptView:nil];
    [self setIndicator:nil];
    [self setLabelTip:nil];
    [self setToggleBtn:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.rowsInSection objectAtIndex:section] integerValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierDefault = @"CellIdentifierDefault";
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    UITableViewCell *cell = nil;
    if (section == 3)
    {
        // 退出当前帐号
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierDefault];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifierDefault];
            cell.backgroundColor = selectedBackgroundColor;
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_MainRightDetail];
        if (cell == nil)
        {
            NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:kNibName_MainRightDetail owner:self options:nil];
            cell = [cellNib objectAtIndex:0];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    UILabel *cellLableMain   = (UILabel *)[cell viewWithTag:kVETableViewCellLabelMainTag];
    UILabel *cellLableDetail = (UILabel *)[cell viewWithTag:kVETableViewCellLabelDetailTag];
    UIView *itemView = (UIView *)[cell viewWithTag:32];
    for (UIView *view in itemView.subviews) {
        [view removeFromSuperview];
    }
    cellLableMain.text = nil;
    cellLableDetail.text = nil;
    cellLableMain.textColor = unreadFontColor;
    cellLableDetail.textColor = readFontColor;

    if (section == 0)     
    {
        // 用户选项
        if (row == 0)
        {
            cellLableMain.text = self.config[User_Name];//账号
            cellLableDetail.text = [VEUtility currentUserName];
        }
        else if (row == 1)
        {
            [itemView addSubview:self.autoLoginSwitcher];
            [self.autoLoginSwitcher sizeToFit];
            [self.autoLoginSwitcher setOn:[VEUtility shouldAutoLoginToServer]];
            cellLableMain.text = self.config[Auto_Login];//自动登录
        }
        else if (row == 2)
        {
            cellLableMain.text = self.config[Modefy_Password];//修改密码
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"ico-alertLevelArrow.png"]];
            imageView.ve_size = CGSizeMake(15, 15);
            imageView.ve_x = itemView.ve_width - 22;
            imageView.ve_centerY = itemView.ve_height * 0.5;
            [itemView addSubview:imageView];

        }
    }
    else if (section == 1)  
    {
         // 数据选项
        if (row == 0)
        {
            cellLableMain.text = self.config[Notify_Option];//通知选项
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"ico-alertLevelArrow.png"]];
            imageView.ve_size = CGSizeMake(15, 15);
            imageView.ve_x = itemView.ve_width - 22;
            imageView.ve_centerY = itemView.ve_height * 0.5;
            [itemView addSubview:imageView];

        }
        else if (row == 1)
        {
            [itemView addSubview: self.shouldReceivePictureSwitcher];
            [self.shouldReceivePictureSwitcher sizeToFit];
            [self.shouldReceivePictureSwitcher setOn:![VEUtility shouldReceivePictureOnCellNetwork]];
            
            cellLableMain.text = self.config[Receive_Image];
        }
    }
    else if (section == 2)  
    {
        // 系统选项
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (row == 0)
        {
            cellLableMain.text = self.config[Device_Lock];
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSString *imgName = nil;
            if ([VEUtility isDeviceLockActivated])
            {
                 imgName = self.config[Icon_Lock];
            }
            else
            {
                imgName = self.config[Icon_Unlock];
            }
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:imgName]];
            imageView.ve_x = itemView.ve_width - imageView.ve_width - 5;
            [itemView addSubview:imageView];
        }
        else if (row == 1)
        {
            cellLableMain.text = self.config[Version_Check];
            cellLableDetail.text = [NSString stringWithFormat:@"v %@", [VEUtility curAppVersion]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (row == 2)
        {
            cellLableMain.text = self.config[Upload_Log];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"ico-alertLevelArrow.png"]];
            imageView.ve_size = CGSizeMake(15, 15);
            imageView.ve_x = itemView.ve_width - 22;
            imageView.ve_centerY = itemView.ve_height * 0.5;
            [itemView addSubview:imageView];

        }
        else if (row == 3)
        {
            cellLableMain.text = self.config[Help_Us];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"ico-alertLevelArrow.png"]];
            imageView.ve_size = CGSizeMake(15, 15);
            imageView.ve_x = itemView.ve_width - 22;
            imageView.ve_centerY = itemView.ve_height * 0.5;
            [itemView addSubview:imageView];

        }
        else if (row == 4)
        {
            cellLableMain.text = self.config[About_Us];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"ico-alertLevelArrow.png"]];
            imageView.ve_size = CGSizeMake(15, 15);
            imageView.ve_x = itemView.ve_width - 22;
            imageView.ve_centerY = itemView.ve_height * 0.5;
            [itemView addSubview:imageView];

        }
    }
    else if (section == 3)  
    {
        // 退出
        if (row == 0)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(9, 0, Main_Screen_Width - 20, 44)];
            button.layer.cornerRadius = 5.0;
            button.layer.masksToBounds = YES;
            [button setTitle:@"退出" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(doSignOffAction) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIColor createImageWithColor:RGBCOLOR(168, 41, 44)] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[UIColor createImageWithColor:RGBCOLOR(227, 79, 79)] forState:UIControlStateNormal];
            [cell addSubview:button];
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0)
    {
        if (row == 2)
        {
            // 密码修改
            [self doChangePassWordAction];
        }
    }
    else if (section == 1) 
    {
        if (row == 0)
        {
            // 通知选项
            [self doAlertNotification]; 
        }
    }
    else if (section == 2)
    {
        if (row == 0)
        {
            // 设备锁
            [self doConfigureDeviceLockAction];
        }
        else if (row == 1)
        {
            // 新版本检测
            [self doCheckNewVersionAction];
        }
        else if (row == 2)
        {
            // 上传日志
            [self doUploadLogAction];
        }
        else if (row == 3)
        {
            // 帮助
            [self doHelpMeAction];
        }
        else if (row == 4)
        {
            // 关于我们
            [self doAboutUsAction];
        }
    }
    else if (section == 3) 
    {
        if (row == 0)
        {
             // 退出当前帐号
            [self doSignOffAction];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3)
    {
        return 20;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lable = [[UILabel alloc] init];
    lable.text = [NSString stringWithFormat:@"  %@", [self.sectionTitles objectAtIndex:section] ];
    lable.font = [UIFont boldSystemFontOfSize:15];
    lable.backgroundColor =  selectedBackgroundColor;
    lable.textColor = unreadFontColor;
    
    return lable;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
 
#pragma mark Action Methods

- (void)doAlertNotification
{
    VEAlertNotificationViewController *alertNotificationViewController = [[VEAlertNotificationViewController alloc] initWithNibName:@"VEAlertNotificationViewController" bundle:nil];
    [self.navigationController pushViewController:alertNotificationViewController animated:YES];
}

- (void)doChangePassWordAction
{
    VEChangePassWordViewController *changePWViewController = [[VEChangePassWordViewController alloc] initWithNibName:@"VEChangePassWordViewController" bundle:nil];
    [self.navigationController pushViewController:changePWViewController animated:YES];
}

- (void)doUploadLogAction
{
    VEUploadLogViewController *logViewController = [[VEUploadLogViewController alloc] initWithNibName:@"VEUploadLogViewController" bundle:nil];
    [self.navigationController pushViewController:logViewController animated:YES];
}

- (void)doAboutUsAction
{
    VEAboutUsViewController *aboutUsViewController = [[VEAboutUsViewController alloc] initWithNibName:@"VEAboutUsViewController" bundle:nil];
    [self.navigationController pushViewController:aboutUsViewController animated:YES];
}

- (void)doHelpMeAction
{
    VEHelpMeViewController *helpMeViewController = [[VEHelpMeViewController alloc] initWithNibName:@"VEHelpMeViewController" bundle:nil];
    [self.navigationController pushViewController:helpMeViewController animated:YES];
}

- (void)doConfigureDeviceLockAction
{
    VEDeviceLockViewController *deviceLockViewController = [[VEDeviceLockViewController alloc] initWithNibName:@"VEDeviceLockViewController" bundle:nil];
    [self.navigationController pushViewController:deviceLockViewController animated:YES];
}

- (void)startShowPromptViewWithTip:(NSString *)tip
{
    self.labelTip.text = tip;
    self.promptView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        self.promptView.alpha = 0.9;
        [self.indicator startAnimating];
    }];
}

- (void)stopShowPromptView
{
    self.promptView.alpha = 0.9;
    [UIView animateWithDuration:2.0
                     animations:^{
                         self.promptView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator stopAnimating];
                         //self.labelTip.text = nil;
                     }
     ];
}

- (void)doCheckNewVersionAction
{
    [self startShowPromptViewWithTip:@"正在检查更新,请稍等..."];
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        
        NSDictionary *resultDic = [self checkNewVersion];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSInteger res = [[resultDic valueForKey:kHasNewVersion] integerValue];
            if (res == 10)
            {
                BOOL bMandatoryUpdate = [[resultDic valueForKey:kMandatoryUpdate] boolValue];
                NSString *updateDiscrip = nil;
                NSString *serverDiscrip = [resultDic valueForKey:kUpdateDiscription];
                if (serverDiscrip.length > 0)
                {
                    updateDiscrip = serverDiscrip;
                }
                else
                {
                    updateDiscrip = @"有最新版本了,请您下载最新版本。\n";
                }
                
                UIAlertView *alert = nil;
                if (bMandatoryUpdate)
                {
                    // 需要强制性更新
                    alert = [[UIAlertView alloc] initWithTitle:@"更新提示"
                                                       message:updateDiscrip
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"立刻更新", nil];
                }
                else
                {
                    // 非强制性更新
                    alert = [[UIAlertView alloc] initWithTitle:@"更新提示"
                                                       message:updateDiscrip
                                                      delegate:self
                                             cancelButtonTitle:@"请勿下载"
                                             otherButtonTitles:@"立刻更新", nil];
                }
                
                alert.tag = kHasVersionAlertTag;
                [alert show];
            }
            else
            {
                self.labelTip.text = @"当前版本已是最新版本";
            }
            
            [self stopShowPromptView];
        }];
    }];
}

- (NSDictionary *)checkNewVersion
{
    NSString *stringUrl = [NSString stringWithFormat:@"%@/ClientVersionCheck", kBaseURL];
    NSURL *checkUrl = [NSURL URLWithString:stringUrl];
    
    NSString *version = [VEUtility curAppVersion];
    NSString *paramsStr = @"device=iga&";
    paramsStr = [paramsStr stringByAppendingFormat:@"version=%@", version];
    
    FYNHttpRequestLoader *httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    NSData *receiveData = [httpRequestLoader startSynRequestWithURL:checkUrl withParams:paramsStr withTimeOut:20];
    
    NSInteger res = 11;
    BOOL bMandatory = NO;
    NSString *updateDiscrip = @"";
    
    if (receiveData)
    {
        NSError *error = nil;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:receiveData
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        if (resultDic == nil)
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
        else
        {
            if ([resultDic count] <= 0)
            {
                NSLog(@"服务器返回的数据格式错误: %@.", resultDic);
            }
            else
            {
                VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultDic];
                if ([jsonParser retrieveRusultValue] == 10)
                {
                    res = 10;
                    bMandatory = [jsonParser retrieveMandatoryUpdateValue];
                    updateDiscrip = [jsonParser retrieveUpdateDiscriptionValue];
                    
                    NSLog(@"--- have new version. ---");
                }
            }
        }
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInteger:res], kHasNewVersion,
                         [NSNumber numberWithBool:bMandatory], kMandatoryUpdate,
                         updateDiscrip, kUpdateDiscription, nil];
    
    if (res == 11)
    {
        NSLog(@"--- no new version. ---");
    }
    
    return dic;
}

- (void)doSignOffAction
{
    if (self.optionActionSheet == nil)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"退出当前帐号"
                                                        otherButtonTitles:nil];
        actionSheet.tag = kOptionActionSheetTag;
        self.optionActionSheet = actionSheet;
    }

    [self.optionActionSheet showInView:self.view];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kHasVersionAlertTag)
    {
        NSString *butTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([butTitle isEqualToString:@"立刻更新"])
        {
            [VEUtility downLoadNewVersion]; 
        }
    }
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kOptionActionSheetTag &&
        buttonIndex == 0)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [VEUtility returnToLoginInterface:NO];
        }];
    }
}

#pragma mark - UIControlEventValueChanged

- (void)switcherValueChanged:(id)sender
{
    UISwitch *switcher = (UISwitch *)sender;
    NSInteger tagValue = switcher.tag;

    if (tagValue == kAutoLoginSwitchTag)
    {
        [VEUtility setShouldAutoLoginToServer:switcher.isOn];
    }
    else if (tagValue == KShouldReceivePicSwitchTag)
    {
        [VEUtility setShouldReceivePictureOnCellNetwork:!switcher.isOn];
    }
    
    [self.tableView reloadData];
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
}

- (void)refleshToggleButtonOnRed
{
    VENavViewController *nav = (VENavViewController *)self.navigationController;
    nav.iconType = [VEUtility isOnRed];
}

@end
