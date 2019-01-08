//
//  SearchAlertTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/21.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VESearchResultsViewController.h"
#import "LocalAreaAgent.h"

#define kNormalSearchHistory        @"VESearchHistory"
#define kLatestAlertSearchHistory   @"VESearchHistory_LatestAlert"
#define kRecommendReadSearchHistory @"VESearchHistory_RecommendRead"

@interface SearchAlertTool : NSObject

/**
 *  保存最近搜索关键词
 */
+(void)saveKeyWord:(NSArray *)keyWordList key:(NSInteger)searchType;

/**
 *  获取搜索关键词
 */
+(NSArray *)getKeyWord:(NSInteger )searchType;

/**
 *  获取地域标签
 */
+(void)loadTagListResultInto:(ResultInfoBlock)resultInfo;

+(void)loadSearchWithUrl:(NSString *)url param:(NSDictionary *)param resultInto:(ResultInfoBlock)resultInfo;
@end
