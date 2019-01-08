//
//  SQLTool.h
//  voiceexpress
//
//  Created by 钱城 on 16/1/15.
//  Copyright © 2016年 CYYUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecommendColumn.h"
@interface RecommendCoreDataTool : NSObject



#pragma mark 推荐阅读
/**
 *  获取本地columnId，用于判断是否已读
 */
+ (NSInteger)newestColumnActicleIdInColumn:(NSString *)columnId withUserName:(NSString *)userName;

/**
 *  保存ArticleId
 */
+ (void)setNewestColumnActicleId:(NSInteger)newestArticleId InColumn:(NSString *)columnId withUserName:(NSString *)userName;

@end
