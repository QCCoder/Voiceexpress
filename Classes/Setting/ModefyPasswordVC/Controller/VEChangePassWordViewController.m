//
//  VEChangePassWordViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-22.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEChangePassWordViewController.h"
#import "VEAppDelegate.h"
#import "PasswordTool.h"

extern BOOL isDefaultPassword;

@interface VEChangePassWordViewController ()

@property (weak, nonatomic) IBOutlet UIView                    *promptView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *indicator;
@property (weak, nonatomic) IBOutlet UITextField               *curPasswordField;
@property (weak, nonatomic) IBOutlet UITextField               *NewPasswordField;
@property (weak, nonatomic) IBOutlet UITextField               *confirmNewPasswordField;

- (IBAction)backgroundTapped:(id)sender;
@end

@implementation VEChangePassWordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNav];
}
/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = @"修改密码";
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(savePassword) image:Config(Tab_Icon_Ok) highImage:nil];
    self.navigationItem.rightBarButtonItem = more;
    if (self.action == OperationChangeDefaultPassword)
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.action == OperationChangeDefaultPassword)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示 "
                                                            message:@"当前账号为初始密码，为了您的账号安全，请修改密码！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - IBAction

- (void)savePassword
{
    NSString *curPassword = self.curPasswordField.text;
    NSString *newPassword = self.NewPasswordField.text;
    NSString *confirmNewPassword = self.confirmNewPasswordField.text;
    
    // MD5加密
    curPassword = [VEUtility md5:curPassword];
    newPassword = [VEUtility md5:newPassword];
    confirmNewPassword = [VEUtility md5:confirmNewPassword];
    
    // 密码不能为空
    if (!curPassword.length || !newPassword.length || !confirmNewPassword.length){
        ALERT(@"提示", @"密码不能为空");
        return;
    }
    
    // 比较当前密码是否正确
    NSString *rightPassWord = [VEUtility currentUserPassword];
    if (![rightPassWord isEqual:curPassword]){
        ALERT(@"提示", @"旧密码不正确,请重新输入");
        return;
    }
    
    // 比较新密码是否一致
    if (![newPassword isEqual:confirmNewPassword]){
        ALERT(@"提示", @"新密码输入不一致,请重新输入");
        return;
    }
    
    // 比较当前密码和新密码是否相同
    if ([curPassword isEqual:newPassword]){
        ALERT(@"提示", @"新密码和旧密码相同,请重新输入");
        return;
    }
    
    // 修改密码
    [self changeOldPassword:curPassword ToNewPassword:newPassword];
    
    
}


//修改密码
- (void) changeOldPassword:(NSString *)oldPassword ToNewPassword:(NSString *)newPassword
{
    NSString *encodeOldPassword = [VEUtility encodeToPercentEscapeString:oldPassword];
    NSString *encodeNewPassword = [VEUtility encodeToPercentEscapeString:newPassword];
    
    
    NSDictionary *dict = @{
                           @"password":encodeOldPassword,
                           @"newpassword":encodeNewPassword,
                           };
    __weak typeof(self) weakSelf = self;
    
    [MBProgressHUD showMessage:@"正在修改，请稍等..."];
    
    [PasswordTool modefyPasswordWithParam:dict LoginSuccess:^(id JSON) {
        [MBProgressHUD hideHUD];
        DLog(@"%@",JSON);
        NSInteger result = [JSON[@"result"] integerValue];
        if (result == 0) {
            [AlertTool showAlertToolWithMessage:@"密码修改成功"];
            [weakSelf updateFromNewPassword:newPassword];
        }else{
            [AlertTool showAlertToolWithCode:result];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        DLog(@"%@",[error localizedDescription]);
    }];
}

- (void)updateFromNewPassword:(NSString *)newPassword
{
    [VEUtility setCurrentUserPassword:newPassword];
    
    if (self.action == OperationChangeDefaultPassword){
        isDefaultPassword = NO;
        
        VEAppDelegate *appDelegate = (VEAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate initWindowRootViewController];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.curPasswordField resignFirstResponder];
    [self.NewPasswordField resignFirstResponder];
    [self.confirmNewPasswordField resignFirstResponder];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.curPasswordField == textField)
    {
        [self.NewPasswordField becomeFirstResponder];
    }
    else if (self.NewPasswordField == textField)
    {
        [self.confirmNewPasswordField becomeFirstResponder];
    }
    return YES;
}

@end





