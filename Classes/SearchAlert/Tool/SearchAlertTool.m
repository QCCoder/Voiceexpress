//
//  SearchAlertTool.m
//  voiceexpress
//
//  Created by 钱城 on 16/1/21.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import "SearchAlertTool.h"

@implementation SearchAlertTool

/**
 *  保存最近搜索关键词
 */
+(void)saveKeyWord:(NSArray *)keyWordList key:(NSInteger)searchType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:keyWordList forKey:[self getKey:searchType]];
    [defaults synchronize];
}

+(NSArray *)getKeyWord:(NSInteger)searchType
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self getKey:searchType]];
}

+(void)loadTagListResultInto:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:@"tagList" param:nil success:^(id JSON) {
        NSArray *array = [LocalAreaAgent objectArrayWithKeyValuesArray:JSON[@"localtags"]];
        resultInfo(YES,array);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(void)loadSearchWithUrl:(NSString *)url param:(NSDictionary *)param resultInto:(ResultInfoBlock)resultInfo{
    [HttpTool postWithSessionClient:url param:param success:^(id JSON) {
        resultInfo(YES,JSON);
    } failure:^(NSError *error) {
        resultInfo(NO,error);
    }];
}

+(NSString *)getKey:(NSInteger)searchType{
    NSString *key = @"";
    switch (searchType){
        case SearchTypeNormal:
            key = kNormalSearchHistory;
            break;
            
        case SearchTypeLatestAlert:
            key = kLatestAlertSearchHistory;
            break;
            
        case SearchTypeRecommendRead:
            key = kRecommendReadSearchHistory;
            break;
            
        default:
            key = kNormalSearchHistory;
        break;
    }
    return key;
}

@end
