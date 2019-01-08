//
//  UserTool.h
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@interface UserTool : NSObject

/**
 *  从本地存用户信息
 *
 *  @param user
 */
+(void)saveUser:(User *)user;

/**
 *  从本地取用户信息
 *
 */
+ (User *)user;

@end
