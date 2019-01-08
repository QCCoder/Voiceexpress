//
//  NetworkReportingAgent.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/19.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "NetworkReportingAgent.h"

@implementation NetworkReportingAgent

MJCodingImplementation

+(NSDictionary *)replacedKeyFromPropertyName
{
    NSDictionary *dict = @{
                           @"articleId":@"aid",
                           @"timePost":@"tmPost",
                        @"timeWarn":@"tmWarn"
                           };
    return dict;
}

@end
