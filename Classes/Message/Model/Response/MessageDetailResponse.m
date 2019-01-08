//
//  MessageDetailResponse.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/29.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "MessageDetailResponse.h"

@implementation MessageDetailResponse

+(NSDictionary *)objectClassInArray{
    return @{
             @"receivers":[Receiver class]
             };
}

@end
