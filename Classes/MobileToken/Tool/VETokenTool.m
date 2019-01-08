//
//  VETokenTool.m
//  voiceexpress
//
//  Created by 钱城 on 15/11/4.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "VETokenTool.h"
#import "VETokenRequest.h"
#import "VETokenRespons.h"
#import "HttpModelTool.h"
#import "FYNHttpRequestLoader.h"
#import "VEUtility.h"
@implementation VETokenTool

+(void)getTokenWithUserId:(NSInteger )userId
{
    VETokenRequest *request = [[VETokenRequest alloc]init];
    request.userId = userId;
    
    [HttpModelTool getWithUrl:@"safelock" requestModel: nil responseClass:[VETokenRespons class] success:^(id model) {
        VETokenRespons *respons = model;
        
        if (respons.result == 1) {
            NSString *str = [respons.serverTime substringToIndex:10];
            long serviceTime = [str integerValue];
            NSInteger localTime = [VETokenTool getTimestamp];
            NSInteger time = localTime - serviceTime;
            [VEUtility setCurrentServiceTime:[NSString stringWithFormat:@"%ld",(long)time]];
//            NSLog(@"serviceTime:%ld",(long)serviceTime);
            [VEUtility setCurrentMobileToken:respons.userkey];
            [VEUtility setCurrentIsopenToken:[NSString stringWithFormat:@"%ld",(long)respons.isopen]];
        }
        
        
    } failure:^(NSError *error) {
        NSLog(@"Token failure: %@",error);
    }];
}

+(long)getTimestamp{
    NSDate *now = [NSDate date];
    long timestamp = (long)[now timeIntervalSince1970];
    return timestamp;
}

+(NSDictionary *)getServiceTime{
    NSInteger time = [[VEUtility currentServiceTime] integerValue];
    NSInteger timesTamp = [VETokenTool getTimestamp] - time;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate *serviceDate = [NSDate dateWithTimeIntervalSince1970:timesTamp];
    NSString *dateString = [dateFormatter stringFromDate:serviceDate];;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)timesTamp] forKey:@"timestamp"];
    [dict setValue:dateString forKey:@"date"];
    
    return dict;
}
@end
