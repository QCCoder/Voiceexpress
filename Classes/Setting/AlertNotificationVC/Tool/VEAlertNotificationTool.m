//
//  VEAlertNotificationTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/4.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "VEAlertNotificationTool.h"
#import "MJExtension.h"
@implementation VEAlertNotificationTool

+(void)findNotificationConfigSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    [HttpModelTool postSessionDataWithTaskUrl:@"FindUserConfig" requestModel:nil responseClass:[VEAlertNotification class] success:^(id model) {
        VEAlertNotification *alert = model;
        alert.isGenralAlert = [self retrievePushAlertValue:alert.veLevels rangeStr:@",3,"];
        alert.isSeriousAlert = [self retrievePushAlertValue:alert.veLevels rangeStr:@",2,"];
        alert.isUrgentAlert = [self retrievePushAlertValue:alert.veLevels rangeStr:@",1,"];
        success(alert);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+(void)updateNotificationWithParam:(VEAlertNotificationModefy *)param ConfigSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    //把模型转换成数据字典
    NSDictionary *params = [param keyValues];
    
    [HttpTool postWithSessionClient:@"UpdateUserConfig" param:params success:^(id JSON) {
        success(JSON);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (BOOL)retrievePushAlertValue:(NSString *)veLevels rangeStr:(NSString *)rangeStr;
{
    NSString *pushlevels = veLevels;
    
    if (pushlevels.length > 0)
    {
        pushlevels = [pushlevels stringByReplacingOccurrencesOfString:@"{" withString:@","];
        pushlevels = [pushlevels stringByReplacingOccurrencesOfString:@"}" withString:@","];
        
        NSRange range = [pushlevels rangeOfString:rangeStr];
        if (range.location != NSNotFound)
        {
            return YES;
        }
    }
    return NO;
}

@end
