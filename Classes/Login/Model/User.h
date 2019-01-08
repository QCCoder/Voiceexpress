//
//  LoginRespons.h
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VEBaseModel.h"
@interface User : VEBaseModel

//服务器标识用户码
@property (nonatomic,copy) NSString *sessionToken;

@property (nonatomic,assign) BOOL isTopLeader;

@property (nonatomic,assign) NSInteger currentUserID;

@property (nonatomic,assign) NSInteger suid;

@property (nonatomic,assign) BOOL isDefaultPassword;

@property (nonatomic,assign) BOOL isSecurityCtrlOpen;

@property (nonatomic,assign) BOOL isLockCtrlOpen;

@property (nonatomic,assign) BOOL isIntelligenceNeedWhole;

@property (nonatomic,assign) BOOL networkReportReview;

@property (nonatomic,copy) NSString *username;

@property (nonatomic,assign) BOOL defaultpwd;

@property (nonatomic,assign) NSInteger guid;
@end
