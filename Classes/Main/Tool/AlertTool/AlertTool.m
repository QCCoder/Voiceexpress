//
//  AlertTool.m
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "AlertTool.h"

@implementation AlertTool

+(void)showAlertToolWithCode:(NSInteger)code
{
    NSString *alertMessage = nil;
    switch (code) {
        case 1:
            alertMessage = @"用户名或密码不正确";
            break;
            
        case 2:
            alertMessage = @"用户名或密码为空";
            break;
            
        case 3:
            alertMessage = @"用户已过期失效";
            break;
            
        case 4:
            alertMessage = @"非法客户端";
            break;
            
        case 5:
            alertMessage = @"您的账号在另一地方被登录了,\r\n请重新登录";
            break;
            
        case 6:
            alertMessage = @"参数错误";
            break;
            
        case 7:
            alertMessage = @"软件版本太低，需升级到最新版本";
            break;
            
        case 9:
            alertMessage = @"服务器错误";
            break;
            
        case -3:
            alertMessage = @"操作失败";
            break;
            
        case -4:
            alertMessage = @"收藏状态初始化失败";
            break;
            
        case NSIntegerMin:
            alertMessage = @"服务器返回数据格式错误";
            break;
            
        default:
            alertMessage = [NSString stringWithFormat:@"未定义的错误码: %ld", (long)code];
            break;
    }
    if (alertMessage) {
        [AlertTool showAlertToolWithMessage:alertMessage];
    }
}

+(NSString *)getHttpMsg:(NSInteger)code
{
    NSString *alertMessage = nil;
    switch (code) {
        case 1:
            alertMessage = @"用户名或密码不正确";
            break;
            
        case 2:
            alertMessage = @"用户名或密码为空";
            break;
            
        case 3:
            alertMessage = @"用户已过期失效";
            break;
            
        case 4:
            alertMessage = @"非法客户端";
            break;
            
        case 5:
            alertMessage = @"您的账号在另一地方被登录了,\r\n请重新登录";
            break;
            
        case 6:
            alertMessage = @"参数错误";
            break;
            
        case 7:
            alertMessage = @"软件版本太低，需升级到最新版本";
            break;
            
        case 9:
            alertMessage = @"服务器错误";
            break;
            
        case -3:
            alertMessage = @"操作失败";
            break;
            
        case -4:
            alertMessage = @"收藏状态初始化失败";
            break;
            
        case NSIntegerMin:
            alertMessage = @"服务器返回数据格式错误";
            break;
            
        default:
            alertMessage = [NSString stringWithFormat:@"未定义的错误码: %ld", (long)code];
            break;
    }
    return alertMessage;
}


+(void)showAlertToolWithMessage:(NSString *)msg
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:msg];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hide:YES afterDelay:0.5];
    });
}

@end
