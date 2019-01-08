//
//  Group.m
//  voiceexpress
//
//  Created by 钱城 on 16/3/8.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "Group.h"

@implementation Group

+(NSDictionary *)objectClassInArray{
    return @{
             @"groupMember":[GroupMember class]
             };
}

@end
