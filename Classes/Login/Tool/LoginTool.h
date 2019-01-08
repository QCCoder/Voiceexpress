//
//  LoginTool.h
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VELoginRequest.h"
#import "User.h"
@interface LoginTool : NSObject


typedef void (^LoginSuccessBlock)(id JSON);
typedef void (^LoginFailureBlock)(NSError *error);



//Http请求sessionDataPostWithParams 异步
+ (void)loginWithLoginSuccess:(LoginSuccessBlock)success failure:(LoginFailureBlock)failure;

/**
 *  同步登陆服务器
 *
 *  @return 返回登录是否成功
 */
+ (BOOL)synchronousLoginToServer;

@end
