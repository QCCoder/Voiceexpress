//
//  LoginTool.m
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "LoginTool.h"
#import "VETokenTool.h"
extern NSString *sessionToken;
extern BOOL isTopLeader;

NSInteger   currentUserID               = 0;
BOOL        isDefaultPassword           = NO;
BOOL        isSecurityCtrlOpen          = NO;
BOOL        isLockCtrlOpen              = NO;
BOOL        isIntelligenceNeedWhole     = NO;
BOOL        networkReportReview         = NO;


@implementation LoginTool

+(VELoginRequest *)getParam{
    VELoginRequest *loginRequest = [[VELoginRequest alloc]init];
    loginRequest.uname = [VEUtility encodeToPercentEscapeString:[VEUtility currentUserName]];
    loginRequest.password = [VEUtility encodeToPercentEscapeString:[VEUtility currentUserPassword]];
    loginRequest.ver = [VEUtility curAppVersion]; // 当前程序版本号
    loginRequest.deviceInfo = [NSString stringWithFormat:@"IOS-%@",[VEUtility getUMSUDID]];
    loginRequest.token = [VEUtility currentAPNSToken]; // 推送Token
    loginRequest.mtype = 11;
    return loginRequest;
}

//设置全局变量
+(void)setFlag:(User *)user{
    currentUserID       = user.currentUserID;
    sessionToken        = user.sessionToken;
    isTopLeader         = (1 == user.isTopLeader ? YES : NO);
    isDefaultPassword   = user.defaultpwd;
    isSecurityCtrlOpen  = user.isSecurityCtrlOpen;
    isLockCtrlOpen      = user.isLockCtrlOpen;
    isIntelligenceNeedWhole = user.isIntelligenceNeedWhole;
    networkReportReview = user.networkReportReview;
}

/**
 *  异步登陆
 *
 */
+(void)loginWithLoginSuccess:(LoginSuccessBlock)success failure:(LoginFailureBlock)failure
{
    [HttpModelTool postWithUrl:@"login" requestModel:[self getParam] responseClass:[User class] success:^(id model) {
        [UserTool saveUser:model];
        [self setFlag:model];
        success(model);
    } failure:^(NSError *error) {
        failure(error);
    }];
}


/**
 *  同步登陆
 */
+ (BOOL)synchronousLoginToServer
{
    NSString *uuid = [VEUtility getUMSUDID];
    NSString *version = [VEUtility curAppVersion];       // 当前程序版本号
    
    // APNS推送Token
    NSString *token = [VEUtility currentAPNSToken];
    
    // 用户名和密码
    NSString *userName = [VEUtility currentUserName];
    NSString *passWord = [VEUtility currentUserPassword];
    
    // 用户名和密码UTF8编码
    NSString *encodeUserName = [VEUtility encodeToPercentEscapeString:userName];
    NSString *encodedPassword = [VEUtility encodeToPercentEscapeString:passWord];
    
    // 登录URL及参数
    NSString *loginString = [NSString stringWithFormat:@"%@/login", kBaseURL];
    NSURL *loginUrl = [NSURL URLWithString:loginString];
    
    NSString *paramStr = [NSString stringWithFormat:@"uname=%@&password=%@&mid=0&mac=0&mtype=11&token=%@&ver=%@&deviceInfo=IOS-%@", encodeUserName, encodedPassword, token, version, uuid];
    
    // 同步请求,超时设为5秒
    FYNHttpRequestLoader *httpRequestLoader = [[FYNHttpRequestLoader alloc] init];
    NSData *receiveData = [httpRequestLoader startSynRequestWithURL:loginUrl withParams:paramStr withTimeOut:5];
    if (receiveData)
    {
        NSError *error = nil;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:receiveData
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        
        if (resultDic != nil && resultDic.count > 0)
        {
            VEJsonParser *jsonParser = [[VEJsonParser alloc] initWithJsonDictionary:resultDic];
            if ([jsonParser retrieveRusultValue] == 0)
            {
                User *user = [[User alloc]init];
                user.sessionToken        = [jsonParser retrieveSessionTokenValue];
                user.currentUserID       = [jsonParser retrieveUIDValue];
                user.isTopLeader         = (1 == [jsonParser retrieveUGroupIDValue] ? YES : NO);
                user.isDefaultPassword   = [jsonParser retrieveIsDefaultPasswordValue];
                user.isSecurityCtrlOpen  = [jsonParser retrieveIsSecurityCtrlOpenValue];
                user.isLockCtrlOpen      = [jsonParser retrieveIsLockCtrlOpenValue];
                user.isIntelligenceNeedWhole = [jsonParser retrieveIsIntelligenceNeedWholeValue];
                user.networkReportReview = [jsonParser retrieveNetworkReportReviewValue];  // 控制是否显示【信息审核】
                
                user.guid =[jsonParser retrieveGIDValue];
                [VEUtility setCurrentUserId:[NSString stringWithFormat:@"%ld",(long)user.guid]];
                [VETokenTool getTokenWithUserId:[[VEUtility currentUserId] integerValue]];
                
                [UserTool saveUser:user];
                [self setFlag:user];
                return YES;
            }
        }
        
        if (error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }
    NSLog(@"--- synchronousLogin failed. ---");
    return NO;
}


@end
