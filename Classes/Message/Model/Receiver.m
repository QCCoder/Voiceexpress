//
//  Receiver.m
//  voiceexpress
//
//  Created by 钱城 on 16/2/26.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "Receiver.h"

@implementation Receiver

+(NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"name":@"message",
             @"isRead":@"result"
             };
}

@end
