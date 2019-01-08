//
//  NetworkReportingAgent.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/19.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Agent.h"
@interface NetworkReportingAgent : Agent

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *timeWarn;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) BOOL isChanged;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *siteName;
@property (nonatomic, copy) NSString *orgTime;

@property (nonatomic,copy) NSString *statusString;
@end
