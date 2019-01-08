//
//  PasswordTool.h
//  voiceexpress
//
//  Created by 钱城 on 15/12/30.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordTool : NSObject

+ (void)modefyPasswordWithParam:(NSDictionary *)param LoginSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

@end
