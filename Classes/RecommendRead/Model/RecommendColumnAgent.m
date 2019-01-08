//
//  RecommendSectionList.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/15.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "RecommendColumnAgent.h"
#import "RecommendCoreDataTool.h"
@implementation RecommendColumnAgent

+ (NSDictionary *)replacedKeyFromPropertyName{
    NSDictionary *dict = @{
                           @"columnId":@"id",
                           @"columnTitle":@"title",
                           @"iconURL":@"iconFile",
                           @"newestArticleId":@"newestSectionArticleId"
                           };
    return dict;
}

-(void)setColumnId:(NSString *)columnId
{
    _columnId = columnId;
    
    self.localNewestArticleId = [RecommendCoreDataTool newestColumnActicleIdInColumn:columnId withUserName:[VEUtility currentUserName]];
}

@end
