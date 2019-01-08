//
//  VEVerifyPasswordViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 14-6-11.
//  Copyright (c) 2014年 CYYUN. All rights reserved.
//

#import "VEVerifyPasswordViewController.h"

BOOL VEVerifyPasswordView_ClearUpDeviceLock = NO;

@interface VEVerifyPasswordViewController ()

@property (weak, nonatomic) IBOutlet UIToolbar    *toolBar;
@property (weak, nonatomic) IBOutlet UILabel      *labelTip;
@property (weak, nonatomic) IBOutlet UITextField  *textFieldPassword;

- (IBAction)back:(id)sender;
- (IBAction)verifyPassword:(id)sender;

@end

@implementation VEVerifyPasswordViewController

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
    
    VEVerifyPasswordView_ClearUpDeviceLock = NO;
    
    [VEUtility initBackgroudImageOfToolBar:self.toolBar];
    self.labelTip.text = [NSString stringWithFormat:@"请输入当前帐号%@的密码", [VEUtility currentUserName]];
}

- (void)viewDidUnload
{
    [self setToolBar:nil];
    [self setLabelTip:nil];
    [self setTextFieldPassword:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)verifyPassword:(id)sender
{
    NSString *toVerifyPassword = [VEUtility md5:self.textFieldPassword.text];
    NSString *userPassword     = [VEUtility currentUserPassword];
    
    if ([userPassword isEqualToString:toVerifyPassword])
    {
        // 清空设备锁设置信息
        [VEUtility clearUpDeviceLock];
        VEVerifyPasswordView_ClearUpDeviceLock = YES;
        
        [self back:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"您输入的密码不正确"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"好的", nil];
        [alertView show];
    }
}

@end
