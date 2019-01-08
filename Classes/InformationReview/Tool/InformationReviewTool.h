//
//  InformationReviewTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/19.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkReportingAgent.h"
@interface InformationReviewTool : NSObject

+(void)loadNetworkReportWithParam:(NSDictionary *)param resultInfo:(ResultInfoBlock)resultInfo;

+(void)updateNetworkReportingReviewWithParam:(NSDictionary *)param resultInfo:(ResultInfoBlock)resultInfo;
@end
