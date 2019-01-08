//
//  QCDeviceViewController.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/7.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "QCDeviceViewController.h"
#import "YLSwipeLockView.h"
#import "DeviceTopView.h"
#define kMaxErrorTimes 6

#define kHRate Main_Screen_Height / 667.0
#define kWRate Main_Screen_Width / 375.0

@interface QCDeviceViewController ()<YLSwipeLockViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) UILabel *warnLabel;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnForgetPassword;

@property (nonatomic,assign) NSInteger errorTimes;
@property (weak, nonatomic) YLSwipeLockView *swipLockView;
@property (nonatomic,weak) DeviceTopView *topView;

@property (nonatomic,strong) UIView *headView;

@property (nonatomic,copy) NSString *firstPassword;
@property (nonatomic,copy) NSString *secondPassword;
@property (nonatomic,assign) NSInteger lastItem;

@end

@implementation QCDeviceViewController

-(UIView *)headView
{
    if (!_headView) {
        UIView *name = [[UIView alloc]initWithFrame:CGRectMake(0, 110 * kHRate, 120 * kWRate, 120 * kWRate)];
        name.centerX = Main_Screen_Width * 0.5;
        [self.view addSubview:name];
        self.headView = name;
        
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[QCZipImageTool imageOrNamed:@"menu_user.pdf"]];
        imageView.frame = CGRectMake(0, 0, 80 * kWRate, 80* kWRate);
        imageView.ve_centerX = name.ve_width * 0.5;
        [name addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+10, 120 * kWRate, 16 * kWRate)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = RGBCOLOR(102, 102,102);
        label.text = [VEUtility currentUserName];
        [name addSubview:label];
        
    }
    return _headView;
}

-(DeviceTopView *)topView
{
    if (!_topView) {
        DeviceTopView *name = [[DeviceTopView alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
        name.ve_centerX = Main_Screen_Width * 0.5;
        name.ve_y = 130.5 * kHRate;
        [self.view addSubview:name];
        self.topView = name;
    }
    return _topView;
}

-(UILabel *)warnLabel
{
    if (!_warnLabel) {
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(_swipLockView.frame) - (55.5 * kHRate), 200, 20)];
        name.ve_centerX = Main_Screen_Width * 0.5;
        name.textColor = RGBCOLOR(138, 138, 138);
        name.font = [UIFont systemFontOfSize:15.0];
        name.hidden = YES;
        name.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:name];
        self.warnLabel = name;
    }
    return _warnLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDeviceView];
    [self setupTitle];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[VEUtility isFirstLogin] integerValue] == 0) {
        
        [VEUtility setIsFirstLogin:@"1"];
        ALERT(@"温馨提示", @"您好，为了您的账号安全，请开启设备锁！");
    }
}

-(void)setupTitle{
    
    self.warnLabel.text = @"绘制解锁图案";
    switch (self.action)
    {
        case VEPatternLockActionVerify:
            self.backBtn.hidden = YES;
            self.errorTimes = [VEUtility lockErrorTimes];
            self.titleLabel.text = @"屏幕被锁定中";
            break;
            
        case VEPatternLockActionInit:
        case VEPatternLockActionLaunchInit:
            self.btnForgetPassword.hidden = YES;
            self.titleLabel.text = @"开启设备锁";
            break;
            
        case VEPatternLockActionClose:
            self.errorTimes = 0;
            self.btnForgetPassword.hidden = YES;
            self.titleLabel.text = @"关闭设备锁";
            break;
            
        default:
            self.titleLabel.text = nil;
            break;
    }
}

-(void)setupDeviceView{
    YLSwipeLockView *lockView = [[YLSwipeLockView alloc] initWithFrame:CGRectMake(52.0 * kWRate,0, Main_Screen_Width - 104.0 * kWRate , Main_Screen_Width - 104.0 * kWRate)];
    lockView.delegate = self;
    [self.view addSubview:lockView];
    _swipLockView = lockView;
    
    if (self.action != VEPatternLockActionVerify) {
        _swipLockView.ve_y = CGRectGetMaxY(self.topView.frame) +  70 * kHRate;
        _lastItem = -1;
        _swipLockView.selectedItem = ^(NSInteger index){
            if (_lastItem != index) {
                _lastItem = index;
                self.topView.selectedIndex = index;
            }
        };
        
        _swipLockView.cleanNode = ^(){
            _lastItem = -1;
            [self.topView cleanNode];
        };
    }else{
        _swipLockView.ve_y = CGRectGetMaxY(self.headView.frame) +  50 * kHRate;
        if (Main_Screen_Height < 568) {
            _swipLockView.frame = CGRectMake(52, 0, Main_Screen_Width - 104, Main_Screen_Width - 104);
            _swipLockView.ve_y = CGRectGetMaxY(self.headView.frame) +  30 * kHRate;
            self.warnLabel.ve_y = CGRectGetMinY(_swipLockView.frame) - (35.5 * kHRate);
        }
    }
}

-(YLSwipeLockViewState)swipeView:(YLSwipeLockView *)swipeView didEndSwipeWithPassword:(NSString *)password
{
    if (password.length > 0 && password.length < 4) {
        [self setWarnText:@"至少连接4个点，请重新绘制"];
        return YLSwipeLockViewStateNormal;
    }

    NSString *localPassword = [VEUtility currentPatternLockPassword];
    switch (self.action)
    {
        case VEPatternLockActionVerify://验证设备锁
            if ([localPassword isEqualToString:password]) {
                [self back:nil];
                return YLSwipeLockViewStateNormal;
            }else{
                self.errorTimes++;
                
                if (self.action == VEPatternLockActionVerify) {
                    [VEUtility setLockErrorTimes:0];
                }
                
                if (self.errorTimes >=kMaxErrorTimes) {
                    if (self.action == VEPatternLockActionVerify) {
                        [VEUtility setLockErrorTimes:0];
                    }
                    [VEUtility returnToLoginInterface:NO];
                }else{
                    [self setWarnText:[NSString stringWithFormat:@"密码错了，还可输入%ld次", (kMaxErrorTimes - self.errorTimes)]];
                }
                return YLSwipeLockViewStateWarning;
            }
            break;
            
        case VEPatternLockActionInit:
        case VEPatternLockActionLaunchInit:
            if (self.firstPassword.length == 0) {
                self.firstPassword = password;
                self.warnLabel.textColor = patternLockTipColor;
                
                self.topView.title = @"请再次绘制解锁图案";
                self.topView.status = QCDeviceTopStatusSelected;
                self.topView.password = password;
                
                return YLSwipeLockViewStateSelected;
            }else{
                self.secondPassword = password;
                if (![self.secondPassword isEqualToString:self.firstPassword]) {
                    [self setWarnText:@"密码不一致，请重新输入"];
                    
                    self.topView.status = QCDeviceTopStatusWarning;
                    self.topView.password = password;
                    
                    return YLSwipeLockViewStateWarning;
                }else{
                    // 保存设备锁密码
                    [VEUtility setPatternLockPassword:self.firstPassword];
                    //默认时间3分钟
                    [VEUtility setPatternLockTime:3];
                    if (self.action == VEPatternLockActionLaunchInit){
                        [VEUtility setPatternLockActivated:YES];
                        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
                        [appDelegate initWindowRootViewController];
                    }else{
                        [self back:nil];
                    }
                }
            }
            
            break;
            
        case VEPatternLockActionClose:
            if (![localPassword isEqualToString:password]) {
                self.errorTimes++;
                if (self.errorTimes >=kMaxErrorTimes) {
                    if (self.action == VEPatternLockActionVerify) {
                        [VEUtility setLockErrorTimes:0];
                    }
                    [VEUtility returnToLoginInterface:NO];
                }
                [self setWarnText:[NSString stringWithFormat:@"密码错了，还可输入%ld次", (kMaxErrorTimes - self.errorTimes)]];
                self.topView.status = QCDeviceTopStatusWarning;
                self.topView.password = password;
                return YLSwipeLockViewStateWarning;
            }
            self.errorTimes = 0;
            [VEUtility setLockErrorTimes:0];
            [VEUtility clearUpDeviceLock];
            [self back:nil];
            break;
            
        default:
            break;
    }
    return YLSwipeLockViewStateNormal;
}

-(void)setWarnText:(NSString *)warnText{
    self.warnLabel.text = warnText;
    self.warnLabel.hidden = NO;
    self.warnLabel.textColor = [UIColor redColor];
    [self shakeAnimationForView:_warnLabel];
}

// 抖动动画效果

- (void)shakeAnimationForView:(UIView *) view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint x = CGPointMake(position.x - 20, position.y);
    CGPoint y = CGPointMake(position.x + 20, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.05];
    [animation setRepeatCount:2];
    
    [viewLayer addAnimation:animation forKey:nil];
}

- (IBAction)back:(id)sender {
    if (self.action == VEPatternLockActionVerify){
        [VEUtility setLockErrorTimes:0];
    }
    if (self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)forgetPassword:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"请输入当前帐号%@的密码", [VEUtility currentUserName]] message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [alertController.textFields firstObject];
        NSString *toVerifyPassword  = [VEUtility md5:textField.text];
        NSString *userPassword      = [VEUtility currentUserPassword];
        
        if ([userPassword isEqualToString:toVerifyPassword]){
            // 清空设备锁设置信息
            [VEUtility clearUpDeviceLock];
            [self back:nil];
        }else{
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
            [UIAlertController showAlertWithtitle:@"密码不正确" message:nil target:self alertActions:ok];
        }
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
        textField.placeholder = @"请输入密码";
    }];
    [alertController addAction:action1];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
