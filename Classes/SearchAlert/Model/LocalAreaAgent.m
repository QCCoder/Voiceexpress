//
//  TagList.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/21.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "LocalAreaAgent.h"

@implementation LocalAreaAgent

MJCodingImplementation

+(NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"tagID":@"id",
             @"tagName":@"name"};
}

@end
