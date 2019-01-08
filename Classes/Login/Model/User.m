//
//  LoginRespons.m
//  voiceexpress
//
//  Created by 钱城 on 15/12/29.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "User.h"
#import "MJExtension.h"
@implementation User

MJCodingImplementation

+ (NSDictionary *)replacedKeyFromPropertyName{
    NSDictionary *dict = @{@"username":@"name",
                           @"isSecurityCtrlOpen":@"SecurityCtrlOpen",
                           @"isLockCtrlOpen":@"LockCtrlOpen",
                           @"networkReportReview":@"NetworkReportReview",
                           @"currentUserID":@"uid",
                           @"isIntelligenceNeedWhole":@"isIntelligenceNeedWhole",
                           @"isTopLeader":@"uGroupID"
                           };
    
    return dict;
}

@end
