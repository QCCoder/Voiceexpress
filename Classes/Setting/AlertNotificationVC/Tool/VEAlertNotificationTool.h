//
//  VEAlertNotificationTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/4.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VEAlertNotification.h"
#import "VEAlertNotificationModefy.h"

@interface VEAlertNotificationTool : NSObject

+ (void)findNotificationConfigSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

+ (void)updateNotificationWithParam:(VEAlertNotificationModefy *)param ConfigSuccess:(SuccessBlock)success failure:(FailureBlock)failure;


@end
