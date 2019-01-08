//
//  PasswordTool.m
//  voiceexpress
//
//  Created by 钱城 on 15/12/30.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "PasswordTool.h"

@implementation PasswordTool

+(void)modefyPasswordWithParam:(NSDictionary *)param LoginSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    [HttpTool postWithUrl:@"changepswd" Parameters:param Success:^(id JSON) {
        success(JSON);
    } Failure:^(NSError *error) {
        failure(error);
    }];
}

@end
