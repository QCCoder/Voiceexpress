//
//  InformationReviewTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/19.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "InformationReviewTool.h"

@implementation InformationReviewTool

+(void)loadNetworkReportWithParam:(NSDictionary *)param resultInfo:(ResultInfoBlock)resultInfo
{
    [HttpTool postWithSessionClient:@"NetworkReportingListForGA" param:param success:^(id JSON) {
        NSArray *array;
        array = [NetworkReportingAgent objectArrayWithKeyValuesArray:JSON[@"list"]];
        NSMutableArray *datalist = [NSMutableArray array];
        for (NetworkReportingAgent *agent in array) {
            agent.isRead = [VEUtility isWarnReadWithArticleId:agent.articleId andWarnType:agent.warnType];
            agent.title = [DES3Util decrypt:agent.title];
            agent.author = [DES3Util decrypt:agent.author];
            agent.nickName = [DES3Util decrypt:agent.nickName];
            agent.siteName = [DES3Util decrypt:agent.siteName];
            
            if (agent.status == 1){
                agent.statusString = @"";
            }else if (agent.status == 2){
                agent.statusString = @"已录用";
            }else if (agent.status == 3){
                agent.statusString = @"未录用";
            }
            
            [datalist addObject:agent];
        }
        array = datalist;
        resultInfo(YES,array);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}


+(void)updateNetworkReportingReviewWithParam:(NSDictionary *)param resultInfo:(ResultInfoBlock)resultInfo{
    [HttpTool postWithUrl:@"NetworkReportingReview" Parameters:param Success:^(id JSON) {
        resultInfo(YES,JSON);
    } Failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}
@end
