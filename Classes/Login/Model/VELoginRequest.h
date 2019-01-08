//
//  VELoginRequest.h
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VELoginRequest : NSObject

//用户名
@property (nonatomic,copy) NSString *uname;
//密码
@property (nonatomic,copy) NSString *password;
//类型
@property (nonatomic,assign) NSInteger mtype;
//token用户推送
@property (nonatomic,copy) NSString *token;
//设备信息
@property (nonatomic,copy) NSString *deviceInfo;
//app版本
@property (nonatomic,copy) NSString *ver;

@end
