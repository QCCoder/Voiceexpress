//
//  UserTool.m
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "UserTool.h"


// 文件路径
#define kFile [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"user.data"]

@implementation UserTool

//存模型
+(void)saveUser:(User *)user
{
    [NSKeyedArchiver archiveRootObject:user toFile:kFile];
}

//取模型
+(User *)user
{
    // 加载模型
    User *user = [NSKeyedUnarchiver unarchiveObjectWithFile:kFile];
    return user;
}

@end
