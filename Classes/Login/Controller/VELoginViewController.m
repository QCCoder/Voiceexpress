//
//  VELoginViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-11.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VELoginViewController.h"
#import "VEAppDelegate.h"
#import "VEUploadLogViewController.h"
#import "VETokenTool.h"
#import "LoginTool.h"
#import "UserTool.h"
#import "UIColor+Utils.h"

@interface VELoginViewController ()
//用户名
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
//密码
@property (weak, nonatomic) IBOutlet UITextField *passWordField;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxBtn;
@property (weak, nonatomic) IBOutlet UILabel *labelKeepLoginState;
@property (weak, nonatomic) IBOutlet UIView *bkView;

@end

@implementation VELoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserver];
    [self reloadImage];
    
    self.checkBoxBtn.selected = [VEUtility shouldAutoLoginToServer];
    [self.userNameField setText:[VEUtility currentUserName]];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LabelTapped:)];
    [self.labelKeepLoginState addGestureRecognizer:tapGestureRecognizer];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _line.ve_height = 0.3;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DLog(@"LoginVC Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog(@"LoginVC Disappear");
}


-(void)reloadImage{
    [super reloadImage];
    
    [self.view setBackgroundColor:[UIColor colorWithHexString:self.config[MainColor]]];
    _bkView.layer.masksToBounds = YES;
    _bkView.layer.cornerRadius = 5.0;
    _loginButton.layer.masksToBounds = YES;
    
    _loginButton.layer.cornerRadius = 5.0;
    _loginButton.layer.shadowColor = [UIColor clearColor].CGColor;
    _logoImageView.image = Image(Icon_Iogo);
    [_checkBoxBtn setImage:Image(Login_Keep_Normal) forState:UIControlStateNormal];
    [_checkBoxBtn setImage:Image(Login_Keep_Pressed) forState:UIControlStateSelected];
    
    [_loginButton setBackgroundImage:[UIColor createImageWithColor:RGBCOLOR(250, 169, 50)] forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:[UIColor createImageWithColor:RGBCOLOR(204, 127, 18)] forState:UIControlStateHighlighted];
}

#pragma mark - My Methods

- (void)logInAction
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"正在登陆" toView:self.view];
    [LoginTool loginWithLoginSuccess:^(id JSON) {

        User *user = JSON;
        if (user.result == 0) {
            [hud hide:YES afterDelay:0.25];
            [VEUtility setCurrentUserId:[NSString stringWithFormat:@"%ld",(long)user.suid]];
            [VETokenTool getTokenWithUserId:[[VEUtility currentUserId] integerValue]];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [VEUtility setLockErrorTimes:0];
                // 注册推送服务
                [VEUtility registerForRemoteNotifications];
                VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate initWindowRootViewController];
            }];
            [UserTool saveUser:user];
        }else{
            [MBProgressHUD changeToErrorWithHUD:hud Message:[AlertTool getHttpMsg:user.result]];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES afterDelay:0.25];
        DLog(@"%@",[error localizedDescription]);
    }];
}

#pragma mark 监听事件

// View背景被点击了
- (IBAction)backgroundTapped:(id)sender
{
    [self.userNameField resignFirstResponder];
    [self.passWordField resignFirstResponder];
}

// 登陆操作
- (IBAction)logIn:(id)sender
{
    @autoreleasepool {
        [self backgroundTapped:nil];
        
        NSString *userName = [self.userNameField text];
        NSString *passWord = [self.passWordField text];
        
        NSString *message = nil;
        if ([userName length] == 0)
        {
            message = @"用户名不能为空";
        }
        else if ([passWord length] == 0)
        {
            message = @"密码不能为空";
        }
        
        if (message != nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"好的"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        // 去掉首位的空格
        userName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [VEUtility setCurrentUserName:userName];
        [VEUtility setCurrentUserPassword:[VEUtility md5:passWord]];
        
        [self logInAction];
    }
}

/**
 *  保持登陆Label点击
 *
 */
- (void)LabelTapped:(id)sender
{
    [self checkBoxClicked:self.checkBoxBtn];
}

/**
 *  保持登陆状态
 *
 */
- (IBAction)checkBoxClicked:(id)sender
{
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    [VEUtility setShouldAutoLoginToServer:btn.selected];
}

/**
 *  上传日志
 */
- (IBAction)uploadLogBtnTapped
{
    VEUploadLogViewController *logViewController = [[VEUploadLogViewController alloc] initWithNibName:@"VEUploadLogViewController" bundle:nil];
    
    logViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:logViewController animated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.userNameField)
    {
        [self.passWordField becomeFirstResponder];
    }
    else
    {
        [self logIn:nil];
    }
    return YES;
}

@end
