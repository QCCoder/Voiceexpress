//
//  VEInternetTool.m
//  voiceexpress
//
//  Created by 钱城 on 15/12/24.
//  Copyright © 2015年 CYYUN. All rights reserved.
//

#import "VEInternetTool.h"
#import "HttpModelTool.h"
#import "Agent.h"

@implementation VEInternetTool

+(void)getInternetInfoWithParam:(VEInternetRequest *)params success:(InternetSuccessBlock)success failure:(InternetFailureBlock)failure{
    
    [HttpModelTool getWithUrl:@"internetInformationFilterList" requestModel:params responseClass:[InternetAgent class] success:^(id JSON) {
        DLog(@"%@",JSON);
    } failure:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

+(void)loadArticleContentWithParamters:(NSDictionary *)request success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [HttpTool postWithSessionClient:@"articledetail" param:request success:^(id JSON) {
        success([Articledetail objectWithKeyValues:JSON]);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
