//
//  RecommendReadTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/14.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecommendCoreDataTool.h"
#import "RecommendColumnAgent.h"
#import "RecommendColumn.h"
#import "RecommendAgent.h"
#import "RecommendRead.h"

@interface RecommendReadTool : NSObject

/**
 *  收藏
 */
+ (void)doFavoriteWithUrl:(NSString *)url param:(NSDictionary *)param success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  一级列表
 */
+ (void)loadSectionListSuccess:(ResultInfoBlock)resultInfo;

/**
 *  二级列表
 */
+ (void)loadSectionWithParam:(NSDictionary *)param columnID:(NSString *)columnID resultInfo:(ResultInfoBlock)resultInfo;

/**
 *  读取coredata数据
 */
+ (BOOL)isRecommendReadInColumn:(NSString *)columnId withArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType;
/**
 *  保存数据到coredata
 */
+ (void)setRecommendReadInColumn:(NSString *)columnId withArticleId:(NSString *)articleId andWarnType:(NSInteger)warnType;


@end
