//
//  VEDeviceLockViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-6-9.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEDeviceLockViewController.h"
#import "VEMainRightDetailTableViewCell.h"
#import "QCDeviceViewController.h"
#import "VEDeviceLockTimeViewController.h"

extern BOOL     isLockCtrlOpen;

static const NSInteger kDeviceLockSwitchTag             = 100;
static const NSInteger kVerifyPasswordAlertViewTag      = 101;
static const NSInteger kOpenDeviceLockAlertViewTag      = 102;

static const NSInteger kVETableViewCellLabelMainTag   = 10;
static const NSInteger kVETableViewCellLabelDetailTag = 11;

@interface VEDeviceLockViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton    *backBtnItem;

@property (strong, nonatomic) UISwitch    *deviceLockSwitcher;
@property (nonatomic, strong) UIAlertView *alertView;


@end

@implementation VEDeviceLockViewController

- (UISwitch *)deviceLockSwitcher
{
    if (_deviceLockSwitcher == nil)
    {
        _deviceLockSwitcher = [[UISwitch alloc] init];
        [_deviceLockSwitcher setOn:NO];
        _deviceLockSwitcher.tag = kDeviceLockSwitchTag;
        [_deviceLockSwitcher addTarget:self
                                action:@selector(switcherValueChanged:)
                      forControlEvents:UIControlEventValueChanged];
    }
    return _deviceLockSwitcher;
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.deviceLockSwitcher setOn:[VEUtility isDeviceLockActivated]];
    
    [self setTitle:@"设备锁"];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.deviceLockSwitcher.on)
    {
        if ([VEUtility currentPatternLockPassword].length == 0)
        {
            [self.deviceLockSwitcher setOn:NO];
        }
        [VEUtility setPatternLockActivated:self.deviceLockSwitcher.on];
    }
    else
    {
        if ([VEUtility isDeviceLockActivated])
        {
            [self.deviceLockSwitcher setOn:YES];
        }
    }
    
    if ([UserTool user].isLockCtrlOpen)
    {
        if ([VEUtility isDeviceLockActivated])
        {
            self.backBtnItem.hidden = NO;
        }
        else
        {
            [self showOpenDeviceLockTip];
        }
    }
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL isLockActivated = [VEUtility isDeviceLockActivated];
    if ([UserTool user].isLockCtrlOpen)
    {
        // 设置了强制性的设备锁
        return (isLockActivated ? 3 : 4);
    }
    else
    {
        return (isLockActivated ? 4 : 1);
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KIdentifier_MainRightDetail];
    if (cell == nil)
    {
        NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:kNibName_MainRightDetail owner:self options:nil];
        cell = [cellNib objectAtIndex:0];
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
    cellLableDetail.textColor = detailTitleColor;
    
    NSInteger row = indexPath.row;
    NSInteger allRows = [tableView numberOfRowsInSection:0];
    if (allRows == 1)
    {
        if (row == 0)
        {
            cellLableMain.text = @"开启设备锁";
            [itemView addSubview:self.deviceLockSwitcher];
            [self.deviceLockSwitcher sizeToFit];
        }
    }
    else 
    {
        if (allRows == 3)
        {
            row += 1;
        }
        
        if (row == 0)
        {
            cellLableMain.text = @"开启设备锁";
            [itemView addSubview:self.deviceLockSwitcher];
            [self.deviceLockSwitcher sizeToFit];
        }
        else if (row == 1)
        {
            cellLableMain.text = @"锁定时间";
            NSInteger time = [VEUtility currentPatternLockTime];
            cellLableDetail.text = (time == 0 ? @"立即\t" : [NSString stringWithFormat:@"%ld分钟", (long)time]);
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"arr_up.png"]];
            imageView.ve_size = CGSizeMake(15, 15);
            imageView.ve_x = itemView.ve_width - 15;
            imageView.ve_centerY = itemView.ve_height * 0.5;
            imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
            [itemView addSubview:imageView];
        }
        else if (row == 2)
        {
            cellLableMain.text = @"修改设备锁";
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"arr_up.png"]];
            imageView.ve_size = CGSizeMake(15, 15);
            imageView.ve_x = itemView.ve_width - 15;
            imageView.ve_centerY = itemView.ve_height * 0.5;
            imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
            [itemView addSubview:imageView];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (row == 3)
        {
            cellLableMain.text = @"忘记密码";
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:@"arr_up.png"]];
            imageView.ve_size = CGSizeMake(15, 15);
            imageView.ve_x = itemView.ve_width - 15;
            imageView.ve_centerY = itemView.ve_height * 0.5;
            imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
            [itemView addSubview:imageView];

        }
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = selectedBackgroundColor;
    
    return view;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger allRows = [tableView numberOfRowsInSection:0];
    NSInteger row = indexPath.row;
    
    NSInteger idx = (allRows == 3 ? 0 : (allRows == 4 ? 1 : -1));
    if (idx != -1)
    {
        if (row == idx)
        {
            [self doConfigureLockTimeAction];
        }
        else if (row == (idx + 1))
        {
            [self changeDeviceLockPattern];
        }
        else if (row == (idx + 2))
        {
            [self doForgetPasswordAction];
        }
    }
}

#pragma mark - MyMethods

- (void)switcherValueChanged:(UISwitch *)sender
{
    if (sender.tag == kDeviceLockSwitchTag)
    {
        QCDeviceViewController *lockViewControlller = [[QCDeviceViewController alloc] initWithNibName:@"QCDeviceViewController" bundle:nil];
        
        if (sender.on)
        {
            // 初始化设备锁
             lockViewControlller.action = VEPatternLockActionInit;
        }
        else
        {
            // 关闭设备锁
             lockViewControlller.action = VEPatternLockActionClose;
        }
        [self presentViewController:lockViewControlller animated:YES completion:nil];
    }
}

- (void)changeDeviceLockPattern
{
    if ([VEUtility isDeviceLockActivated])
    {
        QCDeviceViewController *lockViewControlller = [[QCDeviceViewController alloc] initWithNibName:@"QCDeviceViewController" bundle:nil];
        lockViewControlller.action = VEPatternLockActionInit;
        [self presentViewController:lockViewControlller animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示 "
                                                            message:@"您当前还未开启设备锁。为了您的账号安全，请开启设备锁！"
                                                           delegate:self
                                                  cancelButtonTitle:@"暂不开启"
                                                  otherButtonTitles:@"好的", nil];
        alertView.tag = kOpenDeviceLockAlertViewTag;
        [alertView show];
    }
}

- (void)doConfigureLockTimeAction
{
    VEDeviceLockTimeViewController *deviceLockTimeVC = [[VEDeviceLockTimeViewController alloc] initWithNibName:@"VEDeviceLockTimeViewController" bundle:nil];
    
    [self.navigationController pushViewController:deviceLockTimeVC animated:YES];
}

- (void)doForgetPasswordAction
{
    if (self.alertView == nil)
    {
        NSString *title = [NSString stringWithFormat:@"请输入当前帐号%@的密码", [VEUtility currentUserName]];
        self.alertView = [[UIAlertView alloc] initWithTitle:title
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
        
        self.alertView.tag = kVerifyPasswordAlertViewTag;
        self.alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    }
    
    [self.alertView show];
}

- (void)showOpenDeviceLockTip
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示 "
                                                        message:@"您好，为了您的账号安全，请开启设备锁！"
                                                       delegate:self
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    alertView.tag = kOpenDeviceLockAlertViewTag;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (kVerifyPasswordAlertViewTag == alertView.tag)
    {
        NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([btnTitle isEqualToString:@"确定"])
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *toVerifyPassword = [VEUtility md5:textField.text];
            NSString *userPassword     = [VEUtility currentUserPassword];
            
            if ([userPassword isEqualToString:toVerifyPassword])
            {
                // 清空设备锁设置信息
                [VEUtility clearUpDeviceLock];
                
                [self.deviceLockSwitcher setOn:NO];
                [self.tableView reloadData];
                
                // 如果设置了强制性的开启设备锁，则在清空就密码锁后，强制用户设置新的密码锁
                if ([UserTool user].isLockCtrlOpen)
                {
                    [self showOpenDeviceLockTip];
                    
                    // 将界面中的返回按钮隐藏掉
                    self.backBtnItem.hidden = YES;
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"密码不正确"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"好的"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
    else if (kOpenDeviceLockAlertViewTag == alertView.tag)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"好的"])
        {
            [self.deviceLockSwitcher setOn:YES];
            [self switcherValueChanged:self.deviceLockSwitcher];
        }
    }
}

#pragma mark - Notification

- (void)applicationDidEnterBackgroundNotification
{
    if (self.alertView)
    {
        [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
        self.alertView = nil;
    }
}

@end
